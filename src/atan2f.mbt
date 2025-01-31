pub fn atan2f(y: Float, x: Float) -> Float {
  if x.is_nan() || y.is_nan() {
    return @float.not_a_number
  }

  let pi: Float = 3.1415927410e+00;
  let pi_lo: Float = -8.7422776573e-08;
  let zero: Float = 0.0;

  let ix = x.reinterpret_as_int();
  let iy = y.reinterpret_as_int();

  if ix == 0x3f800000 {
    return atanf(y);
  }

  let m = ((iy >> 31) & 1) | ((ix >> 30) & 2);

  let ix = ix & 0x7fffffff;
  let iy = iy & 0x7fffffff;

  if iy == 0 {
    match m {
      0 | 1 => return y
      2 => return pi
      _ => return -pi
    }
  }

  if ix == 0 {
    let res = if (m & 1) != 0 {
      -pi / 2
    } else {
      pi / 2
    }
    return res;
  }

  if ix == 0x7f800000 {
    if iy == 0x7f800000 {
      match m {
        0 => return pi / 4
        1 => return -pi / 4
        2 => return pi*3.0 / 4
        _ => return -pi*3.0 / 4
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

  if ix + (26 << 23) < iy || iy == 0x7f800000 {
    let res = if (m & 1) != 0 {
      -pi / 2
    } else {
      pi / 2
    }
    return res;
  }

  let z = if (m & 2) != 0 && iy + (26 << 23) < ix {
    zero
  } else {
    atanf(y / x)
  }

  match m {
    0 => z
    1 => -z
    2 => pi - (z - pi_lo)
    _ => (z - pi_lo) - pi
  }
}
