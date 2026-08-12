///|
/// Computes hyperbolic arctangent of ``x`` with single-precision floating-point.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(atanhf(0.0), 0.0);
/// assert_eq(atanhf(0.5), 0.5493061443340548);
/// assert_eq(atanhf(1.0), @float.infinity);
/// assert_eq(atanhf(-0.5), -0.5493061443340548);
/// assert_eq(atanhf(-1.0), @float.neg_infinity);
/// ```
///
/// # Accuracy:
///
/// 0 ulp (unit in the last place).
///
/// # Special cases:
///
/// 1. atanhf(x) = NaN for all |x| > 1
/// 2. atanhf(NaN) = NaN
/// 3. atanhf(1) = +Inf
/// 4. atanhf(-1) = -Inf
pub fn atanhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let sign = u >> 31 != 0
  let u = u & 0x7fffffff
  let x = Float::reinterpret_from_uint(u)
  let x = if u < 0x3f800000U - (1U << 23) {
    if u < 0x3f800000U - (32U << 23) {
      x
    } else {
      // |x| < 0.5, up to 1.7ulp error
      log1pf(x * 2.0 + x * 2.0 * x / ((1.0 : Float) - x)) * 0.5
    }
  } else {
    // avoid overflow
    log1pf(x / ((1.0 : Float) - x) * 2.0) * 0.5
  }
  if sign {
    -x
  } else {
    x
  }
}
