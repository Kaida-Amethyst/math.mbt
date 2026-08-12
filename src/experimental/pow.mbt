///|
/// Compute x pow of y, where x is a double and y is a double.
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
  @core_math.pow(base, expon)
}
