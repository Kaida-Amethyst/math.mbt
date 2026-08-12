///|
test "entr" {
  @ulp.assert_ulp(entr(0.0), 0.0, 0)
  @ulp.assert_ulp(entr(0.5), 0.34657359027997264, 0)
  @ulp.assert_ulp(entr(1.0), 0.0, 0)
  @ulp.assert_ulp(entr(@double.infinity), @double.neg_infinity, 0)
  @ulp.assert_ulp(entr(@double.not_a_number), @double.not_a_number, 0)
  @ulp.assert_ulp(entr(-0.0), 0.0, 0)
  @ulp.assert_ulp(entr(-0.5), @double.neg_infinity, 0)
}
