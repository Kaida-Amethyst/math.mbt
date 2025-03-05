///| Compute sin(pi*x) with high accuracy.
/// # Introduction
///
/// Compute sin(pi*x) with high accuracy.
///
/// # Accuracy
///
/// 1 ulp (1 bit error)
pub fn sinpi(x : Double) -> Double {
  if x < 0 {
    return -sinpi(-x)
  }
  if x < 0.5 {
    return sin(PI * x)
  }
  let mut invert = false
  let mut x = x
  if x < 1 {
    invert = true
    x = -x
  }
  let rem = floor(x)
  if fabs(floor(rem / 2) * 2 - rem) > double_epsilon {
    invert = not(invert)
  }
  let mut rem = x - rem
  if rem > 0.5 {
    rem = 1.0 - rem
  }
  if rem == 0.5 {
    return if invert { -1.0 } else { 1.0 }
  }
  let rem = sin(PI * rem)
  if invert {
    -rem
  } else {
    rem
  }
}

///|
test "sinpi" {
  fn assert_sin_pi_ulp!(input, expect) {
    assert_ulp!(expect, sinpi(input), SINPI_MAX_ULP)
  }

  assert_sin_pi_ulp!(-0.8, -0.587785252292473)
  assert_sin_pi_ulp!(-0.7, -0.8090169943749475)
  assert_sin_pi_ulp!(-0.6, -0.9510565162951536)
  assert_sin_pi_ulp!(-0.5, -1)
  assert_sin_pi_ulp!(-0.4, -0.9510565162951536)
  assert_sin_pi_ulp!(-0.3, -0.8090169943749475)
  assert_sin_pi_ulp!(-0.2, -0.5877852522924731)
  assert_sin_pi_ulp!(-0.1, -0.3090169943749475)
  assert_sin_pi_ulp!(-0, -0)
  assert_sin_pi_ulp!(-3.141592653589793, 0.4303012170000919)
  assert_sin_pi_ulp!(-1.570796326794897, 0.9753679720836315)
  assert_sin_pi_ulp!(-0.7853981633974483, -0.6242659526396991)
  assert_sin_pi_ulp!(0, 0)
  assert_sin_pi_ulp!(0.1, 0.3090169943749475)
  assert_sin_pi_ulp!(0.2, 0.5877852522924731)
  assert_sin_pi_ulp!(0.3, 0.8090169943749475)
  assert_sin_pi_ulp!(0.4, 0.9510565162951536)
  assert_sin_pi_ulp!(0.5, 1)
  assert_sin_pi_ulp!(0.6, 0.9510565162951536)
  assert_sin_pi_ulp!(0.7, 0.8090169943749475)
  assert_sin_pi_ulp!(0.8, 0.587785252292473)
  assert_sin_pi_ulp!(0.9, 0.3090169943749473)
  assert_sin_pi_ulp!(1, -0)
  assert_sin_pi_ulp!(3.141592653589793, -0.4303012170000919)
  assert_sin_pi_ulp!(1.570796326794897, -0.9753679720836315)
  assert_sin_pi_ulp!(0.7853981633974483, 0.6242659526396991)
  assert_sin_pi_ulp!(-1, 0)
  assert_sin_pi_ulp!(-2, -0)
  assert_sin_pi_ulp!(-3, 0)
  assert_sin_pi_ulp!(-4, -0)
  assert_sin_pi_ulp!(-5, 0)
  assert_sin_pi_ulp!(-6, -0)
  assert_sin_pi_ulp!(-7, 0)
  assert_sin_pi_ulp!(-8, -0)
  assert_sin_pi_ulp!(-9, 0)
  assert_sin_pi_ulp!(1, -0)
  assert_sin_pi_ulp!(2, 0)
  assert_sin_pi_ulp!(3, -0)
  assert_sin_pi_ulp!(4, 0)
  assert_sin_pi_ulp!(5, -0)
  assert_sin_pi_ulp!(6, 0)
  assert_sin_pi_ulp!(7, -0)
  assert_sin_pi_ulp!(8, 0)
  assert_sin_pi_ulp!(9, -0)
  assert_sin_pi_ulp!(10, 0)
  assert_sin_pi_ulp!(100, 0)
  assert_sin_pi_ulp!(1000, 0)
  assert_sin_pi_ulp!(10000, 0)
  assert_sin_pi_ulp!(2.5, 1)
  assert_sin_pi_ulp!(3.4, -0.9510565162951535)
  assert_sin_pi_ulp!(5.3, -0.8090169943749471)
  assert_sin_pi_ulp!(6.2, 0.5877852522924736)
  assert_sin_pi_ulp!(7.1, -0.3090169943749463)
  assert_sin_pi_ulp!(8.9, 0.3090169943749463)
  assert_sin_pi_ulp!(9.800000000000001, -0.5877852522924714)
  assert_sin_pi_ulp!(10.7, 0.8090169943749488)
  assert_sin_pi_ulp!(101.6, -0.9510565162951591)
  assert_sin_pi_ulp!(1.542, -0.9913076310695066)
  assert_sin_pi_ulp!(2.846, 0.4651510780774581)
  assert_sin_pi_ulp!(7.881, -0.3652017618915872)
  assert_sin_pi_ulp!(3.772, -0.656585755752957)
  assert_sin_pi_ulp!(-1.542, 0.9913076310695066)
  assert_sin_pi_ulp!(-2.846, -0.4651510780774581)
  assert_sin_pi_ulp!(-7.881, 0.3652017618915872)
  assert_sin_pi_ulp!(-3.772, 0.656585755752957)
  assert_sin_pi_ulp!(-1, 0)
  assert_sin_pi_ulp!(0, 0)
  assert_sin_pi_ulp!(-0, -0)
  assert_sin_pi_ulp!(double_nan, double_nan)
  assert_sin_pi_ulp!(double_pos_inf, double_nan)
  assert_sin_pi_ulp!(double_neg_inf, double_nan)
}
