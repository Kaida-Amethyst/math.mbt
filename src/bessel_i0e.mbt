///| Returns exponentially scaled modified Bessel function of order zero of the argument.
///
/// The function is defined as i0e(x) = exp(-|x|) j0( ix ).
pub fn bessel_i0e(x : Double) -> Double {
  let x = x.abs()
  if x <= 8.0 {
    let y = x / 2.0 - 2.0
    return chbevl(y, i0_arrA)
  }
  return chbevl(32.0 / x - 2.0, i0_arrB) / x.sqrt()
}

///| `i0e` is the alias of `bessel_i0e`.
pub let i0e : (Double) -> Double = bessel_i0e
