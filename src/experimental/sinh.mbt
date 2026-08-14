///|
/// Compute hyperbolic sine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(sinh(-0.5), -0.5210953054937474)
/// assert_eq(sinh(0.0), 0.0)
/// assert_eq(sinh(0.5), 0.5210953054937474)
/// assert_eq(sinh(1.0), 1.1752011936438014)
/// ```
///
/// # Special Cases
///
/// 1. sinh(NaN) = NaN
/// 2. sinh(+inf) = +inf
/// 3. sinh(-inf) = -inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn sinh(x : Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let abs_x = fabs(x)
  let shuge = 1.0e307
  let h = if x < 0.0 { -0.5 } else { 0.5 }
  if ix < 0x40360000 {
    if ix < 0x3e300000 {
      if shuge + x > 1.0 {
        return x
      }
    }
    let t = @math.expm1(abs_x)
    if ix < 0x3ff00000 {
      return h * (2.0 * t - t * t / (t + 1.0))
    }
    return h * (t + t / (t + 1.0))
  }
  if ix < 0x40862E42 {
    return h * @math.exp(abs_x)
  }
  if abs_x.reinterpret_as_uint64() < 0x408633ce8fb9f87d {
    let w = @math.exp(0.5 * abs_x)
    let t = h * w
    return t * w
  }
  x * shuge
}
