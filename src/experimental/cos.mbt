///|
/// Compute cosine of double-precision floating-point number `x`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(cos(-1.0), 0.5403023058681398)
/// assert_eq(cos(0.0), 1)
/// assert_eq(cos(1.5707963267948966), 0.00000000000000006123233995736766)
/// assert_eq(cos(3.141592653589793), -1)
/// assert_eq(cos(10000), -0.9521553682590148)
/// ```
///
/// # Special Cases
///
/// 1. cos(+-inf) = NaN
/// 2. cos(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn cos(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = [0.0, 0.0]
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
    return __kernel_cos(x, z)
  } else {
    let n = rem_pio2(x, y)
    match n & 3 {
      0 => __kernel_cos(y[0], y[1])
      1 => -__kernel_sin(y[0], y[1], 1)
      2 => -__kernel_cos(y[0], y[1])
      _ => __kernel_sin(y[0], y[1], 1)
    }
  }
}
