// asinh(x) = sign(x)*log(|x|+sqrt(x*x+1)) ~= x - x^3/6 + o(x^5) */
///| Inverse hyperbolic sine (Float)
///
/// Calculates the inverse hyperbolic sine of `x`.
/// Is defined as `sgn(x)*log(|x|+sqrt(x*x+1))`.
pub fn asinhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let i = u & 0x7fffffff
  let sign = (u >> 31) != 0
  let ln2 : Float = 0.693147180559945309417232121458176568

  // |x| */
  let x = i.reinterpret_as_float()
  let x = if i >= 0x3f800000U + (12U << 23) {
    // |x| >= 0x1p12 or inf or nan */
    logf(x) + ln2
  } else if i >= 0x3f800000U + (1U << 23) {
    // |x| >= 2 */
    logf(x * 2.0 + recipf(sqrtf(x * x + 1.0) + x))
  } else if i >= 0x3f800000U - (12U << 23) {
    // |x| >= 0x1p-12, up to 1.6ulp error in [0.125,0.5] */
    log1pf(x + x * x / (sqrtf(x * x + 1.0) + 1.0))
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
