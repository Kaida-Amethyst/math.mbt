///| Compute hyperbolic sine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(sinh(-0.5), -0.5210953054937474)
/// assert_eq!(sinh(0.0), 0.0)
/// assert_eq!(sinh(0.5), 0.5210953054937474)
/// assert_eq!(sinh(1.0), 1.1752011936438014)
/// ```
///
/// # Special Cases
///
/// 1. sinh(NaN) = NaN
/// 2. sinh(+inf) = +inf
/// 3. sinh(-inf) = -inf
///
/// # Accuracy
///
/// 1 ulp.
pub fn sinh(x : Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let abs_x = fabs(x)
  let shuge = 1.0e307
  let h = if x < 0.0 { -0.5 } else { 0.5 }
  if ix < 0x40360000 {
    if ix < 0x3e300000 {
      if shuge + x > 1.0 {
        return x
      }
    }
    let t = expm1(abs_x)
    if ix < 0x3ff00000 {
      return h * (2.0 * t - t * t / (t + 1.0))
    }
    return h * (t + t / (t + 1.0))
  }
  if ix < 0x40862E42 {
    return h * exp(abs_x)
  }
  if abs_x.reinterpret_as_uint64() < 0x408633ce8fb9f87d {
    let w = exp(0.5 * abs_x)
    let t = h * w
    return t * w
  }
  x * shuge
}

test "sinh" {
  fn assert_sinh_ulp!(input, expect) {
    assert_ulp!(expect, sinh(input), SINH_MAX_ULP)
  }

  assert_sinh_ulp!(-0.8, -0.888105982187623)
  assert_sinh_ulp!(-0.7, -0.7585837018395334)
  assert_sinh_ulp!(-0.6, -0.6366535821482412)
  assert_sinh_ulp!(-0.5, -0.5210953054937474)
  assert_sinh_ulp!(-0.4, -0.4107523258028155)
  assert_sinh_ulp!(-0.3, -0.3045202934471426)
  assert_sinh_ulp!(-0.2, -0.20133600254109402)
  assert_sinh_ulp!(-0.1, -0.10016675001984403)
  assert_sinh_ulp!(-0, -0)
  assert_sinh_ulp!(-3.141592653589793, -11.548739357257748)
  assert_sinh_ulp!(-1.5707963267948966, -2.3012989023072947)
  assert_sinh_ulp!(-0.7853981633974483, -0.8686709614860095)
  assert_sinh_ulp!(0, 0)
  assert_sinh_ulp!(0.1, 0.10016675001984403)
  assert_sinh_ulp!(0.2, 0.20133600254109402)
  assert_sinh_ulp!(0.3, 0.3045202934471426)
  assert_sinh_ulp!(0.4, 0.4107523258028155)
  assert_sinh_ulp!(0.5, 0.5210953054937474)
  assert_sinh_ulp!(0.6, 0.6366535821482412)
  assert_sinh_ulp!(0.7, 0.7585837018395334)
  assert_sinh_ulp!(0.8, 0.888105982187623)
  assert_sinh_ulp!(0.9, 1.0265167257081753)
  assert_sinh_ulp!(1, 1.1752011936438014)
  assert_sinh_ulp!(3.141592653589793, 11.548739357257748)
  assert_sinh_ulp!(1.5707963267948966, 2.3012989023072947)
  assert_sinh_ulp!(0.7853981633974483, 0.8686709614860095)
  assert_sinh_ulp!(-1, -1.1752011936438014)
  assert_sinh_ulp!(-2, -3.626860407847019)
  assert_sinh_ulp!(-3, -10.017874927409903)
  assert_sinh_ulp!(-4, -27.28991719712775)
  assert_sinh_ulp!(-5, -74.20321057778875)
  assert_sinh_ulp!(-6, -201.71315737027922)
  assert_sinh_ulp!(-7, -548.3161232732465)
  assert_sinh_ulp!(-8, -1490.4788257895502)
  assert_sinh_ulp!(-9, -4051.54190208279)
  assert_sinh_ulp!(1, 1.1752011936438014)
  assert_sinh_ulp!(2, 3.626860407847019)
  assert_sinh_ulp!(3, 10.017874927409903)
  assert_sinh_ulp!(4, 27.28991719712775)
  assert_sinh_ulp!(5, 74.20321057778875)
  assert_sinh_ulp!(6, 201.71315737027922)
  assert_sinh_ulp!(7, 548.3161232732465)
  assert_sinh_ulp!(8, 1490.4788257895502)
  assert_sinh_ulp!(9, 4051.54190208279)
  assert_sinh_ulp!(10, 11013.232874703393)
  assert_sinh_ulp!(100, 13440585709080678000000000000000000000000000)
  assert_sinh_ulp!(1000, double_pos_inf)
  assert_sinh_ulp!(10000, double_pos_inf)
  assert_sinh_ulp!(2.5, 6.0502044810397875)
  assert_sinh_ulp!(3.4, 14.965363388718343)
  assert_sinh_ulp!(5.3, 100.16590919044238)
  assert_sinh_ulp!(6.2, 246.37350583131)
  assert_sinh_ulp!(7.1, 605.9831246938265)
  assert_sinh_ulp!(8.9, 3665.986701383534)
  assert_sinh_ulp!(9.8, 9016.872436188462)
  assert_sinh_ulp!(10.7, 22177.92755387645)
  assert_sinh_ulp!(101.6, 66571656819937820000000000000000000000000000)
  assert_sinh_ulp!(1.542, 2.2299880096162905)
  assert_sinh_ulp!(2.846, 8.580346334855408)
  assert_sinh_ulp!(7.881, 1323.2586883921372)
  assert_sinh_ulp!(3.772, 21.72195288914397)
  assert_sinh_ulp!(-1.542, -2.2299880096162905)
  assert_sinh_ulp!(-2.846, -8.580346334855408)
  assert_sinh_ulp!(-7.881, -1323.2586883921372)
  assert_sinh_ulp!(-3.772, -21.72195288914397)
  assert_sinh_ulp!(-1, -1.1752011936438014)
  assert_sinh_ulp!(0, 0)
  assert_sinh_ulp!(-0, -0)
  assert_sinh_ulp!(double_nan, double_nan)
  assert_sinh_ulp!(double_pos_inf, double_pos_inf)
  assert_sinh_ulp!(double_neg_inf, double_neg_inf)
}
