///|
/// Compute hyperbolic tangent function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(tanh(-0.5), -0.46211715726000974)
/// assert_eq(tanh(0.5), 0.46211715726000974)
/// assert_eq(tanh(0.0), 0.0)
/// assert_eq(tanh(1), 0.7615941559557649)
/// assert_eq(tanh(2), 0.9640275800758169)
/// ```
///
/// # Special Cases
///
/// 1. tanh(NaN) = NaN
/// 2. tanh(+inf) = 1
/// 3. tanh(-inf) = -1
///
/// # Accuracy
///
/// 2 ulp.
pub fn tanh(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if ispinf(x) {
    return 1.0
  }
  if isninf(x) {
    return -1.0
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let tiny = 1.0e-300
  let z = if ix < 0x40360000 {
    if ix < 0x3c800000 {
      x * (1.0 + x)
    } else if ix >= 0x3ff00000 {
      let t = expm1(2.0 * fabs(x))
      1.0 - 2.0 / (t + 2.0)
    } else {
      let t = expm1(-2.0 * fabs(x))
      -t / (t + 2.0)
    }
  } else {
    1.0 - tiny
  }
  if x >= 0.0 {
    z
  } else {
    -z
  }
}
