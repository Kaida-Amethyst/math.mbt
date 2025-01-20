///| Compute 2 raised to the power of x.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(exp2(-1), 0.5);
/// assert_eq!(exp2(-2), 0.25);
/// assert_eq!(exp2(-3), 0.125);
/// assert_eq!(exp2(-4), 0.0625);
/// assert_eq!(exp2(0), 1);
/// assert_eq!(exp2(1), 2);
/// assert_eq!(exp2(2), 4);
/// assert_eq!(exp2(3), 8);
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place)
///
/// # Special Cases
///
/// 1. exp2(+Inf) = +Inf
/// 2. exp2(-Inf) = 0
///.3. exp2(NaN) = NaN
pub fn exp2(x : Double) -> Double {
  pow(2.0, x)
}

test "exp2" {
  fn assert_exp2_ulp!(input, expect) {
    assert_ulp!(expect, exp2(input), EXP2_MAX_ULP)
  }

  assert_exp2_ulp!(-1, 0.5)
  assert_exp2_ulp!(-2, 0.25)
  assert_exp2_ulp!(-3, 0.125)
  assert_exp2_ulp!(-4, 0.0625)
  assert_exp2_ulp!(-5, 0.03125)
  assert_exp2_ulp!(-6, 0.015625)
  assert_exp2_ulp!(-7, 0.0078125)
  assert_exp2_ulp!(-8, 0.00390625)
  assert_exp2_ulp!(-9, 0.001953125)
  assert_exp2_ulp!(1, 2)
  assert_exp2_ulp!(2, 4)
  assert_exp2_ulp!(3, 8)
  assert_exp2_ulp!(4, 16)
  assert_exp2_ulp!(5, 32)
  assert_exp2_ulp!(6, 64)
  assert_exp2_ulp!(7, 128)
  assert_exp2_ulp!(8, 256)
  assert_exp2_ulp!(9, 512)
  assert_exp2_ulp!(10, 1024)
  assert_exp2_ulp!(100, 1267650600228229400000000000000)
  assert_exp2_ulp!(10000, double_pos_inf)
  assert_exp2_ulp!(2.5, 5.656854249492381)
  assert_exp2_ulp!(3.4, 10.556063286183154)
  assert_exp2_ulp!(5.3, 39.396621227037315)
  assert_exp2_ulp!(6.2, 73.51669471981025)
  assert_exp2_ulp!(7.1, 137.1870032046455)
  assert_exp2_ulp!(8.9, 477.7128916668455)
  assert_exp2_ulp!(9.8, 891.4437768152316)
  assert_exp2_ulp!(10.7, 1663.4929077375696)
  assert_exp2_ulp!(101.6, 3842798030625539400000000000000)
  assert_exp2_ulp!(1.542, 2.9119790979981732)
  assert_exp2_ulp!(2.846, 7.190041012888239)
  assert_exp2_ulp!(7.881, 235.73137848449025)
  assert_exp2_ulp!(3.772, 13.661083430259916)
  assert_exp2_ulp!(-1.542, 0.3434090583574056)
  assert_exp2_ulp!(-2.846, 0.13908126507310425)
  assert_exp2_ulp!(-7.881, 0.004242116626258961)
  assert_exp2_ulp!(-3.772, 0.07320063632617563)
  assert_exp2_ulp!(-1, 0.5)
  assert_exp2_ulp!(0, 1)
  assert_exp2_ulp!(-0, 1)
  assert_exp2_ulp!(double_nan, double_nan)
  assert_exp2_ulp!(double_pos_inf, double_pos_inf)
  assert_exp2_ulp!(double_neg_inf, 0)
}
