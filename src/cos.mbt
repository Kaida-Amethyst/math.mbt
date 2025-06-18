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
/// 0 ulp.
pub fn cos(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = [0.0, 0.0]
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
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

///|
test "cos" {
  fn assert_cos_ulp(input, expect) raise {
    assert_ulp(expect, cos(input), COS_MAX_ULP)
  }

  assert_cos_ulp(-0.8, 0.6967067093471654)
  assert_cos_ulp(-0.7, 0.7648421872844885)
  assert_cos_ulp(-0.6, 0.8253356149096783)
  assert_cos_ulp(-0.5, 0.8775825618903728)
  assert_cos_ulp(-0.4, 0.9210609940028851)
  assert_cos_ulp(-0.3, 0.955336489125606)
  assert_cos_ulp(-0.2, 0.9800665778412416)
  assert_cos_ulp(-0.1, 0.9950041652780257)
  assert_cos_ulp(-3.141592653589793, -1)
  assert_cos_ulp(-1.5707963267948966, 6.123233995736766e-17)
  assert_cos_ulp(-0.7853981633974483, 0.7071067811865476)
  assert_cos_ulp(0.1, 0.9950041652780257)
  assert_cos_ulp(0.2, 0.9800665778412416)
  assert_cos_ulp(0.3, 0.955336489125606)
  assert_cos_ulp(0.4, 0.9210609940028851)
  assert_cos_ulp(0.5, 0.8775825618903728)
  assert_cos_ulp(0.6, 0.8253356149096783)
  assert_cos_ulp(0.7, 0.7648421872844885)
  assert_cos_ulp(0.8, 0.6967067093471654)
  assert_cos_ulp(0.9, 0.6216099682706644)
  assert_cos_ulp(1, 0.5403023058681398)
  assert_cos_ulp(3.141592653589793, -1)
  assert_cos_ulp(1.5707963267948966, 6.123233995736766e-17)
  assert_cos_ulp(0.7853981633974483, 0.7071067811865476)
  assert_cos_ulp(-1, 0.5403023058681398)
  assert_cos_ulp(-2, -0.4161468365471424)
  assert_cos_ulp(-3, -0.9899924966004454)
  assert_cos_ulp(-4, -0.6536436208636119)
  assert_cos_ulp(-5, 0.28366218546322625)
  assert_cos_ulp(-6, 0.9601702866503661)
  assert_cos_ulp(-7, 0.7539022543433046)
  assert_cos_ulp(-8, -0.14550003380861354)
  assert_cos_ulp(-9, -0.9111302618846769)
  assert_cos_ulp(1, 0.5403023058681398)
  assert_cos_ulp(2, -0.4161468365471424)
  assert_cos_ulp(3, -0.9899924966004454)
  assert_cos_ulp(4, -0.6536436208636119)
  assert_cos_ulp(5, 0.28366218546322625)
  assert_cos_ulp(6, 0.9601702866503661)
  assert_cos_ulp(7, 0.7539022543433046)
  assert_cos_ulp(8, -0.14550003380861354)
  assert_cos_ulp(9, -0.9111302618846769)
  assert_cos_ulp(10, -0.8390715290764524)
  assert_cos_ulp(100, 0.8623188722876839)
  assert_cos_ulp(1000, 0.562379076290703)
  assert_cos_ulp(10000, -0.9521553682590148)
  assert_cos_ulp(27185679891.54321, 0.9449751254247084)
  assert_cos_ulp(31415926535897.9323846, 0.9999992690101899)
  assert_cos_ulp(516974365183497.332244, 0.11170737916572826)
  assert_cos_ulp(2.5, -0.8011436155469337)
  assert_cos_ulp(3.4, -0.9667981925794611)
  assert_cos_ulp(5.3, 0.5543743361791608)
  assert_cos_ulp(6.2, 0.9965420970232175)
  assert_cos_ulp(7.1, 0.6845466664428066)
  assert_cos_ulp(8.9, -0.8654352092411123)
  assert_cos_ulp(9.800000000000001, -0.9304262721047533)
  assert_cos_ulp(10.7, -0.2912892817213455)
  assert_cos_ulp(101.6, 0.4809704291983219)
  assert_cos_ulp(1.542, 0.028792347171058365)
  assert_cos_ulp(2.846, -0.9566296662824658)
  assert_cos_ulp(7.881, -0.02701507894652548)
  assert_cos_ulp(3.772, -0.807787455278104)
  assert_cos_ulp(-1.542, 0.028792347171058365)
  assert_cos_ulp(-2.846, -0.9566296662824658)
  assert_cos_ulp(-7.881, -0.02701507894652548)
  assert_cos_ulp(-3.772, -0.807787455278104)
  assert_cos_ulp(-15749436813364.748916, -0.9797265387199456)
  assert_cos_ulp(0, 1)
  assert_cos_ulp(-0, 1)
  assert_cos_ulp(@double.not_a_number, @double.not_a_number)
  assert_cos_ulp(@double.infinity, @double.not_a_number)
  assert_cos_ulp(@double.neg_infinity, @double.not_a_number)
}
