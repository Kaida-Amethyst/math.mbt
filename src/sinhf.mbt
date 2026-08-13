///|
fn k_expo2f(x : Float) -> Float {
  let k = 235
  let k_ln2 = Float::reinterpret_from_int(0x4322e3bc)
  let scale = Float::reinterpret_from_int((0x7f + k / 2) << 23)
  expf(x - k_ln2) * scale * scale
}

///|
/// Returns the hyperbolic sine of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity produces negative infinity.
/// - Positive and negative zero are returned unchanged.
/// - Overflow produces an infinity with the sign of `input`; tiny finite
///   inputs, including subnormals, are returned unchanged.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact hyperbolic
/// sine rounded to binary32 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 12,826-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, implementation branches, analytic overflow transitions,
/// and fixed-seed stratified inputs. Its maximum observed error is 2 ULP. The
/// corpus passes in debug and release mode on wasm, wasm-gc, JavaScript, and
/// native; MoonBit Core is checked against the same bound. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/sinhf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from the FreeBSD msun
///   [`sinhf.c`](https://github.com/ifduyue/musl/blob/f21a96538f78fa8e2040831b4209b35f2fb581da/src/math/sinhf.c)
///   implementation distributed by musl.
/// - The public behavior is compatible with
///   [MoonBit Core `math.sinhf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/hyperbolic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(sinhf(0.0), 0.0)
///   assert_eq(sinhf(@float.infinity), @float.infinity)
///   assert_eq(sinhf(@float.neg_infinity), @float.neg_infinity)
/// }
/// ```
pub fn sinhf(input : Float) -> Float {
  let mut half : Float = 0.5
  let mut bits = input.reinterpret_as_uint()
  if bits >> 31 != 0 {
    half = -half
  }
  bits = bits & 0x7fffffff
  let absolute = Float::reinterpret_from_uint(bits)
  if bits < 0x42b17217 {
    let t = expm1f(absolute)
    if bits < 0x3f800000 {
      if bits < 0x3f800000U - (12U << 23) {
        return input
      }
      return half * ((2.0 : Float) * t - t * t / (t + 1.0))
    }
    return half * (t + t / (t + 1.0))
  }
  half * k_expo2f(absolute) * 2.0
}

///|
test "sinhf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(sinhf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(sinhf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(sinhf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(sinhf(@float.neg_infinity).reinterpret_as_uint(), 0xff800000U)
  assert_true(sinhf(quiet_nan).is_nan())
  assert_true(sinhf(signaling_nan).is_nan())
}

///|
test "sinhf preserves minimum subnormal inputs" {
  let minimum_subnormal = Float::reinterpret_from_int(0x00000001)
  let negative_minimum_subnormal = Float::reinterpret_from_int(
    0x80000001U.reinterpret_as_int(),
  )
  assert_eq(
    sinhf(minimum_subnormal).reinterpret_as_uint(),
    minimum_subnormal.reinterpret_as_uint(),
  )
  assert_eq(
    sinhf(negative_minimum_subnormal).reinterpret_as_uint(),
    negative_minimum_subnormal.reinterpret_as_uint(),
  )
}
