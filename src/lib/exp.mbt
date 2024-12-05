///|Returns the exponential of x.
///|
///|Method
///|  1. Argument reduction:
///|     Reduce x to an r so that |r| <= 0.5*ln2 ~ 0.34658.
///| Given x, find r and integer k such that
///|
///|              x = k*ln2 + r,  |r| <= 0.5*ln2.  
///|
///|     Here r will be represented as r = hi-lo for better 
///| accuracy.
///|
///|  2. Approximation of exp(r) by a special rational function on
///| the interval [0,0.34658]:
///| Write
///|     R(r**2) = r*(exp(r)+1)/(exp(r)-1) = 2 + r*r/6 - r**4/360 + ...
///|     We use a special Remes algorithm on [0,0.34658] to generate 
///|	a polynomial of degree 5 to approximate R. The maximum error 
///| of this polynomial approximation is bounded by 2**-59. In
///| other words,
///|     R(z) ~ 2.0 + P1*z + P2*z**2 + P3*z**3 + P4*z**4 + P5*z**5
///| 	(where z=r*r, and the values of P1 to P5 are listed below)
///| and
///|     |                  5          |     -59
///|     | 2.0+P1*z+...+P5*z   -  R(z) | <= 2 
///|     |                             |
///| The computation of exp(r) thus becomes
///|                            2*r
///| 	exp(r) = 1 + -------
///| 	              R - r
///|                                r*R1(r)	
///| 	       = 1 + r + ----------- (for better accuracy)
///| 	                  2 - R1(r)
///| where
///| 		         2       4             10
///| 	R1(r) = r - (P1*r  + P2*r  + ... + P5*r   ).
///| 
///|  3. Scale back to obtain exp(x):
///| From step 1, we have
///|    exp(x) = 2^k * exp(r)
///|
///|Special cases:
///| exp(INF) is INF, exp(NaN) is NaN;
///| exp(-INF) is 0, and
///| for finite argument, only exp(0)=1 is exact.
///|
///|Accuracy:
///| according to an error analysis, the error is always less than
///| 1 ulp (unit in the last place).
///|
///|Misc. info.
///| For IEEE double 
///|     if x >  7.09782712893383973096e+02 then exp(x) overflow
///|     if x < -7.45133219101941108420e+02 then exp(x) underflow
///|
///|Constants:
///|The hexadecimal values are the intended ones for the following 
///|constants. The decimal values may be used, provided that the 
///|compiler will convert from decimal to binary accurately enough
///|to produce the hexadecimal values shown.
pub fn exp(input : Double) -> Double {
  let mut x = input
  let one = 1.0
  let halF = [0.5, -0.5]
  let o_threshold = 7.09782712893383973096e+02
  let u_threshold = -7.45133219101941108420e+02
  let ln2HI = [6.93147180369123816490e-01, -6.93147180369123816490e-01]
  let ln2LO = [1.90821492927058770002e-10, -1.90821492927058770002e-10]
  let invln2 = 1.44269504088896338700e+00
  let p1 = 1.66666666666666019037e-01
  let p2 = -2.77777777770155933842e-03
  let p3 = 6.61375632143793436117e-05
  let p4 = -1.65339022054652515390e-06
  let p5 = 4.13813679705723846039e-08
  let e = 2.718281828459045
  let mut hi = 0.0
  let mut lo = 0.0
  let huge = 1.0e+300
  let twom1000 = 9.33263618503218878990e-302
  let two1023 = 8.988465674311579539e307
  let mut k : Int = 0
  let mut hx : UInt = __hi(input)
  let xsb : Int = ((hx >> 31) & 1).reinterpret_as_int()
  hx = hx & 0x7FFFFFFF
  if hx >= 0x40862E42 {
    if hx >= 0x7FF00000 {
      let lx : UInt = __low(input)
      if ((hx & 0xFFFFF) | lx) != 0 {
        return input + input
      } else if xsb == 0 {
        return input
      } else {
        return 0.0
      }
    }
    if input > o_threshold {
      return huge * huge
    }
    if input < u_threshold {
      return twom1000 * twom1000
    }
  }
  if hx > 0x3FD62E42 {
    if hx < 0x3FF0A2B2 {
      if input == 1.0 {
        return e
      }
      hi = input - ln2HI[xsb]
      lo = ln2LO[xsb]
      k = 1 - xsb - xsb
    } else {
      k = (invln2 * input + halF[xsb]).to_int()
      let t = k.to_double()
      hi = input - t * ln2HI[0]
      lo = t * ln2LO[0]
    }
    x = hi - lo
  } else if hx < 0x3E300000 {
    if huge + x > one {
      return one + x
    }
  } else {
    k = 0
  }
  let t = x * x
  let twopk = if k >= -1021 {
    __combine(
      (0x3FF00000 + (k.reinterpret_as_uint() << 20).reinterpret_as_int())
      .to_int64()
      .reinterpret_as_uint64(),
      0,
    )
  } else {
    __combine(
      0x3FF00000UL + ((k + 1000).reinterpret_as_uint() << 20).to_uint64(),
      0,
    )
  }
  let c = x - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))))
  if k == 0 {
    return one - (x * c / (c - 2.0) - x)
  }
  let y = one - (lo - x * c / (2.0 - c) - hi)
  if k >= -1021 {
    if k == 1024 {
      return y * 2.0 * two1023
    } else {
      return y * twopk
    }
  } else {
    return y * twopk * twom1000
  }
}

// ```c
// #include "fdlibm.h"
//
// #ifdef __STDC__
// static const double
// #else
// static double
// #endif
// ln2_hi  =  6.93147180369123816490e-01,	/* 3fe62e42 fee00000 */
// ln2_lo  =  1.90821492927058770002e-10,	/* 3dea39ef 35793c76 */
// two54   =  1.80143985094819840000e+16,  /* 43500000 00000000 */
// Lg1 = 6.666666666666735130e-01,  /* 3FE55555 55555593 */
// Lg2 = 3.999999999940941908e-01,  /* 3FD99999 9997FA04 */
// Lg3 = 2.857142874366239149e-01,  /* 3FD24924 94229359 */
// Lg4 = 2.222219843214978396e-01,  /* 3FCC71C5 1D8E78AF */
// Lg5 = 1.818357216161805012e-01,  /* 3FC74664 96CB03DE */
// Lg6 = 1.531383769920937332e-01,  /* 3FC39A09 D078C69F */
// Lg7 = 1.479819860511658591e-01;  /* 3FC2F112 DF3E5244 */
//
// static double zero   =  0.0;
//
// #ifdef __STDC__
// 	double __ieee754_log(double x)
// #else
// 	double __ieee754_log(x)
// 	double x;
// #endif
// {
// 	double hfsq,f,s,z,R,w,t1,t2,dk;
// 	int k,hx,i,j;
// 	unsigned lx;
//
// 	hx = __HI(x);		/* high word of x */
// 	lx = __LO(x);		/* low  word of x */
//
// 	k=0;
// 	if (hx < 0x00100000) {			/* x < 2**-1022  */
// 	    if (((hx&0x7fffffff)|lx)==0) 
// 		return -two54/zero;		/* log(+-0)=-inf */
// 	    if (hx<0) return (x-x)/zero;	/* log(-#) = NaN */
// 	    k -= 54; x *= two54; /* subnormal number, scale up x */
// 	    hx = __HI(x);		/* high word of x */
// 	} 
// 	if (hx >= 0x7ff00000) return x+x;
// 	k += (hx>>20)-1023;
// 	hx &= 0x000fffff;
// 	i = (hx+0x95f64)&0x100000;
// 	__HI(x) = hx|(i^0x3ff00000);	/* normalize x or x/2 */
// 	k += (i>>20);
// 	f = x-1.0;
// 	if((0x000fffff&(2+hx))<3) {	/* |f| < 2**-20 */
// 	    if(f==zero) if(k==0) return zero;  else {dk=(double)k;
// 				 return dk*ln2_hi+dk*ln2_lo;}
// 	    R = f*f*(0.5-0.33333333333333333*f);
// 	    if(k==0) return f-R; else {dk=(double)k;
// 	    	     return dk*ln2_hi-((R-dk*ln2_lo)-f);}
// 	}
//  	s = f/(2.0+f); 
// 	dk = (double)k;
// 	z = s*s;
// 	i = hx-0x6147a;
// 	w = z*z;
// 	j = 0x6b851-hx;
// 	t1= w*(Lg2+w*(Lg4+w*Lg6)); 
// 	t2= z*(Lg1+w*(Lg3+w*(Lg5+w*Lg7))); 
// 	i |= j;
// 	R = t2+t1;
// 	if(i>0) {
// 	    hfsq=0.5*f*f;
// 	    if(k==0) return f-(hfsq-s*(hfsq+R)); else
// 		     return dk*ln2_hi-((hfsq-(s*(hfsq+R)+dk*ln2_lo))-f);
// 	} else {
// 	    if(k==0) return f-s*(f-R); else
// 		     return dk*ln2_hi-((s*(f-R)-dk*ln2_lo)-f);
// 	}
// }
// ```

