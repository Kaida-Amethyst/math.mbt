///| Return the largest integral value less than or equal to x.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(floor(2.5), 2.0)
/// assert_eq!(floor(3.14), 3.0)
/// assert_eq!(floor(-3.14), -4.0)
/// assert_eq!(floor(5.0), 5.0)
/// assert_eq!(floor(-5.0), -5.0)
/// ```
///
/// # Special Cases
///
/// 1. floor(NaN) = NaN
/// 2. floor(+-inf) = +-inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn floor(x: Double) -> Double {
  x.floor()
}
