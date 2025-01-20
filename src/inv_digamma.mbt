///| Compute the inverse of the digamma function.
pub fn inv_digamma(x : Double) -> Double {
  fn inner_signum(x : Double) -> Double {
    if x == 0.0 {
      return 0.0
    }
    signum(x)
  }

  if isnan(x) {
    return x
  }
  if isninf(x) {
    return 0.0
  }
  if ispinf(x) {
    return double_pos_inf
  }
  let mut y = exp(x)
  let mut i = 1.0
  while i > 1.0e-15 {
    y += i * inner_signum(x - digamma(y))
    i /= 2.0
  }
  y
}
