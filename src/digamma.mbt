///| digamma(x) computes the digamma function of x.
///
/// digamma defined as $\psi(x) = \frac{d}{dx} \log \Gamma(x)$
///
/// # Reference
///
/// `boost::special_functions::digamma`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(digamma(1.0), -0.5772156649015328);
/// assert_eq!(digamma(2.0), 0.422784335098467);
/// assert_eq!(digamma(-0.5), 0.036489973978576895);
/// ```
///
/// # Special Cases
///
/// 1. digamma(0) = -∞
/// 2. digamma(x) = nan for x < 0 and x is an integer
/// 3. digamma(inf) = inf
/// 4. digamma(-inf) = nan
/// 3. digamma(nan) = nan
///
/// # Accuracy
///
/// 1023 ulp.
pub fn digamma(x : Double) -> Double {
  let pi : Double = 3.14159265358979323846
  let pos_inf : Double = 0x7ff0_0000_0000_0000UL.reinterpret_as_double()
  let mut x = x
  if x == 0.0 {
    return copysign(pos_inf, -x)
  }
  let mut result = 0.0
  if x < 0.0 {
    let x_is_integer = x == x.trunc()
    if x_is_integer {
      return double_nan
    }
    let r = x - x.trunc()
    result = -pi / tan(pi * r)
    x = 1.0 - x
  }
  while x < 10.0 {
    result -= 1.0 / x
    x += 1.0
  }
  if x == 10.0 {
    return result + 2.25175258906672110764
  }
  let mut y = 0.0
  if x < 1.0e17 {
    let a = [
      8.33333333333333333333E-2, -2.10927960927960927961E-2, 7.57575757575757575758E-3,
      -4.16666666666666666667E-3, 3.96825396825396825397E-3, -8.33333333333333333333E-3,
      8.33333333333333333333E-2,
    ]
    let z = 1.0 / (x * x)
    let mut polevl_result = 0.0
    for i = 0; i <= 6; i = i + 1 {
      polevl_result = polevl_result * z + a[i]
    }
    y = z * polevl_result
  }
  log(x) - 0.5 / x - y + result
}

///|
test "digamma" {
  fn assert_digamma_ulp!(input, expect) {
    assert_ulp!(expect, digamma(input), DIGAMMA_MAX_ULP)
  }

  assert_digamma_ulp!(-0.8, -4.039039896592188)
  assert_digamma_ulp!(-0.7, -2.073952793628704)
  assert_digamma_ulp!(-0.6, -0.8947178779184495)
  assert_digamma_ulp!(-0.5, 0.0364899739785769)
  assert_digamma_ulp!(-0.4, 0.9593807861068102)
  assert_digamma_ulp!(-0.3, 2.113309779635399)
  assert_digamma_ulp!(-0.2, 4.034991433293861)
  assert_digamma_ulp!(-0.1, 9.245073050052952)
  assert_digamma_ulp!(-0, double_pos_inf)
  assert_digamma_ulp!(-3.141592653589793, 7.885952385385497)
  assert_digamma_ulp!(-1.570796326794897, 0.0268072380899067)
  assert_digamma_ulp!(-0.7853981633974483, -3.657242587377795)
  assert_digamma_ulp!(0, double_neg_inf)
  assert_digamma_ulp!(0.1, -10.42375494041108)
  assert_digamma_ulp!(0.2, -5.289039896592188)
  assert_digamma_ulp!(0.3, -3.502524222200133)
  assert_digamma_ulp!(0.4, -2.561384544585115)
  assert_digamma_ulp!(0.5, -1.963510026021423)
  assert_digamma_ulp!(0.6, -1.540619213893191)
  assert_digamma_ulp!(0.7, -1.220023553697935)
  assert_digamma_ulp!(0.8, -0.9650085667061385)
  assert_digamma_ulp!(0.9, -0.7549269499470515)
  assert_digamma_ulp!(1, -0.5772156649015328)
  assert_digamma_ulp!(3.141592653589793, 0.9772133079420071)
  assert_digamma_ulp!(1.570796326794897, 0.1006733764274022)
  assert_digamma_ulp!(0.7853981633974483, -0.9990655126841155)
  assert_digamma_ulp!(-1, double_nan)
  assert_digamma_ulp!(-2, double_nan)
  assert_digamma_ulp!(-3, double_nan)
  assert_digamma_ulp!(-4, double_nan)
  assert_digamma_ulp!(-5, double_nan)
  assert_digamma_ulp!(-6, double_nan)
  assert_digamma_ulp!(-7, double_nan)
  assert_digamma_ulp!(-8, double_nan)
  assert_digamma_ulp!(-9, double_nan)
  assert_digamma_ulp!(1, -0.5772156649015328)
  assert_digamma_ulp!(2, 0.422784335098467)
  assert_digamma_ulp!(3, 0.922784335098467)
  assert_digamma_ulp!(4, 1.2561176684318)
  assert_digamma_ulp!(5, 1.5061176684318)
  assert_digamma_ulp!(6, 1.7061176684318)
  assert_digamma_ulp!(7, 1.872784335098467)
  assert_digamma_ulp!(8, 2.01564147795561)
  assert_digamma_ulp!(9, 2.14064147795561)
  assert_digamma_ulp!(10, 2.251752589066721)
  assert_digamma_ulp!(100, 4.600161852738088)
  assert_digamma_ulp!(1000, 6.907255195648812)
  assert_digamma_ulp!(10000, 9.21029037114285)
  assert_digamma_ulp!(2.5, 0.7031566406452434)
  assert_digamma_ulp!(3.4, 1.069567836367265)
  assert_digamma_ulp!(5.3, 1.570410931624808)
  assert_digamma_ulp!(6.2, 1.74174182168953)
  assert_digamma_ulp!(7.1, 1.888022386658046)
  assert_digamma_ulp!(8.9, 2.128820766044583)
  assert_digamma_ulp!(9.800000000000001, 2.230495182536802)
  assert_digamma_ulp!(10.7, 2.322787537024018)
  assert_digamma_ulp!(101.6, 4.616114202447252)
  assert_digamma_ulp!(1.542, 0.07503762854823659)
  assert_digamma_ulp!(2.846, 0.8600612578163895)
  assert_digamma_ulp!(7.881, 1.999671515765365)
  assert_digamma_ulp!(3.772, 1.189232567530244)
  assert_digamma_ulp!(-1.542, 0.3066001878215694)
  assert_digamma_ulp!(-2.846, -4.767348874721767)
  assert_digamma_ulp!(-7.881, -5.881611053411542)
  assert_digamma_ulp!(-3.772, -2.154553439810062)
  assert_digamma_ulp!(-1, double_nan)
  assert_digamma_ulp!(0, double_neg_inf)
  assert_digamma_ulp!(-0, double_pos_inf)
  assert_digamma_ulp!(double_nan, double_nan)
  assert_digamma_ulp!(double_pos_inf, double_pos_inf)
  assert_digamma_ulp!(double_neg_inf, double_nan)
}
