///| Calculates Euclidean division, the matching method for `rem_euclid`.
/// This computes the integer `n` such that
/// `x = n * y + rem_euclid(x, y)`.
/// In other words, the result is `x / y` rounded to the integer `n`
/// such that `x >= n * y`.
///
/// # Precision
///
/// The result of this operation is guaranteed to be the rounded
/// infinite-precision result.
///
// # Examples
//
// ```moonbit
// let a : Double = 7.0
// let b : Double = 4.0
// assert_eq!(div_euclid(a, b), 1.0)   // 7.0 >= 4.0 * 1.0
// assert_eq!(div_euclid(-a, b), -2.0) // -7.0 >= 4.0 * -2.0
// assert_eq!(div_euclid(a, -b), -2.0) // 7.0 >= -4.0 * -2.0
// assert_eq!(div_euclid(-a, -b), 1.0) // -7.0 >= -4.0 * 1.0
// ```
pub fn div_euclid(x : Double, y : Double) -> Double {
  let q = trunc(x / y)
  if x % y < 0.0 {
    if y > 0.0 {
      q - 1.0
    } else {
      q + 1.0
    }
  } else {
    q
  }
}
