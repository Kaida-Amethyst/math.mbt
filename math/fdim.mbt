///| Compute the positive difference between `x` and `y`.
///
/// Computes the positive difference between `x` and `y`, that is, if `x > y`, returns `x - y`, otherwise returns `0`.
///
/// 1. fdim(`x`, `y`) returns `x - y` if `x > y`
/// 2. fdim(`x`, `y`) returns `0` if `x <= y`
/// 3. fdim(`x`, `y`) returns `NaN` if `x` or `y` is `NaN`
pub fn fdim(x : Double, y : Double) -> Double {
  if isnan(x) || isnan(y) {
    double_nan
  } else if x > y {
    x - y
  } else {
    0.0
  }
}
