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
  fprintf(stderr, "log1p oracle: %s\n", message);
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
      UINT64_C(0xbfefffffffffff45), /* observed one-ULP witness */
      UINT64_C(0x7fefffffffffffff), /* maximum finite */
      UINT64_C(0xffefffffffffffff),
      UINT64_C(0x7ff0000000000000), /* +infinity */
      UINT64_C(0xfff0000000000000), /* -infinity */
  };
  for (size_t i = 0; i < sizeof(fixed_bits) / sizeof(fixed_bits[0]); ++i) {
    add_bit_neighborhood(set, fixed_bits[i], 2);
  }

  for (int value = -1024; value <= 1024; ++value) {
    input_set_push(set, double_to_bits((double)value));
  }

  /* Domain and branch thresholds in the FreeBSD-msun implementation. */
  static const uint64_t thresholds[] = {
      UINT64_C(0x0000000000000000), UINT64_C(0x3c90000000000000),
      UINT64_C(0x8000000000000000), UINT64_C(0xbc90000000000000),
      UINT64_C(0x3e20000000000000), UINT64_C(0xbe20000000000000),
      UINT64_C(0xbfd2bec400000000), UINT64_C(0x3fda827a00000000),
      UINT64_C(0xbff0000000000000), UINT64_C(0x4340000000000000),
  };
  for (size_t i = 0; i < sizeof(thresholds) / sizeof(thresholds[0]); ++i) {
    add_bit_neighborhood(set, thresholds[i], 16);
  }
}

static void add_analytic_boundaries(InputSet *set) {
  /* Positive binades and negative binades contained in the real domain. */
  for (uint64_t exponent = 0; exponent < UINT64_C(0x7ff); ++exponent) {
    uint64_t lower = exponent << 52;
    uint64_t upper = lower | F64_FRACTION_MASK;
    add_bit_neighborhood(set, lower, 4);
    add_bit_neighborhood(set, upper, 4);
    if (exponent < UINT64_C(0x3ff)) {
      add_bit_neighborhood(set, lower | F64_SIGN_MASK, 4);
      add_bit_neighborhood(set, upper | F64_SIGN_MASK, 4);
    }
  }

  /* Inputs for which 1+x crosses a logarithmic reduction boundary. */
  mpfr_t boundary;
  mpfr_init2(boundary, 512);
  for (long exponent = -52; exponent <= 1023; ++exponent) {
    mpfr_set_d(boundary, bits_to_double(UINT64_C(0x3ff6a09e00000000)),
               MPFR_RNDN);
    mpfr_mul_2si(boundary, boundary, exponent, MPFR_RNDN);
    mpfr_sub_ui(boundary, boundary, 1, MPFR_RNDN);
    add_mpfr_neighborhood(set, boundary, 8);
  }
  mpfr_clear(boundary);
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;

  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);
    uint64_t random2 = xorshift64star(&state);
    uint64_t random3 = xorshift64star(&state);

    /* Raw finite binary64 inputs cover both valid and invalid domains. */
    uint64_t raw = random;
    if ((raw & F64_EXPONENT_MASK) == F64_EXPONENT_MASK) {
      raw -= UINT64_C(0x0010000000000000);
    }
    input_set_push(set, raw);

    /* Positive exponent-stratified inputs exercise the whole valid domain. */
    uint64_t positive_exponent = random2 % UINT64_C(0x7ff);
    input_set_push(set,
                   (positive_exponent << 52) | (random & F64_FRACTION_MASK));

    /* Negative exponent-stratified inputs remain inside [-1, 0]. */
    uint64_t negative_exponent = random3 % UINT64_C(0x3ff);
    input_set_push(set, F64_SIGN_MASK | (negative_exponent << 52) |
                            (random2 & F64_FRACTION_MASK));

    /* Dense signed samples around zero target cancellation-safe branches. */
    uint64_t small_exponent = random % UINT64_C(0x3ec);
    uint64_t small = (small_exponent << 52) | (random3 & F64_FRACTION_MASK);
    input_set_push(set, (random2 & F64_SIGN_MASK) | small);

    /* Samples on both sides of x=-1 exercise the domain boundary. */
    uint64_t distance = random3 & F64_FRACTION_MASK;
    input_set_push(set, UINT64_C(0xbff0000000000000) + distance);
    input_set_push(set, UINT64_C(0xbff0000000000000) - distance);
  }
}

static uint64_t oracle_log1p(uint64_t input_bits,
                             mpfr_prec_t *used_precision) {
  double input = bits_to_double(input_bits);
  uint64_t magnitude = input_bits & ~F64_SIGN_MASK;
  if (magnitude == 0) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return input_bits;
  }
  if ((input_bits & F64_SIGN_MASK) != 0 &&
      magnitude > UINT64_C(0x3ff0000000000000)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT64_C(0x7ff8000000000000);
  }
  if (input_bits == UINT64_C(0xbff0000000000000)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT64_C(0xfff0000000000000);
  }
  if (input_bits == F64_EXPONENT_MASK) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return input_bits;
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
    mpfr_log1p(lower, x, MPFR_RNDD);
    mpfr_log1p(upper, x, MPFR_RNDU);
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
      .maximum_ulp = 1,
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
  printf("// Code generated by tools/oracle/log1p/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, log1p, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique cases: %zu.\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);
  printf("// Inputs cover special values, domain and branch boundaries, logarithmic reduction boundaries, and five deterministic random strata.\n\n");

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn log1p_mpfr_cases_%zu() -> Array[(UInt64, UInt64)] {\n",
           chunk);
    printf("  [\n");
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%016" PRIx64 "UL, 0x%016" PRIx64 "UL),\n",
             cases[i].input_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn log1p_mpfr_case_groups() -> Array[Array[(UInt64, UInt64)]] {\n");
  printf("  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    log1p_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn log1p_oracle_ulp_error(expect : Double, actual : Double) -> UInt64 {\n");
  printf("  if expect == actual {\n");
  printf("    return 0UL\n");
  printf("  }\n");
  printf("  if expect.is_nan() && actual.is_nan() {\n");
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

  printf("///|\ntest \"log1p agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0UL\n");
  printf("  for cases in log1p_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.log1p(input)\n");
  printf("      assert_eq(\n");
  printf("        @math.ln_1p(input).reinterpret_as_uint64(),\n");
  printf("        actual.reinterpret_as_uint64(),\n");
  printf("      )\n");
  printf("      let error = log1p_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uUL {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"log1p oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uUL)\n", options->maximum_ulp);
  printf("}\n\n");

  printf("///|\ntest \"MoonBit Core ln_1p stays within %d ULP over the corpus\" {\n",
         CORE_MAXIMUM_ULP);
  printf("  for cases in log1p_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @core_math.ln_1p(input)\n");
  printf("      let error = log1p_oracle_ulp_error(expected, actual)\n");
  printf("      if error > %dUL {\n", CORE_MAXIMUM_ULP);
  printf("        println(\n");
  printf("          \"Core ln_1p oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"log1p is monotonic over its real domain\" {\n");
  printf("  let mut previous : Double = 0.0\n");
  printf("  let mut have_previous = false\n");
  printf("  for cases in log1p_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, _) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      if input >= -1.0 {\n");
  printf("        let actual = @math.log1p(input)\n");
  printf("        assert_true(!actual.is_nan())\n");
  printf("        if have_previous {\n");
  printf("          assert_true(previous <= actual)\n");
  printf("        }\n");
  printf("        previous = actual\n");
  printf("        have_previous = true\n");
  printf("      }\n");
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
        .expected_bits = oracle_log1p(inputs.items[i], &used_precision),
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
