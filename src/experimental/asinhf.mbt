///|
/// Compute the inverse hyperbolic sine of `x` with single-precision floating-point.
///
/// Computes the inverse hyperbolic sine of `x`. The inverse hyperbolic sine is defined as:
/// $$\text{asinh}(x) = \log(x + \sqrt{x^2 + 1})$$
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(asinhf(-1), -0.881373587019543)
/// assert_eq(asinhf(-2), -1.4436354751788103)
/// assert_eq(asinhf(1), 0.881373587019543)
/// assert_eq(asinhf(2), 1.4436354751788103)
/// ```
///
/// # Special Cases
///
/// 1. asinhf(NaN) = NaN.
/// 2. asinhf(±0) = ±0.
/// 3. asinhf(±∞) = ±∞.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
pub fn asinhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let i = u & 0x7fffffff
  let sign = u >> 31 != 0
  let ln2 : Float = 0.693147180559945309417232121458176568

  // |x| */
  let x = Float::reinterpret_from_uint(i)
  let x = if i >= 0x3f800000U + (12U << 23) {
    // |x| >= 0x1p12 or inf or nan */
    logf(x) + ln2
  } else if i >= 0x3f800000U + (1U << 23) {
    // |x| >= 2 */
    logf(x * 2.0 + recipf(@math.sqrtf(x * x + 1.0) + x))
  } else if i >= 0x3f800000U - (12U << 23) {
    // |x| >= 0x1p-12, up to 1.6ulp error in [0.125,0.5] */
    log1pf(x + x * x / (@math.sqrtf(x * x + 1.0) + 1.0))
  } else {
    // |x| < 0x1p-12, raise inexact if x!=0 */
    // x + 0x1.0p120
    x
  }
  if sign {
    -x
  } else {
    x
  }
}
