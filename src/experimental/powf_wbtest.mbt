///|
test "powf" {
  fn assert_powf_ulp(input1, input2, expect) raise {
    @ulp.assert_float_ulp(expect, powf(input1, input2), POW_F_MAX_ULP)
  }

  assert_powf_ulp(1, 1, 1)
  assert_powf_ulp(3, 5, 243)
  assert_powf_ulp(-2, 1, -2)
  assert_powf_ulp(-5, 3, -125)
  assert_powf_ulp(9, 6, 531441)
  assert_powf_ulp(7, 11, 1977326720)
  assert_powf_ulp(6.5, -3.25, 0.0022805079352110624)
  assert_powf_ulp(-7.25, 8.625, @float.not_a_number)
  assert_powf_ulp(-52.5, -625.5, @float.not_a_number)
  assert_powf_ulp(12, 13, 106993205379072)
  assert_powf_ulp(7, 16, 33232930209792)
  assert_powf_ulp(19, 33, @float.infinity)
  assert_powf_ulp(@float.infinity, 11, @float.infinity)
  assert_powf_ulp(13, @float.infinity, @float.infinity)
  assert_powf_ulp(@float.neg_infinity, -10.5, 0)
  assert_powf_ulp(-12.5, @float.neg_infinity, 0)
  assert_powf_ulp(@float.not_a_number, 0, 1)
  assert_powf_ulp(0, @float.not_a_number, @float.not_a_number)
  assert_powf_ulp(@float.infinity, @float.infinity, @float.infinity)
  assert_powf_ulp(@float.infinity, @float.neg_infinity, 0)
  assert_powf_ulp(@float.neg_infinity, @float.infinity, @float.infinity)
  assert_powf_ulp(@float.neg_infinity, @float.neg_infinity, 0)
}
