///| Return the fractional part of a number
/// # Introduction
///
/// Returns the fractional part of a number, which is the number without the integer part.
///
/// # Example:
///
/// ```moonbit
/// assert_eq!(fract(3.25), 0.25);
/// ```
///
/// # Accuracy
///
/// This function always returns the exact fractional part of the number.
pub fn fract(x : Double) -> Double {
  x - trunc(x)
}
