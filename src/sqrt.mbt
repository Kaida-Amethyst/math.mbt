///|
/// Returns the square root of `input` as an IEEE 754 binary64 value.
///
/// This function delegates directly to MoonBit's `Double::sqrt` operation.
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
/// This wrapper performs no arithmetic beyond `Double::sqrt`, so it introduces
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
/// - The operation is provided by MoonBit's built-in `Double::sqrt` API.
/// - Special-value behavior follows IEEE 754 square-root semantics as exposed
///   by the MoonBit runtime.
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(sqrt(4.0), 2.0)
///   assert_eq(sqrt(0.0), 0.0)
/// }
/// ```
pub fn sqrt(input : Double) -> Double {
  input.sqrt()
}

///|
test "sqrt handles IEEE 754 special values" {
  let positive_zero = 0x00000000_00000000UL.reinterpret_as_double()
  let negative_zero = 0x80000000_00000000UL.reinterpret_as_double()
  let minimum_subnormal = 0x00000000_00000001UL.reinterpret_as_double()
  let quiet_nan = 0x7ff80000_00000001UL.reinterpret_as_double()
  assert_eq(sqrt(positive_zero).reinterpret_as_uint64(), 0x00000000_00000000UL)
  assert_eq(sqrt(negative_zero).reinterpret_as_uint64(), 0x80000000_00000000UL)
  assert_true(sqrt(minimum_subnormal) > 0.0)
  assert_eq(
    sqrt(@double.infinity).reinterpret_as_uint64(),
    0x7ff00000_00000000UL,
  )
  assert_true(sqrt(-1.0).is_nan())
  assert_true(sqrt(@double.neg_infinity).is_nan())
  assert_true(sqrt(quiet_nan).is_nan())
}

///|
test "sqrt returns exact representable roots" {
  let cases : Array[(Double, Double)] = [
    (0.25, 0.5),
    (1.0, 1.0),
    (4.0, 2.0),
    (9.0, 3.0),
    (65536.0, 256.0),
  ]
  for pair in cases {
    let (input, expected) = pair
    assert_eq(
      sqrt(input).reinterpret_as_uint64(),
      expected.reinterpret_as_uint64(),
    )
  }
}
