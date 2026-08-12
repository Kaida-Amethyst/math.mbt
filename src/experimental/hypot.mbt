///|
/// Returns the square root of the sum of the squares of its arguments, hypot(x, y) = sqrt(x*x, y*y)
/// # Notes
///
/// `hypot` return the square root of the sum of the squares of its arguments, the formula is:
///
/// $$hypot(x) = \sqrt{x^2 + y^2}$$
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(hypot(3, 4), 5)
/// assert_eq(hypot(6, 8), 10)
/// assert_eq(hypot(5, 12), 13)
/// assert_eq(hypot(7, 24), 25)
/// assert_eq(hypot(3.14, -2.71), 4.147734321289154)
/// assert_eq(hypot(-3.14, 2.71), 4.147734321289154)
/// ```
///
/// # Accuracy
///
/// 2 ulps (units in the last place)
///
/// # Special cases
///
/// 1. If x or y is NaN, return NaN
/// 2. If x or y is inf, return +inf
pub fn hypot(x : Double, y : Double) -> Double {
  let x = fabs(x)
  let y = fabs(y)
  if isinf(x) || isinf(y) {
    return @double.infinity
  }
  let (x, y) = if y > x { (y, x) } else { (x, y) }
  if x * double_epsilon >= y {
    return x
  }
  let rat = y / x
  x * sqrt(1.0 + rat * rat)
}
