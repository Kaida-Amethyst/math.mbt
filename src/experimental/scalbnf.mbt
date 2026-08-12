///|
/// Compute x * 2 **n where x is a double and n is an integer.
/// # Introcution:
///
/// Compute x * 2 **n without computing 2 ** n.
///
/// # Accruacy:
///
/// 1 ulp (unit in the last place).
pub fn scalbnf(x : Float, n : Int) -> Float {
  let mut y = x
  let mut n = n
  if n > 127 {
    y *= (0x1.0p127 : Float)
    n -= 127
    if n > 127 {
      y *= (0x1.0p127 : Float)
      n -= 127
      if n > 127 {
        n = 127
      }
    }
  } else if n < -126 {
    y *= (0x1.0p-126 : Float) * 0x1.0p24
    n += 126 - 24
    if n < -126 {
      y *= (0x1.0p-126 : Float) * 0x1.0p24
      n += 126 - 24
      if n < -126 {
        n = -126
      }
    }
  }
  let u = (0x7f + n) << 23
  let x = y * Float::reinterpret_from_int(u)
  return x
}
