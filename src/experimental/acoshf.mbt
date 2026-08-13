///|
const FLOAT_LN2 : Float = 0.693147180559945309417232121458176568

///|
/// Return the inverse hyperbolic cosine of x.
///
/// Returns the inverse hyperbolic cosine of `x`, defined as the value `y` such that `x = cosh(y)`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(acoshf(1.0), 0.0);
/// assert_eq(acoshf(2.0), 1.3169578969248166);
/// assert_eq(acoshf(3.0), 1.7627471740390859);
/// assert_eq(acoshf(4.0), 2.0634370688955608);
/// ```
///
/// # Special cases
///
/// 1. acoshf(x) = NaN for all x < 1.
/// 2. aooshf(NaN) = NaN.
///
/// # Accuracy
///
/// 1 ulp
pub fn acoshf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let a = u & 0x7fffffffU
  if a < 0x3f800000U + (1U << 23) {
    // |x| < 2, invalid if x < 1 or nan */
    // up to 2ulp error in [1,1.125] */
    return @math.log1pf(
      x - 1.0 + ((x - 1.0) * (x - 1.0) + (2.0 : Float) * (x - 1.0)).sqrt(),
    )
  }
  if a < 0x3f800000U + (12U << 23) {
    // |x| < 0x1p12 */
    return @math.logf(x * 2.0 - (1.0 : Float) / (x + (x * x - 1.0).sqrt()))
  }
  // x >= 0x1p12 */
  return @math.logf(x) + FLOAT_LN2
}
