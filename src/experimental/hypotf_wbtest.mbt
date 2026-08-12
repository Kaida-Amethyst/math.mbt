///|
test "hypotf" {
  fn assert_hypotf_ulp(input1, input2, expect) raise {
    @ulp.assert_float_ulp(expect, hypotf(input1, input2), HYPOT_F_MAX_ULP)
  }

  assert_hypotf_ulp(1, 1, 1.4142135381698608)
  assert_hypotf_ulp(3, 5, 5.830951690673828)
  assert_hypotf_ulp(-2, 1, 2.2360680103302)
  assert_hypotf_ulp(-5, 3, 5.830951690673828)
  assert_hypotf_ulp(9, 6, 10.816654205322266)
  assert_hypotf_ulp(7, 11, 13.03840446472168)
  assert_hypotf_ulp(6.5, -3.25, 7.267220973968506)
  assert_hypotf_ulp(-7.25, 8.625, 11.267348289489746)
  assert_hypotf_ulp(-52.5, -625.5, 627.6994018554688)
  assert_hypotf_ulp(12, 13, 17.69180679321289)
  assert_hypotf_ulp(7, 16, 17.464248657226562)
  assert_hypotf_ulp(19, 33, 38.07886505126953)
  assert_hypotf_ulp(@float.infinity, 11, @float.infinity)
  assert_hypotf_ulp(13, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, -10.5, @float.infinity)
  assert_hypotf_ulp(-12.5, @float.neg_infinity, @float.infinity)
  assert_hypotf_ulp(@float.not_a_number, 0, @float.not_a_number)
  assert_hypotf_ulp(0, @float.not_a_number, @float.not_a_number)
  assert_hypotf_ulp(@float.infinity, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.infinity, @float.neg_infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, @float.neg_infinity, @float.infinity)
}
