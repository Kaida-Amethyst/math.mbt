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

static const uint64_t RANDOM_SEED = UINT64_C(0xbb67ae8584caa73b);
static const uint64_t F64_SIGN_MASK = UINT64_C(0x8000000000000000);
static const uint64_t F64_EXPONENT_MASK = UINT64_C(0x7ff0000000000000);
static const uint64_t F64_FRACTION_MASK = UINT64_C(0x000fffffffffffff);

typedef struct {
  uint64_t y_bits;
  uint64_t x_bits;
} InputPair;

typedef struct {
  InputPair *items;
  size_t length;
  size_t capacity;
} InputPairSet;

typedef struct {
  uint64_t y_bits;
  uint64_t x_bits;
  uint64_t expected_bits;
} OracleCase;

typedef struct {
  size_t samples_per_stratum;
  unsigned maximum_ulp;
} GeneratorOptions;

static void die(const char *message) {
  fprintf(stderr, "atan2 oracle: %s\n", message);
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

static uint64_t make_finite(uint64_t bits) {
  if ((bits & F64_EXPONENT_MASK) == F64_EXPONENT_MASK) {
    bits -= UINT64_C(0x0010000000000000);
  }
  return bits;
}

static void pair_set_push(InputPairSet *set, uint64_t y_bits,
                          uint64_t x_bits) {
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    InputPair *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting input pairs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] = (InputPair){y_bits, x_bits};
}

static void add_pair_neighborhood(InputPairSet *set, uint64_t y_center,
                                  uint64_t x_center, unsigned radius) {
  for (unsigned y_offset = 0; y_offset <= radius; ++y_offset) {
    for (unsigned x_offset = 0; x_offset <= radius; ++x_offset) {
      uint64_t y_values[2] = {y_center - y_offset, y_center + y_offset};
      uint64_t x_values[2] = {x_center - x_offset, x_center + x_offset};
      size_t y_count = y_offset == 0 ? 1 : 2;
      size_t x_count = x_offset == 0 ? 1 : 2;
      if (y_center < y_offset || y_center > UINT64_MAX - y_offset ||
          x_center < x_offset || x_center > UINT64_MAX - x_offset) {
        continue;
      }
      for (size_t yi = 0; yi < y_count; ++yi) {
        for (size_t xi = 0; xi < x_count; ++xi) {
          pair_set_push(set, y_values[yi], x_values[xi]);
        }
      }
    }
  }
}

static int compare_pairs(const void *left, const void *right) {
  const InputPair *a = left;
  const InputPair *b = right;
  if (a->y_bits != b->y_bits) {
    return (a->y_bits > b->y_bits) - (a->y_bits < b->y_bits);
  }
  return (a->x_bits > b->x_bits) - (a->x_bits < b->x_bits);
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

static void add_signed_pair(InputPairSet *set, uint64_t y_magnitude,
                            uint64_t x_magnitude) {
  for (uint64_t y_sign = 0; y_sign <= F64_SIGN_MASK;
       y_sign += F64_SIGN_MASK) {
    for (uint64_t x_sign = 0; x_sign <= F64_SIGN_MASK;
         x_sign += F64_SIGN_MASK) {
      pair_set_push(set, y_magnitude | y_sign, x_magnitude | x_sign);
      if (x_sign == F64_SIGN_MASK) {
        break;
      }
    }
    if (y_sign == F64_SIGN_MASK) {
      break;
    }
  }
}

static void add_fixed_inputs(InputPairSet *set) {
  static const uint64_t values[] = {
      UINT64_C(0x0000000000000000), /* +0 */
      UINT64_C(0x8000000000000000), /* -0 */
      UINT64_C(0x0000000000000001), /* minimum positive subnormal */
      UINT64_C(0x8000000000000001),
      UINT64_C(0x000fffffffffffff), /* maximum positive subnormal */
      UINT64_C(0x800fffffffffffff),
      UINT64_C(0x0010000000000000), /* minimum positive normal */
      UINT64_C(0x8010000000000000),
      UINT64_C(0x3fe0000000000000), /* 0.5 */
      UINT64_C(0x3ff0000000000000), /* 1 */
      UINT64_C(0xbff0000000000000),
      UINT64_C(0x4000000000000000), /* 2 */
      UINT64_C(0xc000000000000000),
      UINT64_C(0x7fefffffffffffff), /* maximum finite */
      UINT64_C(0xffefffffffffffff),
      UINT64_C(0x7ff0000000000000), /* +infinity */
      UINT64_C(0xfff0000000000000), /* -infinity */
      UINT64_C(0x7ff8000000000001), /* quiet NaN */
      UINT64_C(0x7ff0000000000001), /* signaling NaN encoding */
  };
  size_t count = sizeof(values) / sizeof(values[0]);
  for (size_t y = 0; y < count; ++y) {
    for (size_t x = 0; x < count; ++x) {
      pair_set_push(set, values[y], values[x]);
    }
  }

  static const double regressions[][2] = {
      {3.0, 5.0},       {-5.0, 3.0},      {6.5, -3.25},
      {-7.25, 8.625},   {-52.5, -625.5},
  };
  for (size_t i = 0; i < sizeof(regressions) / sizeof(regressions[0]); ++i) {
    add_pair_neighborhood(set, double_to_bits(regressions[i][0]),
                          double_to_bits(regressions[i][1]), 2);
  }

  /* Observed 1-ULP witness retained independently of analytic generation. */
  add_pair_neighborhood(set, UINT64_C(0x0005555555555555),
                        UINT64_C(0x003aaaaaaaaaaaaa), 2);
}

static void add_analytic_boundaries(InputPairSet *set) {
  static const uint64_t fractions[] = {
      UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001),
      UINT64_C(0x0005555555555555), UINT64_C(0x000aaaaaaaaaaaaa),
      UINT64_C(0x000ffffffffffffe), UINT64_C(0x000fffffffffffff),
  };
  static const unsigned gaps[] = {0, 1, 59, 60, 61, 511, 1022, 2045};

  for (uint64_t exponent = 0; exponent < 2047; ++exponent) {
    uint64_t x = (exponent << 52) | fractions[exponent % 6];
    for (size_t i = 0; i < sizeof(gaps) / sizeof(gaps[0]); ++i) {
      unsigned gap = gaps[i];
      uint64_t lower_exponent = exponent > gap ? exponent - gap : 0;
      uint64_t upper_exponent = exponent + gap < 2047 ? exponent + gap : 2046;
      uint64_t lower = (lower_exponent << 52) | fractions[(exponent + i) % 6];
      uint64_t upper = (upper_exponent << 52) |
                       fractions[(exponent + i + 1) % 6];
      add_signed_pair(set, lower, x);
      add_signed_pair(set, upper, x);
    }
  }

  /* Dense representatives immediately around the two 60-bit shortcuts. */
  static const uint64_t anchor_exponents[] = {
      1, 60, 61, 256, 512, 1023, 1083, 1536, 1986, 2045,
  };
  for (size_t i = 0;
       i < sizeof(anchor_exponents) / sizeof(anchor_exponents[0]); ++i) {
    uint64_t exponent = anchor_exponents[i];
    uint64_t x = (exponent << 52) | UINT64_C(0x0007ffffffffffff);
    for (int gap = 59; gap <= 61; ++gap) {
      if (exponent + (uint64_t)gap < 2047) {
        uint64_t y = ((exponent + (uint64_t)gap) << 52) |
                     UINT64_C(0x0007ffffffffffff);
        add_pair_neighborhood(set, y, x, 4);
      }
      if (exponent > (uint64_t)gap) {
        uint64_t y = ((exponent - (uint64_t)gap) << 52) |
                     UINT64_C(0x0007ffffffffffff);
        add_pair_neighborhood(set, y, x | F64_SIGN_MASK, 4);
      }
    }
  }

  /* Axes, the diagonal, and the negative-x branch cut. */
  static const uint64_t magnitudes[] = {
      UINT64_C(0x0000000000000001), UINT64_C(0x000fffffffffffff),
      UINT64_C(0x0010000000000000), UINT64_C(0x3ff0000000000000),
      UINT64_C(0x7fefffffffffffff),
  };
  for (size_t i = 0; i < sizeof(magnitudes) / sizeof(magnitudes[0]); ++i) {
    uint64_t value = magnitudes[i];
    add_pair_neighborhood(set, 0, value, 4);
    add_pair_neighborhood(set, 0, value | F64_SIGN_MASK, 4);
    add_pair_neighborhood(set, value, value, 4);
    add_pair_neighborhood(set, value, value | F64_SIGN_MASK, 4);
  }
}

static void add_random_inputs(InputPairSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random0 = (uint64_t)xorshift64star(&state);
    uint64_t random1 = (uint64_t)xorshift64star(&state);
    uint64_t random2 = (uint64_t)xorshift64star(&state);
    uint64_t random3 = (uint64_t)xorshift64star(&state);

    /* Raw finite pairs. */
    pair_set_push(set, make_finite(random0), make_finite(random1));

    /* Same-binade pairs exercise all quadrants and ratios near one. */
    uint64_t exponent = random0 % UINT64_C(0x7ff);
    pair_set_push(set,
                  (random0 & F64_SIGN_MASK) | (exponent << 52) |
                      (random1 & F64_FRACTION_MASK),
                  (random2 & F64_SIGN_MASK) | (exponent << 52) |
                      (random3 & F64_FRACTION_MASK));

    /* Exponent gaps immediately around the two implementation shortcuts. */
    uint64_t gap = UINT64_C(59) + random1 % UINT64_C(3);
    uint64_t lower_exponent = exponent > gap ? exponent - gap : 0;
    pair_set_push(set,
                  (random0 & F64_SIGN_MASK) | (exponent << 52) |
                      (random2 & F64_FRACTION_MASK),
                  (random1 & F64_SIGN_MASK) | (lower_exponent << 52) |
                      (random3 & F64_FRACTION_MASK));

    /* Extreme exponent gaps stress saturation to signed zero, pi, or pi/2. */
    uint64_t extreme_gap = UINT64_C(61) + random2 % UINT64_C(1985);
    uint64_t small_exponent = exponent > extreme_gap ? exponent - extreme_gap : 0;
    pair_set_push(set,
                  (random0 & F64_SIGN_MASK) | (small_exponent << 52) |
                      (random1 & F64_FRACTION_MASK),
                  (random2 & F64_SIGN_MASK) | (exponent << 52) |
                      (random3 & F64_FRACTION_MASK));

    /* Tiny signed y with negative x samples both sides of the branch cut. */
    pair_set_push(set,
                  (random3 & F64_SIGN_MASK) |
                      (random0 & F64_FRACTION_MASK),
                  F64_SIGN_MASK | (UINT64_C(0x7fe) << 52) |
                      (random1 & F64_FRACTION_MASK));
  }
}

static uint64_t oracle_atan2(uint64_t y_bits, uint64_t x_bits,
                              mpfr_prec_t *used_precision) {
  if (is_nan_bits(y_bits) || is_nan_bits(x_bits)) {
    *used_precision = INITIAL_ORACLE_PRECISION;
    return UINT64_C(0x7ff8000000000000);
  }

  mpfr_t y;
  mpfr_t x;
  mpfr_t lower;
  mpfr_t upper;
  mpfr_init2(y, 64);
  mpfr_init2(x, 64);
  mpfr_init2(lower, INITIAL_ORACLE_PRECISION);
  mpfr_init2(upper, INITIAL_ORACLE_PRECISION);
  mpfr_set_d(y, bits_to_double(y_bits), MPFR_RNDN);
  mpfr_set_d(x, bits_to_double(x_bits), MPFR_RNDN);

  for (mpfr_prec_t precision = INITIAL_ORACLE_PRECISION;
       precision <= MAX_ORACLE_PRECISION; precision *= 2) {
    mpfr_set_prec(lower, precision);
    mpfr_set_prec(upper, precision);
    mpfr_atan2(lower, y, x, MPFR_RNDD);
    mpfr_atan2(upper, y, x, MPFR_RNDU);
    uint64_t lower_bits = double_to_bits(mpfr_get_d(lower, MPFR_RNDN));
    uint64_t upper_bits = double_to_bits(mpfr_get_d(upper, MPFR_RNDN));
    if (lower_bits == upper_bits) {
      *used_precision = precision;
      mpfr_clears(y, x, lower, upper, (mpfr_ptr)0);
      return lower_bits;
    }
  }

  mpfr_clears(y, x, lower, upper, (mpfr_ptr)0);
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
  printf("// Code generated by tools/oracle/atan2/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, atan2, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Oracle method: adaptive [%d, %d]-bit directed-rounding interval; maximum precision used: %ld bits.\n",
         INITIAL_ORACLE_PRECISION, MAX_ORACLE_PRECISION,
         (long)maximum_precision);
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; admitted error: %u ULP; total unique pairs: %zu.\n",
         RANDOM_SEED, options->samples_per_stratum, options->maximum_ulp,
         count);
  printf("// Pairs cover IEEE 754 classes, quadrants, the branch cut, 60-bit ratio transitions, and five deterministic random strata.\n\n");

  size_t chunk_count =
      (count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    size_t begin = chunk * GENERATED_CASES_PER_CHUNK;
    size_t end = begin + GENERATED_CASES_PER_CHUNK;
    if (end > count) {
      end = count;
    }
    printf("///|\nfn atan2_mpfr_cases_%zu() -> Array[(UInt64, UInt64, UInt64)] {\n",
           chunk);
    printf("  [\n");
    for (size_t i = begin; i < end; ++i) {
      printf("    (0x%016" PRIx64 "UL, 0x%016" PRIx64 "UL, 0x%016" PRIx64
             "UL),\n",
             cases[i].y_bits, cases[i].x_bits, cases[i].expected_bits);
    }
    printf("  ]\n}\n\n");
  }

  printf("///|\nfn atan2_mpfr_case_groups() -> Array[Array[(UInt64, UInt64, UInt64)]] {\n");
  printf("  [\n");
  for (size_t chunk = 0; chunk < chunk_count; ++chunk) {
    printf("    atan2_mpfr_cases_%zu(),\n", chunk);
  }
  printf("  ]\n}\n\n");

  printf("///|\nfn atan2_ordered_rank(bits : UInt64) -> UInt64 {\n");
  printf("  if (bits & 0x8000000000000000UL) != 0UL {\n");
  printf("    0x8000000000000000UL - (bits & 0x7fffffffffffffffUL)\n");
  printf("  } else {\n");
  printf("    0x8000000000000000UL + bits\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\nfn atan2_oracle_ulp_error(expect : Double, actual : Double) -> UInt64 {\n");
  printf("  if expect == actual {\n");
  printf("    return 0UL\n");
  printf("  }\n");
  printf("  if expect.is_nan() && actual.is_nan() {\n");
  printf("    return 0UL\n");
  printf("  }\n");
  printf("  if expect.is_nan() || actual.is_nan() || expect.is_inf() || actual.is_inf() {\n");
  printf("    return 0xffffffffffffffffUL\n");
  printf("  }\n");
  printf("  let expect_rank = atan2_ordered_rank(expect.reinterpret_as_uint64())\n");
  printf("  let actual_rank = atan2_ordered_rank(actual.reinterpret_as_uint64())\n");
  printf("  if expect_rank >= actual_rank {\n");
  printf("    expect_rank - actual_rank\n");
  printf("  } else {\n");
  printf("    actual_rank - expect_rank\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\ntest \"atan2 agrees with the MPFR oracle within %u ULP\" {\n",
         options->maximum_ulp);
  printf("  let mut maximum_error = 0UL\n");
  printf("  for cases in atan2_mpfr_case_groups() {\n");
  printf("    for triple in cases {\n");
  printf("      let (y_bits, x_bits, expected_bits) = triple\n");
  printf("      let y = y_bits.reinterpret_as_double()\n");
  printf("      let x = x_bits.reinterpret_as_double()\n");
  printf("      let expected = expected_bits.reinterpret_as_double()\n");
  printf("      let actual = @math.atan2(y, x)\n");
  printf("      let error = atan2_oracle_ulp_error(expected, actual)\n");
  printf("      if error > maximum_error {\n");
  printf("        maximum_error = error\n");
  printf("      }\n");
  printf("      if error > %uUL {\n", options->maximum_ulp);
  printf("        println(\n");
  printf("          \"atan2 oracle mismatch: y_bits=\\{y_bits}, x_bits=\\{x_bits}, expected_bits=\\{expected_bits}, actual_bits=\\{actual.reinterpret_as_uint64()}, ulp=\\{error}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("  assert_true(maximum_error <= %uUL)\n", options->maximum_ulp);
  printf("}\n\n");

  printf("///|\ntest \"atan2 stays in range and reflects exactly across the x-axis\" {\n");
  printf("  let negative_pi : Double = -3.1415926535897931160e+00\n");
  printf("  let positive_pi : Double = 3.1415926535897931160e+00\n");
  printf("  for cases in atan2_mpfr_case_groups() {\n");
  printf("    for triple in cases {\n");
  printf("      let (y_bits, x_bits, _) = triple\n");
  printf("      let y = y_bits.reinterpret_as_double()\n");
  printf("      let x = x_bits.reinterpret_as_double()\n");
  printf("      if !y.is_nan() && !x.is_nan() {\n");
  printf("        let actual = @math.atan2(y, x)\n");
  printf("        assert_true(actual >= negative_pi && actual <= positive_pi)\n");
  printf("        assert_eq(\n");
  printf("          @math.atan2(-y, x).reinterpret_as_uint64(),\n");
  printf("          (-actual).reinterpret_as_uint64(),\n");
  printf("        )\n");
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
        .y_bits = inputs.items[i].y_bits,
        .x_bits = inputs.items[i].x_bits,
        .expected_bits = oracle_atan2(inputs.items[i].y_bits,
                                      inputs.items[i].x_bits, &used_precision),
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
