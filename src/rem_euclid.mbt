///| Calculates the least nonnegative remainder of `x (mod y)`.
/// In particular, the return value `r` satisfies `0.0 <= r < abs(y)` in
/// most cases. However, due to a floating point round-off error it can
/// result in `r == abs(y)`, violating the mathematical definition, if
/// `x` is much smaller than `abs(y)` in magnitude and `x < 0.0`.
/// This result is not an element of the function's codomain, but it is the
/// closest floating point number in the real numbers and thus fulfills the
/// property `x == div_euclid(x, y) * y + rem_euclid(x, y)`
/// approximately.
///
/// # Precision
///
/// The result of this operation is guaranteed to be the rounded
/// infinite-precision result.
///
/// # Examples
///
/// ```
/// let a: Double = 7.0;
/// let b = 4.0;
/// assert_eq!(rem_euclid(a, b), 3.0);
/// assert_eq!(rem_euclid(-a, b), 1.0);
/// assert_eq!(rem_euclid(a, -b), 3.0);
/// assert_eq!(rem_euclid(-a, -b), 1.0);
/// ```
pub fn rem_euclid(x : Double, y : Double) -> Double {
  let r = x % y
  if r < 0.0 {
    r + fabs(y)
  } else {
    r
  }
}
