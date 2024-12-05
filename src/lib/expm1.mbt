///| Return exp(x)-1
///
/// # Introduction
///
/// Computes the exponential of `x` minus one.
///
/// # Special cases
///
/// 1. expm1(INF) is INF
/// 2. expm1(NaN) is NaN
/// 3. expm1(-INF) is -1
/// 4. for finite argument, only expm1(0) is exact.
/// 5. if x > 7.09782712893383973096e+02 then expm1(x) overflows
///
/// # Accuracy
///
/// According to an error analysis, the error is always less than
/// 1 ulp (unit in the last place).
//  * Method
//  *   1. Argument reduction:
//  *	Given x, find r and integer k such that
//  *
//  *               x = k*ln2 + r,  |r| <= 0.5*ln2 ~ 0.34658  
//  *
//  *      Here a correction term c will be computed to compensate 
//  *	the error in r when rounded to a floating-point number.
//  *
//  *   2. Approximating expm1(r) by a special rational function on
//  *	the interval [0,0.34658]:
//  *	Since
//  *	    r*(exp(r)+1)/(exp(r)-1) = 2+ r^2/6 - r^4/360 + ...
//  *	we define R1(r*r) by
//  *	    r*(exp(r)+1)/(exp(r)-1) = 2+ r^2/6 * R1(r*r)
//  *	That is,
//  *	    R1(r**2) = 6/r *((exp(r)+1)/(exp(r)-1) - 2/r)
//  *		     = 6/r * ( 1 + 2.0*(1/(exp(r)-1) - 1/r))
//  *		     = 1 - r^2/60 + r^4/2520 - r^6/100800 + ...
//  *      We use a special Remes algorithm on [0,0.347] to generate 
//  * 	a polynomial of degree 5 in r*r to approximate R1. The 
//  *	maximum error of this polynomial approximation is bounded 
//  *	by 2**-61. In other words,
//  *	    R1(z) ~ 1.0 + Q1*z + Q2*z**2 + Q3*z**3 + Q4*z**4 + Q5*z**5
//  *	where 	Q1  =  -1.6666666666666567384E-2,
//  * 		Q2  =   3.9682539681370365873E-4,
//  * 		Q3  =  -9.9206344733435987357E-6,
//  * 		Q4  =   2.5051361420808517002E-7,
//  * 		Q5  =  -6.2843505682382617102E-9;
//  *  	(where z=r*r, and the values of Q1 to Q5 are listed below)
//  *	with error bounded by
//  *	    |                  5           |     -61
//  *	    | 1.0+Q1*z+...+Q5*z   -  R1(z) | <= 2 
//  *	    |                              |
//  *	
//  *	expm1(r) = exp(r)-1 is then computed by the following 
//  * 	specific way which minimize the accumulation rounding error: 
//  *			       2     3
//  *			      r     r    [ 3 - (R1 + R1*r/2)  ]
//  *	      expm1(r) = r + --- + --- * [--------------------]
//  *		              2     2    [ 6 - r*(3 - R1*r/2) ]
//  *	
//  *	To compensate the error in the argument reduction, we use
//  *		expm1(r+c) = expm1(r) + c + expm1(r)*c 
//  *			   ~ expm1(r) + c + r*c 
//  *	Thus c+r*c will be added in as the correction terms for
//  *	expm1(r+c). Now rearrange the term to avoid optimization 
//  * 	screw up:
//  *		        (      2                                    2 )
//  *		        ({  ( r    [ R1 -  (3 - R1*r/2) ]  )  }    r  )
//  *	 expm1(r+c)~r - ({r*(--- * [--------------------]-c)-c} - --- )
//  *	                ({  ( 2    [ 6 - r*(3 - R1*r/2) ]  )  }    2  )
//  *                      (                                             )
//  *    	
//  *		   = r - E
//  *   3. Scale back to obtain expm1(x):
//  *	From step 1, we have
//  *	   expm1(x) = either 2^k*[expm1(r)+1] - 1
//  *		    = or     2^k*[expm1(r) + (1-2^-k)]
//  *   4. Implementation notes:
//  *	(A). To save one multiplication, we scale the coefficient Qi
//  *	     to Qi*2^i, and replace z by (x^2)/2.
//  *	(B). To achieve maximum accuracy, we compute expm1(x) by
//  *	  (i)   if x < -56*ln2, return -1.0, (raise inexact if x!=inf)
//  *	  (ii)  if k=0, return r-E
//  *	  (iii) if k=-1, return 0.5*(r-E)-0.5
//  *        (iv)	if k=1 if r < -0.25, return 2*((r+0.5)- E)
//  *	       	       else	     return  1.0+2.0*(r-E);
//  *	  (v)   if (k<-2||k>56) return 2^k(1-(E-r)) - 1 (or exp(x)-1)
//  *	  (vi)  if k <= 20, return 2^k((1-2^-k)-(E-r)), else
//  *	  (vii) return 2^k(1-((E+2^-k)-r)) 
pub fn expm1(x: Double) -> Double {
  let one = 1.0
  let huge = 1.0e+300
  let tiny = 1.0e-300
  let o_threshold = 7.09782712893383973096e+02
  let ln2_hi = 6.93147180369123816490e-01
  let ln2_lo = 1.90821492927058770002e-10
  let invln2 = 1.44269504088896338700e+00
  let q1 = -3.33333333333331316428e-02
  let q2 = 1.58730158725481460165e-03
  let q3 = -7.93650757867487942473e-05
  let q4 = 4.00821782732936239552e-06
  let q5 = -2.01099218183624371326e-07
  let mut x = x

  let mut hx = __hi(x)
  let xsb : Int = (hx & 0x80000000).reinterpret_as_int()
  let y:Double = if xsb == 0 { x } else { -x }
  hx = hx & 0x7fffffff
  if hx >= 0x4043687A {
    if hx >= 0x40862E42 {
      if hx >= 0x7ff00000 {
        if ((hx & 0xfffff) | __low(x)) != 0 {
          return x + x
        } else {
          return if xsb == 0 { x } else { -1.0 }
        }
      }
      if x > o_threshold {
        return huge * huge
      }
    }
    if xsb != 0 {
      if x + tiny < 0.0 {
        return tiny - one
      }
    }
  }

  let mut hi = 0.0
  let mut lo = 0.0
  let mut k = 0
  let mut c = 0.0
  if hx > 0x3fd62e42 {
    if hx < 0x3FF0A2B2 {
      hi = if xsb == 0 { x - ln2_hi } else { x + ln2_hi }
      lo = if xsb == 0 { ln2_lo } else { -ln2_lo }
      k = if xsb == 0 { 1 } else { -1 }
    } else {
      k = (invln2 * x +(if xsb == 0 { 0.5 } else { -0.5 })).to_int()
      let t:Double = k.to_double()
      hi = x - t * ln2_hi
      lo = t * ln2_lo
    }
    x = hi - lo
    c = (hi - x) - lo
  } else if hx < 0x3c900000 {
    let t:Double = huge + x
    return x - (t - (huge + x))
  } else {
    k = 0
  }
  let hfx: Double = 0.5 * x
  let hxs: Double = x * hfx
  let r1: Double = one + hxs * (q1 + hxs * (q2 + hxs * (q3 + hxs * (q4 + hxs * q5))))
  let t: Double = 3.0 - r1 * hfx
  let e: Double = hxs * ((r1 - t) / (6.0 - x * t))
  if k == 0 {
    return x - (x * e - hxs)
  } else {
    let e: Double = (x * (e - c) - c)
    let e: Double = e - hxs
    if k == -1 {
      return 0.5 * (x - e) - 0.5
    }
    if k == 1 {
      return if x < -0.25 { -2.0 * (e - (x + 0.5)) } else { one + 2.0 * (x - e) }
    }
    if k <= -2 || k > 56 {
      let mut y: Double = one - (e - x)
      // __hi(y) += k << 20
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
      return y - one
    }
    let mut t: Double = one
    if k < 20 {
      // __hi(t) = 0x3ff00000 - (0x200000 >> k)
      t = __combineW((0x3ff00000 - (0x200000 >> k)).reinterpret_as_uint(), 0)
      let mut y: Double = t - (e - x)
      // __hi(y) += k << 20
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
    } else {
      t = __combineW(((0x3ff - k) << 20).reinterpret_as_uint(), 0)
      let mut y: Double = x - (e + t) + one
      // __hi(y) += k << 20
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
    }
  }
  return y
}
