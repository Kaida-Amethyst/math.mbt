// /* __ieee754_sinh(x)
//  * Method : 
//  * mathematically sinh(x) if defined to be (exp(x)-exp(-x))/2
//  *	1. Replace x by |x| (sinh(-x) = -sinh(x)). 
//  *	2. 
//  *		                                    E + E/(E+1)
//  *	    0        <= x <= 22     :  sinh(x) := --------------, E=expm1(x)
//  *			       			        2
//  *
//  *	    22       <= x <= lnovft :  sinh(x) := exp(x)/2 
//  *	    lnovft   <= x <= ln2ovft:  sinh(x) := exp(x/2)/2 * exp(x/2)
//  *	    ln2ovft  <  x	    :  sinh(x) := x*shuge (overflow)
//  *
//  * Special cases:
//  *	sinh(x) is |x| if x is +INF, -INF, or NaN.
//  *	only sinh(0)=0 is exact for finite x.
//  */
///| Compute hyperbolic sine function of a double-precision floating point number.
///
/// # Special Cases
///
/// 1. sinh(x) is |x| if x is +INF, -INF, or NaN.
/// 2. Only sinh(0)=0 is exact for finite x.
pub fn sinh(x: Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let abs_x = fabs(x)
  let shuge = 1.0e307
  
  let h = if x < 0.0 { -0.5 } else { 0.5 }

  if ix < 0x40360000 {
    if ix < 0x3e300000 {
      if shuge + x > 1.0 {
        return x
      }
    }
    let t = expm1(abs_x)
    if ix < 0x3ff00000 {
      return h * (2.0 * t - t * t / (t + 1.0))
    }
    return h * (t + t / (t + 1.0))
  }

  if ix < 0x40862E42 {
    return h * exp(abs_x)
  }

  if abs_x.reinterpret_as_uint64() < 0x408633ce8fb9f87d {
    let w = exp(0.5 * abs_x)
    let t = h * w
    return t * w
  }

  x * shuge
}
