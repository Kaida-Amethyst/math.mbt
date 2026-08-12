///|
/// Compute the principal value of the arc cosine of `x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(acos(-0.5), 2.0943951023931957)
/// assert_eq(acos(0.5), 1.0471975511965979)
/// assert_eq(acos(1), 0)
/// assert_eq(acos(0), 1.5707963267948966)
/// assert_eq(acos(-1), 3.141592653589793)
/// ```
///
/// # Accruacy
///
/// 1 ulp (unit in the last place).
///
/// # Special cases
///
/// 1. If `x` is NaN, a NaN is returned.
/// 2. If |x| > 1, a NaN is returned with the invalid signal raised.
pub fn acos(x : Double) -> Double {
  let one : Double = 1.0
  let pi : Double = 3.14159265358979311600
  let pio2_hi : Double = 1.57079632679489655800
  let pio2_lo : Double = 6.12323399573676603587e-17
  let ps0 : Double = 1.66666666666666657415e-01
  let ps1 : Double = -3.25565818622400915405e-01
  let ps2 : Double = 2.01212532134862925881e-01
  let ps3 : Double = -4.00555345006794114027e-02
  let ps4 : Double = 7.91534994289814532176e-04
  let ps5 : Double = 3.47933107596021167570e-05
  let qs1 : Double = -2.40339491173441421878e+00
  let qs2 : Double = 2.02094576023350569471e+00
  let qs3 : Double = -6.88283971605453293030e-01
  let qs4 : Double = 7.70381505559019352791e-02
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let absx = x.abs()
  if absx >= 1.0 {
    if absx == 1.0 {
      if x > 0 {
        return 0.0
      } else {
        return pi + 2.0 * pio2_lo
      }
    }
    return @double.not_a_number
  }
  if absx < 0.5 {
    if ix <= 0x3c600000 {
      return pio2_hi + pio2_lo
    }
    let z = x * x
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let r = p / q
    pio2_hi - (x - (pio2_lo - x * r))
  } else if x < 0 {
    let z = (one + x) * 0.5
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let s = z.sqrt()
    let r = p / q
    let w = r * s - pio2_lo
    pi - 2.0 * (s + w)
  } else {
    let z = (one - x) * 0.5
    let s = z.sqrt()
    let df = s
    let c = (z - df * df) / (s + df)
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let r = p / q
    let w = r * s + c
    2.0 * (df + w)
  }
}
