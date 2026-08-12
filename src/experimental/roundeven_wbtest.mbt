///|
test "roundeven" {
  fn assert_roundeven(x : Double, expected : Double) raise {
    if isnan(x) && isnan(expected) {
      return assert_eq(true, true)
    }
    assert_eq(roundeven(x), expected)
  }

  assert_roundeven(1.4, 1.0)
  assert_roundeven(1.5, 2.0)
  assert_roundeven(1.6, 2.0)
  assert_roundeven(2.4, 2.0)
  assert_roundeven(2.5, 2.0)
  assert_roundeven(2.6, 3.0)
  assert_roundeven(3.4, 3.0)
  assert_roundeven(3.5, 4.0)
  assert_roundeven(@double.not_a_number, @double.not_a_number)
  assert_roundeven(@double.infinity, @double.infinity)
  assert_roundeven(@double.neg_infinity, @double.neg_infinity)
}
