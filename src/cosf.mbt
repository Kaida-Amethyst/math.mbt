///|
/// Returns the cosine of `input` radians as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce NaN.
/// - Both positive and negative zero produce exactly `1.0`.
/// - Every finite result lies in `[-1.0, 1.0]`; subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact cosine
/// rounded to binary32 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 28,974-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, quadrant landmarks, the range
/// reduction transition at `142.90625`, and fixed-seed stratified inputs. An
/// enlarged 171,796-case audit also passed in native debug and release mode.
/// The fixed corpus checks bit-exact even symmetry and range and passes in debug
/// and release mode on wasm, wasm-gc, JavaScript, and native, with a maximum
/// observed error of 1 ULP; MoonBit Core is checked against the same independent
/// reference. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/cosf/README.md) for the corpus design,
/// maximum-error witness, and reproduction commands.
///
/// ## References
///
/// - The public behavior and implementation structure are compatible with
///   [MoonBit Core `math.cosf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Large arguments use an integer Payne–Hanek-style range reduction; reference
///   results are generated independently with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(cosf(0.0), 1.0)
///   assert_eq(cosf(1.0).reinterpret_as_uint(), 0x3f0a5140U)
/// }
/// ```
pub fn cosf(input : Float) -> Float {
  if input.is_nan() || input.is_inf() {
    return @float.not_a_number
  }
  if input == 0.0 {
    return 1.0
  }
  let (reduced, quadrant) = trig_reduce(input, COS_SWITCHOVER)
  sin_cos_core(reduced, quadrant + 1)
}

///|
test "cosf handles non-finite values and zeros" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(cosf(positive_zero), 1.0)
  assert_eq(cosf(negative_zero), 1.0)
  assert_true(cosf(@float.infinity).is_nan())
  assert_true(cosf(@float.neg_infinity).is_nan())
  assert_true(cosf(quiet_nan).is_nan())
}

///|
test "cosf covers quadrant landmarks and its range-reduction transition" {
  assert_eq(cosf(1.0).reinterpret_as_uint(), 0x3f0a5140U)
  assert_eq(
    cosf(Float::reinterpret_from_uint(0x3fc90fdbU)).reinterpret_as_uint(),
    0xb33bbd2eU,
  )
  assert_eq(cosf(Float::reinterpret_from_uint(0x40490fdbU)), -1.0)
  assert_eq(
    cosf(Float::reinterpret_from_uint(0x430ee800U)).reinterpret_as_uint(),
    0xbd144ea7U,
  )
}
