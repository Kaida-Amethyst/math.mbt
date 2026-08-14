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
  GENERATED_CASES_PER_CHUNK = 1024,
};

static const uint64_t RANDOM_SEED = UINT64_C(0xa54ff53a5f1d36f1);
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
  fprintf(stderr, "asin oracle: %s\n", message);
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

static void add_signed_neighborhood(InputSet *set, uint64_t magnitude,
                                    unsigned radius) {
  add_bit_neighborhood(set, magnitude, radius);
  add_bit_neighborhood(set, magnitude | F64_SIGN_MASK, radius);
}

static int compare_u64(const void *left, const void *right) {
  uint64_t a = *(const uint64_t *)left;
  uint64_t b = *(const uint64_t *)right;
  return (a > b) - (a < b);
}

static int compare_numeric(const void *left, const void *right) {
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
  qsort(set->items, set->length, sizeof(*set->items), compare_numeric);
}

static uint64_t xorshift64star(uint64_t *state) {
  uint64_t x = *state;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *state = x;
  return x * UINT64_C(0x2545f4914f6cdd1d);
}

static uint64_t make_finite(uint64_t bits) {
  if ((bits & F64_EXPONENT_MASK) == F64_EXPONENT_MASK) {
    bits -= UINT64_C(0x0010000000000000);
  }
  return bits;
}

static void add_fixed_inputs(InputSet *set) {
  static const uint64_t fixed[] = {
      UINT64_C(0x0000000000000000), UINT64_C(0x8000000000000000),
      UINT64_C(0x0000000000000001), UINT64_C(0x8000000000000001),
      UINT64_C(0x000fffffffffffff), UINT64_C(0x800fffffffffffff),
      UINT64_C(0x0010000000000000), UINT64_C(0x8010000000000000),
      UINT64_C(0x3ff0000000000000), UINT64_C(0xbff0000000000000),
      UINT64_C(0x7fefffffffffffff), UINT64_C(0xffefffffffffffff),
      UINT64_C(0x3fe0000000000000), UINT64_C(0xbfe0000000000000),
      UINT64_C(0x3fef333300000000), UINT64_C(0xbfef333300000000),
      UINT64_C(0x7ff0000000000000), UINT64_C(0xfff0000000000000),
      UINT64_C(0xbfef3333000fcd4d), /* observed 1-ULP witness */
  };
  for (size_t i = 0; i < sizeof(fixed) / sizeof(fixed[0]); ++i) {
    add_bit_neighborhood(set, fixed[i], 2);
  }
  for (int value = -1024; value <= 1024; ++value) {
    input_set_push(set, double_to_bits((double)value));
  }
}

static void add_analytic_boundaries(InputSet *set) {
  for (uint64_t exponent = 0; exponent < UINT64_C(0x7ff); ++exponent) {
    uint64_t lower = exponent << 52;
    uint64_t upper = lower | F64_FRACTION_MASK;
    add_signed_neighborhood(set, lower, 1);
    add_signed_neighborhood(set, upper, 1);
  }

  static const uint64_t transitions[] = {
      UINT64_C(0x3e50000000000000), /* 2^-26 */
      UINT64_C(0x3fe0000000000000), /* 0.5 */
      UINT64_C(0x3fef333300000000), /* high-word split near 0.975 */
      UINT64_C(0x3ff0000000000000), /* domain endpoint 1.0 */
  };
  for (size_t i = 0; i < sizeof(transitions) / sizeof(transitions[0]); ++i) {
    add_signed_neighborhood(set, transitions[i], 64);
  }
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;
  static const uint64_t transitions[] = {
      UINT64_C(0x3e50000000000000), UINT64_C(0x3fe0000000000000),
      UINT64_C(0x3fef333300000000), UINT64_C(0x3ff0000000000000),
  };
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random0 = xorshift64star(&state);
    uint64_t random1 = xorshift64star(&state);
    uint64_t random2 = xorshift64star(&state);

    input_set_push(set, make_finite(random0));

    uint64_t valid_magnitude = random2 % UINT64_C(0x3ff0000000000001);
    input_set_push(set, (random1 & F64_SIGN_MASK) | valid_magnitude);

    uint64_t center = transitions[random1 % UINT64_C(4)];
    uint64_t distance = random2 & UINT64_C(0x00000000000fffff);
    uint64_t magnitude = (random2 & UINT64_C(0x0010000000000000)) == 0
                             ? center + distance
                             : center - distance;
    input_set_push(set, (random0 & F64_SIGN_MASK) | magnitude);

    input_set_push(set, (random1 & F64_SIGN_MASK) |
                            (random0 % UINT64_C(0x3e50000000000000)));
  }
}

static uint64_t oracle_asin(uint64_t input_bits,
                            mpfr_prec_t *used_precision) {
  mpfr_t x;
  mpfr_t lower;
  mpfr_t upper;
  mpfr_init2(x, 64);
  mpfr_init2(lower, INITIAL_ORACLE_PRECISION);
  mpfr_init2(upper, INITIAL_ORACLE_PRECISION);
  mpfr_set_d(x, bits_to_double(input_bits), MPFR_RNDN);

  for (mpfr_prec_t precision = INITIAL_ORACLE_PRECISION;
       precision <= MAX_ORACLE_PRECISION; precision *= 2) {
    mpfr_set_prec(lower, precision);
    mpfr_set_prec(upper, precision);
    mpfr_asin(lower, x, MPFR_RNDD);
    mpfr_asin(upper, x, MPFR_RNDU);
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
  GeneratorOptions options = {DEFAULT_SAMPLES_PER_STRATUM, 1};
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
      if (errno != 0 || end == argv[i] || *end != '\0' || parsed > UINT32_MAX) {
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
  printf("// Code generated by tools/oracle/asin/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, asin, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique cases: %zu.\n\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn asin_mpfr_cases_%zu() -> Array[(UInt64, UInt64)] {\n  [\n",
           chunk);
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%016" PRIx64 "UL, 0x%016" PRIx64 "UL),\n",
             cases[i].input_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn asin_mpfr_case_groups() -> Array[Array[(UInt64, UInt64)]] {\n  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    asin_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn asin_oracle_ulp_error(expect : Double, actual : Double) -> UInt64 {\n");
  printf("  if expect == actual {\n    return 0UL\n  }\n");
  printf("  if expect.is_nan() && actual.is_nan() {\n    return 0UL\n  }\n");
  printf("  if expect.is_nan() || actual.is_nan() || expect.is_inf() || actual.is_inf() {\n");
  printf("    return 0xffffffffffffffffUL\n  }\n");
  printf("  let expect_bits = expect.reinterpret_as_uint64()\n");
  printf("  let actual_bits = actual.reinterpret_as_uint64()\n");
  printf("  if expect_bits >= actual_bits {\n    expect_bits - actual_bits\n  } else {\n");
  printf("    actual_bits - expect_bits\n  }\n}\n\n");

  printf("///|\ntest \"asin agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0UL\n");
  printf("  for cases in asin_mpfr_case_groups() {\n    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.asin(input)\n");
  printf("      let error = asin_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n        maximum_error = error\n      }\n");
  printf("      if error > %uUL {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"asin oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n      }\n    }\n  }\n");
  printf("  assert_true(maximum_error <= %uUL)\n}\n\n", options->maximum_ulp);

  printf("///|\ntest \"MoonBit Core asin meets the oracle bound over the corpus\" {\n");
  printf("  for cases in asin_mpfr_case_groups() {\n    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @core_math.asin(input_bits.reinterpret_as_double())\n");
  printf("      assert_true(asin_oracle_ulp_error(expected, actual) <= %uUL)\n",
         options->maximum_ulp);
  printf("    }\n  }\n}\n\n");

  printf("///|\ntest \"asin is monotonic and odd over its real domain\" {\n");
  printf("  let mut previous = 0.0\n  let mut have_previous = false\n");
  printf("  for cases in asin_mpfr_case_groups() {\n    for pair in cases {\n");
  printf("      let (input_bits, _) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      if input >= -1.0 && input <= 1.0 {\n");
  printf("        let actual = @math.asin(input)\n");
  printf("        assert_eq(\n");
  printf("          @math.asin(-input).reinterpret_as_uint64(),\n");
  printf("          (-actual).reinterpret_as_uint64(),\n        )\n");
  printf("        if have_previous {\n          assert_true(previous <= actual)\n        }\n");
  printf("        previous = actual\n        have_previous = true\n      }\n    }\n  }\n}\n");
}

int main(int argc, char **argv) {
  if (sizeof(double) != sizeof(uint64_t) || DBL_MANT_DIG != 53 ||
      DBL_MAX_EXP != 1024) {
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
    cases[i] = (OracleCase){inputs.items[i],
                            oracle_asin(inputs.items[i], &used_precision)};
    if (used_precision > maximum_precision) {
      maximum_precision = used_precision;
    }
  }
  emit_tests(cases, inputs.length, &options, maximum_precision);
  free(cases);
  free(inputs.items);
  return EXIT_SUCCESS;
}
