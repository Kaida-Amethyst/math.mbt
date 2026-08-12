///|
test "atan2f" {
  fn assert_atan2f_ulp(input1, input2, expect) raise {
    @ulp.assert_float_ulp(expect, atan2f(input1, input2), ATAN2_F_MAX_ULP)
  }

  assert_atan2f_ulp(1, 1, 0.7853981852531433)
  assert_atan2f_ulp(3, 5, 0.5404195189476013)
  assert_atan2f_ulp(-2, 1, -1.1071487665176392)
  assert_atan2f_ulp(-5, 3, 1.0303767919540405)
  assert_atan2f_ulp(9, 6, 0.9827937483787537)
  assert_atan2f_ulp(7, 11, 0.5667291879653931)
  assert_atan2f_ulp(6.5, -3.25, 4.248741149902344)
  assert_atan2f_ulp(-7.25, 8.625, 0.6989995837211609)
  assert_atan2f_ulp(-52.5, -625.5, -3.0578560829162598)
  assert_atan2f_ulp(12, 13, 0.7454195022583008)
  assert_atan2f_ulp(7, 16, 0.4124104380607605)
  assert_atan2f_ulp(19, 33, 0.5224034190177917)
  assert_atan2f_ulp(@float.infinity, 11, 1.5707963705062866)
  assert_atan2f_ulp(13, @float.infinity, 0)
  assert_atan2f_ulp(@float.neg_infinity, -10.5, -1.5707963705062866)
  assert_atan2f_ulp(-12.5, @float.neg_infinity, -3.1415927410125732)
  assert_atan2f_ulp(@float.not_a_number, 0, @float.not_a_number)
  assert_atan2f_ulp(0, @float.not_a_number, @float.not_a_number)
  assert_atan2f_ulp(@float.infinity, @float.infinity, 0.7853981852531433)
  assert_atan2f_ulp(@float.infinity, @float.neg_infinity, 2.356194496154785)
  assert_atan2f_ulp(@float.neg_infinity, @float.infinity, -0.7853981852531433)
  assert_atan2f_ulp(
    @float.neg_infinity, @float.neg_infinity, -2.356194496154785,
  )
}
