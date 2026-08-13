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
};

static const uint64_t RANDOM_SEED = UINT64_C(0x1f83d9abfb41bd6b);
static const uint32_t F32_SIGN_MASK = UINT32_C(0x80000000);
static const uint32_t F32_EXPONENT_MASK = UINT32_C(0x7f800000);
static const uint32_t F32_FRACTION_MASK = UINT32_C(0x007fffff);

typedef struct {
  uint32_t *items;
  size_t length;
  size_t capacity;
} InputSet;

typedef struct {
  uint32_t input_bits;
  uint32_t expected_bits;
} OracleCase;

typedef struct {
  size_t samples_per_stratum;
  unsigned maximum_ulp;
} GeneratorOptions;

static void die(const char *message) {
  fprintf(stderr, "tanf oracle: %s\n", message);
  exit(EXIT_FAILURE);
}

static uint32_t float_to_bits(float value) {
  uint32_t bits;
  memcpy(&bits, &value, sizeof(bits));
  return bits;
}

static float bits_to_float(uint32_t bits) {
  float value;
  memcpy(&value, &bits, sizeof(value));
  return value;
}

static int is_nan_bits(uint32_t bits) {
  return (bits & F32_EXPONENT_MASK) == F32_EXPONENT_MASK &&
         (bits & F32_FRACTION_MASK) != 0;
}

static void input_set_push(InputSet *set, uint32_t bits) {
  if (is_nan_bits(bits)) {
    return;
  }
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    uint32_t *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting inputs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] = bits;
}

static void add_bit_neighborhood(InputSet *set, uint32_t center,
                                 unsigned radius) {
  for (unsigned offset = 0; offset <= radius; ++offset) {
    if (center >= offset) {
      input_set_push(set, center - offset);
    }
    if (offset != 0 && center <= UINT32_MAX - offset) {
      input_set_push(set, center + offset);
    }
  }
}

static int compare_u32(const void *left, const void *right) {
  uint32_t a = *(const uint32_t *)left;
  uint32_t b = *(const uint32_t *)right;
  return (a > b) - (a < b);
}

static int compare_input_numeric(const void *left, const void *right) {
  uint32_t a_bits = *(const uint32_t *)left;
  uint32_t b_bits = *(const uint32_t *)right;
  float a = bits_to_float(a_bits);
  float b = bits_to_float(b_bits);
  if (a < b) {
    return -1;
  }
  if (a > b) {
    return 1;
  }
  return (a_bits > b_bits) - (a_bits < b_bits);
}

static void sort_and_deduplicate(InputSet *set) {
  qsort(set->items, set->length, sizeof(*set->items), compare_u32);
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

static void add_fixed_inputs(InputSet *set) {
  static const uint32_t fixed_bits[] = {
      UINT32_C(0x00000000), /* +0 */
      UINT32_C(0x80000000), /* -0 */
      UINT32_C(0x00000001), /* minimum positive subnormal */
      UINT32_C(0x80000001),
      UINT32_C(0x007fffff), /* maximum positive subnormal */
      UINT32_C(0x807fffff),
      UINT32_C(0x00800000), /* minimum positive normal */
      UINT32_C(0x80800000),
      UINT32_C(0x3f800000), /* +1 */
      UINT32_C(0xbf800000), /* -1 */
      UINT32_C(0x3fc90fdb), /* nearest binary32 to pi/2 */
      UINT32_C(0xbfc90fdb),
      UINT32_C(0x40490fdb), /* nearest binary32 to pi */
      UINT32_C(0xc0490fdb),
      UINT32_C(0x430ee800), /* implementation switchover: 142.90625 */
      UINT32_C(0xc30ee800),
      UINT32_C(0x7f7fffff), /* maximum finite */
      UINT32_C(0xff7fffff),
      UINT32_C(0x7f800000), /* +infinity */
      UINT32_C(0xff800000), /* -infinity */
  };
  for (size_t i = 0; i < sizeof(fixed_bits) / sizeof(fixed_bits[0]); ++i) {
    add_bit_neighborhood(set, fixed_bits[i], 2);
  }

  for (int value = -1024; value <= 1024; ++value) {
    input_set_push(set, float_to_bits((float)value));
  }
}

static void add_analytic_boundaries(InputSet *set) {
  /* Every exponent boundary, including invalid-domain inputs. */
  for (uint32_t exponent = 0; exponent < 255; ++exponent) {
    uint32_t lower = exponent << 23;
    uint32_t upper = lower | F32_FRACTION_MASK;
    add_bit_neighborhood(set, lower, 4);
    add_bit_neighborhood(set, upper, 4);
    add_bit_neighborhood(set, lower | F32_SIGN_MASK, 4);
    add_bit_neighborhood(set, upper | F32_SIGN_MASK, 4);
  }

  static const uint32_t branch_magnitudes[] = {
      UINT32_C(0x00000000), /* zero */
      UINT32_C(0x39800000), /* 2^-12 */
      UINT32_C(0x3f490fdb), /* pi/4 */
      UINT32_C(0x3fc90fdb), /* pi/2 */
      UINT32_C(0x40490fdb), /* pi */
      UINT32_C(0x430ee800), /* implementation switchover */
  };
  for (size_t i = 0;
       i < sizeof(branch_magnitudes) / sizeof(branch_magnitudes[0]); ++i) {
    add_bit_neighborhood(set, branch_magnitudes[i], 64);
    add_bit_neighborhood(set, branch_magnitudes[i] | F32_SIGN_MASK, 64);
  }
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;

  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);
    uint32_t random2 = (uint32_t)xorshift64star(&state);

    /* Raw finite binary32 bit patterns. */
    uint32_t raw = (uint32_t)random;
    if ((raw & F32_EXPONENT_MASK) == F32_EXPONENT_MASK) {
      raw -= UINT32_C(0x00800000);
    }
    input_set_push(set, raw);

    /* Exponent-stratified inputs, including subnormals and extreme binades. */
    uint32_t exponent = (uint32_t)(random % UINT64_C(0xff));
    uint32_t sign = random2 & F32_SIGN_MASK;
    uint32_t fraction_bits = random2 & F32_FRACTION_MASK;
    input_set_push(set, sign | (exponent << 23) | fraction_bits);

    /* A second independently exponent-stratified finite input. */
    uint32_t random3 = (uint32_t)xorshift64star(&state);
    uint32_t exponent2 = random3 % UINT32_C(0xff);
    input_set_push(set, (random3 & F32_SIGN_MASK) | (exponent2 << 23) |
                            ((uint32_t)random & F32_FRACTION_MASK));

    /* Dense samples around reduction and quadrant boundaries. */
    static const uint32_t branch_magnitudes[] = {
        UINT32_C(0x39800000), UINT32_C(0x3f490fdb),
        UINT32_C(0x3fc90fdb), UINT32_C(0x40490fdb),
        UINT32_C(0x430ee800),
    };
    uint32_t center = branch_magnitudes[random3 % UINT32_C(5)];
    uint32_t distance = random3 & UINT32_C(0x0000ffff);
    uint32_t magnitude = (random3 & UINT32_C(0x00010000)) == 0
                             ? center + distance
                             : center - distance;
    input_set_push(set, (random2 & F32_SIGN_MASK) | magnitude);

    /* Dense samples near zero exercise the odd polynomial. */
    input_set_push(set, (random3 & F32_SIGN_MASK) |
                            (random2 % UINT32_C(0x39800000)));
  }
}

static uint32_t oracle_tanf(uint32_t input_bits,
                              mpfr_prec_t *used_precision) {
  float input = bits_to_float(input_bits);
  uint32_t magnitude = input_bits & ~F32_SIGN_MASK;
  if (magnitude == 0) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return input_bits;
  }
  if (magnitude == F32_EXPONENT_MASK) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT32_C(0x7fc00000);
  }
  mpfr_t x;
  mpfr_t lower;
  mpfr_t upper;
  mpfr_init2(x, 32);
  mpfr_init2(lower, INITIAL_ORACLE_PRECISION);
  mpfr_init2(upper, INITIAL_ORACLE_PRECISION);
  mpfr_set_flt(x, input, MPFR_RNDN);

  for (mpfr_prec_t precision = INITIAL_ORACLE_PRECISION;
       precision <= MAX_ORACLE_PRECISION; precision *= 2) {
    mpfr_set_prec(lower, precision);
    mpfr_set_prec(upper, precision);
    mpfr_tan(lower, x, MPFR_RNDD);
    mpfr_tan(upper, x, MPFR_RNDU);
    uint32_t lower_bits = float_to_bits(mpfr_get_flt(lower, MPFR_RNDN));
    uint32_t upper_bits = float_to_bits(mpfr_get_flt(upper, MPFR_RNDN));
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
  printf("// Code generated by tools/oracle/tanf/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, tan, binary32 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique cases: %zu.\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);
  printf("// Inputs cover IEEE 754 classes, all exponent boundaries, quadrant landmarks, the reduction switchover, and four deterministic random strata.\n\n");

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn tanf_mpfr_cases_%zu() -> Array[(UInt, UInt)] {\n",
           chunk);
    printf("  [\n");
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%08" PRIx32 "U, 0x%08" PRIx32 "U),\n",
             cases[i].input_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn tanf_mpfr_case_groups() -> Array[Array[(UInt, UInt)]] {\n");
  printf("  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    tanf_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn tanf_oracle_ulp_error(expect : Float, actual : Float) -> UInt {\n");
  printf("  if expect == actual {\n");
  printf("    return 0U\n");
  printf("  }\n");
  printf("  if expect.is_nan() && actual.is_nan() {\n");
  printf("    return 0U\n");
  printf("  }\n");
  printf("  if expect.is_nan() || actual.is_nan() || expect.is_inf() || actual.is_inf() {\n");
  printf("    return 0xffffffffU\n");
  printf("  }\n");
  printf("  let expect_bits = expect.reinterpret_as_uint()\n");
  printf("  let actual_bits = actual.reinterpret_as_uint()\n");
  printf("  if expect_bits >= actual_bits {\n");
  printf("    expect_bits - actual_bits\n");
  printf("  } else {\n");
  printf("    actual_bits - expect_bits\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"tanf agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0U\n");
  printf("  for cases in tanf_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())\n");
  printf("      let expected = Float::reinterpret_from_int(\n");
  printf("        expected_bits.reinterpret_as_int(),\n");
  printf("      )\n");
  printf("      let actual = @math.tanf(input)\n");
  printf("      let error = tanf_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uU {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"tanf oracle mismatch: input_bits=\\{input_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uU)\n", options->maximum_ulp);
  printf("}\n\n");

  printf("///|\ntest \"MoonBit Core tanf meets the oracle bound over the corpus\" {\n");
  printf("  for cases in tanf_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, expected_bits) = pair\n");
  printf("      let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())\n");
  printf("      let expected = Float::reinterpret_from_int(\n");
  printf("        expected_bits.reinterpret_as_int(),\n");
  printf("      )\n");
  printf("      let actual = @core_math.tanf(input)\n");
  printf("      assert_true(tanf_oracle_ulp_error(expected, actual) <= %uU)\n",
         options->maximum_ulp);
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"tanf is odd over finite inputs\" {\n");
  printf("  for cases in tanf_mpfr_case_groups() {\n");
  printf("    for pair in cases {\n");
  printf("      let (input_bits, _) = pair\n");
  printf("      let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())\n");
  printf("      if (input_bits & 0x7fffffffU) < 0x7f800000U {\n");
  printf("        let actual = @math.tanf(input)\n");
  printf("        assert_true(!actual.is_nan())\n");
  printf("        let opposite = @math.tanf(-input)\n");
  printf("        assert_eq(\n");
  printf("          opposite.reinterpret_as_uint(),\n");
  printf("          (-actual).reinterpret_as_uint(),\n");
  printf("        )\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n");
}

int main(int argc, char **argv) {
  if (FLT_RADIX != 2 || FLT_MANT_DIG != 24 || FLT_MAX_EXP != 128 ||
      sizeof(float) != sizeof(uint32_t)) {
    die("generator requires IEEE 754 binary32 float");
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
        .expected_bits = oracle_tanf(inputs.items[i], &used_precision),
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
