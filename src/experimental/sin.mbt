///|
/// Compute sine of double-precision floating-point number `x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(sin(-1.0), -0.8414709848078965)
/// assert_eq(sin(0.0), 0)
/// assert_eq(sin(1.5707963267948966), 1.0)
/// assert_eq(sin(3.141592653589793), 0.00000000000000012246467991473532)
/// assert_eq(sin(10000), -0.30561438888825215)
/// ```
///
/// # Special Cases
///
/// 1. sin(+-inf) = NaN
/// 2. sin(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn sin(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = [0.0, 0.0]
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
    return __kernel_sin(x, z, 0)
  } else {
    let n = rem_pio2(x, y)
    match n & 3 {
      0 => __kernel_sin(y[0], y[1], 1)
      1 => __kernel_cos(y[0], y[1])
      2 => -__kernel_sin(y[0], y[1], 1)
      _ => -__kernel_cos(y[0], y[1])
    }
  }
}
