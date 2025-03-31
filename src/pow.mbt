///| Compute x pow of y, where x is a double and y is a double.
/// # Introduction:
///
///   Compute `x**y` where `x` is a double and `y` is a double.
///
/// # Special cases:
///
/// 1.  (anything) ** 0  is 1  
/// 2.  (anything) ** 1  is itself  
/// 3.  (anything) ** NAN is NAN  
/// 4.  NAN ** (anything except 0) is NAN  
/// 5.  +-(|x| > 1) **  +INF is +INF  
/// 6.  +-(|x| > 1) **  -INF is +0  
/// 7.  +-(|x| < 1) **  +INF is +0  
/// 8.  +-(|x| < 1) **  -INF is +INF  
/// 9.  +-1         ** +-INF is NAN  
/// 10. +0 ** (+anything except 0, NAN)               is +0  
/// 11. -0 ** (+anything except 0, NAN, odd integer)  is +0  
/// 12. +0 ** (-anything except 0, NAN)               is +INF  
/// 13. -0 ** (-anything except 0, NAN, odd integer)  is +INF  
/// 14. -0 ** (odd integer) = -( +0 ** (odd integer) )  
/// 15. +INF ** (+anything except 0,NAN) is +INF  
/// 16. +INF ** (-anything except 0,NAN) is +0  
/// 17. -INF ** (anything)  = -0 ** (-anything)  
/// 18. (-anything) ** (integer) is (-1)**(integer)*(+anything**integer)  
/// 19. (-anything except 0 and inf) ** (non-integer) is NAN  
///
///# Accuracy:
///
/// pow(x,y) returns x**y nearly rounded. In particular `pow(integer,integer)`
/// always returns the correct integer provided it is 
/// representable.
///
/// 2 ulp (units in the last place) are added for rounding.
pub fn pow(base : Double, expon : Double) -> Double {
  base.pow(expon)
}

///|
test "pow" {
  fn assert_pow_ulp!(base, exponent, expect) {
    assert_ulp!(expect, pow(base, exponent), POW_MAX_ULP)
  }

  assert_pow_ulp!(2.0, 3.0, 8.0)
  assert_pow_ulp!(3.0, 2.0, 9.0)
  assert_pow_ulp!(5.0, 3.0, 125.0)
  assert_pow_ulp!(10.0, 2.0, 100.0)
  assert_pow_ulp!(2.0, 10.0, 1024.0)
  assert_pow_ulp!(1.5, 2.0, 2.25)
  assert_pow_ulp!(2.5, 3.0, 15.625)
  assert_pow_ulp!(10.0, 0.5, 3.1622776601683795)
  assert_pow_ulp!(8.0, 1.0 / 3.0, 2.0)
  assert_pow_ulp!(-2.0, 3.0, -8.0)
  assert_pow_ulp!(-3.0, 2.0, 9.0)
  assert_pow_ulp!(-5.0, 3.0, -125.0)
  assert_pow_ulp!(-1.5, 2.0, 2.25)
  assert_pow_ulp!(-2.5, 3.0, -15.625)
  assert_pow_ulp!(-2.0, -3.0, -0.125)
  assert_pow_ulp!(-3.0, -2.0, 0.1111111111111111)
  assert_pow_ulp!(-5.0, -3.0, -0.008)
  assert_pow_ulp!(-1.5, -2.0, 0.4444444444444444)
  assert_pow_ulp!(-2.5, -3.0, -0.064)
  assert_pow_ulp!(2.0, -3.0, 0.125)
  assert_pow_ulp!(3.0, -2.0, 0.1111111111111111)
  assert_pow_ulp!(5.0, -3.0, 0.008)
  assert_pow_ulp!(10.0, -2.0, 0.01)
  assert_pow_ulp!(1.5, -2.0, 0.4444444444444444)
  assert_pow_ulp!(2.5, -3.0, 0.064)
  assert_pow_ulp!(0.0, 0.0, 1.0)
  assert_pow_ulp!(0.0, 5.0, 0.0)
  assert_pow_ulp!(0.0, -5.0, @double.infinity)
  assert_pow_ulp!(1.0, 100.0, 1.0)
  assert_pow_ulp!(1.0, -100.0, 1.0)
  assert_pow_ulp!(-1.0, 100.0, 1.0)
  assert_pow_ulp!(-1.0, 101.0, -1.0)
  assert_pow_ulp!(@double.not_a_number, 2.0, @double.not_a_number)
  assert_pow_ulp!(2.0, @double.not_a_number, @double.not_a_number)
  assert_pow_ulp!(@double.infinity, 2.0, @double.infinity)
  assert_pow_ulp!(2.0, @double.infinity, @double.infinity)
  assert_pow_ulp!(@double.neg_infinity, 2.0, @double.infinity)
  assert_pow_ulp!(2.0, @double.neg_infinity, 0.0)
  assert_pow_ulp!(-2.0, @double.infinity, @double.infinity)
  assert_pow_ulp!(-2.0, @double.neg_infinity, 0.0)
  assert_pow_ulp!(0.0, @double.infinity, 0.0)
  assert_pow_ulp!(0.0, @double.neg_infinity, @double.infinity)
  assert_pow_ulp!(@double.neg_infinity, -2.0, 0.0)
  assert_pow_ulp!(@double.neg_infinity, -3.0, -0.0)
  assert_pow_ulp!(1.4142, 3.1415, 2.9705015380568383)
  assert_pow_ulp!(10.0, 0.1, 1.2589254117941673)
  assert_pow_ulp!(2.7182, 3.1415, 23.136360554262573)
}
