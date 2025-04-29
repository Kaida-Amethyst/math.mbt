///| Compute cosine of double-precision floating-point number `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(cosf(-1.0), 0.5403023058681398)
/// assert_eq!(cosf(0.0), 1)
/// assert_eq!(cosf(1.5707963267948966), -4.371138828673793e-8)
/// assert_eq!(cosf(3.141592653589793), -1)
/// assert_eq!(cosf(10000), -0.9521553682590148)
/// ```
///
/// # Special Cases
///
/// 1. cosf(+-inf) = NaN
/// 2. cosf(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn cosf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return 1.0
  }
  let (x, q) = trig_reduce(x, COS_SWITCHOVER)
  sin_cos_core(x, q + 1)
}

///|
test "cosf" {
  fn assert_cosf_ulp!(input, expect) {
    assert_float_ulp!(expect, cosf(input), COS_F_MAX_ULP)
  }

  assert_cosf_ulp!(-1, 0.5403022766113281)
  assert_cosf_ulp!(1, 0.5403022766113281)
  assert_cosf_ulp!(8, -0.1455000340938568)
  assert_cosf_ulp!(-8, -0.1455000340938568)
  assert_cosf_ulp!(0, 1)
  assert_cosf_ulp!(27, -0.29213881492614746)
  assert_cosf_ulp!(-27, -0.29213881492614746)
  assert_cosf_ulp!(0.125, 0.9921976923942566)
  assert_cosf_ulp!(-0.125, 0.9921976923942566)
  assert_cosf_ulp!(0.5, 0.8775825500488281)
  assert_cosf_ulp!(-0.5, 0.8775825500488281)
  assert_cosf_ulp!(1.5, 0.07073719799518585)
  assert_cosf_ulp!(-1.5, 0.07073719799518585)
  assert_cosf_ulp!(2, -0.41614681482315063)
  assert_cosf_ulp!(-2, -0.41614681482315063)
  assert_cosf_ulp!(3, -0.9899924993515015)
  assert_cosf_ulp!(-3, -0.9899924993515015)
  assert_cosf_ulp!(64, 0.39185723662376404)
  assert_cosf_ulp!(-64, 0.39185723662376404)
  assert_cosf_ulp!(1000, 0.5623790621757507)
  assert_cosf_ulp!(-1000, 0.5623790621757507)
  assert_cosf_ulp!(512, -0.9968333840370178)
  assert_cosf_ulp!(729, 0.9886955618858337)
  assert_cosf_ulp!(3511808, -0.8001007437705994)
  assert_cosf_ulp!(15.25, -0.8969548344612122)
  assert_cosf_ulp!(6859, -0.6190708875656128)
  assert_cosf_ulp!(68.25, 0.6486109495162964)
  assert_cosf_ulp!(701.625, -0.49771133065223694)
  assert_cosf_ulp!(@float.not_a_number, @float.not_a_number)
  assert_cosf_ulp!(@float.infinity, @float.not_a_number)
  assert_cosf_ulp!(@float.neg_infinity, @float.not_a_number)
}
