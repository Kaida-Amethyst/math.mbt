//
//Method
// 
//  1. Argument reduction:
//     Reduce x to an r so that |r| <= 0.5*ln2 ~ 0.34658.
// Given x, find r and integer k such that
//              x = k*ln2 + r,  |r| <= 0.5*ln2.  
//     Here r will be represented as r = hi-lo for better 
// accuracy.
//
//  2. Approximation of exp(r) by a special rational function on
// the interval [0,0.34658]:
// Write
//     R(r**2) = r*(exp(r)+1)/(exp(r)-1) = 2 + r*r/6 - r**4/360 + ...
//     We use a special Remes algorithm on [0,0.34658] to generate 
//	a polynomial of degree 5 to approximate R. The maximum error 
// of this polynomial approximation is bounded by 2**-59. In
// other words,
//     R(z) ~ 2.0 + P1*z + P2*z**2 + P3*z**3 + P4*z**4 + P5*z**5
// 	(where z=r*r, and the values of P1 to P5 are listed below)
// and
//     |                  5          |     -59
//     | 2.0+P1*z+...+P5*z   -  R(z) | <= 2 
//     |                             |
// 
// The computation of exp(r) thus becomes
//                            2*r
// 	exp(r) = 1 + -------
// 	              R - r
//                                r*R1(r)	
// 	       = 1 + r + ----------- (for better accuracy)
// 	                  2 - R1(r)
// where
// 		         2       4             10
// 	R1(r) = r - (P1*r  + P2*r  + ... + P5*r   ).
//  3. Scale back to obtain exp(x):
// From step 1, we have
//    exp(x) = 2^k * exp(r)
///| # Introduction:
///
/// Compute exp(x)
///
/// # Special cases:
///   exp(INF) is INF, exp(NaN) is NaN;
///   exp(-INF) is 0, and
///   for finite argument, only exp(0)=1 is exact.
///
/// # Accuracy:
/// 
///   according to an error analysis, the error is always less than
///   1 ulp (unit in the last place).
///
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
