//  Method :
//  Based on
//  	acosh(x) = log [ x + sqrt(x*x-1) ]
//  we have
//  	acosh(x) := log(x)+ln2,	if x is large; else
//  	acosh(x) := log(2x-1/(sqrt(x*x-1)+x)) if x>2; else
//  	acosh(x) := log1p(t+sqrt(2.0*t+t*t)); where t=x-1.
//
//  Special cases:
//  acosh(x) is NaN with signal if x<1.
//  acosh(NaN) is NaN without signal.
//

///|
/// Return the inverse hyperbolic cosine of x.
///
/// Returns the inverse hyperbolic cosine of `x`, defined as the value `y` such that `x = cosh(y)`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(acosh(1.0), 0.0);
/// assert_eq(acosh(2.0), 1.3169578969248166);
/// assert_eq(acosh(3.0), 1.7627471740390859);
/// assert_eq(acosh(4.0), 2.0634370688955608);
/// ```
///
/// # Special cases
///
/// 1. acosh(x) = NaN for all x < 1.
/// 2. aoosh(NaN) = NaN.
///
/// # Accuracy
///
/// 1 ulp
pub fn acosh(x : Double) -> Double {
  let one = 1.0
  let ln2 = 6.93147180559945286227e-01 // 0x3FE62E42, 0xFEFA39EF
  let hx = __hi(x).reinterpret_as_int()
  if x < 1.0 || isnan(x) {
    // x < 1
    return @double.not_a_number
  } else if x == 1.0 {
    return 0.0
  } else if ispinf(x) {
    return @double.infinity
  } else if hx >= 0x41b00000 {
    // x > 2**28
    return log(x) + ln2
  } else if hx > 0x40000000 {
    // 2**28 > x > 2
    let t = x * x
    return log(2.0 * x - one / (x + @math.sqrt(t - one)))
  } else {
    // 1 < x < 2
    let t = x - one
    return @math.log1p(t + @math.sqrt(2.0 * t + t * t))
  }
}
