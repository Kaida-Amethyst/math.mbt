///|
/// Compute cosine of double-precision floating-point number `x`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(cosf(-1.0), 0.5403023058681398)
/// assert_eq(cosf(0.0), 1)
/// assert_eq(cosf(1.5707963267948966), -4.371138828673793e-8)
/// assert_eq(cosf(3.141592653589793), -1)
/// assert_eq(cosf(10000), -0.9521553682590148)
/// ```
///
/// # Special Cases
///
/// 1. cosf(+-inf) = NaN
/// 2. cosf(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn cosf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return 1.0
  }
  let (x, q) = trig_reduce(x, COS_SWITCHOVER)
  sin_cos_core(x, q + 1)
}
