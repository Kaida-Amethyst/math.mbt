
///| ldexp(x, exp) = x * 2^exp. It is equivalent to scalbn(x, exp).
pub fn ldexp(x: Double, exp: Int) -> Double {
  scalbn(x, exp)
}
