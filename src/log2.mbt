///| Compute the base-2 logarithm of a number.
pub fn log2(x: Double) -> Double {
  x.log2()
}

test "log2" {
  assert_ulp!(LOG2E, log2(E), LOG2_MAX_ULP)
}
