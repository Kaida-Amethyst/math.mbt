// Method : 
// mathematically cosh(x) if defined to be (exp(x)+exp(-x))/2
// 1. Replace x by |x| (cosh(x) = cosh(-x)). 
// 2. 
// 	                                        [ exp(x) - 1 ]^2 
//     0        <= x <= ln2/2  :  cosh(x) := 1 + -------------------
// 		       			           2*exp(x)
// 
// 	                                  exp(x) +  1/exp(x)
//     ln2/2    <= x <= 22     :  cosh(x) := -------------------
// 		       			          2
//     22       <= x <= lnovft :  cosh(x) := exp(x)/2 
//     lnovft   <= x <= ln2ovft:  cosh(x) := exp(x/2)/2 * exp(x/2)
//     ln2ovft  <  x	    :  cosh(x) := huge*huge (overflow)
// 
// Special cases:
// cosh(x) is |x| if x is +INF, -INF, or NaN.
// only cosh(0)=1 is exact for finite x.

///| Compute hyperbolic cosine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(cosh(0), 1)
/// assert_eq!(cosh(1), 1.5430806348152437)
/// assert_eq!(cosh(2), 3.7621956910836314)
/// assert_eq!(cosh(3), 10.067661995777765)
/// assert_eq!(cosh(-1), 1.5430806348152437)
/// ```
///
/// # Special Cases
///
/// 1. cosh(x) is |x| if x is +INF, -INF, or NaN.
/// 2. Only cosh(0)=1 is exact for finite x.
///
/// # Accuracy
///
/// 0 ulp.
pub fn cosh(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if isinf(x) {
    return double_pos_inf
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  if ix < 0x3fd62e43 {
    let t = expm1(fabs(x))
    let w = 1.0 + t
    if ix < 0x3c800000 {
      return w
    }
    return 1.0 + t * t / (w + w)
  }
  if ix < 0x40360000 {
    let t = exp(fabs(x))
    return 0.5 * t + 0.5 / t
  }
  if ix < 0x40862E42 {
    return 0.5 * exp(fabs(x))
  }
  let lx = __low(x).reinterpret_as_int()
  if ix < 0x408633ce || (ix == 0x408633ce && lx <= 0x8fb9f87d) {
    let w = exp(0.5 * fabs(x))
    let t = 0.5 * w
    return t * w
  }
  double_pos_inf
}

///|
pub impl Floating for Double with cosh(self) -> Double {
  cosh(self)
}

///|
test "cosh" {
  fn assert_cosh_ulp!(input, expect) {
    assert_ulp!(expect, cosh(input), COSH_MAX_ULP)
  }

  assert_cosh_ulp!(-0.8, 1.3374349463048447)
  assert_cosh_ulp!(-0.7, 1.255169005630943)
  assert_cosh_ulp!(-0.6, 1.1854652182422676)
  assert_cosh_ulp!(-0.5, 1.1276259652063807)
  assert_cosh_ulp!(-0.4, 1.081072371838455)
  assert_cosh_ulp!(-0.3, 1.0453385141288605)
  assert_cosh_ulp!(-0.2, 1.020066755619076)
  assert_cosh_ulp!(-0.1, 1.0050041680558035)
  assert_cosh_ulp!(-0, 1)
  assert_cosh_ulp!(-3.141592653589793, 11.591953275521519)
  assert_cosh_ulp!(-1.5707963267948966, 2.5091784786580567)
  assert_cosh_ulp!(-0.7853981633974483, 1.3246090892520057)
  assert_cosh_ulp!(0, 1)
  assert_cosh_ulp!(0.1, 1.0050041680558035)
  assert_cosh_ulp!(0.2, 1.020066755619076)
  assert_cosh_ulp!(0.3, 1.0453385141288605)
  assert_cosh_ulp!(0.4, 1.081072371838455)
  assert_cosh_ulp!(0.5, 1.1276259652063807)
  assert_cosh_ulp!(0.6, 1.1854652182422676)
  assert_cosh_ulp!(0.7, 1.255169005630943)
  assert_cosh_ulp!(0.8, 1.3374349463048447)
  assert_cosh_ulp!(0.9, 1.4330863854487745)
  assert_cosh_ulp!(1, 1.5430806348152437)
  assert_cosh_ulp!(3.141592653589793, 11.591953275521519)
  assert_cosh_ulp!(1.5707963267948966, 2.5091784786580567)
  assert_cosh_ulp!(0.7853981633974483, 1.3246090892520057)
  assert_cosh_ulp!(-1, 1.5430806348152437)
  assert_cosh_ulp!(-2, 3.7621956910836314)
  assert_cosh_ulp!(-3, 10.067661995777765)
  assert_cosh_ulp!(-4, 27.308232836016487)
  assert_cosh_ulp!(-5, 74.20994852478785)
  assert_cosh_ulp!(-6, 201.7156361224559)
  assert_cosh_ulp!(-7, 548.317035155212)
  assert_cosh_ulp!(-8, 1490.479161252178)
  assert_cosh_ulp!(-9, 4051.5420254925943)
  assert_cosh_ulp!(1, 1.5430806348152437)
  assert_cosh_ulp!(2, 3.7621956910836314)
  assert_cosh_ulp!(3, 10.067661995777765)
  assert_cosh_ulp!(4, 27.308232836016487)
  assert_cosh_ulp!(5, 74.20994852478785)
  assert_cosh_ulp!(6, 201.7156361224559)
  assert_cosh_ulp!(7, 548.317035155212)
  assert_cosh_ulp!(8, 1490.479161252178)
  assert_cosh_ulp!(9, 4051.5420254925943)
  assert_cosh_ulp!(10, 11013.232920103324)
  assert_cosh_ulp!(100, 13440585709080678000000000000000000000000000)
  assert_cosh_ulp!(1000, double_pos_inf)
  assert_cosh_ulp!(10000, double_pos_inf)
  assert_cosh_ulp!(2.5, 6.132289479663686)
  assert_cosh_ulp!(3.4, 14.998736658678668)
  assert_cosh_ulp!(5.3, 100.17090078434929)
  assert_cosh_ulp!(6.2, 246.3755352619463)
  assert_cosh_ulp!(7.1, 605.9839497987498)
  assert_cosh_ulp!(8.9, 3665.986837772461)
  assert_cosh_ulp!(9.8, 9016.872491640062)
  assert_cosh_ulp!(10.7, 22177.92757642139)
  assert_cosh_ulp!(101.6, 66571656819937820000000000000000000000000000)
  assert_cosh_ulp!(1.542, 2.443940777316919)
  assert_cosh_ulp!(2.846, 8.638422496385937)
  assert_cosh_ulp!(7.881, 1323.2590662471498)
  assert_cosh_ulp!(3.772, 21.74495889437803)
  assert_cosh_ulp!(-1.542, 2.443940777316919)
  assert_cosh_ulp!(-2.846, 8.638422496385937)
  assert_cosh_ulp!(-7.881, 1323.2590662471498)
  assert_cosh_ulp!(-3.772, 21.74495889437803)
  assert_cosh_ulp!(-1, 1.5430806348152437)
  assert_cosh_ulp!(0, 1)
  assert_cosh_ulp!(-0, 1)
  assert_cosh_ulp!(double_nan, double_nan)
  assert_cosh_ulp!(double_pos_inf, double_pos_inf)
  assert_cosh_ulp!(double_neg_inf, double_pos_inf)
}
