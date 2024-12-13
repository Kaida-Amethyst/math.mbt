// /* Tanh(x)
//  * Return the Hyperbolic Tangent of x
//  *
//  * Method :
//  *				       x    -x
//  *				      e  - e
//  *	0. tanh(x) is defined to be -----------
//  *				       x    -x
//  *				      e  + e
//  *	1. reduce x to non-negative by tanh(-x) = -tanh(x).
//  *	2.  0      <= x <= 2**-55 : tanh(x) := x*(one+x)
//  *					        -t
//  *	    2**-55 <  x <=  1     : tanh(x) := -----; t = expm1(-2x)
//  *					       t + 2
//  *						     2
//  *	    1      <= x <=  22.0  : tanh(x) := 1-  ----- ; t=expm1(2x)
//  *						   t + 2
//  *	    22.0   <  x <= INF    : tanh(x) := 1.
//  *
//  * Special cases:
//  *	tanh(NaN) is NaN;
//  *	only tanh(0)=0 is exact for finite argument.
//  */
///| Compute hyperbolic tangent function of a double-precision floating point number.
///
/// # Special Cases
///
/// 1. tanh(x) is x if x is NaN.
/// 2. tanh(x) is 1 if x is +INF.
pub fn tanh(x: Double) -> Double {
  if isnan(x) {
    return x
  }

  if ispinf(x) {
    return 1.0
  }

  if isninf(x) {
    return -1.0
  }

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff

  let tiny = 1.0e-300

  let z = if ix < 0x40360000 {
    if ix < 0x3c800000 {
      x * (1.0 + x)
    } else if ix >= 0x3ff00000 {
      let t = expm1(2.0 * fabs(x))
      1.0 - 2.0 / (t + 2.0)
    } else {
      let t = expm1(-2.0 * fabs(x))
      -t / (t + 2.0)
    }
  } else {
    1.0 - tiny
  }

  if x >= 0.0 {
    z
  } else {
    -z
  }
}
