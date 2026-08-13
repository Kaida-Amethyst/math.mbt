///|
/// Returns the hyperbolic tangent of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces exactly `1.0`.
/// - Negative infinity produces exactly `-1.0`.
/// - Positive and negative zero are returned unchanged.
/// - Tiny finite inputs may produce a subnormal result.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact hyperbolic
/// tangent rounded to binary32 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 12,727-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, implementation branches, analytic rounding transitions,
/// and fixed-seed stratified inputs. Its maximum observed error is 2 ULP. The
/// corpus passes in debug and release mode on wasm, wasm-gc, JavaScript, and
/// native; MoonBit Core is checked against the same bound. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/tanhf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from the FreeBSD msun
///   [`tanhf.c`](https://github.com/ifduyue/musl/blob/f21a96538f78fa8e2040831b4209b35f2fb581da/src/math/tanhf.c)
///   implementation distributed by musl.
/// - The public behavior is compatible with
///   [MoonBit Core `math.tanhf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/hyperbolic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(tanhf(0.0), 0.0)
///   assert_eq(tanhf(@float.infinity), 1.0)
///   assert_eq(tanhf(@float.neg_infinity), -1.0)
/// }
/// ```
pub fn tanhf(input : Float) -> Float {
  let mut bits = input.reinterpret_as_uint()
  let negative = bits >> 31 != 0
  bits = bits & 0x7fffffff
  let x = Float::reinterpret_from_uint(bits)
  let result = if bits > 0x3f0c9f54 {
    if bits > 0x41200000 {
      (1.0 : Float) + (0.0 : Float) / x
    } else {
      let t = expm1f(x * 2.0)
      (1.0 : Float) - (2.0 : Float) / (t + 2.0)
    }
  } else if bits > 0x3e82c578 {
    let t = expm1f(x * 2.0)
    t / (t + 2.0)
  } else if bits >= 0x00800000 {
    let t = expm1f(x * -2.0)
    -t / (t + 2.0)
  } else {
    x
  }
  if negative {
    -result
  } else {
    result
  }
}

///|
test "tanhf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(tanhf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(tanhf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(tanhf(@float.infinity).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(tanhf(@float.neg_infinity).reinterpret_as_uint(), 0xbf800000U)
  assert_true(tanhf(quiet_nan).is_nan())
  assert_true(tanhf(signaling_nan).is_nan())
}

///|
test "tanhf preserves minimum subnormal inputs" {
  let minimum_subnormal = Float::reinterpret_from_int(0x00000001)
  let negative_minimum_subnormal = Float::reinterpret_from_int(
    0x80000001U.reinterpret_as_int(),
  )
  assert_eq(
    tanhf(minimum_subnormal).reinterpret_as_uint(),
    minimum_subnormal.reinterpret_as_uint(),
  )
  assert_eq(
    tanhf(negative_minimum_subnormal).reinterpret_as_uint(),
    negative_minimum_subnormal.reinterpret_as_uint(),
  )
}
