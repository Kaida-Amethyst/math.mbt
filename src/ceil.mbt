///| Return the smallest integral value that is not less than x
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(ceil(2.5), 3.0)
/// assert_eq!(ceil(3.14), 4.0)
/// assert_eq!(ceil(-3.14), -3.0)
/// assert_eq!(ceil(5.0), 5.0)
/// assert_eq!(ceil(-5.0), -5.0)
/// ```
///
/// # Special Cases
///
/// 1. ceil(NaN) = NaN
/// 2. ceil(+-inf) = +-inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn ceil(x : Double) -> Double {
  x.ceil()
}
