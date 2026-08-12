///|
test "signum" {
  assert_eq(signum(0.0), 1.0)
  assert_eq(signum(-0.0), -1.0)
  assert_eq(signum(1.0), 1.0)
  assert_eq(signum(-1.0), -1.0)
  assert_eq(signum(3.8), 1.0)
  assert_eq(signum(-3.8), -1.0)
  assert_eq(signum(@double.infinity), 1.0)
  assert_eq(signum(@double.neg_infinity), -1.0)
}
