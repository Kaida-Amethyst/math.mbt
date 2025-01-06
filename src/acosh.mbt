///| Return the inverse hyperbolic cosine of x.
/// # Introduction
///
/// Returns the inverse hyperbolic cosine of `x`, defined as the value `y` such that `x = cosh(y)`.
///
/// # Special cases
///
/// 1. If `x` is less than 1, the result is `NaN`.
/// 2. If `x` is `NaN`, the result is `NaN`.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
//  Method :
//  Based on 
//  	acosh(x) = log [ x + sqrt(x*x-1) ]
//  we have
//  	acosh(x) := log(x)+ln2,	if x is large; else
//  	acosh(x) := log(2x-1/(sqrt(x*x-1)+x)) if x>2; else
//  	acosh(x) := log1p(t+sqrt(2.0*t+t*t)); where t=x-1.
//  
//  Special cases:
//  acosh(x) is NaN with signal if x<1.
//  acosh(NaN) is NaN without signal.
//  
pub fn acosh(x: Double) -> Double {
  let one = 1.0
  let ln2 = 6.93147180559945286227e-01 // 0x3FE62E42, 0xFEFA39EF
  let hx = __hi(x).reinterpret_as_int()
  if x < 1.0 || isnan(x) {
    // x < 1
    return double_nan
  } else if x == 1.0 {
    return 0.0
  } else if ispinf(x) {
    return double_pos_inf
  } else if hx >= 0x41b00000 {
    // x > 2**28
    return log(x) + ln2
  } else if hx > 0x40000000 {
    // 2**28 > x > 2
    let t = x * x
    return log(2.0 * x - one / (x + sqrt(t - one)))
  } else {
    // 1 < x < 2
    let t = x - one
    return log1p(t + sqrt(2.0 * t + t * t))
  }
}

test "acosh" {
  fn assert_acosh_ulp!(input, expect) {
    assert_ulp!(expect, acosh(input), ACOSH_MAX_ULP);
  }
  assert_acosh_ulp!(-1, double_nan)
  assert_acosh_ulp!(-2, double_nan)
  assert_acosh_ulp!(-3, double_nan)
  assert_acosh_ulp!(-4, double_nan)
  assert_acosh_ulp!(-5, double_nan)
  assert_acosh_ulp!(-6, double_nan)
  assert_acosh_ulp!(-7, double_nan)
  assert_acosh_ulp!(-8, double_nan)
  assert_acosh_ulp!(-9, double_nan)
  assert_acosh_ulp!(1, 0)
  assert_acosh_ulp!(2, 1.3169578969248166)
  assert_acosh_ulp!(3, 1.762747174039086)
  assert_acosh_ulp!(4, 2.0634370688955608)
  assert_acosh_ulp!(5, 2.2924316695611777)
  assert_acosh_ulp!(6, 2.477888730288475)
  assert_acosh_ulp!(7, 2.6339157938496336)
  assert_acosh_ulp!(8, 2.7686593833135738)
  assert_acosh_ulp!(9, 2.8872709503576206)
  assert_acosh_ulp!(10, 2.993222846126381)
  assert_acosh_ulp!(100, 5.298292365610485)
  assert_acosh_ulp!(1000, 7.600902209541989)
  assert_acosh_ulp!(10000, 9.903487550036129)
  assert_acosh_ulp!(2.5, 1.5667992369724109)
  assert_acosh_ulp!(3.4, 1.8945590126722978)
  assert_acosh_ulp!(5.3, 2.351832816454804)
  assert_acosh_ulp!(6.2, 2.5111284516219943)
  assert_acosh_ulp!(7.1, 2.6482453267067454)
  assert_acosh_ulp!(8.9, 2.8760272423851934)
  assert_acosh_ulp!(9.8, 2.972916260933044)
  assert_acosh_ulp!(10.7, 3.0612001381589975)
  assert_acosh_ulp!(101.6, 5.314166496026017)
  assert_acosh_ulp!(1.542, 0.9990799125933574)
  assert_acosh_ulp!(2.846, 1.7066606669574687)
  assert_acosh_ulp!(7.881, 2.7535523517164964)
  assert_acosh_ulp!(3.772, 2.002699466791843)
  assert_acosh_ulp!(-1.542, double_nan)
  assert_acosh_ulp!(-2.846, double_nan)
  assert_acosh_ulp!(-7.881, double_nan)
  assert_acosh_ulp!(-3.772, double_nan)
  assert_acosh_ulp!(-1, double_nan)
  assert_acosh_ulp!(0, double_nan)
  assert_acosh_ulp!(-0, double_nan)
  assert_acosh_ulp!(double_nan, double_nan)
  assert_acosh_ulp!(double_pos_inf, double_pos_inf)
  assert_acosh_ulp!(double_neg_inf, double_nan)
}
