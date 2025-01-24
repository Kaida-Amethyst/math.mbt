///| Computes the cumulative distribution function (CDF) of the gamma distribution.
pub fn gdtr(a : Double, b : Double, x : Double) -> Double {
  if x < 0.0 {
    return 0.0
  }
  return igam(b, a * x)
}

///| Computes the complement of the cumulative distribution function (CDF) of the gamma distribution.
pub fn gdtrc(a : Double, b : Double, x : Double) -> Double {
  if x < 0.0 {
    return 0.0
  }
  return igamc(b, a * x)
}
