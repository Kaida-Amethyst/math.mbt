///| Calculate the inverse of the standard normal cumulative distribution function.
pub fn normcdfinv(x : Double) -> Double {
  if x < 0 || x > 1 {
    return double_nan
  }

  if x <= 0.5 {
    let y = 2.0 * x - 1
    let z = erfinv(y)
    SQRT2 * z
  } else {
    let y = 2.0 * x
    let z = erfcinv(y)
    -SQRT2 * z
  }
}
