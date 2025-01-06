///| erfinv(x) computes the inverse error function of x.
///
/// # Special Cases
///
/// - erfinv(1) returns +inf
/// - erfinv(-1) returns -inf
/// - erfinv(x) returns NaN if x is outside the range [-1, 1]
/// - erfinv(NaN) returns NaN
/// - erfinv(+inf) returns NaN
/// - erfinv(-inf) returns NaN
pub fn erfinv(x: Double) -> Double {
    if x == 1.0 {
      return double_pos_inf
    }

    if x == -1.0 {
      return double_neg_inf
    }

    if x > 1.0 || x < -1.0 {
      return double_nan
    }

    if isnan(x) {
      return double_nan
    }

    let mut w = 0.0;
    let mut p = 0.0;
    let sign = if x > 0.0 { 1.0 } else { -1.0 };
    let x_abs = x.abs();

    w = -((1.0 - x_abs) * (1.0 + x_abs)).ln();

    if w < 6.250000 {
        w -= 3.125000;
        p = -3.6444120640178196996e-21;
        p = -1.685059138182016589e-19 + p * w;
        p = 1.2858480715256400167e-18 + p * w;
        p = 1.115787767802518096e-17 + p * w;
        p = -1.333171662854620906e-16 + p * w;
        p = 2.0972767875968561637e-17 + p * w;
        p = 6.6376381343583238325e-15 + p * w;
        p = -4.0545662729752068639e-14 + p * w;
        p = -8.1519341976054721522e-14 + p * w;
        p = 2.6335093153082322977e-12 + p * w;
        p = -1.2975133253453532498e-11 + p * w;
        p = -5.4154120542946279317e-11 + p * w;
        p = 1.051212273321532285e-09 + p * w;
        p = -4.1126339803469836976e-09 + p * w;
        p = -2.9070369957882005086e-08 + p * w;
        p = 4.2347877827932403518e-07 + p * w;
        p = -1.3654692000834678645e-06 + p * w;
        p = -1.3882523362786468719e-05 + p * w;
        p = 0.0001867342080340571352 + p * w;
        p = -0.00074070253416626697512 + p * w;
        p = -0.0060336708714301490533 + p * w;
        p = 0.24015818242558961693 + p * w;
        p = 1.6536545626831027356 + p * w;
    } else if w < 16.000000 {
        w = w.sqrt() - 3.250000;
        p = 2.2137376921775787049e-09;
        p = 9.0756561938885390979e-08 + p * w;
        p = -2.7517406297064545428e-07 + p * w;
        p = 1.8239629214389227755e-08 + p * w;
        p = 1.5027403968909827627e-06 + p * w;
        p = -4.013867526981545969e-06 + p * w;
        p = 2.9234449089955446044e-06 + p * w;
        p = 1.2475304481671778723e-05 + p * w;
        p = -4.7318229009055733981e-05 + p * w;
        p = 6.8284851459573175448e-05 + p * w;
        p = 2.4031110387097893999e-05 + p * w;
        p = -0.0003550375203628474796 + p * w;
        p = 0.00095328937973738049703 + p * w;
        p = -0.0016882755560235047313 + p * w;
        p = 0.0024914420961078508066 + p * w;
        p = -0.0037512085075692412107 + p * w;
        p = 0.005370914553590063617 + p * w;
        p = 1.0052589676941592334 + p * w;
        p = 3.0838856104922207635 + p * w;
    } else {
        w = w.sqrt() - 5.000000;
        p = -2.7109920616438573243e-11;
        p = -2.5556418169965252055e-10 + p * w;
        p = 1.5076572693500548083e-09 + p * w;
        p = -3.7894654401267369937e-09 + p * w;
        p = 7.6157012080783393804e-09 + p * w;
        p = -1.4960026627149240478e-08 + p * w;
        p = 2.9147953450901080826e-08 + p * w;
        p = -6.7711997758452339498e-08 + p * w;
        p = 2.2900482228026654717e-07 + p * w;
        p = -9.9298272942317002539e-07 + p * w;
        p = 4.5260625972231537039e-06 + p * w;
        p = -1.9681778105531670567e-05 + p * w;
        p = 7.5995277030017761139e-05 + p * w;
        p = -0.00021503011930044477347 + p * w;
        p = -0.00013871931833623122026 + p * w;
        p = 1.0103004648645343977 + p * w;
        p = 4.8499064014085844221 + p * w;
    }

    sign * p * x_abs
}


test "erfinv" {
  fn assert_erfinv_ulp!(input, expect) {
    assert_ulp!(expect, erfinv(input), ERFINV_MAX_ULP);
  }
  assert_erfinv_ulp!(-0.8, -0.9061938024368232)
  assert_erfinv_ulp!(-0.7, -0.7328690779592169)
  assert_erfinv_ulp!(-0.6, -0.5951160814499948)
  assert_erfinv_ulp!(-0.5, -0.4769362762044699)
  assert_erfinv_ulp!(-0.4, -0.37080715859355795)
  assert_erfinv_ulp!(-0.3, -0.2724627147267544)
  assert_erfinv_ulp!(-0.2, -0.1791434546212917)
  assert_erfinv_ulp!(-0.1, -0.08885599049425769)
  assert_erfinv_ulp!(-0, 0)
  assert_erfinv_ulp!(-0.7853981633974483, -0.8775270040652184)
  assert_erfinv_ulp!(0, 0)
  assert_erfinv_ulp!(0.1, 0.08885599049425769)
  assert_erfinv_ulp!(0.2, 0.1791434546212917)
  assert_erfinv_ulp!(0.3, 0.2724627147267544)
  assert_erfinv_ulp!(0.4, 0.37080715859355795)
  assert_erfinv_ulp!(0.5, 0.4769362762044699)
  assert_erfinv_ulp!(0.6, 0.5951160814499948)
  assert_erfinv_ulp!(0.7, 0.7328690779592169)
  assert_erfinv_ulp!(0.8, 0.9061938024368232)
  assert_erfinv_ulp!(0.9, 1.1630871536766743)
  assert_erfinv_ulp!(3.141592653589793, double_nan)
  assert_erfinv_ulp!(1.5707963267948966, double_nan)
  assert_erfinv_ulp!(0.7853981633974483, 0.8775270040652184)
  assert_erfinv_ulp!(-1, double_neg_inf)
  assert_erfinv_ulp!(-2, double_nan)
  assert_erfinv_ulp!(1, double_pos_inf)
  assert_erfinv_ulp!(2, double_nan)
  assert_erfinv_ulp!(0, 0)
  assert_erfinv_ulp!(-0, 0)
  assert_erfinv_ulp!(double_nan, double_nan)
  assert_erfinv_ulp!(double_pos_inf, double_nan)
  assert_erfinv_ulp!(double_neg_inf, double_nan)
}
