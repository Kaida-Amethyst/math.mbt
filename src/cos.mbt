pub fn cos(x : Double) -> Double {
  if Double::is_inf(x) || Double::is_nan(x) {
    x
  } else {
    let mut sign = false
    let x_ = x.abs()
    let mut j = (x_ * pi4).to_int64()
    if (j & 1L) == 1L {
      j += 1L
    }
    let y = j.to_double()
    j = j & 7L
    if j > 3L {
      sign = sign.not()
      j -= 4L
    }
    let z = x_ - y * pi4a - y * pi4b - y * pi4c
    if j > 1L {
      sign = sign.not()
    }
    let zz = z * z
    (if j == 1L || j == 2L {
      z +
      z *
      zz *
      (
        (
          (((sin_[0] * zz + sin_[1]) * zz + sin_[2]) * zz + sin_[3]) * zz +
          sin_[4]
        ) *
        zz +
        sin_[5]
      )
    } else {
      1.0 -
      0.5 * zz +
      zz *
      zz *
      (
        (
          (((cos_[0] * zz + cos_[1]) * zz + cos_[2]) * zz + cos_[3]) * zz +
          cos_[4]
        ) *
        zz +
        cos_[5]
      )
    }) *
    (if sign { -1.0 } else { 1.0 })
  }
}
