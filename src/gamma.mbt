///|
const TWO_SQRT_E_OVER_PI : Double = 1.8603827342052657173362492472666631120594218414085755

///| Compute the gamma function of x.
pub fn tgamma(x : Double) -> Double {
  let gamma_r = 10.900511
  let gamma_dk = [
    2.48574089138753565546e-5, 1.05142378581721974210, -3.45687097222016235469, 4.51227709466894823700,
    -2.98285225323576655721, 1.05639711577126713077, -1.95428773191645869583e-1,
    1.70970543404441224307e-2, -5.71926117404305781283e-4, 4.63399473359905636708e-6,
    -2.71994908488607703910e-9,
  ]
  if x < 0.5 {
    let mut s = gamma_dk[0]
    for i = 1; i < gamma_dk.length(); i = i + 1 {
      s = s + gamma_dk[i] / (i.to_double() - x)
    }
    PI /
    (sinpi(x) * s * TWO_SQRT_E_OVER_PI * ((0.5 - x + gamma_r) / E).pow(0.5 - x))
  } else {
    let mut s = gamma_dk[0]
    for i = 1; i < gamma_dk.length(); i = i + 1 {
      s = s + gamma_dk[i] / (x + i.to_double() - 1.0)
    }
    s * TWO_SQRT_E_OVER_PI * pow((x - 0.5 + gamma_r) / E, x - 0.5)
  }
}

///| Compute the gamma function of x, alias for `tgamma`.
pub fn gamma(x : Double) -> Double {
  tgamma(x)
}

///|
const TGAMMA_MAX_ULP : Int = 541

test "tgamma" {
  fn assert_tgamma_ulp!(input, expect) {
    assert_ulp!(expect, tgamma(input), TGAMMA_MAX_ULP)
  }

  assert_tgamma_ulp!(-0.8, -5.738554639998505)
  assert_tgamma_ulp!(-0.7, -4.273669982410843)
  assert_tgamma_ulp!(-0.6, -3.69693257292948)
  assert_tgamma_ulp!(-0.5, -3.544907701811032)
  assert_tgamma_ulp!(-0.4, -3.722980622032042)
  assert_tgamma_ulp!(-0.3, -4.326851108825193)
  assert_tgamma_ulp!(-0.2, -5.821148568626517)
  assert_tgamma_ulp!(-0.1, -10.68628702119319)
  assert_tgamma_ulp!(-3.141592653589793, 1.015697144460219)
  assert_tgamma_ulp!(-1.570796326794897, 2.302490707537118)
  assert_tgamma_ulp!(-0.7853981633974483, -5.425310390867353)
  assert_tgamma_ulp!(0.1, 9.513507698668731)
  assert_tgamma_ulp!(0.2, 4.590843711998803)
  assert_tgamma_ulp!(0.3, 2.991568987687591)
  assert_tgamma_ulp!(0.4, 2.218159543757688)
  assert_tgamma_ulp!(0.5, 1.772453850905516)
  assert_tgamma_ulp!(0.6, 1.489192248812817)
  assert_tgamma_ulp!(0.7, 1.298055332647558)
  assert_tgamma_ulp!(0.8, 1.164229713725303)
  assert_tgamma_ulp!(0.9, 1.068628702119319)
  assert_tgamma_ulp!(1, 1)
  assert_tgamma_ulp!(3.141592653589793, 2.288037795340032)
  assert_tgamma_ulp!(1.570796326794897, 0.8905608903815393)
  assert_tgamma_ulp!(0.7853981633974483, 1.181043114925474)
  assert_tgamma_ulp!(1, 1)
  assert_tgamma_ulp!(2, 1)
  assert_tgamma_ulp!(3, 2)
  assert_tgamma_ulp!(4, 6)
  assert_tgamma_ulp!(5, 24)
  assert_tgamma_ulp!(6, 120)
  assert_tgamma_ulp!(7, 720)
  assert_tgamma_ulp!(8, 5040)
  assert_tgamma_ulp!(9, 40320)
  assert_tgamma_ulp!(10, 362880)
  assert_tgamma_ulp!(100, 9.332621544394415e+155)
  assert_tgamma_ulp!(2.5, 1.329340388179137)
  assert_tgamma_ulp!(3.4, 2.981206426810333)
  assert_tgamma_ulp!(5.3, 38.07797644995235)
  assert_tgamma_ulp!(6.2, 169.406099461723)
  assert_tgamma_ulp!(7.1, 868.9568588006398)
  assert_tgamma_ulp!(8.9, 32569.40492585501)
  assert_tgamma_ulp!(9.800000000000001, 231791.8799196757)
  assert_tgamma_ulp!(10.7, 1799844.078931372)
  assert_tgamma_ulp!(101.6, 1.486211638228605e+159)
  assert_tgamma_ulp!(1.542, 0.888309360094435)
  assert_tgamma_ulp!(2.846, 1.743366861718904)
  assert_tgamma_ulp!(7.881, 3968.913713991595)
  assert_tgamma_ulp!(3.772, 4.539900655157358)
  assert_tgamma_ulp!(double_nan, double_nan)
}
