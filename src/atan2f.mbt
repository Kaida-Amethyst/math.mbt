///| `atan2f(y, x)` returns the angle whose tangent is `y/x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(atan2f(1, 0), 1.5707963267948966)
/// assert_eq!(atan2f(1, 1), 0.7853981633974483)
/// assert_eq!(atan2f(0, -1), 3.141592653589793)
/// ```
///
/// # Special Cases:
///
/// 1. `atan2f((anything), NaN)` is NaN;
/// 2. `atan2f(NAN, (anything))` is NaN;
/// 3. `atan2f(+-0, +(anything but NaN))` is +-0;
/// 4. `atan2f(+-0, -(anything but NaN))` is +-pi;
/// 5. `atan2f(+-(anything but 0 and NaN), 0)` is +-pi/2;
/// 6. `atan2f(+-(anything but INF and NaN), +INF)` is +-0;
/// 7. `atan2f(+-(anything but INF and NaN), -INF)` is +-pi;
/// 8. `atan2f(+-INF,+INF)` is +-pi/4;
/// 9. `atan2f(+-INF,-INF)` is +-3pi/4;
/// 10. `atan2f(+-INF, (anything but,0,NaN, and INF))` is +-pi/2;
pub fn atan2f(y : Float, x : Float) -> Float {
  if x.is_nan() || y.is_nan() {
    return @float.not_a_number
  }
  let pi : Float = 3.1415927410e+00
  let pi_lo : Float = -8.7422776573e-08
  let zero : Float = 0.0
  let ix = x.reinterpret_as_uint()
  let iy = y.reinterpret_as_uint()
  if ix == 0x3f800000 {
    return atanf(y)
  }
  let m = ((iy >> 31) & 1) | ((ix >> 30) & 2)
  let ix = ix & 0x7fffffff
  let iy = iy & 0x7fffffff
  if iy == 0 {
    match m {
      0 | 1 => return y
      2 => return pi
      _ => return -pi
    }
  }
  if ix == 0 {
    let res = if (m & 1) != 0 { -pi / 2 } else { pi / 2 }
    return res
  }
  if ix == 0x7f800000 {
    if iy == 0x7f800000 {
      match m {
        0 => return pi / 4
        1 => return -pi / 4
        2 => return pi * 3.0 / 4
        _ => return -pi * 3.0 / 4
      }
    } else {
      match m {
        0 => return 0.0
        1 => return -0.0
        2 => return pi
        _ => return -pi
      }
    }
  }
  if ix + (26U << 23) < iy || iy == 0x7f800000 {
    let res = if (m & 1) != 0 { -pi / 2 } else { pi / 2 }
    return res
  }
  let z = if (m & 2) != 0 && iy + (26U << 23) < ix {
    zero
  } else {
    atanf(y / x)
  }
  match m {
    0 => z
    1 => -z
    2 => pi - (z - pi_lo)
    _ => z - pi_lo - pi
  }
}

///|
test "atan2f" {
  fn assert_atan2f_ulp(input1, input2, expect) raise {
    assert_float_ulp(expect, atan2f(input1, input2), ATAN2_F_MAX_ULP)
  }

  assert_atan2f_ulp(1, 1, 0.7853981852531433)
  assert_atan2f_ulp(3, 5, 0.5404195189476013)
  assert_atan2f_ulp(-2, 1, -1.1071487665176392)
  assert_atan2f_ulp(-5, 3, 1.0303767919540405)
  assert_atan2f_ulp(9, 6, 0.9827937483787537)
  assert_atan2f_ulp(7, 11, 0.5667291879653931)
  assert_atan2f_ulp(6.5, -3.25, 4.248741149902344)
  assert_atan2f_ulp(-7.25, 8.625, 0.6989995837211609)
  assert_atan2f_ulp(-52.5, -625.5, -3.0578560829162598)
  assert_atan2f_ulp(12, 13, 0.7454195022583008)
  assert_atan2f_ulp(7, 16, 0.4124104380607605)
  assert_atan2f_ulp(19, 33, 0.5224034190177917)
  assert_atan2f_ulp(@float.infinity, 11, 1.5707963705062866)
  assert_atan2f_ulp(13, @float.infinity, 0)
  assert_atan2f_ulp(@float.neg_infinity, -10.5, -1.5707963705062866)
  assert_atan2f_ulp(-12.5, @float.neg_infinity, -3.1415927410125732)
  assert_atan2f_ulp(@float.not_a_number, 0, @float.not_a_number)
  assert_atan2f_ulp(0, @float.not_a_number, @float.not_a_number)
  assert_atan2f_ulp(@float.infinity, @float.infinity, 0.7853981852531433)
  assert_atan2f_ulp(@float.infinity, @float.neg_infinity, 2.356194496154785)
  assert_atan2f_ulp(@float.neg_infinity, @float.infinity, -0.7853981852531433)
  assert_atan2f_ulp(
    @float.neg_infinity, @float.neg_infinity, -2.356194496154785,
  )
}
