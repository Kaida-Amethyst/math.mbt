///| Compute arcsine of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(asin(0), 0)
/// assert_eq!(asin(1), 1.5707963267948966)
/// assert_eq!(asin(-1), -1.5707963267948966)
/// ```
///
/// # Special Cases
///
/// 1. asin(NaN) = NaN
/// 2. asin(x) = NaN for all |x| > 1
///
/// # Accuracy
///
/// 1 ulp
pub fn asin(x : Double) -> Double {
  if isinf(x) {
    return double_nan
  }
  if isnan(x) || x == 0.0 {
    x
  } else {
    let x_ = x.abs()
    if x_ > 1.0 {
      double_nan
    } else {
      let temp = (1.0 - x_ * x_).sqrt()
      (if x > 0.7 { PI / 2.0 - satan(temp / x_) } else { satan(x_ / temp) }) *
      x.signum()
    }
  }
}

test "asin" {
  fn assert_asin_ulp!(input, expect) {
    assert_ulp!(expect, asin(input), ASIN_MAX_ULP);
  }
  assert_asin_ulp!(-0.8, -0.9272952180016123)
  assert_asin_ulp!(-0.7, -0.775397496610753)
  assert_asin_ulp!(-0.6, -0.6435011087932844)
  assert_asin_ulp!(-0.5, -0.5235987755982989)
  assert_asin_ulp!(-0.4, -0.41151684606748806)
  assert_asin_ulp!(-0.3, -0.3046926540153975)
  assert_asin_ulp!(-0.2, -0.2013579207903308)
  assert_asin_ulp!(-0.1, -0.1001674211615598)
  assert_asin_ulp!(-0, -0)
  assert_asin_ulp!(-3.141592653589793, double_nan)
  assert_asin_ulp!(-1.5707963267948966, double_nan)
  assert_asin_ulp!(-0.7853981633974483, -0.9033391107665127)
  assert_asin_ulp!(0, 0)
  assert_asin_ulp!(0.1, 0.1001674211615598)
  assert_asin_ulp!(0.2, 0.2013579207903308)
  assert_asin_ulp!(0.3, 0.3046926540153975)
  assert_asin_ulp!(0.4, 0.41151684606748806)
  assert_asin_ulp!(0.5, 0.5235987755982989)
  assert_asin_ulp!(0.6, 0.6435011087932844)
  assert_asin_ulp!(0.7, 0.775397496610753)
  assert_asin_ulp!(0.8, 0.9272952180016123)
  assert_asin_ulp!(0.9, 1.1197695149986342)
  assert_asin_ulp!(1, 1.5707963267948966)
  assert_asin_ulp!(3.141592653589793, double_nan)
  assert_asin_ulp!(1.5707963267948966, double_nan)
  assert_asin_ulp!(0.7853981633974483, 0.9033391107665127)
  assert_asin_ulp!(double_nan, double_nan)
  assert_asin_ulp!(double_pos_inf, double_nan)
  assert_asin_ulp!(double_neg_inf, double_nan)
}
