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
static const unsigned CORE_MAXIMUM_ULP = 2;
static const uint32_t F32_SIGN_MASK = UINT32_C(0x80000000);
static const uint32_t F32_EXPONENT_MASK = UINT32_C(0x7f800000);
static const uint32_t F32_FRACTION_MASK = UINT32_C(0x007fffff);

typedef struct {
  uint32_t x_bits;
  uint32_t y_bits;
} InputPair;

typedef struct {
  InputPair *items;
  size_t length;
  size_t capacity;
} InputPairSet;

typedef struct {
  uint32_t x_bits;
  uint32_t y_bits;
  uint32_t expected_bits;
} OracleCase;

typedef struct {
  size_t samples_per_stratum;
  unsigned maximum_ulp;
} GeneratorOptions;

static void die(const char *message) {
  fprintf(stderr, "hypotf oracle: %s\n", message);
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

static int is_infinite_bits(uint32_t bits) {
  return (bits & ~F32_SIGN_MASK) == F32_EXPONENT_MASK;
}

static void pair_set_push(InputPairSet *set, uint32_t x_bits,
                          uint32_t y_bits) {
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    InputPair *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting input pairs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] = (InputPair){x_bits, y_bits};
}

static void add_axis_neighborhood(InputPairSet *set, uint32_t x_center,
                                  uint32_t y_center, unsigned radius) {
  for (unsigned offset = 0; offset <= radius; ++offset) {
    if (x_center >= offset) {
      pair_set_push(set, x_center - offset, y_center);
    }
    if (y_center >= offset) {
      pair_set_push(set, x_center, y_center - offset);
    }
    if (offset != 0 && x_center <= UINT32_MAX - offset) {
      pair_set_push(set, x_center + offset, y_center);
    }
    if (offset != 0 && y_center <= UINT32_MAX - offset) {
      pair_set_push(set, x_center, y_center + offset);
    }
  }
}

static int compare_pairs(const void *left, const void *right) {
  const InputPair *a = left;
  const InputPair *b = right;
  if (a->x_bits != b->x_bits) {
    return (a->x_bits > b->x_bits) - (a->x_bits < b->x_bits);
  }
  return (a->y_bits > b->y_bits) - (a->y_bits < b->y_bits);
}

static void sort_and_deduplicate(InputPairSet *set) {
  qsort(set->items, set->length, sizeof(*set->items), compare_pairs);
  size_t output = 0;
  for (size_t input = 0; input < set->length; ++input) {
    if (output == 0 || compare_pairs(&set->items[input],
                                     &set->items[output - 1]) != 0) {
      set->items[output++] = set->items[input];
    }
  }
  set->length = output;
}

static uint64_t xorshift64star(uint64_t *state) {
  uint64_t x = *state;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *state = x;
  return x * UINT64_C(0x2545f4914f6cdd1d);
}

static uint32_t make_finite(uint32_t bits) {
  if ((bits & F32_EXPONENT_MASK) == F32_EXPONENT_MASK) {
    bits -= UINT32_C(0x00800000);
  }
  return bits;
}

static void add_fixed_inputs(InputPairSet *set) {
  static const uint32_t values[] = {
      UINT32_C(0x00000000), /* +0 */
      UINT32_C(0x80000000), /* -0 */
      UINT32_C(0x00000001), /* minimum positive subnormal */
      UINT32_C(0x80000001),
      UINT32_C(0x007fffff), /* maximum positive subnormal */
      UINT32_C(0x00800000), /* minimum positive normal */
      UINT32_C(0x3f800000), /* 1 */
      UINT32_C(0x40000000), /* 2 */
      UINT32_C(0x40400000), /* 3 */
      UINT32_C(0x40800000), /* 4 */
      UINT32_C(0x40a00000), /* 5 */
      UINT32_C(0x7f3504f3), /* near max-finite / sqrt(2) */
      UINT32_C(0x7f7fffff), /* maximum finite */
      UINT32_C(0xff7fffff),
      UINT32_C(0x7f800000), /* +infinity */
      UINT32_C(0xff800000), /* -infinity */
      UINT32_C(0x7fc00001), /* quiet NaN */
      UINT32_C(0x7f800001), /* signaling NaN encoding */
  };
  size_t count = sizeof(values) / sizeof(values[0]);
  for (size_t x = 0; x < count; ++x) {
    for (size_t y = 0; y < count; ++y) {
      pair_set_push(set, values[x], values[y]);
    }
  }

  static const float triples[][2] = {
      {3.0f, 4.0f}, {5.0f, 12.0f}, {7.0f, 24.0f}, {8.0f, 15.0f},
  };
  for (size_t i = 0; i < sizeof(triples) / sizeof(triples[0]); ++i) {
    for (int scale = -120; scale <= 120; scale += 12) {
      float factor = bits_to_float((uint32_t)(scale + 127) << 23);
      pair_set_push(set, float_to_bits(triples[i][0] * factor),
                    float_to_bits(triples[i][1] * factor));
    }
  }
}

static void add_analytic_boundaries(InputPairSet *set) {
  for (uint32_t exponent = 0; exponent < 255; ++exponent) {
    uint32_t lower = exponent << 23;
    uint32_t upper = lower | F32_FRACTION_MASK;
    add_axis_neighborhood(set, lower, lower, 2);
    add_axis_neighborhood(set, upper, lower, 2);
    add_axis_neighborhood(set, upper, upper, 2);
    pair_set_push(set, lower, UINT32_C(0x3f800000));
    pair_set_push(set, lower | F32_SIGN_MASK, UINT32_C(0xbf800000));
  }

  static const unsigned exponent_gaps[] = {0,  1,  2,  11, 12, 22,
                                            23, 24, 74, 75, 126};
  for (uint32_t exponent = 1; exponent < 255; ++exponent) {
    for (size_t i = 0;
         i < sizeof(exponent_gaps) / sizeof(exponent_gaps[0]); ++i) {
      unsigned gap = exponent_gaps[i];
      uint32_t smaller_exponent = exponent > gap ? exponent - gap : 0;
      uint32_t x = (exponent << 23) | UINT32_C(0x00555555);
      uint32_t y = (smaller_exponent << 23) | UINT32_C(0x002aaaaa);
      pair_set_push(set, x, y);
      pair_set_push(set, x | F32_SIGN_MASK, y);
      pair_set_push(set, x, y | F32_SIGN_MASK);
    }
  }

  add_axis_neighborhood(set, UINT32_C(0x7f3504f3),
                        UINT32_C(0x7f3504f3), 128);
  add_axis_neighborhood(set, UINT32_C(0x00800000),
                        UINT32_C(0x007fffff), 128);
  add_axis_neighborhood(set, UINT32_C(0x00000001),
                        UINT32_C(0x00000001), 32);
}

static void add_random_inputs(InputPairSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint32_t random0 = (uint32_t)xorshift64star(&state);
    uint32_t random1 = (uint32_t)xorshift64star(&state);
    uint32_t random2 = (uint32_t)xorshift64star(&state);
    uint32_t random3 = (uint32_t)xorshift64star(&state);

    pair_set_push(set, make_finite(random0), make_finite(random1));

    uint32_t exponent = random0 % UINT32_C(0xff);
    pair_set_push(set,
                  (random0 & F32_SIGN_MASK) | (exponent << 23) |
                      (random1 & F32_FRACTION_MASK),
                  (random2 & F32_SIGN_MASK) | (exponent << 23) |
                      (random3 & F32_FRACTION_MASK));

    uint32_t gap = random1 % UINT32_C(127);
    uint32_t smaller_exponent = exponent > gap ? exponent - gap : 0;
    pair_set_push(set,
                  (random0 & F32_SIGN_MASK) | (exponent << 23) |
                      (random2 & F32_FRACTION_MASK),
                  (random1 & F32_SIGN_MASK) | (smaller_exponent << 23) |
                      (random3 & F32_FRACTION_MASK));

    uint32_t overflow_center = UINT32_C(0x7f3504f3);
    pair_set_push(set, overflow_center + (random0 & UINT32_C(0x0000ffff)),
                  overflow_center - (random1 & UINT32_C(0x0000ffff)));

    pair_set_push(set, random2 & F32_FRACTION_MASK,
                  random3 & F32_FRACTION_MASK);
  }
}

static uint32_t oracle_hypotf(uint32_t x_bits, uint32_t y_bits,
                              mpfr_prec_t *used_precision) {
  if (is_infinite_bits(x_bits) || is_infinite_bits(y_bits)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT32_C(0x7f800000);
  }
  if (is_nan_bits(x_bits) || is_nan_bits(y_bits)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT32_C(0x7fc00000);
  }

  mpfr_t x;
  mpfr_t y;
  mpfr_t lower;
  mpfr_t upper;
  mpfr_init2(x, 32);
  mpfr_init2(y, 32);
  mpfr_init2(lower, INITIAL_ORACLE_PRECISION);
  mpfr_init2(upper, INITIAL_ORACLE_PRECISION);
  mpfr_set_flt(x, bits_to_float(x_bits), MPFR_RNDN);
  mpfr_set_flt(y, bits_to_float(y_bits), MPFR_RNDN);

  for (mpfr_prec_t precision = INITIAL_ORACLE_PRECISION;
       precision <= MAX_ORACLE_PRECISION; precision *= 2) {
    mpfr_set_prec(lower, precision);
    mpfr_set_prec(upper, precision);
    mpfr_hypot(lower, x, y, MPFR_RNDD);
    mpfr_hypot(upper, x, y, MPFR_RNDU);
    uint32_t lower_bits = float_to_bits(mpfr_get_flt(lower, MPFR_RNDN));
    uint32_t upper_bits = float_to_bits(mpfr_get_flt(upper, MPFR_RNDN));
    if (lower_bits == upper_bits) {
      *used_precision = precision;
      mpfr_clears(x, y, lower, upper, (mpfr_ptr)0);
      return lower_bits;
    }
  }

  mpfr_clears(x, y, lower, upper, (mpfr_ptr)0);
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
  printf("// Code generated by tools/oracle/hypotf/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, hypot, binary32 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique cases: %zu.\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);
  printf("// Pairs cover IEEE 754 classes, exponent gaps, normal/subnormal and overflow boundaries, and deterministic random strata.\n\n");

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn hypotf_mpfr_cases_%zu() -> Array[(UInt, UInt, UInt)] {\n",
           chunk);
    printf("  [\n");
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%08" PRIx32 "U, 0x%08" PRIx32 "U, 0x%08" PRIx32
             "U),\n",
             cases[i].x_bits, cases[i].y_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn hypotf_mpfr_case_groups() -> Array[Array[(UInt, UInt, UInt)]] {\n");
  printf("  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    hypotf_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn hypotf_oracle_ulp_error(expect : Float, actual : Float) -> UInt {\n");
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

  printf("///|\ntest \"hypotf agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0U\n");
  printf("  for cases in hypotf_mpfr_case_groups() {\n");
  printf("    for triple in cases {\n");
  printf("      let (x_bits, y_bits, expected_bits) = triple\n");
  printf("      let x = Float::reinterpret_from_uint(x_bits)\n");
  printf("      let y = Float::reinterpret_from_uint(y_bits)\n");
  printf("      let expected = Float::reinterpret_from_uint(expected_bits)\n");
  printf("      let actual = @math.hypotf(x, y)\n");
  printf("      let error = hypotf_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uU {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"hypotf oracle mismatch: x_bits=\\{x_bits}, y_bits=\\{y_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uU)\n", options->maximum_ulp);
  printf("}\n\n");

  printf("///|\ntest \"MoonBit Core hypotf comparison over finite-reference results\" {\n");
  printf("  for cases in hypotf_mpfr_case_groups() {\n");
  printf("    for triple in cases {\n");
  printf("      let (x_bits, y_bits, expected_bits) = triple\n");
  printf("      let x = Float::reinterpret_from_uint(x_bits)\n");
  printf("      let y = Float::reinterpret_from_uint(y_bits)\n");
  printf("      let expected = Float::reinterpret_from_uint(expected_bits)\n");
  printf("      let actual = @core_math.hypotf(x, y)\n");
  printf("      if !expected.is_inf() {\n");
  printf("        assert_true(hypotf_oracle_ulp_error(expected, actual) <= %uU)\n",
         CORE_MAXIMUM_ULP);
  printf("      } else if x.is_inf() || y.is_inf() {\n");
  printf("        assert_true(actual.is_inf())\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"hypotf is symmetric, sign-invariant, and no smaller than either magnitude\" {\n");
  printf("  for cases in hypotf_mpfr_case_groups() {\n");
  printf("    for triple in cases {\n");
  printf("      let (x_bits, y_bits, _) = triple\n");
  printf("      let x = Float::reinterpret_from_uint(x_bits)\n");
  printf("      let y = Float::reinterpret_from_uint(y_bits)\n");
  printf("      if !x.is_nan() && !y.is_nan() {\n");
  printf("        let actual = @math.hypotf(x, y)\n");
  printf("        assert_eq(\n");
  printf("          @math.hypotf(y, x).reinterpret_as_uint(),\n");
  printf("          actual.reinterpret_as_uint(),\n");
  printf("        )\n");
  printf("        assert_eq(\n");
  printf("          @math.hypotf(-x, -y).reinterpret_as_uint(),\n");
  printf("          actual.reinterpret_as_uint(),\n");
  printf("        )\n");
  printf("        assert_true(actual >= x.abs())\n");
  printf("        assert_true(actual >= y.abs())\n");
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
  InputPairSet inputs = {0};
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
        .x_bits = inputs.items[i].x_bits,
        .y_bits = inputs.items[i].y_bits,
        .expected_bits = oracle_hypotf(inputs.items[i].x_bits,
                                      inputs.items[i].y_bits, &used_precision),
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
