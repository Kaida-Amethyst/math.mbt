///| Compute the entropy of a probability distribution.
///
/// # Notes
///
/// Computes the entropy of a probability distribution, defined as $-x \times \log(x)$.
///
/// # Examples
///
/// ```moonbit
/// assert_eq(entr(0.0), 0.0);
/// assert_eq(entr(0.5), 0.34657359027997264);
/// assert_eq(entr(1.0), 0.0);
/// ```
///
/// # Accuracy
///
/// 0 ulp.
///
/// # Special Cases
///
/// 1. entr(NaN) = NaN
/// 2. entr(x) = -inf for x < 0
pub fn entr(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if x > 0 {
    return -x * log(x)
  }
  if x == 0 {
    return 0
  }
  return @double.neg_infinity
}

///|
test "entr" {
  assert_ulp(entr(0.0), 0.0, 0)
  assert_ulp(entr(0.5), 0.34657359027997264, 0)
  assert_ulp(entr(1.0), 0.0, 0)
  assert_ulp(entr(@double.infinity), @double.neg_infinity, 0)
  assert_ulp(entr(@double.not_a_number), @double.not_a_number, 0)
  assert_ulp(entr(-0.0), 0.0, 0)
  assert_ulp(entr(-0.5), @double.neg_infinity, 0)
}
