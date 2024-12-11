
///| Restrict a value to a certain interval unless it is NaN.
///
/// Returns `max` if `x` is greater than `max`, and `min` if `self` is
/// less than `min`. Otherwise this returns `self`.
///
/// Note that this function returns NaN if the initial value was NaN as
/// well.
///
/// Note that if `min > max`, it will flip the `min` and `max` values.
///
/// # Special cases
///
/// If `x`, `min`, `max` one of them is NaN, the result is NaN.
///
/// # Examples
///
/// ```
/// assert!((-3.0f64).clamp(-3.0, -2.0, 1.0) == -2.0);
/// assert!((0.0f64).clamp(0.0, -2.0, 1.0) == 0.0);
/// assert!((2.0f64).clamp(2.0, -2.0, 1.0) == 1.0);
/// ```
pub fn clamp(x: Double, min: Double, max: Double) -> Double {
  let (min, max) = if min > max { (max, min) } else { (min, max) };
  if x < min {
    return min
  }
  if x > max {
    return max
  }
  x
}
