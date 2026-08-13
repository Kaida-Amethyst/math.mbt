///|
/// Returns the hyperbolic cosine of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce positive infinity.
/// - Positive and negative zero produce exactly `1.0`.
/// - Overflow produces positive infinity.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact hyperbolic
/// cosine rounded to binary32 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 12,832-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, implementation branches, analytic overflow transitions,
/// and fixed-seed stratified inputs. Its maximum observed error is 1 ULP. The
/// corpus passes in debug and release mode on wasm, wasm-gc, JavaScript, and
/// native; MoonBit Core is checked against the same bound. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/coshf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from the FreeBSD msun
///   [`coshf.c`](https://github.com/ifduyue/musl/blob/f21a96538f78fa8e2040831b4209b35f2fb581da/src/math/coshf.c)
///   implementation distributed by musl.
/// - The public behavior is compatible with
///   [MoonBit Core `math.coshf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/hyperbolic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(coshf(0.0), 1.0)
///   assert_eq(coshf(@float.infinity), @float.infinity)
///   assert_eq(coshf(@float.neg_infinity), @float.infinity)
/// }
/// ```
pub fn coshf(input : Float) -> Float {
  let bits = input.reinterpret_as_uint() & 0x7fffffff
  let x = Float::reinterpret_from_uint(bits)
  if bits < 0x3f317217 {
    if bits < 0x3f800000U - (12U << 23) {
      return 1.0
    }
    let t = expm1f(x)
    return (1.0 : Float) + t * t / ((2.0 : Float) * (t + 1.0))
  }
  if bits < 0x42b17217 {
    let t = expf(x)
    return (t + (1.0 : Float) / t) * 0.5
  }
  k_expo2f(x)
}

///|
test "coshf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(coshf(positive_zero).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(coshf(negative_zero).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(coshf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(coshf(@float.neg_infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(coshf(quiet_nan).is_nan())
  assert_true(coshf(signaling_nan).is_nan())
}

///|
test "coshf rounds tiny inputs to one" {
  let maximum_subnormal = Float::reinterpret_from_int(0x007fffff)
  let minimum_normal = Float::reinterpret_from_int(0x00800000)
  assert_eq(coshf(maximum_subnormal).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(coshf(minimum_normal).reinterpret_as_uint(), 0x3f800000U)
}
