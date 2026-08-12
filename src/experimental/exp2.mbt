///|
/// Compute 2 raised to the power of x.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(exp2(-1), 0.5);
/// assert_eq(exp2(-2), 0.25);
/// assert_eq(exp2(-3), 0.125);
/// assert_eq(exp2(-4), 0.0625);
/// assert_eq(exp2(0), 1);
/// assert_eq(exp2(1), 2);
/// assert_eq(exp2(2), 4);
/// assert_eq(exp2(3), 8);
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place)
///
/// # Special Cases
///
/// 1. exp2(+Inf) = +Inf
/// 2. exp2(-Inf) = 0
///.3. exp2(NaN) = NaN
pub fn exp2(x : Double) -> Double {
  pow(2.0, x)
}
