///|
const ERFCINV_MAX_ULP : Int = 505787246

///|
test "erfcinv" {
  fn assert_erfcinv_ulp(input, expect) raise {
    @ulp.assert_ulp(expect, erfcinv(input), ERFCINV_MAX_ULP)
  }

  assert_erfcinv_ulp(-0.8, @double.infinity)
  assert_erfcinv_ulp(-0.2, @double.infinity)
  assert_erfcinv_ulp(-0.1, @double.infinity)
  assert_erfcinv_ulp(-0, @double.infinity)
  assert_erfcinv_ulp(-3.141592653589793, @double.infinity)
  assert_erfcinv_ulp(-1.5707963267948966, @double.infinity)
  assert_erfcinv_ulp(-0.7853981633974483, @double.infinity)
  assert_erfcinv_ulp(0, @double.infinity)
  assert_erfcinv_ulp(0.1, 1.1630871536766738)
  assert_erfcinv_ulp(0.2, 0.9061938024368232)
  assert_erfcinv_ulp(0.3, 0.7328690779592169)
  assert_erfcinv_ulp(0.4, 0.5951160814499948)
  assert_erfcinv_ulp(0.5, 0.4769362762044699)
  assert_erfcinv_ulp(0.6, 0.37080715859355795)
  assert_erfcinv_ulp(0.7, 0.27246271472675443)
  assert_erfcinv_ulp(0.8, 0.17914345462129164)
  assert_erfcinv_ulp(0.9, 0.08885599049425767)
  assert_erfcinv_ulp(1, 0)
  assert_erfcinv_ulp(3.141592653589793, @double.neg_infinity)
  assert_erfcinv_ulp(1.5707963267948966, -0.5590068522631568)
  assert_erfcinv_ulp(0.7853981633974483, 0.19253891596997583)
  assert_erfcinv_ulp(-1, @double.infinity)
  assert_erfcinv_ulp(-2, @double.infinity)
  assert_erfcinv_ulp(1, 0)
  assert_erfcinv_ulp(2, @double.neg_infinity)
  assert_erfcinv_ulp(3, @double.neg_infinity)
  assert_erfcinv_ulp(4, @double.neg_infinity)
  assert_erfcinv_ulp(1.542, -0.52477516419095)
  assert_erfcinv_ulp(2.846, @double.neg_infinity)
  assert_erfcinv_ulp(3.772, @double.neg_infinity)
  assert_erfcinv_ulp(-1.542, @double.infinity)
  assert_erfcinv_ulp(-2.846, @double.infinity)
  assert_erfcinv_ulp(-1, @double.infinity)
  assert_erfcinv_ulp(0, @double.infinity)
  assert_erfcinv_ulp(-0, @double.infinity)
  assert_erfcinv_ulp(@double.not_a_number, @double.not_a_number)
  assert_erfcinv_ulp(@double.infinity, @double.neg_infinity)
  assert_erfcinv_ulp(@double.neg_infinity, @double.infinity)
}
