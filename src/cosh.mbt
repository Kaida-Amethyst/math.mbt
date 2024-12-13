///| Compute hyperbolic cosine function of a double-precision floating point number.
///
/// # Special Cases
///
/// 1. cosh(x) is |x| if x is +INF, -INF, or NaN.
/// 2. Only cosh(0)=1 is exact for finite x.
// Method : 
// mathematically cosh(x) if defined to be (exp(x)+exp(-x))/2
// 1. Replace x by |x| (cosh(x) = cosh(-x)). 
// 2. 
// 	                                        [ exp(x) - 1 ]^2 
//     0        <= x <= ln2/2  :  cosh(x) := 1 + -------------------
// 		       			           2*exp(x)
// 
// 	                                  exp(x) +  1/exp(x)
//     ln2/2    <= x <= 22     :  cosh(x) := -------------------
// 		       			          2
//     22       <= x <= lnovft :  cosh(x) := exp(x)/2 
//     lnovft   <= x <= ln2ovft:  cosh(x) := exp(x/2)/2 * exp(x/2)
//     ln2ovft  <  x	    :  cosh(x) := huge*huge (overflow)
// 
// Special cases:
// cosh(x) is |x| if x is +INF, -INF, or NaN.
// only cosh(0)=1 is exact for finite x.
pub fn cosh(x: Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff

  if ix < 0x3fd62e43 {
    let t = expm1(fabs(x))
    let w = 1.0 + t
    if ix < 0x3c800000 {
      return w
    }
    return 1.0 + (t * t) / (w + w)
  }

  if ix < 0x40360000 {
    let t = exp(fabs(x))
    return 0.5 * t + 0.5 / t
  }

  if ix < 0x40862E42 {
    return 0.5 * exp(fabs(x))
  }

  let lx = __low(x).reinterpret_as_int()
  if ix < 0x408633ce || (ix == 0x408633ce && lx <= 0x8fb9f87d) {
    let w = exp(0.5 * fabs(x))
    let t = 0.5 * w
    return t * w
  }

  double_pos_inf
}

// #ifdef __STDC__
// static const double one=1.0, two=2.0, tiny = 1.0e-300;
// #else
// static double one=1.0, two=2.0, tiny = 1.0e-300;
// #endif
//
// #ifdef __STDC__
// 	double tanh(double x)
// #else
// 	double tanh(x)
// 	double x;
// #endif
// {
// 	double t,z;
// 	int jx,ix;
//
//     /* High word of |x|. */
// 	jx = __HI(x);
// 	ix = jx&0x7fffffff;
//
//     /* x is INF or NaN */
// 	if(ix>=0x7ff00000) { 
// 	    if (jx>=0) return one/x+one;    /* tanh(+-inf)=+-1 */
// 	    else       return one/x-one;    /* tanh(NaN) = NaN */
// 	}
//
//     /* |x| < 22 */
// 	if (ix < 0x40360000) {		/* |x|<22 */
// 	    if (ix<0x3c800000) 		/* |x|<2**-55 */
// 		return x*(one+x);    	/* tanh(small) = small */
// 	    if (ix>=0x3ff00000) {	/* |x|>=1  */
// 		t = expm1(two*fabs(x));
// 		z = one - two/(t+two);
// 	    } else {
// 	        t = expm1(-two*fabs(x));
// 	        z= -t/(t+two);
// 	    }
//     /* |x| > 22, return +-1 */
// 	} else {
// 	    z = one - tiny;		/* raised inexact flag */
// 	}
// 	return (jx>=0)? z: -z;
// }

