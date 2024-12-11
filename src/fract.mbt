
///| Return the fractional part of a number
/// # Introduction
///
/// Returns the fractional part of a number, which is the number without the integer part.
///
/// # Example:
///
/// ```moonbit
/// let x = 3.14;
/// let y = fract(x);
/// assert!(y == 0.14);
/// ```
///
/// # Accuracy
///
/// This function always returns the exact fractional part of the number.
pub fn fract(x: Double) -> Double {
  x - trunc(x)
}
