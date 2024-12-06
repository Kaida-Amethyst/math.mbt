let tan_p = [
  -0x3325.B1A49E7E6F070EEA7F33, 0x1199EC.A5FC9DDCB62A659C2F5C, -0x111FEAD.3299175F331F9B486E14,
]

let tan_q = [
  1.0, 0x3571.4BDD66CAE3B4F57353EC, -0x1427BC.582ABC95B9AA3C9963BF, 0x17D98FC.2EAD8EF5BE3D475ECC36,
  -0x335FC07.97CB461BD8709633FE8F,
]

///| Compute the tangent of double-precision floating-point number `x`.
pub fn tan(x : Double) -> Double {
  if Double::is_inf(x) || Double::is_nan(x) {
    x
  } else {
    let x_ = x.abs()
    let mut j = (x_ * pi4).to_int64()
    if (j & 1L) == 1L {
      j += 1L
    }
    let y = j.to_double()
    let z = x_ - y * pi4a - y * pi4b - y * pi4c
    let mut zz = z * z
    zz = if zz > 1.0e-14 {
      z +
      z *
      (
        zz *
        ((tan_p[0] * zz + tan_p[1]) * zz + tan_p[2]) /
        ((((zz + tan_q[1]) * zz + tan_q[2]) * zz + tan_q[3]) * zz + tan_q[4])
      )
    } else {
      z
    }
    if (j & 2L) == 2L {
      zz = -1.0 / zz
    }
    if x.signum() < 0.0 {
      -zz
    } else {
      zz
    }
  }
}
