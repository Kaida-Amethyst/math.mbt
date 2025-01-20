///| Return next representable double-precision floating-point value after argument `x` in the direction of `y`.
///
/// # Special cases
///
/// 1. nextafter(x, y) = y if x equals y.
/// 2. nextafter(x, y) = NaN if either x or y are NaN.
pub fn nextafter(x : Double, y : Double) -> Double {
  if isnan(x) || isnan(y) {
    return double_nan
  }
  if x == y {
    return x
  }
  let mut hx = __hi(x).reinterpret_as_int()
  let mut lx = __low(x).reinterpret_as_int()
  let hy = __hi(y).reinterpret_as_int()
  let ly = __low(y).reinterpret_as_int()
  if x == 0 {
    let x = if y < 0 { 0x80000000_00000001UL } else { 0x1 }
    let x = x.reinterpret_as_double()
    let y = x * x
    if y == x {
      return y
    } else {
      return x
    }
  }
  if x > 0 {
    if hx > hy || (hx == hy && lx > ly) {
      if lx == 0 {
        hx -= 1
      }
      lx -= 1
    } else {
      lx += 1
      if lx == 0 {
        hx += 1
      }
    }
  } else if hy >= 0 || hx > hy || (hx == hy && lx > ly) {
    if lx == 0 {
      hx -= 1
    }
    lx -= 1
  } else {
    lx += 1
    if lx == 0 {
      hx += 1
    }
  }
  let hy = hx & 0x7ff00000
  if hy >= 0x7ff00000 {
    return x + x
  }
  if hy < 0x00100000 {
    let y = x * x
    if y != x {
      let y = __combineW(hx.reinterpret_as_uint(), lx.reinterpret_as_uint())
      return y
    }
  }
  __combineW(hx.reinterpret_as_uint(), lx.reinterpret_as_uint())
}
