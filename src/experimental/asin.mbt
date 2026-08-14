///|
/// Compute arcsine of `x`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(asin(0), 0)
/// assert_eq(asin(1), 1.5707963267948966)
/// assert_eq(asin(-1), -1.5707963267948966)
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
pub fn asin(x : Double) -> Double {
  let huge = 1.0e+300
  let pio4_hi = 7.85398163397448278999e-01
  let pio2_hi = 1.57079632679489655800
  let pio2_lo = 6.12323399573676603587e-17
  let ps0 = 1.66666666666666657415e-01
  let ps1 = -3.25565818622400915405e-01
  let ps2 = 2.01212532134862925881e-01
  let ps3 = -4.00555345006794114027e-02
  let ps4 = 7.91534994289814532176e-04
  let ps5 = 3.47933107596021167570e-05
  let qs1 = -2.40339491173441421878e+00
  let qs2 = 2.02094576023350569471e+00
  let qs3 = -6.88283971605453293030e-01
  let qs4 = 7.70381505559019352791e-02
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let absx = fabs(x)
  if absx >= 1.0 {
    if absx == 1.0 {
      return x * pio2_hi + x * pio2_lo
    } else {
      return @double.not_a_number
    }
  } else if absx < 0.5 {
    if ix < 0x3e400000 {
      if huge + x > 1.0 {
        return x
      }
    } else {
      let t = x * x
      let p = t *
        (ps0 + t * (ps1 + t * (ps2 + t * (ps3 + t * (ps4 + t * ps5)))))
      let q = 1.0 + t * (qs1 + t * (qs2 + t * (qs3 + t * qs4)))
      let w = p / q
      return x + x * w
    }
  }
  let w = 1.0 - absx
  let t = w * 0.5
  let p = t * (ps0 + t * (ps1 + t * (ps2 + t * (ps3 + t * (ps4 + t * ps5)))))
  let q = 1.0 + t * (qs1 + t * (qs2 + t * (qs3 + t * qs4)))
  let s = @math.sqrt(t)
  if ix >= 0x3FEF3333 {
    let w = p / q
    let t = pio2_hi - (2.0 * (s + s * w) - pio2_lo)
    return if x > 0.0 { t } else { -t }
  } else {
    let mut w = s
    w = __combineW(__hi(w), 0)
    let c = (t - w * w) / (s + w)
    let r = p / q
    let p = 2.0 * s * r - (pio2_lo - 2.0 * c)
    let q = pio4_hi - 2.0 * w
    let t = pio4_hi - (p - q)
    return if x > 0.0 { t } else { -t }
  }
}
