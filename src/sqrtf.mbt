///|
/// Returns the square root of `input` as an IEEE 754 binary32 value.
///
/// This function delegates directly to MoonBit's `Float::sqrt` operation.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - A negative finite input or negative infinity produces NaN.
/// - Positive and negative zero are returned unchanged.
/// - Positive subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// This wrapper performs no arithmetic beyond `Float::sqrt`, so it introduces
/// no additional rounding. Its accuracy is exactly that of the MoonBit runtime
/// operation on the selected backend.
///
/// ## Verification
///
/// Contract tests cover IEEE 754 special values, signed zero, subnormal input,
/// and exactly representable roots. The same wrapper and tests run in debug and
/// release mode on wasm, wasm-gc, JavaScript, and native. No independent oracle
/// or formal proof is claimed for this direct wrapper.
///
/// ## References
///
/// - The operation is provided by MoonBit's built-in `Float::sqrt` API.
/// - Special-value behavior follows IEEE 754 square-root semantics as exposed
///   by the MoonBit runtime.
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(sqrtf(4.0), 2.0)
///   assert_eq(sqrtf(0.0), 0.0)
/// }
/// ```
pub fn sqrtf(input : Float) -> Float {
  input.sqrt()
}

///|
test "sqrtf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let minimum_subnormal = Float::reinterpret_from_uint(0x00000001U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(sqrtf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(sqrtf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_true(sqrtf(minimum_subnormal) > 0.0)
  assert_eq(sqrtf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(sqrtf(-1.0).is_nan())
  assert_true(sqrtf(@float.neg_infinity).is_nan())
  assert_true(sqrtf(quiet_nan).is_nan())
}

///|
test "sqrtf returns exact representable roots" {
  let cases : Array[(Float, Float)] = [
    (0.25, 0.5),
    (1.0, 1.0),
    (4.0, 2.0),
    (9.0, 3.0),
    (65536.0, 256.0),
  ]
  for pair in cases {
    let (input, expected) = pair
    assert_eq(
      sqrtf(input).reinterpret_as_uint(),
      expected.reinterpret_as_uint(),
    )
  }
}
