///| Return the inverse hyperbolic cosine of x.
/// # Introduction
///
/// Returns the inverse hyperbolic cosine of `x`, defined as the value `y` such that `x = cosh(y)`.
///
/// # Special cases
///
/// 1. If `x` is less than 1, the result is `NaN`.
/// 2. If `x` is `NaN`, the result is `NaN`.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
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
pub fn acosh(x: Double) -> Double {
  let one = 1.0
  let ln2 = 6.93147180559945286227e-01 // 0x3FE62E42, 0xFEFA39EF
  let hx = __hi(x).reinterpret_as_int()
  if hx < 0x3ff00000 {
    // x < 1
    return (x - x) / (x - x)
  } else if hx >= 0x41b00000 {
    // x > 2**28
    if hx >= 0x7ff00000 {
      // x is inf of NaN
      return x + x
    } else {
      return log(x) + ln2
    }
  } else if ((hx - 0x3ff00000) | __low(x).reinterpret_as_int()) == 0 {
    return 0.0
  } else if hx > 0x40000000 {
    // 2**28 > x > 2
    let t = x * x
    return log(2.0 * x - one / (x + sqrt(t - one)))
  } else {
    // 1 < x < 2
    let t = x - one
    return log1p(t + sqrt(2.0 * t + t * t))
  }
}
