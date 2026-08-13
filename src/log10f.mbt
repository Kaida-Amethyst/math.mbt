///|
/// Returns the base-10 logarithm of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Positive and negative zero produce negative infinity.
/// - A negative finite input or negative infinity produces NaN.
/// - `log10f(1.0)` is positive zero.
/// - Positive subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every positive finite input, the result is within 1 ULP of the exact
/// base-10 logarithm rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 27,188-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, argument-reduction boundaries,
/// powers of ten and their neighborhoods, and fixed-seed stratified inputs. It
/// verifies monotonicity and passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native, with a maximum observed error of 1 ULP. This is
/// testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/log10f/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from the FreeBSD msun
///   [`e_log10f.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_log10f.c)
///   implementation distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(log10f(1.0), 0.0)
///   assert_eq(log10f(1000.0), 3.0)
/// }
/// ```
pub fn log10f(input : Float) -> Float {
  let inverse_ln10_hi : Float = 4.3432617188e-01
  let inverse_ln10_lo : Float = -3.1689971365e-05
  let log10_2_hi : Float = 3.0102920532e-01
  let log10_2_lo : Float = 7.9034151668e-07
  let lg1 : Float = 0.66666662693
  let lg2 : Float = 0.40000972152
  let lg3 : Float = 0.28498786688
  let lg4 : Float = 0.24279078841
  let mut x = input
  let mut bits = x.reinterpret_as_uint()
  let mut exponent = 0
  if bits < 0x00800000U || bits >> 31 != 0U {
    if bits << 1 == 0U {
      return (-1.0 : Float) / (x * x)
    }
    if bits >> 31 != 0U {
      return (x - x) / 0.0
    }
    exponent -= 25
    x *= 0x1.0p25
    bits = x.reinterpret_as_uint()
  } else if bits >= 0x7f800000U {
    return x
  } else if bits == 0x3f800000U {
    return 0.0
  }
  bits += 0x3f800000U - 0x3f3504f3U
  exponent += (bits >> 23).reinterpret_as_int() - 0x7f
  bits = (bits & 0x007fffffU) + 0x3f3504f3U
  x = Float::reinterpret_from_uint(bits)
  let f = x - 1.0
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let first = w * (lg2 + w * lg4)
  let second = z * (lg1 + w * lg3)
  let remainder = second + first
  let half_square = f * f * 0.5
  let high_bits = (f - half_square).reinterpret_as_uint() & 0xfffff000U
  let high = Float::reinterpret_from_uint(high_bits)
  let low = f - high - half_square + s * (half_square + remainder)
  let float_exponent = Float::from_int(exponent)
  float_exponent * log10_2_lo +
  (low + high) * inverse_ln10_lo +
  low * inverse_ln10_hi +
  high * inverse_ln10_hi +
  float_exponent * log10_2_hi
}

///|
test "log10f handles its domain and IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(log10f(positive_zero).reinterpret_as_uint(), 0xff800000U)
  assert_eq(log10f(negative_zero).reinterpret_as_uint(), 0xff800000U)
  assert_eq(log10f(1.0).reinterpret_as_uint(), 0x00000000U)
  assert_eq(log10f(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(log10f(-1.0).is_nan())
  assert_true(log10f(@float.neg_infinity).is_nan())
  assert_true(log10f(quiet_nan).is_nan())
}

///|
test "log10f is exact at representative powers of ten" {
  let cases : Array[(Float, Float)] = [
    (0.01, -2.0),
    (0.1, -1.0),
    (10.0, 1.0),
    (100.0, 2.0),
    (1000.0, 3.0),
  ]
  for pair in cases {
    let (input, expected) = pair
    assert_eq(log10f(input), expected)
  }
}
