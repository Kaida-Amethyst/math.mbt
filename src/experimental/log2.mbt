///|
/// Compute the base-2 logarithm of a number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(log2(0.1), -3.321928094887362)
/// assert_eq(log2(1), 0)
/// assert_eq(log2(2), 1)
/// assert_eq(log2(3), 1.584962500721156)
/// ```
///
/// # Special Cases:
///
/// 1. log2(x) = NaN for all x < 0 (including -inf).
/// 2. log2(inf) = +inf.
/// 3. log2(0) = -inf
///
/// # Accuracy
///
/// 1 ulp.
pub fn log2(x : Double) -> Double {
  @core_math.log2(x)
}
