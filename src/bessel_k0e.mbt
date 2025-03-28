///| Returns exponentially scaled modified Bessel function of the third kind of order zero of the argument.
pub fn bessel_k0e(x : Double) -> Double {
  if x <= 0.0 {
    return @double.not_a_number
  }
  if x <= 2.0 {
    let y = x * x - 2.0
    let y = chbevl(y, k0_arrA) - log(0.5 * x) * bessel_i0(x)
    return y * exp(x)
  }
  return chbevl(8.0 / x - 2.0, k0_arrB) / sqrt(x)
}

///| `k0e` is an alias for `bessel_k0e`.
pub let k0e : (Double) -> Double = bessel_k0e
