///|
/// `atan2(y, x)` returns the angle whose tangent is `y/x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(atan2(1, 0), 1.5707963267948966)
/// assert_eq(atan2(1, 1), 0.7853981633974483)
/// assert_eq(atan2(0, -1), 3.141592653589793)
/// ```
///
/// # Special Cases:
///
/// 1. `atan2((anything), NaN)` is NaN;
/// 2. `atan2(NAN, (anything))` is NaN;
/// 3. `atan2(+-0, +(anything but NaN))` is +-0;
/// 4. `atan2(+-0, -(anything but NaN))` is +-pi;
/// 5. `atan2(+-(anything but 0 and NaN), 0)` is +-pi/2;
/// 6. `atan2(+-(anything but INF and NaN), +INF)` is +-0;
/// 7. `atan2(+-(anything but INF and NaN), -INF)` is +-pi;
/// 8. `atan2(+-INF,+INF)` is +-pi/4;
/// 9. `atan2(+-INF,-INF)` is +-3pi/4;
/// 10. `atan2(+-INF, (anything but,0,NaN, and INF))` is +-pi/2;
pub fn atan2(y : Double, x : Double) -> Double {
  if x.is_nan() || y.is_nan() {
    return @double.not_a_number
  }
  let tiny = 1.0e-300
  let zero = 0.0
  let pi_o_4 = 7.8539816339744827900E-01
  let pi_o_2 = 1.5707963267948965580E+00
  let pi = 3.1415926535897931160E+00
  let pi_lo = 1.2246467991473531772E-16 // 0x3FE921FB, 0x54442D18
  // 0x3FF921FB, 0x54442D18
  // 0x400921FB, 0x54442D18
  // 0x3CA1A626, 0x33145C07
  let hx = __hi(x).reinterpret_as_int()
  let hy = __hi(y).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let iy = hy & 0x7fffffff
  if x == 1.0 {
    return atan(y)
  }
  let m = ((hy >> 31) & 1) | ((hx >> 30) & 2)
  if y == 0 {
    match m {
      0 | 1 => return y
      2 => return pi + tiny
      _ => return -pi - tiny // case m == 3
    }
  }
  if x == 0 {
    return if hy < 0 { -pi_o_2 - tiny } else { pi_o_2 + tiny }
  }
  if x.is_inf() {
    if y.is_inf() {
      match m {
        0 => return pi_o_4 + tiny
        1 => return -pi_o_4 - tiny
        2 => return 3.0 * pi_o_4 + tiny
        _ => return -3.0 * pi_o_4 - tiny // case m == 3
      }
    } else {
      match m {
        0 => return zero
        1 => return -zero
        2 => return pi + tiny
        _ => return -pi - tiny // case m == 3
      }
    }
  }
  if y.is_inf() {
    return if hy < 0 { -pi_o_2 - tiny } else { pi_o_2 + tiny }
  }
  let k = (iy - ix) >> 20
  let z = if k > 60 {
    pi_o_2 + 0.5 * pi_lo
  } else if hx < 0 && k < -60 {
    0.0
  } else {
    atan(fabs(y / x))
  }
  match m {
    0 => z
    1 => -z
    2 => pi - (z - pi_lo)
    _ => z - pi_lo - pi
  }
}
