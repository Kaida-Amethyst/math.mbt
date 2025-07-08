///| Return a number that represents the sign of the argument.
///
/// - `1.0` if the argument is positive, `+0.0` or `+Inf`
/// - `-1.0` if the argument is negative, `-0.0` or `-Inf`
/// - `NaN` if the argument is `NaN`
pub fn signum(x : Double) -> Double {
  if isnan(x) {
    @double.not_a_number
  } else {
    copysign(1.0, x)
  }
}

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
