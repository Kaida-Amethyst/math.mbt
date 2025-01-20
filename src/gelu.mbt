///| Computes the Gaussian Error Linear Unit (GELU) function.
pub fn gelu(x : Double) -> Double {
  x * 0.5 * (1.0 + erf(x / SQRT2))
}
