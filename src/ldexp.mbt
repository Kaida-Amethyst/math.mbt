///| ldexp(x, exp) = x * 2^exp. It is equivalent to scalbn(x, exp).
/// ldexp(x, exp) = x * 2^exp. It is equivalent to scalbn(x, exp), but with differnt implemenation.
pub fn ldexp(x: Double, pw2: Int) -> Double {
  let mut u = x.reinterpret_as_uint64()
  let mut e = ((u >> 52) & 0x7FF).to_int()

  if e == 0 {
    if x == 0.0 {
        return 0.0
    }
    // Input is denormal.
    let mut x = x
    let mut pw2 = pw2
    while e == 0 {
      if pw2 > 0 {
        x *= 2.0
        pw2 -= 1
      }
      if pw2 < 0 {
        if pw2 < -53 {
          return 0.0
        }
        x /= 2.0
        pw2 += 1
      }
      if pw2 == 0 {
        return x
      }
      u = x.reinterpret_as_uint64()
      e = ((u >> 52) & 0x7FF).to_int()
    }
  }

  e += pw2

  // Handle overflow
  if e >= 0x7FF {
    return @double.infinity
  }

  // Handle denormalized results
  if e < 1 {
    if e < -53 {
      return 0.0
    }
    u = u & 0x800F_FFFF_FFFF_FFFF
    u = u | 0x0010_0000_0000_0000
    let x = u.reinterpret_as_double()
    return x * ldexp(1.0, e - 1)
  } else {
    u = u & 0x800F_FFFF_FFFF_FFFF
    u = u | ((e.to_uint64()) & 0x7FF) << 52
    return u.reinterpret_as_double()
  }
}
