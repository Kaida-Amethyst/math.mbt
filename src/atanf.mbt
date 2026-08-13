///|
/// Returns the arctangent of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce positive and negative π/2.
/// - Positive and negative zero are returned unchanged.
/// - Every finite input is in the real domain; subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact arctangent
/// rounded to binary32 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 29,197-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every signed exponent boundary, all implementation
/// transitions, and fixed-seed stratified inputs. It checks monotonicity and
/// bit-exact odd symmetry and passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native, with a maximum observed error of 1 ULP; MoonBit Core
/// is checked against the same independent reference. This is testing evidence,
/// not a formal proof. See the
/// [oracle documentation](../tools/oracle/atanf/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and polynomial approximation are derived from the
///   FreeBSD msun
///   [`s_atanf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_atanf.c)
///   implementation distributed by OpenLibm.
/// - The public behavior is compatible with
///   [MoonBit Core `math.atanf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(atanf(0.0), 0.0)
///   assert_eq(atanf(1.0).reinterpret_as_uint(), 0x3f490fdbU)
/// }
/// ```
pub fn atanf(input : Float) -> Float {
  let atan_high : ReadOnlyArray[Float] = [
    4.6364760399e-01, 7.8539812565e-01, 9.8279368877e-01, 1.5707962513e+00,
  ]
  let atan_low : ReadOnlyArray[Float] = [
    5.0121582440e-09, 3.7748947079e-08, 3.4473217170e-08, 7.5497894159e-08,
  ]
  let coefficients : ReadOnlyArray[Float] = [
    3.3333328366e-01, -1.9999158382e-01, 1.4253635705e-01, -1.0648017377e-01, 6.1687607318e-02,
  ]
  let raw_bits = input.reinterpret_as_int()
  let sign = raw_bits >> 31
  let magnitude = raw_bits & 0x7fffffff
  let mut reduction = 0
  let mut x = input
  if magnitude >= 0x4c800000 {
    if x.is_nan() {
      return x
    }
    let result = atan_high[3] + atan_low[3]
    return if sign != 0 { -result } else { result }
  }
  if magnitude < 0x3ee00000 {
    if magnitude < 0x39800000 {
      return x
    }
    reduction = -1
  } else {
    x = x.abs()
    if magnitude < 0x3f980000 {
      if magnitude < 0x3f300000 {
        reduction = 0
        x = (2.0 * x - 1.0) / (2.0 + x)
      } else {
        reduction = 1
        x = (x - 1.0) / (x + 1.0)
      }
    } else if magnitude < 0x401c0000 {
      reduction = 2
      x = (x - 1.5) / (1.0 + x * 1.5)
    } else {
      reduction = 3
      x = (-1.0 : Float) / x
    }
  }
  let square = x * x
  let fourth_power = square * square
  let odd_terms = square *
    (
      coefficients[0] +
      fourth_power * (coefficients[2] + fourth_power * coefficients[4])
    )
  let even_terms = fourth_power *
    (coefficients[1] + fourth_power * coefficients[3])
  if reduction < 0 {
    return x - x * (odd_terms + even_terms)
  }
  let result = atan_high[reduction] -
    (x * (odd_terms + even_terms) - atan_low[reduction] - x)
  if sign != 0 {
    -result
  } else {
    result
  }
}

///|
test "atanf handles IEEE 754 special values and signed zero" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(atanf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(atanf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(atanf(@float.infinity).reinterpret_as_uint(), 0x3fc90fdbU)
  assert_eq(atanf(@float.neg_infinity).reinterpret_as_uint(), 0xbfc90fdbU)
  assert_true(atanf(quiet_nan).is_nan())
}

///|
test "atanf preserves tiny inputs and representative values" {
  let tiny_positive = Float::reinterpret_from_uint(0x397fffffU)
  let tiny_negative = Float::reinterpret_from_uint(0xb97fffffU)
  assert_eq(atanf(tiny_positive).reinterpret_as_uint(), 0x397fffffU)
  assert_eq(atanf(tiny_negative).reinterpret_as_uint(), 0xb97fffffU)
  assert_eq(atanf(1.0).reinterpret_as_uint(), 0x3f490fdbU)
  assert_eq(atanf(-1.0).reinterpret_as_uint(), 0xbf490fdbU)
}

///|
test "atanf retains the low part of pi over two for large inputs" {
  let cases : Array[(UInt, UInt)] = [
    (0x4c7fffffU, 0x3fc90fdbU),
    (0x4c800000U, 0x3fc90fdbU),
    (0xcc800000U, 0xbfc90fdbU),
    (0xcc7fffffU, 0xbfc90fdbU),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    assert_eq(
      atanf(Float::reinterpret_from_uint(input_bits)).reinterpret_as_uint(),
      expected_bits,
    )
  }
}
