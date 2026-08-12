///|
/// Compute sine of double-precision floating-point number `x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(sinf(-1.0), -0.8414709848078965)
/// assert_eq(sinf(0.0), 0)
/// assert_eq(sinf(1.5707963267948966), 1.0)
/// assert_eq(sinf(3.141592653589793), -8.742277657347586e-8)
/// assert_eq(sinf(10000), -0.30561438888825215)
/// ```
///
/// # Special Cases
///
/// 1. sinf(+-inf) = NaN
/// 2. sinf(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn sinf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return x
  }
  let (x, q) = trig_reduce(x, SIN_SWITCHOVER)
  sin_cos_core(x, q)
}
