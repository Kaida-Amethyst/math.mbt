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

static const uint64_t RANDOM_SEED = UINT64_C(0xbb67ae8584caa73b);
static const uint32_t F32_SIGN_MASK = UINT32_C(0x80000000);
static const uint32_t F32_EXPONENT_MASK = UINT32_C(0x7f800000);
static const uint32_t F32_FRACTION_MASK = UINT32_C(0x007fffff);

typedef struct {
  uint32_t input_bits;
  int32_t exponent;
} ScalbnfInput;

typedef struct {
  ScalbnfInput *items;
  size_t length;
  size_t capacity;
} InputSet;

typedef struct {
  uint32_t input_bits;
  int32_t exponent;
  uint32_t expected_bits;
} OracleCase;

static void die(const char *message) {
  fprintf(stderr, "scalbnf oracle: %s\n", message);
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

static void input_set_push(InputSet *set, uint32_t bits, int32_t exponent) {
  if (is_nan_bits(bits)) {
    return;
  }
  if (set->length == set->capacity) {
    size_t next_capacity = set->capacity == 0 ? 4096 : set->capacity * 2;
    ScalbnfInput *next = realloc(set->items, next_capacity * sizeof(*next));
    if (next == NULL) {
      die("out of memory while collecting inputs");
    }
    set->items = next;
    set->capacity = next_capacity;
  }
  set->items[set->length++] =
      (ScalbnfInput){.input_bits = bits, .exponent = exponent};
}

static int compare_inputs(const void *left, const void *right) {
  const ScalbnfInput *a = left;
  const ScalbnfInput *b = right;
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

static int floor_log2_fraction(uint32_t fraction) {
  int result = -1;
  while (fraction != 0) {
    fraction >>= 1;
    ++result;
  }
  return result;
}

static int binary32_ilogb(uint32_t bits) {
  uint32_t magnitude = bits & ~F32_SIGN_MASK;
  unsigned exponent_field = magnitude >> 23;
  if (exponent_field != 0) {
    return (int)exponent_field - 127;
  }
  return floor_log2_fraction(magnitude & F32_FRACTION_MASK) - 149;
}

static void add_transition_exponents(InputSet *set, uint32_t bits) {
  uint32_t magnitude = bits & ~F32_SIGN_MASK;
  if (magnitude == 0 || magnitude >= F32_EXPONENT_MASK) {
    return;
  }

  static const int output_exponents[] = {
      -151, -150, -149, -148, -127, -126, -125, 126, 127, 128,
  };
  int input_exponent = binary32_ilogb(bits);
  for (size_t i = 0;
       i < sizeof(output_exponents) / sizeof(output_exponents[0]); ++i) {
    int center = output_exponents[i] - input_exponent;
    for (int offset = -3; offset <= 3; ++offset) {
      input_set_push(set, bits, (int32_t)(center + offset));
    }
  }
}

static void add_fixed_inputs(InputSet *set) {
  static const uint32_t positive_inputs[] = {
      UINT32_C(0x00000000), /* zero */
      UINT32_C(0x00000001), /* minimum subnormal */
      UINT32_C(0x00000002),
      UINT32_C(0x00000003),
      UINT32_C(0x003fffff),
      UINT32_C(0x007ffffe),
      UINT32_C(0x007fffff), /* maximum subnormal */
      UINT32_C(0x00800000), /* minimum normal */
      UINT32_C(0x00800001),
      UINT32_C(0x00ffffff),
      UINT32_C(0x3e4ccccd), /* 0.2 */
      UINT32_C(0x3e800000), /* 0.25 */
      UINT32_C(0x3f000000), /* 0.5 */
      UINT32_C(0x3f7fffff),
      UINT32_C(0x3f800000), /* 1 */
      UINT32_C(0x3f800001),
      UINT32_C(0x3fc00000), /* 1.5 */
      UINT32_C(0x40000000), /* 2 */
      UINT32_C(0x40400000), /* 3 */
      UINT32_C(0x40490fdb), /* pi */
      UINT32_C(0x7e7fffff),
      UINT32_C(0x7f000000), /* 2^127 */
      UINT32_C(0x7f7ffffe),
      UINT32_C(0x7f7fffff), /* maximum finite */
      UINT32_C(0x7f800000), /* infinity */
  };
  static const int32_t fixed_exponents[] = {
      INT32_MIN, -1000000, -513, -512, -383, -382, -381, -332, -331,
      -330,      -329,     -230, -229, -228, -227, -152, -151, -150,
      -149,      -148,     -128, -127, -126, -125, -103, -102, -101,
      -25,       -24,      -23,  -1,   0,    1,    23,   24,   25,
      101,       102,      103,  125,  126,  127,  128,  129,  253,
      254,       255,      256,  380,  381,  382,  383,  512,  513,
      1000000,   INT32_MAX,
  };

  for (size_t input = 0;
       input < sizeof(positive_inputs) / sizeof(positive_inputs[0]); ++input) {
    uint32_t positive = positive_inputs[input];
    uint32_t negative = positive | F32_SIGN_MASK;
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

static uint32_t finite_random_bits(uint64_t *state) {
  uint32_t bits = (uint32_t)xorshift64star(state);
  if ((bits & F32_EXPONENT_MASK) == F32_EXPONENT_MASK) {
    bits ^= UINT32_C(0x00800000);
  }
  return bits;
}

static void add_random_inputs(InputSet *set, size_t samples_per_stratum) {
  uint64_t state = RANDOM_SEED;

  /* Uniform binary32 bit patterns with scaling exponents near the usable
     output range and the staged implementation branches. */
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint32_t bits = finite_random_bits(&state);
    int32_t exponent = (int32_t)(xorshift64star(&state) % 1027) - 513;
    input_set_push(set, bits, exponent);
  }

  /* Uniform binary32 exponent fields, with output exponents concentrated on
     normal/subnormal and finite/infinity transitions. */
  static const int targets[] = {
      -151, -150, -149, -148, -127, -126, -125, 126, 127, 128,
  };
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint64_t random = xorshift64star(&state);
    uint32_t sign = (uint32_t)random & F32_SIGN_MASK;
    uint32_t exponent_field =
        (uint32_t)(xorshift64star(&state) % UINT64_C(0xff)) << 23;
    uint32_t fraction =
        (uint32_t)xorshift64star(&state) & F32_FRACTION_MASK;
    uint32_t bits = sign | exponent_field | fraction;
    if ((bits & ~F32_SIGN_MASK) == 0) {
      bits |= 1;
    }
    int target = targets[i % (sizeof(targets) / sizeof(targets[0]))];
    int32_t exponent = (int32_t)(target - binary32_ilogb(bits));
    input_set_push(set, bits, exponent);
  }

  /* Full-width Int exponents verify that saturation does not overflow while
     still sampling arbitrary binary32 significands. */
  for (size_t i = 0; i < samples_per_stratum; ++i) {
    uint32_t bits = finite_random_bits(&state);
    int32_t exponent = (int32_t)xorshift64star(&state);
    input_set_push(set, bits, exponent);
  }
}

static uint32_t oracle_bits(mpfr_t value, uint32_t input_bits,
                            int32_t exponent) {
  uint32_t magnitude = input_bits & ~F32_SIGN_MASK;
  uint32_t sign = input_bits & F32_SIGN_MASK;

  if (magnitude == 0 || magnitude == F32_EXPONENT_MASK) {
    return input_bits;
  }
  if (exponent > 512) {
    return sign | F32_EXPONENT_MASK;
  }
  if (exponent < -512) {
    return sign;
  }

  mpfr_set_flt(value, bits_to_float(input_bits), MPFR_RNDN);
  mpfr_mul_2si(value, value, exponent, MPFR_RNDN);
  return float_to_bits(mpfr_get_flt(value, MPFR_RNDN));
}

static void emit_header(size_t samples_per_stratum, size_t case_count) {
  printf("// Code generated by tools/oracle/scalbnf/generate.c; DO NOT EDIT.\n");
  printf("// Oracle: MPFR %s, exact multiplication by 2^n, binary32 round-to-nearest ties-to-even.\n",
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
    printf("///|\nfn scalbnf_mpfr_cases_%zu() -> Array[(UInt, Int, UInt)] {\n",
           group);
    printf("  [\n");
    for (size_t i = start; i < end; ++i) {
      printf("    (0x%08" PRIx32 "U, %" PRId32 ", 0x%08" PRIx32 "U),\n",
             cases[i].input_bits, cases[i].exponent, cases[i].expected_bits);
    }
    printf("  ]\n");
    printf("}\n\n");
  }

  printf("///|\nfn scalbnf_mpfr_case_groups() -> Array[Array[(UInt, Int, UInt)]] {\n");
  printf("  [\n");
  for (size_t group = 0; group < group_count; ++group) {
    printf("    scalbnf_mpfr_cases_%zu(),\n", group);
  }
  printf("  ]\n");
  printf("}\n\n");
}

static void emit_tests(void) {
  printf("///|\n");
  printf("test \"scalbnf agrees exactly with the MPFR oracle\" {\n");
  printf("  for cases in scalbnf_mpfr_case_groups() {\n");
  printf("    for item in cases {\n");
  printf("      let (input_bits, exponent, expected_bits) = item\n");
  printf("      let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())\n");
  printf("      let actual_bits = @math.scalbnf(input, exponent).reinterpret_as_uint()\n");
  printf("      if actual_bits != expected_bits {\n");
  printf("        println(\n");
  printf("          \"scalbnf oracle mismatch: input_bits=\\{input_bits}, exponent=\\{exponent}, expected_bits=\\{expected_bits}, actual_bits=\\{actual_bits}\",\n");
  printf("        )\n");
  printf("        assert_true(false)\n");
  printf("      }\n");
  printf("    }\n");
  printf("  }\n");
  printf("}\n\n");

  printf("///|\n");
  printf("test \"scalbnf matches MoonBit Core over the oracle corpus\" {\n");
  printf("  for cases in scalbnf_mpfr_case_groups() {\n");
  printf("    for item in cases {\n");
  printf("      let (input_bits, exponent, _) = item\n");
  printf("      let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())\n");
  printf("      assert_eq(\n");
  printf("        @math.scalbnf(input, exponent).reinterpret_as_uint(),\n");
  printf("        @core_math.scalbnf(input, exponent).reinterpret_as_uint(),\n");
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

  if (FLT_RADIX != 2 || FLT_MANT_DIG != 24 || FLT_MAX_EXP != 128 ||
      sizeof(float) != sizeof(uint32_t)) {
    die("generator requires IEEE 754 binary32 float");
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
  mpfr_init2(value, 24);
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
