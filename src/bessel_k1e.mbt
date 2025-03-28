///| Returns exponentially scaled modified Bessel function of the third kind of order one of the argument:
pub fn bessel_k1e(x : Double) -> Double {
  if x <= 0.0 {
    return @double.infinity
  }
  if x <= 2.0 {
    let y = x * x - 2.0
    let y = log(0.5 * x) * bessel_i1(x) + chbevl(y, k1_arrA) / x
    return y * exp(x)
  }
  return chbevl(8.0 / x - 2.0, k1_arrB) / sqrt(x)
}

///| `k1e` is an alias for `bessel_k1e`.
pub let k1e : (Double) -> Double = bessel_k1e
