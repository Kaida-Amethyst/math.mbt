///| pown computes `x ** n` where x is a Double and n is an Int.
pub fn pown(x : Double, n : Int) -> Double {
  let (n, nisneg) = if n < 0 { (-n, true) } else { (n, false) }
  let mut n = n
  let mut r : Double = x
  let mut s : Double = 1.0
  while n > 0 {
    if (n & 0x1) == 1 {
      s *= r
    }
    r *= r
    n = n >> 1
  }
  if nisneg {
    s = 1.0 / s
  }
  s
}

///| powi computes `x ** i` where x is a Double and i is an Int. It is an alias for `pown`.
pub fn powi(x : Double, i : Int) -> Double {
  pown(x, i)
}
