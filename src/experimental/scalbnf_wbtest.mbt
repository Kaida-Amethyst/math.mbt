///|
test "scalbnf" {
  fn assert_scalbnf_ulp(input1, input2, expect) raise {
    @ulp.assert_float_ulp(expect, scalbnf(input1, input2), SCALBN_F_MAX_ULP)
  }

  assert_scalbnf_ulp(1, 1, 2)
  assert_scalbnf_ulp(3, 5, 96)
  assert_scalbnf_ulp(-2, 1, -4)
  assert_scalbnf_ulp(-5, 3, -40)
  assert_scalbnf_ulp(9, 6, 576)
  assert_scalbnf_ulp(7, 11, 14336)
  assert_scalbnf_ulp(6.5, -3, 0.8125)
  assert_scalbnf_ulp(-7.25, 8, -1856)
  assert_scalbnf_ulp(-52.5, -625, 0)
  assert_scalbnf_ulp(12, 13, 98304)
  assert_scalbnf_ulp(7, 16, 458752)
  assert_scalbnf_ulp(19, 33, 163208757248)
  assert_scalbnf_ulp(@float.infinity, 11, @float.infinity)
  assert_scalbnf_ulp(@float.neg_infinity, 11, @float.neg_infinity)
  assert_scalbnf_ulp(@float.not_a_number, 0, @float.not_a_number)
}
