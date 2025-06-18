///| Return the integral part of a floating point number
///
/// # Examples
///
/// ```moonbit
/// assert_eq(trunc(2.5), 2.0)
/// assert_eq(trunc(3.14), 3.0)
/// assert_eq(trunc(-3.14), -3.0)
/// assert_eq(trunc(5.0), 5.0)
/// assert_eq(trunc(-5.0), -5.0)
/// ```
///
/// # Special Cases
///
/// 1. trunc(NaN) = NaN
/// 2. trunc(+-inf) = +-inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn trunc(x : Double) -> Double {
  x.trunc()
}
