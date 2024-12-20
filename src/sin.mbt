///| Compute sine of double-precision floating-point number `x`.
pub fn sin(x : Double) -> Double {
  if Double::is_inf(x) || Double::is_nan(x) {
    double_nan
  } else {
    let mut sign = false
    let mut x_ = x
    if x_ < 0.0 {
      x_ = -x_
      sign = true
    }
    let mut j = (x_ * pi4).to_int64()
    if (j & 1L) == 1L {
      j += 1L
    }
    let y = j.to_double()
    j = j & 7L
    if j > 3L {
      sign = not(sign)
      j -= 4L
    }
    let z = x_ - y * pi4a - y * pi4b - y * pi4c
    let zz = z * z
    (if j == 1L || j == 2L {
      1.0 -
      0.5 * zz +
      zz *
      zz *
      (
        (
          (((cos_[0] * zz + cos_[1]) * zz + cos_[2]) * zz + cos_[3]) * zz +
          cos_[4]
        ) *
        zz +
        cos_[5]
      )
    } else {
      z +
      z *
      zz *
      (
        (
          (((sin_[0] * zz + sin_[1]) * zz + sin_[2]) * zz + sin_[3]) * zz +
          sin_[4]
        ) *
        zz +
        sin_[5]
      )
    }) *
    (if sign { -1.0 } else { 1.0 })
  }
}

test "sin" {
  fn assert_sin_ulp!(input, expect) {
    assert_ulp!(expect, sin(input), SIN_MAX_ULP);
  }
  assert_sin_ulp!(-0.8, -0.7173560908995228)
  assert_sin_ulp!(-0.7, -0.644217687237691)
  assert_sin_ulp!(-0.6, -0.5646424733950354)
  assert_sin_ulp!(-0.5, -0.479425538604203)
  assert_sin_ulp!(-0.4, -0.3894183423086505)
  assert_sin_ulp!(-0.3, -0.29552020666133955)
  assert_sin_ulp!(-0.2, -0.19866933079506122)
  assert_sin_ulp!(-0.1, -0.09983341664682815)
  assert_sin_ulp!(-0, -0)
  // assert_sin_ulp!(-3.141592653589793, -0.00000000000000012246467991473532)
  assert_sin_ulp!(-1.5707963267948966, -1)
  assert_sin_ulp!(-0.7853981633974483, -0.7071067811865475)
  assert_sin_ulp!(0, 0)
  assert_sin_ulp!(0.1, 0.09983341664682815)
  assert_sin_ulp!(0.2, 0.19866933079506122)
  assert_sin_ulp!(0.3, 0.29552020666133955)
  assert_sin_ulp!(0.4, 0.3894183423086505)
  assert_sin_ulp!(0.5, 0.479425538604203)
  assert_sin_ulp!(0.6, 0.5646424733950354)
  assert_sin_ulp!(0.7, 0.644217687237691)
  assert_sin_ulp!(0.8, 0.7173560908995228)
  assert_sin_ulp!(0.9, 0.7833269096274834)
  assert_sin_ulp!(1, 0.8414709848078965)
  // assert_sin_ulp!(3.141592653589793, 0.00000000000000012246467991473532)
  assert_sin_ulp!(1.5707963267948966, 1)
  assert_sin_ulp!(0.7853981633974483, 0.7071067811865475)
  assert_sin_ulp!(-1, -0.8414709848078965)
  assert_sin_ulp!(-2, -0.9092974268256817)
  assert_sin_ulp!(-3, -0.1411200080598672)
  assert_sin_ulp!(-4, 0.7568024953079282)
  assert_sin_ulp!(-5, 0.9589242746631385)
  assert_sin_ulp!(-6, 0.27941549819892586)
  assert_sin_ulp!(-7, -0.6569865987187891)
  assert_sin_ulp!(-8, -0.9893582466233818)
  assert_sin_ulp!(-9, -0.4121184852417566)
  assert_sin_ulp!(1, 0.8414709848078965)
  assert_sin_ulp!(2, 0.9092974268256817)
  assert_sin_ulp!(3, 0.1411200080598672)
  assert_sin_ulp!(4, -0.7568024953079282)
  assert_sin_ulp!(5, -0.9589242746631385)
  assert_sin_ulp!(6, -0.27941549819892586)
  assert_sin_ulp!(7, 0.6569865987187891)
  assert_sin_ulp!(8, 0.9893582466233818)
  assert_sin_ulp!(9, 0.4121184852417566)
  assert_sin_ulp!(10, -0.5440211108893698)
  assert_sin_ulp!(100, -0.5063656411097588)
  assert_sin_ulp!(1000, 0.8268795405320025)
  assert_sin_ulp!(10000, -0.30561438888825215)
  assert_sin_ulp!(2.5, 0.5984721441039565)
  assert_sin_ulp!(3.4, -0.2555411020268312)
  assert_sin_ulp!(5.3, -0.8322674422239013)
  assert_sin_ulp!(6.2, -0.0830894028174964)
  assert_sin_ulp!(7.1, 0.7289690401258759)
  assert_sin_ulp!(8.9, 0.5010208564578846)
  assert_sin_ulp!(9.8, -0.3664791292519284)
  assert_sin_ulp!(10.7, -0.9566350162701879)
  assert_sin_ulp!(101.6, 0.8767368169734758)
  assert_sin_ulp!(1.542, 0.9995854144315939)
  assert_sin_ulp!(2.846, 0.29130685125533545)
  assert_sin_ulp!(7.881, 0.9996350261518016)
  assert_sin_ulp!(3.772, -0.5894738561593084)
  assert_sin_ulp!(-1.542, -0.9995854144315939)
  assert_sin_ulp!(-2.846, -0.29130685125533545)
  assert_sin_ulp!(-7.881, -0.9996350261518016)
  assert_sin_ulp!(-3.772, 0.5894738561593084)
  assert_sin_ulp!(-1, -0.8414709848078965)
  assert_sin_ulp!(0, 0)
  assert_sin_ulp!(-0, -0)
  assert_sin_ulp!(double_nan, double_nan)
  assert_sin_ulp!(double_pos_inf, double_nan)
  assert_sin_ulp!(double_neg_inf, double_nan)
}
