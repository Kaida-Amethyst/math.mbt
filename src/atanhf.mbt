///|
/// Returns the inverse hyperbolic tangent of `input` as an IEEE 754 binary32
/// value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - An input of `1.0` produces positive infinity; `-1.0` produces negative
///   infinity.
/// - A finite input with absolute value greater than `1.0`, or either infinity,
///   produces NaN.
/// - Positive and negative zero are returned unchanged.
/// - Subnormal inputs are supported and retain their sign.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in the real domain, the result is within 1 ULP of
/// the exact inverse hyperbolic tangent rounded to binary32 with
/// round-to-nearest, ties-to-even. Correct rounding is not promised.
///
/// ## Verification
///
/// A 28,416-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, the real-domain boundary at absolute value `1`, every
/// exponent boundary, the implementation transitions at `2^-32` and `0.5`,
/// and fixed-seed stratified inputs. It checks monotonicity and bit-exact odd
/// symmetry over the real domain and passes in debug and release mode on wasm,
/// wasm-gc, JavaScript, and native; MoonBit Core is checked against the same
/// bound. The maximum observed error is 1 ULP. This is testing evidence, not a
/// formal proof. See the
/// [oracle documentation](../tools/oracle/atanhf/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The overflow-safe piecewise formulas are derived from musl
///   [`atanhf.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/atanhf.c?h=v1.2.5).
/// - The public behavior is compatible with
///   [MoonBit Core `math.atanhf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/hyperbolic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(atanhf(0.0), 0.0)
///   assert_eq(atanhf(1.0), @float.infinity)
///   assert_eq(atanhf(-1.0), @float.neg_infinity)
/// }
/// ```
pub fn atanhf(input : Float) -> Float {
  let bits = input.reinterpret_as_uint()
  let negative = bits >> 31 != 0
  let magnitude = bits & 0x7fffffff
  let absolute = Float::reinterpret_from_uint(magnitude)
  let result = if magnitude < 0x3f000000U {
    if magnitude < 0x2f800000U {
      absolute
    } else {
      log1pf(
        absolute * 2.0 + absolute * 2.0 * absolute / ((1.0 : Float) - absolute),
      ) *
      0.5
    }
  } else {
    log1pf(absolute / ((1.0 : Float) - absolute) * 2.0) * 0.5
  }
  if negative {
    -result
  } else {
    result
  }
}

///|
test "atanhf handles its domain and IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(atanhf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(atanhf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(atanhf(1.0).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(atanhf(-1.0).reinterpret_as_uint(), 0xff800000U)
  assert_true(atanhf(1.0000001).is_nan())
  assert_true(atanhf(-1.0000001).is_nan())
  assert_true(atanhf(@float.infinity).is_nan())
  assert_true(atanhf(@float.neg_infinity).is_nan())
  assert_true(atanhf(quiet_nan).is_nan())
}

///|
test "atanhf covers its branch and domain transitions" {
  let cases : Array[(UInt, UInt)] = [
    (0x2f7fffffU, 0x2f7fffffU),
    (0x2f800000U, 0x2f800000U),
    (0x3effffffU, 0x3f0c9f53U),
    (0x3f000000U, 0x3f0c9f54U),
    (0x3f7fffffU, 0x410aa123U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = Float::reinterpret_from_uint(input_bits)
    let actual_bits = atanhf(input).reinterpret_as_uint()
    let error = if actual_bits >= expected_bits {
      actual_bits - expected_bits
    } else {
      expected_bits - actual_bits
    }
    assert_true(error <= 1U)
    assert_eq(atanhf(-input).reinterpret_as_uint(), actual_bits | 0x80000000U)
  }
}
