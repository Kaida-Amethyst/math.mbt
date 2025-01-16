///| Compute cosine of double-precision floating-point number `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(cos(-1.0), 0.5403023058681398)
/// assert_eq!(cos(0.0), 1)
/// assert_eq!(cos(1.5707963267948966), 0.00000000000000006123233995736766)
/// assert_eq!(cos(3.141592653589793), -1)
/// assert_eq!(cos(10000), -0.9521553682590148)
/// ```
///
/// # Special Cases
///
/// 1. cos(+-inf) = NaN
/// 2. cos(NaN) = NaN
///
/// # Accuracy
///
/// 1 ulp.
pub fn cos(x: Double) -> Double {
  if isinf(x) || isnan(x) {
    return double_nan
  }

  let y = [0.0, 0.0]
  let z = 0.0

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff

  if ix <= 0x3fe921fb {
    return __kernel_cos(x, z)
  } else {
    let n = rem_pio2(x, y)
    match n & 3 {
      0 => __kernel_cos(y[0], y[1])
      1 => -__kernel_sin(y[0], y[1], 1)
      2 => -__kernel_cos(y[0], y[1])
      _ => __kernel_sin(y[0], y[1], 1)
    }
  }
}

test "cos" {
  fn assert_cos_ulp!(input, expect) {
    assert_ulp!(expect, cos(input), COS_MAX_ULP);
  }
  assert_cos_ulp!(-0.8, 0.6967067093471654)
  assert_cos_ulp!(-0.7, 0.7648421872844885)
  assert_cos_ulp!(-0.6, 0.8253356149096783)
  assert_cos_ulp!(-0.5, 0.8775825618903728)
  assert_cos_ulp!(-0.4, 0.9210609940028851)
  assert_cos_ulp!(-0.3, 0.955336489125606)
  assert_cos_ulp!(-0.2, 0.9800665778412416)
  assert_cos_ulp!(-0.1, 0.9950041652780258)
  assert_cos_ulp!(-0, 1)
  assert_cos_ulp!(-3.141592653589793, -1)
  assert_cos_ulp!(-1.5707963267948966, 0.00000000000000006123233995736766)
  assert_cos_ulp!(-0.7853981633974483, 0.7071067811865476)
  assert_cos_ulp!(0, 1)
  assert_cos_ulp!(0.1, 0.9950041652780258)
  assert_cos_ulp!(0.2, 0.9800665778412416)
  assert_cos_ulp!(0.3, 0.955336489125606)
  assert_cos_ulp!(0.4, 0.9210609940028851)
  assert_cos_ulp!(0.5, 0.8775825618903728)
  assert_cos_ulp!(0.6, 0.8253356149096783)
  assert_cos_ulp!(0.7, 0.7648421872844885)
  assert_cos_ulp!(0.8, 0.6967067093471654)
  assert_cos_ulp!(0.9, 0.6216099682706644)
  assert_cos_ulp!(1, 0.5403023058681398)
  assert_cos_ulp!(3.141592653589793, -1)
  assert_cos_ulp!(1.5707963267948966, 0.00000000000000006123233995736766)
  assert_cos_ulp!(0.7853981633974483, 0.7071067811865476)
  assert_cos_ulp!(-1, 0.5403023058681398)
  assert_cos_ulp!(-2, -0.4161468365471424)
  assert_cos_ulp!(-3, -0.9899924966004454)
  assert_cos_ulp!(-4, -0.6536436208636119)
  assert_cos_ulp!(-5, 0.28366218546322625)
  assert_cos_ulp!(-6, 0.960170286650366)
  assert_cos_ulp!(-7, 0.7539022543433046)
  assert_cos_ulp!(-8, -0.14550003380861354)
  assert_cos_ulp!(-9, -0.9111302618846769)
  assert_cos_ulp!(1, 0.5403023058681398)
  assert_cos_ulp!(2, -0.4161468365471424)
  assert_cos_ulp!(3, -0.9899924966004454)
  assert_cos_ulp!(4, -0.6536436208636119)
  assert_cos_ulp!(5, 0.28366218546322625)
  assert_cos_ulp!(6, 0.960170286650366)
  assert_cos_ulp!(7, 0.7539022543433046)
  assert_cos_ulp!(8, -0.14550003380861354)
  assert_cos_ulp!(9, -0.9111302618846769)
  assert_cos_ulp!(10, -0.8390715290764524)
  assert_cos_ulp!(100, 0.8623188722876839)
  assert_cos_ulp!(1000, 0.5623790762907029)
  assert_cos_ulp!(10000, -0.9521553682590148)
  assert_cos_ulp!(2.5, -0.8011436155469337)
  assert_cos_ulp!(3.4, -0.9667981925794611)
  assert_cos_ulp!(5.3, 0.5543743361791608)
  assert_cos_ulp!(6.2, 0.9965420970232175)
  assert_cos_ulp!(7.1, 0.6845466664428066)
  assert_cos_ulp!(8.9, -0.8654352092411123)
  assert_cos_ulp!(9.8, -0.9304262721047533)
  assert_cos_ulp!(10.7, -0.2912892817213455)
  assert_cos_ulp!(101.6, 0.4809704291983219)
  assert_cos_ulp!(1.542, 0.028792347171058365)
  assert_cos_ulp!(2.846, -0.9566296662824658)
  assert_cos_ulp!(7.881, -0.02701507894652548)
  assert_cos_ulp!(3.772, -0.807787455278104)
  assert_cos_ulp!(-1.542, 0.028792347171058365)
  assert_cos_ulp!(-2.846, -0.9566296662824658)
  assert_cos_ulp!(-7.881, -0.02701507894652548)
  assert_cos_ulp!(-3.772, -0.807787455278104)
  assert_cos_ulp!(-1, 0.5403023058681398)
  assert_cos_ulp!(0, 1)
  assert_cos_ulp!(-0, 1)
  assert_cos_ulp!(double_nan, double_nan)
  assert_cos_ulp!(double_pos_inf, double_nan)
  assert_cos_ulp!(double_neg_inf, double_nan)
}
