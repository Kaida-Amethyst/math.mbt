///|
const FLOAT_LN2 : Float = 0.693147180559945309417232121458176568

///|
pub fn acoshf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let a = u & 0x7fffffffU
  if a < 0x3f800000U + (1U << 23) {
    // |x| < 2, invalid if x < 1 or nan */
    // up to 2ulp error in [1,1.125] */
    return log1pf(
      x - 1.0 + ((x - 1.0) * (x - 1.0) + (2.0 : Float) * (x - 1.0)).sqrt(),
    )
  }
  if a < 0x3f800000U + (12U << 23) {
    // |x| < 0x1p12 */
    return logf(x * 2.0 - (1.0 : Float) / (x + (x * x - 1.0).sqrt()))
  }
  // x >= 0x1p12 */
  return logf(x) + FLOAT_LN2
}
