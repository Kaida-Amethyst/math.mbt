///| Compute arcsine of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(asinf(0), 0)
/// assert_eq!(asinf(1), 1.5707963267948966)
/// assert_eq!(asinf(-1), -1.5707963267948966)
/// ```
///
/// # Special Cases
///
/// 1. asinf(NaN) = NaN
/// 2. asinf(x) = NaN for all |x| > 1
///
/// # Accuracy
///
/// 1 ulp
pub fn asinf(x : Float) -> Float {
  let x1p120 = 0x3870000000000000UL.reinterpret_as_double()
  let pio2 : Double = 1.570796326794896558e+00

  // coefficients for R(x^2) */
  let ps0 : Float = 1.6666586697e-01
  let ps1 : Float = -4.2743422091e-02
  let ps2 : Float = -8.6563630030e-03
  let qs2 : Float = -7.0662963390e-01
  fn r(z : Float) -> Float {
    let p = z * (ps0 + z * (ps1 + z * ps2))
    let q = z * qs2 + 1.0
    p / q
  }

  let hx = x.reinterpret_as_uint()
  let ix = hx & 0x7fffffff
  if ix >= 0x3f800000 {
    if ix == 0x3f800000 {
      return (x.to_double() * pio2 + x1p120).to_float()
    }
    return @float.not_a_number // asin(|x|>1) is NaN */
  }
  if ix < 0x3f000000 {
    if ix is (0x00800000..=0x39800000) {
      return x
    }
    return x + x * r(x * x)
  }
  let z = ((1.0 : Float) - x.abs()) * 0.5
  let s = z.to_double().sqrt()
  let x = (pio2 - 2.0 * (s + s * r(z).to_double())).to_float()
  if hx >> 31 != 0 {
    -x
  } else {
    x
  }
}

///|
test "asinf" {
  fn assert_asinf_ulp(input, expect) raise {
    assert_float_ulp(expect, asinf(input), ASIN_F_MAX_ULP)
  }

  assert_asinf_ulp(-1, -1.5707963705062866)
  assert_asinf_ulp(1, 1.5707963705062866)
  assert_asinf_ulp(0.5, 0.5235987901687622)
  assert_asinf_ulp(-0.5, -0.5235987901687622)
  assert_asinf_ulp(0.25, 0.252680242061615)
  assert_asinf_ulp(-0.25, -0.252680242061615)
  assert_asinf_ulp(-0.125, -0.12532782554626465)
  assert_asinf_ulp(0.125, 0.12532782554626465)
  assert_asinf_ulp(0.0625, 0.06254076212644577)
  assert_asinf_ulp(-0.0625, -0.06254076212644577)
  assert_asinf_ulp(0.625, 0.6751315593719482)
  assert_asinf_ulp(-0.625, -0.6751315593719482)
  assert_asinf_ulp(0.75, 0.8480620980262756)
  assert_asinf_ulp(-0.75, -0.8480620980262756)
  assert_asinf_ulp(0.875, 1.065435767173767)
  assert_asinf_ulp(-0.875, -1.065435767173767)
  assert_asinf_ulp(0.9375, 1.2153751850128174)
  assert_asinf_ulp(-0.9375, -1.2153751850128174)
  assert_asinf_ulp(0.03125, 0.0312550887465477)
  assert_asinf_ulp(-0.03125, -0.0312550887465477)
  assert_asinf_ulp(0.015625, 0.015625635161995888)
  assert_asinf_ulp(-0.015625, -0.015625635161995888)
  assert_asinf_ulp(0.0078125, 0.007812579162418842)
  assert_asinf_ulp(-0.0078125, -0.007812579162418842)
  assert_asinf_ulp(10, @float.not_a_number)
  assert_asinf_ulp(-10, @float.not_a_number)
  assert_asinf_ulp(@float.not_a_number, @float.not_a_number)
  assert_asinf_ulp(@float.infinity, @float.not_a_number)
  assert_asinf_ulp(@float.neg_infinity, @float.not_a_number)
}
