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
  DEFAULT_RANDOM_SAMPLES_PER_STRATUM = 4096,
  GENERATED_CASES_PER_CHUNK = 2048,
};

static const uint64_t RANDOM_SEED = UINT64_C(0x243f6a8885a308d3);
static const uint64_t F64_SIGN_MASK = UINT64_C(0x8000000000000000);
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
  const char *input_file;
} GeneratorOptions;

static void die(const char *message) {
  fprintf(stderr, "exp oracle: %s\n", message);
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

static void input_set_push(InputSet *set, uint64_t bits) {
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

static void add_high_word_transition(InputSet *set, uint32_t high_word) {
  uint64_t positive = (uint64_t)high_word << 32;
  add_bit_neighborhood(set, positive, 4);
  add_bit_neighborhood(set, positive | F64_SIGN_MASK, 4);
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

static int is_nan_bits(uint64_t bits) {
  return (bits & UINT64_C(0x7ff0000000000000)) ==
             UINT64_C(0x7ff0000000000000) &&
         (bits & F64_FRACTION_MASK) != 0;
}

static void sort_and_deduplicate(InputSet *set) {
  qsort(set->items, set->length, sizeof(*set->items), compare_u64);
  size_t output = 0;
  for (size_t input = 0; input < set->length; ++input) {
    if (!is_nan_bits(set->items[input]) &&
        (output == 0 || set->items[input] != set->items[output - 1])) {
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

static void mpfr_set_u64_exact(mpfr_t result, uint64_t value) {
  mpfr_set_ui(result, (unsigned long)(value >> 32), MPFR_RNDN);
  mpfr_mul_2ui(result, result, 32, MPFR_RNDN);
  mpfr_add_ui(result, result, (unsigned long)(value & UINT32_MAX), MPFR_RNDN);
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
      UINT64_C(0x7fefffffffffffff), /* maximum finite */
      UINT64_C(0xffefffffffffffff),
      UINT64_C(0x7ff0000000000000), /* +infinity */
      UINT64_C(0xfff0000000000000), /* -infinity */
      /* Known one-ULP witness found in the CORE-MATH hard-case corpus. */
      UINT64_C(0xc086f6872b5f94e6),
  };
  for (size_t i = 0; i < sizeof(fixed_bits) / sizeof(fixed_bits[0]); ++i) {
    add_bit_neighborhood(set, fixed_bits[i], 2);
  }

  /* Every integer in the finite transition region. */
  for (int value = -750; value <= 710; ++value) {
    input_set_push(set, double_to_bits((double)value));
  }

  /* Branches in the fdlibm-derived implementation are selected by high words.
   */
  add_high_word_transition(set, UINT32_C(0x3e300000)); /* 2^-28 */
  add_high_word_transition(set, UINT32_C(0x3fd62e42)); /* about 0.5*ln(2) */
  add_high_word_transition(set, UINT32_C(0x3ff0a2b2)); /* about 1.5*ln(2) */
  add_high_word_transition(set, UINT32_C(0x40862e42)); /* overflow region */

  add_bit_neighborhood(set, UINT64_C(0x3ff0000000000000),
                       16); /* x == 1 shortcut */
  add_bit_neighborhood(set, UINT64_C(0x40862e42fefa39ef),
                       32); /* fdlibm overflow threshold */
  add_bit_neighborhood(set, UINT64_C(0xc0874910d52d3051),
                       32); /* fdlibm underflow threshold */
}

static void add_analytic_boundaries(InputSet *set) {
  mpfr_t ln2;
  mpfr_t value;
  mpfr_t scratch;
  mpfr_inits2(512, ln2, value, scratch, (mpfr_ptr)0);
  mpfr_const_log2(ln2, MPFR_RNDN);

  /* All argument-reduction cell boundaries x = (k + 1/2) ln(2). */
  for (long k = -1076; k <= 1024; ++k) {
    mpfr_set_si(value, 2 * k + 1, MPFR_RNDN);
    mpfr_mul(value, value, ln2, MPFR_RNDN);
    mpfr_div_2ui(value, value, 1, MPFR_RNDN);
    add_mpfr_neighborhood(set, value, 2);
  }

  /* Scaling boundaries used by the reconstruction of 2^k. */
  static const long scaling_exponents[] = {
      -1076, -1075, -1074, -1023, -1022, -1021, -1000, 0, 1023, 1024,
  };
  for (size_t i = 0;
       i < sizeof(scaling_exponents) / sizeof(scaling_exponents[0]); ++i) {
    mpfr_mul_si(value, ln2, scaling_exponents[i], MPFR_RNDN);
    add_mpfr_neighborhood(set, value, 8);
  }

  /* Rounding transition: exp(x) changes from +0 to the minimum subnormal. */
  mpfr_set_ui_2exp(value, 1, -1075, MPFR_RNDN);
  mpfr_log(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 16);

  /* Rounding transition: minimum subnormal to twice the minimum subnormal. */
  mpfr_set_ui_2exp(value, 3, -1075, MPFR_RNDN);
  mpfr_log(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 16);

  /* Rounding transition between the maximum subnormal and minimum normal. */
  mpfr_set_ui_2exp(value, 1, -1022, MPFR_RNDN);
  mpfr_set_ui_2exp(scratch, 1, -1075, MPFR_RNDN);
  mpfr_sub(value, value, scratch, MPFR_RNDN);
  mpfr_log(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 16);

  /* Round-to-nearest overflow transition above the maximum finite Double. */
  mpfr_set_d(value, DBL_MAX, MPFR_RNDN);
  mpfr_set_ui_2exp(scratch, 1, 970, MPFR_RNDN);
  mpfr_add(value, value, scratch, MPFR_RNDN);
  mpfr_log(value, value, MPFR_RNDN);
  add_mpfr_neighborhood(set, value, 16);

  mpfr_clears(ln2, value, scratch, (mpfr_ptr)0);
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;
  mpfr_t fraction;
  mpfr_t value;
  mpfr_t ln2;
  mpfr_inits2(192, fraction, value, ln2, (mpfr_ptr)0);
  mpfr_const_log2(ln2, MPFR_RNDN);

  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);

    /* Numerically uniform samples over the finite exp transition interval. */
    mpfr_set_u64_exact(fraction, random);
    mpfr_div_2ui(fraction, fraction, 64, MPFR_RNDN);
    mpfr_mul_ui(value, fraction, 1462, MPFR_RNDN);
    mpfr_sub_ui(value, value, 750, MPFR_RNDN);
    input_set_push(set, double_to_bits(mpfr_get_d(value, MPFR_RNDN)));

    /* Exponent-stratified raw binary64 inputs, including tiny magnitudes. */
    uint64_t random2 = xorshift64star(&state);
    uint64_t exponent = random % UINT64_C(0x409);
    uint64_t sign = random2 & F64_SIGN_MASK;
    uint64_t fraction_bits = random2 & F64_FRACTION_MASK;
    input_set_push(set, sign | (exponent << 52) | fraction_bits);

    /* Random interiors of argument-reduction cells. */
    uint64_t random3 = xorshift64star(&state);
    long k = (long)(random3 % 2100) - 1075;
    mpfr_set_u64_exact(fraction, xorshift64star(&state));
    mpfr_div_2ui(fraction, fraction, 64, MPFR_RNDN);
    mpfr_sub_d(fraction, fraction, 0.5, MPFR_RNDN);
    mpfr_add_si(value, fraction, k, MPFR_RNDN);
    mpfr_mul(value, value, ln2, MPFR_RNDN);
    input_set_push(set, double_to_bits(mpfr_get_d(value, MPFR_RNDN)));
  }

  mpfr_clears(fraction, value, ln2, (mpfr_ptr)0);
}

static size_t add_input_file(InputSet *set, const char *path) {
  if (path == NULL) {
    return 0;
  }
  FILE *input = fopen(path, "r");
  if (input == NULL) {
    die("could not open the additional input file");
  }
  char line[256];
  size_t count = 0;
  while (fgets(line, sizeof(line), input) != NULL) {
    char *start = line;
    while (*start == ' ' || *start == '\t') {
      ++start;
    }
    if (*start == '\0' || *start == '\n' || *start == '#') {
      continue;
    }
    /* NaN payload and signaling behavior belongs to the contract test. */
    if (strstr(start, "nan") != NULL || strstr(start, "NaN") != NULL ||
        strstr(start, "NAN") != NULL) {
      continue;
    }
    errno = 0;
    char *end = NULL;
    double value = strtod(start, &end);
    if (end == start || (errno != 0 && errno != ERANGE)) {
      fclose(input);
      die("invalid floating-point value in the additional input file");
    }
    while (*end == ' ' || *end == '\t' || *end == '\r' || *end == '\n') {
      ++end;
    }
    if (*end != '\0' && *end != '#') {
      fclose(input);
      die("unexpected trailing text in the additional input file");
    }
    input_set_push(set, double_to_bits(value));
    ++count;
  }
  if (ferror(input)) {
    fclose(input);
    die("failed while reading the additional input file");
  }
  fclose(input);
  return count;
}

static uint64_t oracle_exp(uint64_t input_bits, mpfr_prec_t *used_precision) {
  double input = bits_to_double(input_bits);
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
    mpfr_exp(lower, x, MPFR_RNDD);
    mpfr_exp(upper, x, MPFR_RNDU);
    uint64_t lower_bits = double_to_bits(mpfr_get_d(lower, MPFR_RNDN));
    uint64_t upper_bits = double_to_bits(mpfr_get_d(upper, MPFR_RNDN));
    if (lower_bits == upper_bits) {
      *used_precision = precision;
      mpfr_clears(x, lower, upper, (mpfr_ptr)0);
      return lower_bits;
    }
  }

  mpfr_clears(x, lower, upper, (mpfr_ptr)0);
  die("could not determine a correctly rounded result within the precision "
      "limit");
  return 0;
}

static GeneratorOptions parse_options(int argc, char **argv) {
  GeneratorOptions options = {
      .samples_per_stratum = DEFAULT_RANDOM_SAMPLES_PER_STRATUM,
      .maximum_ulp = 1,
      .input_file = NULL,
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
      if (errno != 0 || end == argv[i] || *end != '\0' || parsed > UINT32_MAX) {
        die("maximum ULP must be a nonnegative 32-bit integer");
      }
      options.maximum_ulp = (unsigned)parsed;
    } else if (strcmp(argv[i], "--input-file") == 0 && i + 1 < argc) {
      options.input_file = argv[++i];
    } else {
      die("usage: generate [--samples-per-stratum COUNT] [--max-ulp COUNT] "
          "[--input-file PATH]");
    }
  }
  return options;
}

static void print_generated_test(const OracleCase *cases, size_t count,
                                 size_t samples_per_stratum,
                                 unsigned maximum_ulp,
                                 size_t additional_input_count,
                                 mpfr_prec_t maximum_precision) {
  printf("// Code generated by tools/oracle/exp/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, exp, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; "
         "maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique "
         "cases: %zu.\n",
         RANDOM_SEED, samples_per_stratum, maximum_ulp, count);
  if (additional_input_count != 0) {
    printf("// Additional inputs loaded from a text corpus: %zu.\n",
           additional_input_count);
  }
  printf(
      "// Inputs cover special values, implementation and analytic boundaries, "
      "all reduction cells, and three deterministic random strata.\n\n");
  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\n");
    printf("let exp_mpfr_cases_%zu : Array[(UInt64, UInt64)] = [\n", chunk);
    for (size_t i = begin; i < end; ++i) {
      printf("  (0x%016" PRIx64 "UL, 0x%016" PRIx64 "UL),\n",
             cases[i].input_bits, cases[i].expected_bits);
    }
    printf("]\n\n");
  }
  printf("///|\n");
  printf("let exp_mpfr_case_groups : Array[Array[(UInt64, UInt64)]] = [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    if (chunk % 5 == 0) {
      printf("  ");
    }
    printf("exp_mpfr_cases_%zu,", chunk);
    if (chunk % 5 == 4 || chunk + 1 == chunk_count) {
      printf("\n");
    } else {
      printf(" ");
    }
  }
  printf("]\n\n");
  printf("///|\n");
  printf("fn exp_oracle_ulp_error(expect : Double, actual : Double) -> UInt64 "
         "{\n");
  printf("  if expect == actual {\n");
  printf("    return 0UL\n");
  printf("  }\n");
  printf("  if expect.is_nan() || actual.is_nan() || expect.is_inf() || "
         "actual.is_inf() {\n");
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
  printf("///|\n");
  printf("test \"exp agrees with the MPFR oracle within %u ULP\" {\n",
         maximum_ulp);
  printf("  let mut maximum_error = 0UL\n");
  printf("  for cases in exp_mpfr_case_groups {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expect_bits) = pair\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      let expect = expect_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.exp(input)\n");
  printf("      let error = exp_oracle_ulp_error(expect, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uUL {\n", maximum_ulp);
  printf("        println(\n");
  printf("          \"exp oracle mismatch: input_bits=\\{input_bits}, "
         "expect_bits=\\{expect_bits}, "
         "actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uUL)\n", maximum_ulp);
  printf("}\n\n");
  printf("///|\n");
  printf("test \"exp range and monotonicity over the oracle corpus\" {\n");
  printf("  let mut previous = 0.0\n");
  printf("  let mut have_previous = false\n");
  printf("  for cases in exp_mpfr_case_groups {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, _) = pair\n");
  printf("      let actual = @math.exp(input_bits.reinterpret_as_double())\n");
  printf("      assert_true(!actual.is_nan())\n");
  printf("      assert_eq(actual.reinterpret_as_uint64() >> 63, 0UL)\n");
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
  if (sizeof(double) != sizeof(uint64_t) || DBL_MANT_DIG != 53 ||
      DBL_MAX_EXP != 1024) {
    die("the generator requires IEEE 754 binary64 double");
  }

  GeneratorOptions options = parse_options(argc, argv);
  InputSet inputs = {0};
  add_fixed_inputs(&inputs);
  add_analytic_boundaries(&inputs);
  add_random_inputs(&inputs, options.samples_per_stratum);
  size_t additional_input_count = add_input_file(&inputs, options.input_file);
  sort_and_deduplicate(&inputs);

  OracleCase *cases = calloc(inputs.length, sizeof(*cases));
  if (cases == NULL) {
    die("out of memory while allocating oracle cases");
  }
  mpfr_prec_t maximum_precision = 0;
  for (size_t i = 0; i < inputs.length; ++i) {
    mpfr_prec_t used_precision = 0;
    cases[i].input_bits = inputs.items[i];
    cases[i].expected_bits = oracle_exp(inputs.items[i], &used_precision);
    if (used_precision > maximum_precision) {
      maximum_precision = used_precision;
    }
  }

  print_generated_test(cases, inputs.length, options.samples_per_stratum,
                       options.maximum_ulp, additional_input_count,
                       maximum_precision);
  free(cases);
  free(inputs.items);
  return EXIT_SUCCESS;
}
