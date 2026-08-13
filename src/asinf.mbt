///|
/// Returns the arcsine of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Inputs outside `[-1.0, 1.0]`, including both infinities, produce NaN.
/// - Positive and negative zero are returned unchanged.
/// - Inputs `1.0` and `-1.0` produce positive and negative π/2.
/// - Subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in `[-1.0, 1.0]`, the result is within 1 ULP of the
/// exact arcsine rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 28,410-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every signed exponent boundary, the domain endpoints,
/// implementation transitions at `2^-12` and `0.5`, and fixed-seed stratified
/// inputs. It checks monotonicity and bit-exact odd symmetry over the real domain
/// and passes in debug and release mode on wasm, wasm-gc, JavaScript, and native,
/// with a maximum observed error of 1 ULP; MoonBit Core is checked against the
/// same independent reference. This is testing evidence, not a formal proof. See
/// the
/// [oracle documentation](../tools/oracle/asinf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The endpoint reduction and rational approximation are derived from the
///   FreeBSD msun
///   [`e_asinf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_asinf.c)
///   implementation distributed by OpenLibm.
/// - The public behavior is compatible with
///   [MoonBit Core `math.asinf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(asinf(0.0), 0.0)
///   assert_eq(asinf(1.0).reinterpret_as_uint(), 0x3fc90fdbU)
/// }
/// ```
pub fn asinf(input : Float) -> Float {
  let pi_over_two : Double = 1.570796326794896558e+00
  let coefficient0 : Float = 1.6666586697e-01
  let coefficient1 : Float = -4.2743422091e-02
  let coefficient2 : Float = -8.6563630030e-03
  let denominator_coefficient : Float = -7.0662963390e-01
  fn remainder(square : Float) -> Float {
    let numerator = square *
      (coefficient0 + square * (coefficient1 + square * coefficient2))
    numerator / (1.0 + square * denominator_coefficient)
  }

  let raw_bits = input.reinterpret_as_uint()
  let magnitude = raw_bits & 0x7fffffffU
  if magnitude >= 0x3f800000U {
    if magnitude == 0x3f800000U {
      return Float::from_double(input.to_double() * pi_over_two)
    }
    return @float.not_a_number
  }
  if magnitude < 0x3f000000U {
    if magnitude < 0x39800000U {
      return input
    }
    let square = input * input
    return input + input * remainder(square)
  }
  let half_distance = ((1.0 : Float) - input.abs()) * 0.5
  let root = half_distance.to_double().sqrt()
  let correction = remainder(half_distance).to_double()
  let result = Float::from_double(
    pi_over_two - 2.0 * (root + root * correction),
  )
  if raw_bits >> 31 != 0U {
    -result
  } else {
    result
  }
}

///|
test "asinf handles its domain, endpoints, and signed zero" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(asinf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(asinf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(asinf(1.0).reinterpret_as_uint(), 0x3fc90fdbU)
  assert_eq(asinf(-1.0).reinterpret_as_uint(), 0xbfc90fdbU)
  assert_true(asinf(Float::reinterpret_from_uint(0x3f800001U)).is_nan())
  assert_true(asinf(Float::reinterpret_from_uint(0xbf800001U)).is_nan())
  assert_true(asinf(@float.infinity).is_nan())
  assert_true(asinf(@float.neg_infinity).is_nan())
  assert_true(asinf(quiet_nan).is_nan())
}

///|
test "asinf preserves tiny inputs and covers the half transition" {
  let tiny_positive = Float::reinterpret_from_uint(0x397fffffU)
  let tiny_negative = Float::reinterpret_from_uint(0xb97fffffU)
  assert_eq(asinf(tiny_positive).reinterpret_as_uint(), 0x397fffffU)
  assert_eq(asinf(tiny_negative).reinterpret_as_uint(), 0xb97fffffU)
  assert_eq(asinf(0.5).reinterpret_as_uint(), 0x3f060a92U)
  assert_eq(asinf(-0.5).reinterpret_as_uint(), 0xbf060a92U)
}
