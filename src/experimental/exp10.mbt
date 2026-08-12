///|
/// Compute 10 raised to the power of x.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(exp10(-1), 0.1);
/// assert_eq(exp10(-2), 0.01);
/// assert_eq(exp10(0), 1.0);
/// assert_eq(exp10(1), 10.0);
/// assert_eq(exp10(2), 100.0);
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place)
///
/// # Special Cases
///
/// 1. exp10(NaN) = NaN
/// 2. exp10(+Inf) = +Inf
/// 3. exp10(-Inf) = 0
pub fn exp10(x : Double) -> Double {
  pow(10.0, x)
}
