///|
/// Returns the square root of the sum of the squares of its arguments, hypot(x, y) = sqrt(x*x, y*y)
/// # Notes
///
/// `hypotf` return the square root of the sum of the squares of its arguments, the formula is:
///
/// $$hypot(x) = \sqrt{x^2 + y^2}$$
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(hypotf(3, 4), 5)
/// assert_eq(hypotf(6, 8), 10)
/// assert_eq(hypotf(5, 12), 13)
/// assert_eq(hypotf(7, 24), 25)
/// assert_eq(hypotf(3.14, -2.71), 4.147734642028809)
/// assert_eq(hypotf(-3.14, 2.71), 4.147734642028809)
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
pub fn hypotf(x : Float, y : Float) -> Float {
  let x = x.abs()
  let y = y.abs()
  if x.is_inf() || y.is_inf() {
    return @float.infinity
  }
  let (x, y) = if y > x { (y, x) } else { (x, y) }
  if x * FLOAT_EPSILON >= y {
    return x
  }
  let rat = y / x
  x * (rat * rat + 1.0).sqrt()
}
