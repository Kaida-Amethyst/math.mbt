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
  let pio2 : Double = 1.57079632679489655800
  let ps0 : Float = 1.6666586697e-01
  let ps1 : Float = -4.2743422091e-02
  let ps2 : Float = -8.6563630030e-03
  let qs1 : Float = -7.0662963390e-01
  let one : Float = 1.0
  fn r(z : Float) -> Float {
    let p = z * (ps0 + z * (ps1 + z * ps2))
    let q = z * qs1 + 1.0
    p / q
  }

  let hx = x.reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix >= 0x3ff00000 {
    if ix == 0x3ff00000 {
      return (x.to_double() * pio2 + 0x1.0p-120).to_float()
    }
    return @float.not_a_number
  }
  if ix < 0x3f800000 {
    if ix < 0x3f19999a {
      return x
    }
    return x + x * r(x * x)
  }
  let z = (one - x.abs()) * 0.5
  let s = z.sqrt()
  let w = s + s * r(z)
  let r = pio2 - w.to_double() * 2.0
  let r = if (hx >> 31) != 0 { -r } else { r }
  r.to_float()
}
