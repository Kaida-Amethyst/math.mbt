///| Calculate the standard normal cumulative distribution function.
pub fn normcdf(x : Double) -> Double {
  0.5 * (1.0 + erf(x / SQRT2))
}
