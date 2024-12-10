
///| Compute the inverse hyperbolic sine of `x`.
/// # Introduction
///
/// Computes the inverse hyperbolic sine of `x`. The inverse hyperbolic sine is defined as:
/// $$\text{asinh}(x) = \log(x + \sqrt{x^2 + 1})$$
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
// asinh(x)
// Method :
// Based on 
// 	asinh(x) = sign(x) * log [ |x| + sqrt(x*x+1) ]
// we have
// asinh(x) := x  if  1+x*x=1,
// 	 := sign(x)*(log(x)+ln2)) for large |x|, else
// 	 := sign(x)*log(2|x|+1/(|x|+sqrt(x*x+1))) if|x|>2, else
// 	 := sign(x)*log1p(|x| + x^2/(1 + sqrt(1+x^2)))  
pub fn asinh(x: Double) -> Double {
  let one : Double = 1.0
  let ln2 : Double = 6.93147180559945286227e-01
  let huge : Double = 1.0e300

  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix >= 0x7ff00000 {
    return x + x
  }
  if ix < 0x3e300000 {
    if huge + x > one {
      return x
    }
  }
  let w: Double = if ix > 0x41b00000 {
    log(fabs(x)) + ln2
  } else if ix > 0x40000000 {
    let t = fabs(x)
    log(2.0 * t + one / (sqrt(x * x + one) + t))
  } else {
    let t = x * x
    log1p(fabs(x) + t / (one + sqrt(one + t)))
  }
  if hx > 0 {
    w
  } else {
    -w
  }
}
