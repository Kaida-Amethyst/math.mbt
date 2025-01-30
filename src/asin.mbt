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
pub fn asin(x: Double) -> Double {
  let huge = 1.0e+300;
  let pio4_hi =  7.85398163397448278999e-01
  let pio2_hi = 1.57079632679489655800;
  let pio2_lo = 6.12323399573676603587e-17;
  let ps0 = 1.66666666666666657415e-01;
  let ps1 = -3.25565818622400915405e-01;
  let ps2 = 2.01212532134862925881e-01;
  let ps3 = -4.00555345006794114027e-02;
  let ps4 = 7.91534994289814532176e-04;
  let ps5 = 3.47933107596021167570e-05;
  let qs1 = -2.40339491173441421878e+00;
  let qs2 = 2.02094576023350569471e+00;
  let qs3 = -6.88283971605453293030e-01;
  let qs4 = 7.70381505559019352791e-02;

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff;
  let absx = fabs(x);
  if absx >= 1.0 {
    if absx == 1.0 {
      return x * pio2_hi + x * pio2_lo;
    } else {
      return @double.not_a_number;
    }
  } else if absx < 0.5 {
    if ix < 0x3e400000 {
      if huge + x > 1.0 {
        return x;
      }
    } else {
      let t = x * x;
      let p = t * (ps0 + t * (ps1 + t * (ps2 + t * (ps3 + t * (ps4 + t * ps5)))));
      let q = 1.0 + t * (qs1 + t * (qs2 + t * (qs3 + t * qs4)));
      let w = p / q;
      return x + x * w;
    }
  }

  let w = 1.0 - absx;
  let t = w * 0.5;
  let p = t * (ps0 + t * (ps1 + t * (ps2 + t * (ps3 + t * (ps4 + t * ps5)))));
  let q = 1.0 + t * (qs1 + t * (qs2 + t * (qs3 + t * qs4)));
  let s = sqrt(t);
  if ix >= 0x3FEF3333 {
    let w = p / q;
    let t = pio2_hi - (2.0 * (s + s * w) - pio2_lo);
    return if x > 0.0 { t } else { -t };
  } else {
    let mut w = s;
    w = __combineW(__hi(w), 0);
    let c = (t - w * w) / (s + w);
    let r = p / q;
    let p = 2.0 * s * r - (pio2_lo - 2.0 * c);
    let q = pio4_hi - 2.0 * w;
    let t = pio4_hi - (p - q);
    return if x > 0.0 { t } else { -t };
  }
}

test "asin" {
    fn assert_asin_ulp!(input, expect) {
       assert_ulp!(expect, asin(input), ASIN_MAX_ULP);
    }
    assert_asin_ulp!(0, 0);
    assert_asin_ulp!(1, 1.5707963267948966);
    assert_asin_ulp!(2, @double.not_a_number);
    assert_asin_ulp!(3, @double.not_a_number);
    assert_asin_ulp!(0.12, 0.12028988239478806);
    assert_asin_ulp!(0.23, 0.23207768286271319);
    assert_asin_ulp!(0.34, 0.34691689752716176);
    assert_asin_ulp!(0.45, 0.4667653390472964);
    assert_asin_ulp!(0.56, 0.5943858000010622);
    assert_asin_ulp!(0.67, 0.7342087874533589);
    assert_asin_ulp!(0.78, 0.8946658172342352);
    assert_asin_ulp!(0.89, 1.0973451695228305);
    assert_asin_ulp!(0.9, 1.1197695149986342);
    assert_asin_ulp!(-0.87, -1.0552023205488061);
    assert_asin_ulp!(-0.76, -0.8633131150155536);
    assert_asin_ulp!(-0.65, -0.7075844367253556);
    assert_asin_ulp!(-0.54, -0.570437109399922);
    assert_asin_ulp!(-0.43, -0.444492776935819);
    assert_asin_ulp!(-0.32, -0.3257294872946302); // ulp = 1
    assert_asin_ulp!(-0.21, -0.2115749597580956);
    assert_asin_ulp!(-0.1, -0.1001674211615598);
    assert_asin_ulp!(0.12345, 0.12376573109305462);
    assert_asin_ulp!(0.23456, 0.2367659157944504);
    assert_asin_ulp!(0.34567, 0.35295270589447797);
    assert_asin_ulp!(0.45678, 0.47437213354283125);
    assert_asin_ulp!(0.56789, 0.6039401158198346);
    assert_asin_ulp!(0.6789, 0.7462634283531875);
    assert_asin_ulp!(0.78901, 0.9091959463091327);
    assert_asin_ulp!(0.89012, 1.097608417837682);
    assert_asin_ulp!(0.90123, 1.1225996009543824);
    assert_asin_ulp!(-0.98765, -1.4134717929906069);
    assert_asin_ulp!(-0.87654, -1.0686260295664562);
    assert_asin_ulp!(-0.76543, -0.8717092659157806);
    assert_asin_ulp!(-0.65432, -0.7132830584090974);
    assert_asin_ulp!(-0.54321, -0.5742556651342754);
    assert_asin_ulp!(-0.4321, -0.4468200910587503);  // ulp = 1
    assert_asin_ulp!(-0.32109, -0.32688020707396226);
    assert_asin_ulp!(-0.21098, -0.21257741888859172);
    assert_asin_ulp!(-0.10987, -0.11009225722376173);
    assert_asin_ulp!(1.234, @double.not_a_number);
    assert_asin_ulp!(1.7320508, @double.not_a_number);
    assert_asin_ulp!(0.5772157, 0.6153149053473578);
    assert_asin_ulp!(0.3010299, 0.30577246612266595);
    assert_asin_ulp!(0.6931472, 0.7658462217893365);
    assert_asin_ulp!(0.4342945, 0.4492549107723582);
    assert_asin_ulp!(0.0000001, 0.00000010000000000000017);
    assert_asin_ulp!(1000000000, @double.not_a_number);
    assert_asin_ulp!(31415926535897.1234, @double.not_a_number);
    assert_asin_ulp!(-27182818284590.5678, @double.not_a_number);
    assert_asin_ulp!(@double.max_value, @double.not_a_number);
    assert_asin_ulp!(@double.min_value, @double.not_a_number);
    assert_asin_ulp!(@double.infinity, @double.not_a_number);
    assert_asin_ulp!(@double.neg_infinity, @double.not_a_number);
    assert_asin_ulp!(@double.not_a_number, @double.not_a_number);
}
