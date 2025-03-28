///| Returns exponentially scaled modified Bessel function of order one of the argument.
pub fn bessel_i1e(x : Double) -> Double {
  let z = x.abs()
  let z = if z <= 8.0 {
    let y = z / 2.0 - 2.0
    chbevl(y, i1_arrA) * z
  } else {
    chbevl(32.0 / z - 2.0, i1_arrB) / sqrt(z)
  }
  return if x < 0.0 { -z } else { z }
}

///| `i1e` is an alias for `bessel_i1e`.
pub let i1e : (Double) -> Double = bessel_i1e
