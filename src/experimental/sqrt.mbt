///|
/// Compute Square Root of a number
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(sqrt(0), 0);
/// assert_eq(sqrt(1), 1);
/// assert_eq(sqrt(2), 1.4142135623730951);
/// assert_eq(sqrt(3), 1.7320508075688772);
/// ```
///
/// # Special Cases
///
/// 1. sqrt(NaN) = NaN
/// 2. sqrt(x) = NaN if x < 0
/// 3. sqrt(+inf) = +inf
/// 4. sqrt(-inf) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn sqrt(x : Double) -> Double {
  x.sqrt()
}
