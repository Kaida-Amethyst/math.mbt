///|
/// # Introcution:
///
/// Compute x * 2 **n without computing 2 ** n.
///
/// # Accruacy:
///
/// 1 ulp (unit in the last place).
pub fn scalbn(input: Double, n: Int) -> Double {
  let two54 = 1.80143985094819840000e+16
  let twom54 = 5.55111512312578270212e-17
  let huge = 1.0e+300
  let tiny = 1.0e-300
  let mut x = input
  let mut k : Int = 0
  let hx : UInt = __hi(x)
  let lx : UInt = __low(x)
  k = ((hx & 0x7ff00000) >> 20).reinterpret_as_int()
  if k == 0 {
    if (lx | (hx & 0x7fffffff)) == 0 {
      return x
    }
    x *= two54
    let hx = __hi(x)
    k = (((hx & 0x7ff00000) >> 20) - 54).reinterpret_as_int()
    if n < -50000 {
      return tiny * x
    }
  }
  if k == 0x7ff {
    return x + x
  }
  k = k + n
  if k > 0x7fe {
    return huge * copysign(huge, x)
  }
  if k > 0 {
    x = __combineW(((hx & 0x800fffff) | (k << 20).reinterpret_as_uint()), lx)
    return x
  }
  if k <= -54 {
    if n > 50000 {
      return huge * copysign(huge, x)
    } else {
      return tiny * copysign(tiny, x)
    }
  }
  k = k + 54
  x = __combineW(((hx & 0x800fffff) | (k << 20).reinterpret_as_uint()), lx)
  return x * twom54
}
