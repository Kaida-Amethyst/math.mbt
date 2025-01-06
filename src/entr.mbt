///| Compute the entropy of a probability distribution.
pub fn entr(x: Double) -> Double {
  if isnan(x) {
    return x
  }

  if x > 0 {
    return -x * log(x)
  }

  if x == 0 {
    return 0
  }

  return double_neg_inf
}

test "entr" {
  assert_ulp!(entr(0.0), 0.0, 0);
  assert_ulp!(entr(0.5), 0.34657359027997264, 0);
  assert_ulp!(entr(1.0), 0.0, 0);
  assert_ulp!(entr(double_pos_inf), double_neg_inf, 0);
  assert_ulp!(entr(double_nan), double_nan, 0);
  assert_ulp!(entr(-0.0), 0.0, 0);
  assert_ulp!(entr(-0.5), double_neg_inf, 0);
}
