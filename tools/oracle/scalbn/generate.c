#include <errno.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpfr.h>

enum {
  DEFAULT_SAMPLES_PER_STRATUM = 4096,
  GENERATED_CASES_PER_CHUNK = 2048,
};

static const uint64_t RANDOM_SEED = UINT64_C(0x6a09e667f3bcc909);
static const uint64_t F64_SIGN_MASK = UINT64_C(0x8000000000000000);
static const uint64_t F64_EXPONENT_MASK = UINT64_C(0x7ff0000000000000);
static const uint64_t F64_FRACTION_MASK = UINT64_C(0x000fffffffffffff);

typedef struct {
  uint64_t input_bits;
  int32_t exponent;
} ScalbnInput;

typedef struct {
  ScalbnInput *items;
  size_t length;
  size_t capacity;
} InputSet;

typedef struct {
  uint64_t input_bits;
  int32_t exponent;
  uint64_t expected_bits;
} OracleCase;

static void die(const char *message) {
  fprintf(stderr, "scalbn oracle: %s\n", message);
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

static void input_set_push(InputSet *set, uint64_t bits, int32_t exponent) {
  if (is_nan_bits(bits)) {
    return;
  }
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    ScalbnInput *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting inputs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] =
      (ScalbnInput){.input_bits = bits, .exponent = exponent};
}

static int compare_inputs(const void *left, const void *right) {
  const ScalbnInput *a = left;
  const ScalbnInput *b = right;
  if (a->input_bits != b->input_bits) {
    return (a->input_bits > b->input_bits) -
           (a->input_bits < b->input_bits);
  }
  return (a->exponent > b->exponent) - (a->exponent < b->exponent);
}

static void sort_and_deduplicate(InputSet *set) {
  qsort(set->items, set->length, sizeof(*set->items), compare_inputs);
  size_t output = 0;
  for (size_t input = 0; input < set->length; ++input) {
    if (output == 0 ||
        compare_inputs(&set->items[input], &set->items[output - 1]) != 0) {
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

static int floor_log2_fraction(uint64_t fraction) {
  int result = -1;
  while (fraction != 0) {
    fraction >>= 1;
    ++result;
  }
  return result;
}

static int binary64_ilogb(uint64_t bits) {
  uint64_t magnitude = bits & ~F64_SIGN_MASK;
  unsigned exponent_field = (unsigned)(magnitude >> 52);
  if (exponent_field != 0) {
    return (int)exponent_field - 1023;
  }
  return floor_log2_fraction(magnitude & F64_FRACTION_MASK) - 1074;
}

static void add_transition_exponents(InputSet *set, uint64_t bits) {
  uint64_t magnitude = bits & ~F64_SIGN_MASK;
  if (magnitude == 0 || magnitude >= F64_EXPONENT_MASK) {
    return;
  }

  static const int output_exponents[] = {
      -1076, -1075, -1074, -1073, -1023,
      -1022, -1021, 1022,  1023,  1024,
  };
  int input_exponent = binary64_ilogb(bits);
  for (size_t i = 0;
       i < sizeof(output_exponents) / sizeof(output_exponents[0]); ++i) {
    int center = output_exponents[i] - input_exponent;
    for (int offset = -3; offset <= 3; ++offset) {
      input_set_push(set, bits, (int32_t)(center + offset));
    }
  }
}

static void add_fixed_inputs(InputSet *set) {
  static const uint64_t positive_inputs[] = {
      UINT64_C(0x0000000000000000), /* zero */
      UINT64_C(0x0000000000000001), /* minimum subnormal */
      UINT64_C(0x0000000000000002),
      UINT64_C(0x0000000000000003),
      UINT64_C(0x0007ffffffffffff),
      UINT64_C(0x000ffffffffffffe),
      UINT64_C(0x000fffffffffffff), /* maximum subnormal */
      UINT64_C(0x0010000000000000), /* minimum normal */
      UINT64_C(0x0010000000000001),
      UINT64_C(0x001fffffffffffff),
      UINT64_C(0x3fc999999999999a), /* 0.2 */
      UINT64_C(0x3fd0000000000000), /* 0.25 */
      UINT64_C(0x3fe0000000000000), /* 0.5 */
      UINT64_C(0x3fefffffffffffff),
      UINT64_C(0x3ff0000000000000), /* 1 */
      UINT64_C(0x3ff0000000000001),
      UINT64_C(0x3ff8000000000000), /* 1.5 */
      UINT64_C(0x4000000000000000), /* 2 */
      UINT64_C(0x4008000000000000), /* 3 */
      UINT64_C(0x400921fb54442d18), /* pi */
      UINT64_C(0x7fdfffffffffffff),
      UINT64_C(0x7fe0000000000000), /* 2^1023 */
      UINT64_C(0x7feffffffffffffe),
      UINT64_C(0x7fefffffffffffff), /* maximum finite */
      UINT64_C(0x7ff0000000000000), /* infinity */
  };
  static const int32_t fixed_exponents[] = {
      INT32_MIN, -1000000, -4097, -4096, -3072, -2962, -2961, -2960,
      -2048, -1993, -1992, -1991, -1077, -1076, -1075, -1074, -1073,
      -1024, -1023, -1022, -1021, -970, -969, -968, -54, -53, -52,
      -1, 0, 1, 52, 53, 54, 968, 969, 970, 1021, 1022, 1023, 1024,
      2046, 2047, 2048, 3069, 3070, 3071, 4096, 4097, 1000000,
      INT32_MAX,
  };

  for (size_t input = 0;
       input < sizeof(positive_inputs) / sizeof(positive_inputs[0]); ++input) {
    uint64_t positive = positive_inputs[input];
    uint64_t negative = positive | F64_SIGN_MASK;
    for (size_t exponent = 0;
         exponent < sizeof(fixed_exponents) / sizeof(fixed_exponents[0]);
         ++exponent) {
      input_set_push(set, positive, fixed_exponents[exponent]);
      input_set_push(set, negative, fixed_exponents[exponent]);
    }
    add_transition_exponents(set, positive);
    add_transition_exponents(set, negative);
  }
}

static uint64_t finite_random_bits(uint64_t *state) {
  uint64_t bits = xorshift64star(state);
  if ((bits & F64_EXPONENT_MASK) == F64_EXPONENT_MASK) {
    bits ^= UINT64_C(0x0010000000000000);
  }
  return bits;
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;

  /* Uniform binary64 bit patterns with scaling exponents near the usable
     output range and the staged implementation branches. */
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t bits = finite_random_bits(&state);
    int32_t exponent = (int32_t)(xorshift64star(&state) % 8195) - 4097;
    input_set_push(set, bits, exponent);
  }

  /* Uniform binary64 exponent fields, with output exponents concentrated on
     normal/subnormal and finite/infinity transitions. */
  static const int targets[] = {
      -1076, -1075, -1074, -1073, -1023,
      -1022, -1021, 1022,  1023,  1024,
  };
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);
    uint64_t sign = random & F64_SIGN_MASK;
    uint64_t exponent_field =
        (xorshift64star(&state) % UINT64_C(0x7ff)) << 52;
    uint64_t fraction = xorshift64star(&state) & F64_FRACTION_MASK;
    uint64_t bits = sign | exponent_field | fraction;
    if ((bits & ~F64_SIGN_MASK) == 0) {
      bits |= 1;
    }
    int target = targets[i % (sizeof(targets) / sizeof(targets[0]))];
    int32_t exponent = (int32_t)(target - binary64_ilogb(bits));
    input_set_push(set, bits, exponent);
  }

  /* Full-width Int exponents verify that saturation does not overflow while
     still sampling arbitrary binary64 significands. */
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t bits = finite_random_bits(&state);
    int32_t exponent = (int32_t)xorshift64star(&state);
    input_set_push(set, bits, exponent);
  }
}

static uint64_t oracle_bits(mpfr_t value, uint64_t input_bits,
                            int32_t exponent) {
  uint64_t magnitude = input_bits & ~F64_SIGN_MASK;
  uint64_t sign = input_bits & F64_SIGN_MASK;

  if (magnitude == 0 || magnitude == F64_EXPONENT_MASK) {
    return input_bits;
  }
  if (exponent > 4096) {
    return sign | F64_EXPONENT_MASK;
  }
  if (exponent < -4096) {
    return sign;
  }

  mpfr_set_d(value, bits_to_double(input_bits), MPFR_RNDN);
  mpfr_mul_2si(value, value, exponent, MPFR_RNDN);
  return double_to_bits(mpfr_get_d(value, MPFR_RNDN));
}

static void emit_header(size_t samples_per_stratum, size_t case_count) {
  printf("// Code generated by tools/oracle/scalbn/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, exact multiplication by 2^n, binary64 round-to-nearest ties-to-even.\n",
         mpfr_get_version());
  printf("// Random seed: 0x%016" PRIx64
         "; samples per stratum: %zu; total unique cases: %zu.\n",
         RANDOM_SEED, samples_per_stratum, case_count);
  printf("// Inputs cover signed special values, implementation branches, result-format transitions, and three deterministic random strata.\n\n");
}

static void emit_cases(const OracleCase *cases, size_t case_count) {
  size_t group_count =
      (case_count + GENERATED_CASES_PER_CHUNK - 1) / GENERATED_CASES_PER_CHUNK;
  for (size_t group = 0; group < group_count; ++group) {
    size_t start = group * GENERATED_CASES_PER_CHUNK;
    size_t end = start + GENERATED_CASES_PER_CHUNK;
    if (end > case_count) {
      end = case_count;
    }
    printf("///|\nfn scalbn_mpfr_cases_%zu() -> Array[(UInt64, Int, UInt64)] {\n",
           group);
    printf("  [\n");
    for (size_t i = start; i < end; ++i) {
      printf("    (0x%016" PRIx64 "UL, %" PRId32 ", 0x%016" PRIx64
             "UL),\n",
             cases[i].input_bits, cases[i].exponent, cases[i].expected_bits);
    }
    printf("  ]\n");
    printf("}\n\n");
  }

  printf("///|\nfn scalbn_mpfr_case_groups() -> Array[Array[(UInt64, Int, UInt64)]] {\n");
  printf("  [\n");
  for (size_t group = 0; group < group_count; ++group) {
    printf("    scalbn_mpfr_cases_%zu(),\n", group);
  }
  printf("  ]\n");
  printf("}\n\n");
}

static void emit_oracle_check(const char *function_name) {
  printf("///|\n");
  printf("test \"%s agrees exactly with the MPFR oracle\" {\n", function_name);
  printf("  for cases in scalbn_mpfr_case_groups() {\n");
  printf("    for item in cases {\n");
  printf("      let (input_bits, exponent, expected_bits) = item\n");
  printf("      let actual_bits = @math.%s(\n", function_name);
  printf("        input_bits.reinterpret_as_double(),\n");
  printf("        exponent,\n");
  printf("      ).reinterpret_as_uint64()\n");
  printf("      if actual_bits != expected_bits {\n");
  printf("        println(\n");
  printf("          \"%s oracle mismatch: input_bits=\\{input_bits}, exponent=\\{exponent}, expected_bits=\\{expected_bits}, actual_bits=\\{actual_bits}\",\n",
         function_name);
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");
}

static void emit_tests(void) {
  emit_oracle_check("scalbn");
  emit_oracle_check("ldexp");

  printf("///|\n");
  printf("test \"scalbn matches MoonBit Core over the oracle corpus\" {\n");
  printf("  for cases in scalbn_mpfr_case_groups() {\n");
  printf("    for item in cases {\n");
  printf("      let (input_bits, exponent, _) = item\n");
  printf("      let input = input_bits.reinterpret_as_double()\n");
  printf("      assert_eq(\n");
  printf("        @math.scalbn(input, exponent).reinterpret_as_uint64(),\n");
  printf("        @core_math.scalbn(input, exponent).reinterpret_as_uint64(),\n");
  printf("      )\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n");
}

static size_t parse_size(const char *text) {
  char *end = NULL;
  errno = 0;
  unsigned long long value = strtoull(text, &end, 10);
  if (errno != 0 || end == text || *end != '\0' || value == 0 ||
      value > SIZE_MAX) {
    die("invalid positive sample count");
  }
  return (size_t)value;
}

int main(int argc, char **argv) {
  size_t samples_per_stratum = DEFAULT_SAMPLES_PER_STRATUM;
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "--samples-per-stratum") == 0 && i + 1 < argc) {
      samples_per_stratum = parse_size(argv[++i]);
    } else {
      die("usage: generate [--samples-per-stratum COUNT]");
    }
  }

  if (FLT_RADIX != 2 || DBL_MANT_DIG != 53 || DBL_MAX_EXP != 1024 ||
      sizeof(double) != sizeof(uint64_t)) {
    die("generator requires IEEE 754 binary64 double");
  }

  InputSet inputs = {0};
  add_fixed_inputs(&inputs);
  add_random_inputs(&inputs, samples_per_stratum);
  sort_and_deduplicate(&inputs);

  OracleCase *cases = malloc(inputs.length * sizeof(*cases));
  if (cases == NULL) {
    die("out of memory while producing oracle cases");
  }

  mpfr_t value;
  mpfr_init2(value, 53);
  for (size_t i = 0; i < inputs.length; ++i) {
    cases[i] = (OracleCase){
        .input_bits = inputs.items[i].input_bits,
        .exponent = inputs.items[i].exponent,
        .expected_bits = oracle_bits(value, inputs.items[i].input_bits,
                                     inputs.items[i].exponent),
    };
  }
  mpfr_clear(value);

  emit_header(samples_per_stratum, inputs.length);
  emit_cases(cases, inputs.length);
  emit_tests();

  free(cases);
  free(inputs.items);
  return EXIT_SUCCESS;
}
