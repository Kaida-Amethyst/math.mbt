///|
/// Returns `sqrt(x * x + y * y)` as an IEEE 754 binary32 value without
/// spurious intermediate overflow or underflow.
///
/// ## Domain and special values
///
/// - The result is nonnegative and independent of the signs and order of the
///   inputs.
/// - If either input is infinite, positive infinity is returned even when the
///   other input is NaN.
/// - Otherwise, a NaN input produces NaN; no NaN payload is promised.
/// - Any combination of positive and negative zero produces positive zero.
/// - Subnormal inputs and results are supported. A finite exact result that
///   overflows binary32 produces positive infinity.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For finite inputs whose correctly rounded result is finite, the result is
/// within 1 ULP of the exact hypotenuse rounded to binary32 with
/// round-to-nearest, ties-to-even. Overflow classification is exact. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 36,470-pair fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, exponent gaps, Pythagorean
/// triples, and normal/subnormal and overflow transitions. An enlarged audit
/// covers 179,796 pairs; both observed a maximum error of 0 ULP. The fixed
/// corpus passes in debug and release mode on wasm, wasm-gc, JavaScript, and native.
/// Symmetry, sign invariance, and the lower bound by either input magnitude are
/// also checked. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/hypotf/README.md) for the corpus
/// design, the MoonBit Core comparison, and reproduction commands.
///
/// ## References
///
/// - Special-value and range-error behavior follows
///   [POSIX `hypot`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/hypot.html).
/// - [MoonBit Core `math.hypotf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/algebraic.mbt)
///   is checked as an ecosystem comparison; known accuracy and overflow-boundary
///   differences are recorded by the oracle documentation.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(hypotf(3.0, 4.0), 5.0)
///   assert_eq(hypotf(5.0, 12.0), 13.0)
/// }
/// ```
pub fn hypotf(x : Float, y : Float) -> Float {
  let x = x.abs()
  let y = y.abs()
  if x.is_inf() || y.is_inf() {
    return @float.infinity
  }
  let x = x.to_double()
  let y = y.to_double()
  Float::from_double((x * x + y * y).sqrt())
}

///|
test "hypotf handles zeros, non-finite values, and overflow" {
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  let near_overflow = Float::reinterpret_from_uint(0x7f3504f3U)
  assert_eq(hypotf(negative_zero, negative_zero).reinterpret_as_uint(), 0U)
  assert_eq(hypotf(@float.infinity, quiet_nan), @float.infinity)
  assert_eq(hypotf(quiet_nan, @float.neg_infinity), @float.infinity)
  assert_true(hypotf(quiet_nan, 1.0).is_nan())
  assert_true(hypotf(1.0, quiet_nan).is_nan())
  assert_eq(hypotf(near_overflow, near_overflow), @float.infinity)
}

///|
test "hypotf covers exact triples, subnormals, and a widening regression" {
  assert_eq(hypotf(3.0, 4.0), 5.0)
  assert_eq(hypotf(-5.0, 12.0), 13.0)
  let minimum_subnormal = Float::reinterpret_from_uint(0x00000001U)
  assert_eq(
    hypotf(minimum_subnormal, minimum_subnormal).reinterpret_as_uint(),
    0x00000001U,
  )
  let regression_x = Float::reinterpret_from_uint(0x04eca996U)
  let regression_y = Float::reinterpret_from_uint(0x003f7d1dU)
  assert_eq(
    hypotf(regression_x, regression_y).reinterpret_as_uint(),
    0x04eca99fU,
  )
}
