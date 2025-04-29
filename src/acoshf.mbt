///|
const FLOAT_LN2 : Float = 0.693147180559945309417232121458176568

///|
pub fn acoshf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let a = u & 0x7fffffffU
  if a < 0x3f800000U + (1U << 23) {
    // |x| < 2, invalid if x < 1 or nan */
    // up to 2ulp error in [1,1.125] */
    return log1pf(
      x - 1.0 + ((x - 1.0) * (x - 1.0) + (2.0 : Float) * (x - 1.0)).sqrt(),
    )
  }
  if a < 0x3f800000U + (12U << 23) {
    // |x| < 0x1p12 */
    return logf(x * 2.0 - (1.0 : Float) / (x + (x * x - 1.0).sqrt()))
  }
  // x >= 0x1p12 */
  return logf(x) + FLOAT_LN2
}

///|
test "acoshf" {
  fn assert_acoshf_ulp!(input, expect) {
    assert_float_ulp!(expect, acoshf(input), ACOSH_F_MAX_ULP)
  }

  assert_acoshf_ulp!(-1, @float.not_a_number)
  assert_acoshf_ulp!(1, 0)
  assert_acoshf_ulp!(8, 2.7686593532562256)
  assert_acoshf_ulp!(-8, @float.not_a_number)
  assert_acoshf_ulp!(0, @float.not_a_number)
  assert_acoshf_ulp!(27, 3.9886410236358643)
  assert_acoshf_ulp!(-27, @float.not_a_number)
  assert_acoshf_ulp!(0.125, @float.not_a_number)
  assert_acoshf_ulp!(-0.125, @float.not_a_number)
  assert_acoshf_ulp!(0.5, @float.not_a_number)
  assert_acoshf_ulp!(-0.5, @float.not_a_number)
  assert_acoshf_ulp!(1.5, 0.9624236822128296)
  assert_acoshf_ulp!(-1.5, @float.not_a_number)
  assert_acoshf_ulp!(2, 1.316957950592041)
  assert_acoshf_ulp!(-2, @float.not_a_number)
  assert_acoshf_ulp!(3, 1.7627471685409546)
  assert_acoshf_ulp!(-3, @float.not_a_number)
  assert_acoshf_ulp!(64, 4.851969242095947)
  assert_acoshf_ulp!(-64, @float.neg_infinity)
  assert_acoshf_ulp!(1000, 7.600902080535889)
  assert_acoshf_ulp!(-1000, 3.8712010383605957)
  assert_acoshf_ulp!(512, 6.93147087097168)
  assert_acoshf_ulp!(729, 7.284820556640625)
  assert_acoshf_ulp!(3511808, 15.764789581298828)
  assert_acoshf_ulp!(15.25, 3.4166500568389893)
  assert_acoshf_ulp!(6859, 9.526464462280273)
  assert_acoshf_ulp!(68.25, 4.916270732879639)
  assert_acoshf_ulp!(701.625, 7.246545791625977)
  assert_acoshf_ulp!(@float.not_a_number, @float.not_a_number)
  assert_acoshf_ulp!(@float.infinity, @float.infinity)
  assert_acoshf_ulp!(@float.neg_infinity, @float.not_a_number)
}
