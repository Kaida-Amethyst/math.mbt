#include <errno.h>
#include <float.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpfr.h>

enum {
  INITIAL_ORACLE_PRECISION = 128,
  MAX_ORACLE_PRECISION = 16384,
  DEFAULT_SAMPLES_PER_STRATUM = 4096,
  GENERATED_CASES_PER_CHUNK = 2048,
  CORE_MAXIMUM_ULP = 2,
};

static const uint64_t RANDOM_SEED = UINT64_C(0x3c6ef372fe94f82b);
static const uint64_t F64_SIGN_MASK = UINT64_C(0x8000000000000000);
static const uint64_t F64_EXPONENT_MASK = UINT64_C(0x7ff0000000000000);
static const uint64_t F64_FRACTION_MASK = UINT64_C(0x000fffffffffffff);

typedef struct {
  uint64_t *items;
  size_t length;
  size_t capacity;
} InputSet;

typedef struct {
  uint64_t input_bits;
  uint64_t expected_bits;
} OracleCase;

typedef struct {
  size_t samples_per_stratum;
  unsigned maximum_ulp;
} GeneratorOptions;

static void die(const char *message) {
  fprintf(stderr, "tanh oracle: %s\n", message);
  exit(EXIT_FAILURE);
}

static uint64_t double_to_bits(double value) {
  uint64_t bits;
  memcpy(&bits, &value, sizeof(bits));
  return bits;
}

static double bits_to_double(uint64_t bits) {
  double value;
  memcpy(&value, &bits, sizeof(value));
  return value;
}

static int is_nan_bits(uint64_t bits) {
  return (bits & F64_EXPONENT_MASK) == F64_EXPONENT_MASK &&
         (bits & F64_FRACTION_MASK) != 0;
}

static void input_set_push(InputSet *set, uint64_t bits) {
  if (is_nan_bits(bits)) {
    return;
  }
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    uint64_t *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting inputs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] = bits;
}

static void add_bit_neighborhood(InputSet *set, uint64_t center,
                                 unsigned radius) {
  for (unsigned offset = 0; offset <= radius; ++offset) {
    if (center >= offset) {
      input_set_push(set, center - offset);
    }
    if (offset != 0 && center <= UINT64_MAX - offset) {
      input_set_push(set, center + offset);
    }
  }
}

static void add_double_neighborhood(InputSet *set, double center,
                                    unsigned radius) {
  add_bit_neighborhood(set, double_to_bits(center), radius);
}

static int compare_u64(const void *left, const void *right) {
  uint64_t a = *(const uint64_t *)left;
  uint64_t b = *(const uint64_t *)right;
  return (a > b) - (a < b);
}

static int compare_input_numeric(const void *left, const void *right) {
  uint64_t a_bits = *(const uint64_t *)left;
  uint64_t b_bits = *(const uint64_t *)right;
  double a = bits_to_double(a_bits);
  double b = bits_to_double(b_bits);
  if (a < b) {
    return -1;
  }
  if (a > b) {
    return 1;
  }
  return (a_bits > b_bits) - (a_bits < b_bits);
}

static void sort_and_deduplicate(InputSet *set) {
  qsort(set->items, set->length, sizeof(*set->items), compare_u64);
  size_t output = 0;
  for (size_t input = 0; input < set->length; ++input) {
    if (output == 0 || set->items[input] != set->items[output - 1]) {
      set->items[output++] = set->items[input];
    }
  }
  set->length = output;
  qsort(set->items, set->length, sizeof(*set->items), compare_input_numeric);
}

static uint64_t xorshift64star(uint64_t *state) {
  uint64_t x = *state;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *state = x;
  return x * UINT64_C(0x2545f4914f6cdd1d);
}

static void add_mpfr_neighborhood(InputSet *set, const mpfr_t center,
                                  unsigned radius) {
  add_double_neighborhood(set, mpfr_get_d(center, MPFR_RNDN), radius);
}

static void add_fixed_inputs(InputSet *set) {
  static const uint64_t fixed_bits[] = {
      UINT64_C(0x0000000000000000), /* +0 */
      UINT64_C(0x8000000000000000), /* -0 */
      UINT64_C(0x0000000000000001), /* minimum positive subnormal */
      UINT64_C(0x8000000000000001),
      UINT64_C(0x000fffffffffffff), /* maximum positive subnormal */
      UINT64_C(0x800fffffffffffff),
      UINT64_C(0x0010000000000000), /* minimum positive normal */
      UINT64_C(0x8010000000000000),
      UINT64_C(0x3ff0000000000000), /* +1 */
      UINT64_C(0xbff0000000000000), /* -1 */
      UINT64_C(0xbfe033d8e590f821), /* observed two-ULP witness */
      UINT64_C(0x7fefffffffffffff), /* maximum finite */
      UINT64_C(0xffefffffffffffff),
      UINT64_C(0x7ff0000000000000), /* +infinity */
      UINT64_C(0xfff0000000000000), /* -infinity */
  };
  for (size_t i = 0; i < sizeof(fixed_bits) / sizeof(fixed_bits[0]); ++i) {
    add_bit_neighborhood(set, fixed_bits[i], 2);
  }

  for (int value = -30; value <= 30; ++value) {
    input_set_push(set, double_to_bits((double)value));
  }

  /* Branch thresholds in the FreeBSD-msun-derived implementation. */
  static const uint64_t thresholds[] = {
      UINT64_C(0x3e30000000000000), UINT64_C(0x3ff0000000000000),
      UINT64_C(0x4036000000000000),
  };
  for (size_t i = 0; i < sizeof(thresholds) / sizeof(thresholds[0]); ++i) {
    add_bit_neighborhood(set, thresholds[i], 16);
    add_bit_neighborhood(set, thresholds[i] | F64_SIGN_MASK, 16);
  }
}

static void add_analytic_boundaries(InputSet *set) {
  mpfr_t value;
  mpfr_t scratch;
  mpfr_inits2(512, value, scratch, (mpfr_ptr)0);

  /* Round-to-nearest transition where tanh(x) saturates at one. */
  mpfr_set_ui(value, 1, MPFR_RNDN);
  mpfr_set_ui_2exp(scratch, 1, -54, MPFR_RNDN);
  mpfr_sub(value, value, scratch, MPFR_RNDN);
  mpfr_atanh(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 32);
  mpfr_neg(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 32);

  mpfr_clears(value, scratch, (mpfr_ptr)0);
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;
  mpfr_t fraction;
  mpfr_t value;
  mpfr_inits2(192, fraction, value, (mpfr_ptr)0);

  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);

    /* Numerically uniform inputs over the transition interval. */
    mpfr_set_ui(fraction, (unsigned long)random, MPFR_RNDN);
    mpfr_div_2ui(fraction, fraction, 64, MPFR_RNDN);
    mpfr_mul_ui(value, fraction, 60, MPFR_RNDN);
    mpfr_sub_ui(value, value, 30, MPFR_RNDN);
    input_set_push(set, double_to_bits(mpfr_get_d(value, MPFR_RNDN)));

    /* Exponent-stratified raw binary64 inputs, including tiny magnitudes. */
    uint64_t random2 = (uint64_t)xorshift64star(&state);
    uint64_t exponent = random % UINT64_C(0x7ff);
    uint64_t sign = random2 & F64_SIGN_MASK;
    uint64_t fraction_bits = random2 & F64_FRACTION_MASK;
    input_set_push(set, sign | (exponent << 52) | fraction_bits);

    /* Random interiors of each finite piecewise-formula region. */
    mpfr_set_ui(fraction, (unsigned long)xorshift64star(&state), MPFR_RNDN);
    mpfr_div_2ui(fraction, fraction, 64, MPFR_RNDN);
    switch (random % 5) {
    case 0:
      mpfr_mul_2si(value, fraction, -28, MPFR_RNDN);
      break;
    case 1:
      mpfr_mul_d(value, fraction, 0.9999999962747097, MPFR_RNDN);
      mpfr_add_d(value, value, 0.0000000037252903, MPFR_RNDN);
      break;
    case 2:
      mpfr_mul_ui(value, fraction, 17, MPFR_RNDN);
      mpfr_add_ui(value, value, 1, MPFR_RNDN);
      break;
    case 3:
      mpfr_mul_ui(value, fraction, 4, MPFR_RNDN);
      mpfr_add_ui(value, value, 18, MPFR_RNDN);
      break;
    default:
      mpfr_mul_ui(value, fraction, 8, MPFR_RNDN);
      mpfr_add_ui(value, value, 22, MPFR_RNDN);
      break;
    }
    if (random2 & F64_SIGN_MASK) {
      mpfr_neg(value, value, MPFR_RNDN);
    }
    input_set_push(set, double_to_bits(mpfr_get_d(value, MPFR_RNDN)));
  }

  mpfr_clears(fraction, value, (mpfr_ptr)0);
}

static uint64_t oracle_tanh(uint64_t input_bits,
                             mpfr_prec_t *used_precision) {
  double input = bits_to_double(input_bits);
  if (input_bits == F64_EXPONENT_MASK ||
      input_bits == (F64_SIGN_MASK | F64_EXPONENT_MASK)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return input_bits == F64_EXPONENT_MASK ? UINT64_C(0x3ff0000000000000)
                                           : UINT64_C(0xbff0000000000000);
  }

  mpfr_t x;
  mpfr_t lower;
  mpfr_t upper;
  mpfr_init2(x, 64);
  mpfr_init2(lower, INITIAL_ORACLE_PRECISION);
  mpfr_init2(upper, INITIAL_ORACLE_PRECISION);
  mpfr_set_d(x, input, MPFR_RNDN);

  for (mpfr_prec_t precision = INITIAL_ORACLE_PRECISION;
       precision <= MAX_ORACLE_PRECISION; precision *= 2) {
    mpfr_set_prec(lower, precision);
    mpfr_set_prec(upper, precision);
    mpfr_tanh(lower, x, MPFR_RNDD);
    mpfr_tanh(upper, x, MPFR_RNDU);
    uint64_t lower_bits = double_to_bits(mpfr_get_d(lower, MPFR_RNDN));
    uint64_t upper_bits = double_to_bits(mpfr_get_d(upper, MPFR_RNDN));
    if (lower_bits == upper_bits) {
      *used_precision = precision;
      mpfr_clears(x, lower, upper, (mpfr_ptr)0);
      return lower_bits;
    }
  }

  mpfr_clears(x, lower, upper, (mpfr_ptr)0);
  die("could not determine a correctly rounded result within the precision limit");
  return 0;
}

static GeneratorOptions parse_options(int argc, char **argv) {
  GeneratorOptions options = {
      .samples_per_stratum = DEFAULT_SAMPLES_PER_STRATUM,
      .maximum_ulp = 2,
  };
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "--samples-per-stratum") == 0 && i + 1 < argc) {
      errno = 0;
      char *end = NULL;
      unsigned long parsed = strtoul(argv[++i], &end, 10);
      if (errno != 0 || end == argv[i] || *end != '\0' || parsed == 0) {
        die("sample count must be a positive integer");
      }
      options.samples_per_stratum = (size_t)parsed;
    } else if (strcmp(argv[i], "--max-ulp") == 0 && i + 1 < argc) {
      errno = 0;
      char *end = NULL;
      unsigned long parsed = strtoul(argv[++i], &end, 10);
      if (errno != 0 || end == argv[i] || *end != '\0' ||
          parsed > UINT32_MAX) {
        die("maximum ULP must be a nonnegative 32-bit integer");
      }
      options.maximum_ulp = (unsigned)parsed;
    } else {
      die("usage: generate [--samples-per-stratum COUNT] [--max-ulp COUNT]");
    }
  }
  return options;
}

static void emit_tests(const OracleCase *cases, size_t count,
                       const GeneratorOptions *options,
                       mpfr_prec_t maximum_precision) {
  printf("// Code generated by tools/oracle/tanh/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, tanh, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique cases: %zu.\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);
  printf("// Inputs cover special values, implementation and analytic boundaries, and three deterministic random strata.\n\n");

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn tanh_mpfr_cases_%zu() -> Array[(UInt64, UInt64)] {\n",
           chunk);
    printf("  [\n");
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%016" PRIx64 "UL, 0x%016" PRIx64 "UL),\n",
             cases[i].input_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn tanh_mpfr_case_groups() -> Array[Array[(UInt64, UInt64)]] {\n");
  printf("  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    tanh_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn tanh_oracle_ulp_error(expect : Double, actual : Double) -> UInt64 {\n");
  printf("  if expect == actual {\n");
  printf("    return 0UL\n");
  printf("  }\n");
  printf("  if expect.is_nan() || actual.is_nan() || expect.is_inf() || actual.is_inf() {\n");
  printf("    return 0xffffffffffffffffUL\n");
  printf("  }\n");
  printf("  let expect_bits = expect.reinterpret_as_uint64()\n");
  printf("  let actual_bits = actual.reinterpret_as_uint64()\n");
  printf("  if expect_bits >= actual_bits {\n");
  printf("    expect_bits - actual_bits\n");
  printf("  } else {\n");
  printf("    actual_bits - expect_bits\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"tanh agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0UL\n");
  printf("  for cases in tanh_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.tanh(input)\n");
  printf("      let error = tanh_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uUL {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"tanh oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uUL)\n", options->maximum_ulp);
  printf("}\n\n");

  printf("///|\ntest \"MoonBit Core tanh stays within %d ULP over the corpus\" {\n",
         CORE_MAXIMUM_ULP);
  printf("  for cases in tanh_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @core_math.tanh(input)\n");
  printf("      let error = tanh_oracle_ulp_error(expected, actual)\n");
  printf("      if error > %dUL {\n", CORE_MAXIMUM_ULP);
  printf("        println(\n");
  printf("          \"Core tanh oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"tanh odd symmetry and monotonicity over the oracle corpus\" {\n");
  printf("  let mut previous : Double = 0.0\n");
  printf("  let mut have_previous = false\n");
  printf("  for cases in tanh_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, _) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.tanh(input)\n");
  printf("      assert_true(!actual.is_nan())\n");
  printf("      assert_true(actual >= -1.0)\n");
  printf("      assert_true(actual <= 1.0)\n");
  printf("      let opposite = @math.tanh(-input)\n");
  printf("      assert_eq(\n");
  printf("        actual.reinterpret_as_uint64() ^ 0x8000000000000000UL,\n");
  printf("        opposite.reinterpret_as_uint64(),\n");
  printf("      )\n");
  printf("      if have_previous {\n");
  printf("        assert_true(previous <= actual)\n");
  printf("      }\n");
  printf("      previous = actual\n");
  printf("      have_previous = true\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n");
}

int main(int argc, char **argv) {
  if (FLT_RADIX != 2 || DBL_MANT_DIG != 53 || DBL_MAX_EXP != 1024 ||
      sizeof(double) != sizeof(uint64_t)) {
    die("generator requires IEEE 754 binary64 double");
  }

  GeneratorOptions options = parse_options(argc, argv);
  InputSet inputs = {0};
  add_fixed_inputs(&inputs);
  add_analytic_boundaries(&inputs);
  add_random_inputs(&inputs, options.samples_per_stratum);
  sort_and_deduplicate(&inputs);

  OracleCase *cases = malloc(inputs.length * sizeof(*cases));
  if (cases == NULL) {
    die("out of memory while producing oracle cases");
  }
  mpfr_prec_t maximum_precision = 0;
  for (size_t i = 0; i < inputs.length; ++i) {
    mpfr_prec_t used_precision = 0;
    cases[i] = (OracleCase){
        .input_bits = inputs.items[i],
        .expected_bits = oracle_tanh(inputs.items[i], &used_precision),
    };
    if (used_precision > maximum_precision) {
      maximum_precision = used_precision;
    }
  }

  emit_tests(cases, inputs.length, &options, maximum_precision);
  free(cases);
  free(inputs.items);
  return EXIT_SUCCESS;
}
