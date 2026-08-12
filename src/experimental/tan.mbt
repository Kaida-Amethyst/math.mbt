///|
/// Compute the tangent of double-precision floating-point number `x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(tan(-1.0), -1.5574077246549023)
/// assert_eq(tan(3.141592653589793), -0.00000000000000012246467991473532)
/// assert_eq(tan(1.5707963267948966), 16331239353195370)
/// assert_eq(tan(0.7853981633974483), 0.9999999999999999)
/// assert_eq(tan(0.0), 0)
/// assert_eq(tan(10000), 0.3209711346238147)
/// ```
///
/// # Special Cases
///
/// 1. tan(+-inf) = NaN
/// 2. tan(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn tan(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = Array::make(2, 0.0)
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
    __kernel_tan(x, z, 1)
  } else {
    let n = rem_pio2(x, y)
    __kernel_tan(y[0], y[1], 1 - ((n & 1) << 1))
  }
}
