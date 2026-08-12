///|
/// Compute arctangent of `x`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(atan(0), 0)
/// assert_eq(atan(1), 0.7853981633974483)
/// assert_eq(atan(2), 1.1071487177940904)
/// assert_eq(atan(-1),-0.7853981633974483)
/// assert_eq(atan(-2),-1.1071487177940904)
/// assert_eq(atan(@double.infinity), 1.5707963267948966)
/// assert_eq(atan(@double.neg_infinity), -1.5707963267948966)
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
///
/// 1. atan(NaN) = NaN
/// 2. atan(+Inf) = +π/2
/// 3. atan(-Inf) = -π/2
pub fn atan(x : Double) -> Double {
  if x.is_nan() || x == 0.0 {
    return x
  }
  let atan_hi = [
    4.63647609000806093515e-01, 7.85398163397448278999e-01, 9.82793723247329054082e-01,
    1.57079632679489655800e+00,
  ]
  let atan_lo = [
    2.26987774529616870924e-17, 3.06161699786838301793e-17, 1.39033110312309984516e-17,
    6.12323399573676603587e-17,
  ]
  let a_t = [
    3.33333333333329318027e-01, -1.99999999998764832476e-01, 1.42857142725034663711e-01,
    -1.11111104054623557880e-01, 9.09088713343650656196e-02, -7.69187620504482999495e-02,
    6.66107313738753120669e-02, -5.83357013379057348645e-02, 4.97687799461593236017e-02,
    -3.65315727442169155270e-02, 1.62858201153657823623e-02,
  ]
  let one = 1.0
  let huge = 1.0e300
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let mut id = 0
  let mut z = 0.0
  let mut w = 0.0
  let mut x = x
  let x_is_neg = x < 0.0
  if ix >= 0x44100000 {
    if x > 0 {
      return atan_hi[3] + atan_lo[3]
    } else {
      return -atan_hi[3] - atan_lo[3]
    }
  }
  if ix < 0x3fdc0000 {
    if ix < 0x3e200000 {
      if huge + x > one {
        return x
      }
    }
    id = -1
  } else {
    x = x.abs()
    if ix < 0x3ff30000 {
      if ix < 0x3fe60000 {
        id = 0
        x = (2.0 * x - one) / (2.0 + x)
      } else {
        id = 1
        x = (x - one) / (x + one)
      }
    } else if ix < 0x40038000 {
      id = 2
      x = (x - 1.5) / (one + 1.5 * x)
    } else {
      id = 3
      x = -1.0 / x
    }
  }
  z = x * x
  w = z * z
  let s1 = z *
    (
      a_t[0] +
      w * (a_t[2] + w * (a_t[4] + w * (a_t[6] + w * (a_t[8] + w * a_t[10]))))
    )
  let s2 = w *
    (a_t[1] + w * (a_t[3] + w * (a_t[5] + w * (a_t[7] + w * a_t[9]))))
  if id < 0 {
    x - x * (s1 + s2)
  } else {
    z = atan_hi[id] - (x * (s1 + s2) - atan_lo[id] - x)
    if x_is_neg {
      -z
    } else {
      z
    }
  }
}
