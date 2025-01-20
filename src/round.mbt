///| Return the nearest integer value to `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(round(2.5), 3.0)
/// assert_eq!(round(3.14), 3.0)
/// assert_eq!(round(-3.14), -3.0)
/// assert_eq!(round(5.0), 5.0)
/// assert_eq!(round(-5.0), -5.0)
/// ```
///
/// # Special Cases
///
/// 1. round(NaN) = NaN
/// 2. round(+-inf) = +-inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn round(x: Double) -> Double {
  x.round()
}
