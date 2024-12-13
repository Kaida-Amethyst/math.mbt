///| Compute x pow of y, where x is a double and y is a double.
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
pub fn pow(base: Double, expon: Double) -> Double {
  let x = base
  let y = expon
  let bp = [1.0, 1.5]
  let dp_h = [0.0, 5.84962487220764160156e-01]
  let dp_l = [0.0, 1.35003920212974897128e-08]
  let zero = 0.0
  let one = 1.0
  let two = 2.0
  let two53 = 9007199254740992.0
  let huge = 1.0e300
  let tiny = 1.0e-300

  let l1  =  5.99999999999994648725e-01  // 0x3FE33333, 0x33333303
  let l2  =  4.28571428578550184252e-01 // 0x3FDB6DB6, 0xDB6FABFF
  let l3  =  3.33333329818377432918e-01 // 0x3FD55555, 0x518F264D
  let l4  =  2.72728123808534006489e-01 // 0x3FD17460, 0xA91D4101
  let l5  =  2.30660745775561754067e-01 // 0x3FCD864A, 0x93C9DB65
  let l6  =  2.06975017800338417784e-01 // 0x3FCA7E28, 0x4A454EEF
  let p1   =  1.66666666666666019037e-01 // 0x3FC55555, 0x5555553E
  let p2   = -2.77777777770155933842e-03 // 0xBF66C16C, 0x16BEBD93
  let p3   =  6.61375632143793436117e-05 // 0x3F11566A, 0xAF25DE2C
  let p4   = -1.65339022054652515390e-06 // 0xBEBBBD41, 0xC5D26BF1
  let p5   =  4.13813679705723846039e-08 // 0x3E663769, 0x72BEA4D0
  let lg2  =  6.93147180559945286227e-01 // 0x3FE62E42, 0xFEFA39EF
  let lg2_h  =  6.93147182464599609375e-01 // 0x3FE62E43, 0x00000000
  let lg2_l  = -1.90465429995776804525e-09 // 0xBE205C61, 0x0CA86C39
  let ovt =  8.0085662595372944372e-0017 // -(1024-log2(ovfl+.5ulp))
  let cp    =  9.61796693925975554329e-01 // 0x3FEEC709, 0xDC3A03FD =2/(3ln2)
  let cp_h  =  9.61796700954437255859e-01 // 0x3FEEC709, 0xE0000000 =(float)cp
  let cp_l  = -7.02846165095275826516e-09 // 0xBE3E2FE0, 0x145B01F5 =tail of cp_h
  let ivln2    =  1.44269504088896338700e+00 // 0x3FF71547, 0x652B82FE =1/ln2
  let ivln2_h  =  1.44269502162933349609e+00 // 0x3FF71547, 0x60000000 =24b 1/ln2
  let ivln2_l  =  1.92596299112661746887e-08 // 0x3E54AE0B, 0xF85DDF44 =1/ln2 tail

  let (hx, lx) : (Int, Int) = (__hi(x).reinterpret_as_int(), __low(x).reinterpret_as_int())
  let (hy, ly) : (Int, Int) = (__hi(y).reinterpret_as_int(), __low(y).reinterpret_as_int())
  let mut ix = hx & 0x7fffffff
  let iy = hy & 0x7fffffff

  // y==zero: x**0 = 1
  if (iy | ly) == 0 {
    return one
  }

  // +-NaN return x+y
  if (isnan(x) || isnan(y)) {
    return double_nan
  }

  // determine if y is an odd int when x < 0
  // yisint = 0	... y is not an integer
  // yisint = 1	... y is an odd int
  // yisint = 2	... y is an even int
  let mut yisint = 0
  let mut k = 0
  if hx < 0 {
    if iy >= 0x43400000 {
      yisint = 2
    } else if iy >= 0x3ff00000 {
      k = (iy >> 20) - 0x3ff
      if k > 20 {
        let j = ly >> (52 - k)
        if (j << (52 - k)) == ly {
          yisint = 2 - (j & 1)
        }
      } else if ly == 0 {
        let j = iy >> (20 - k)
        if (j << (20 - k)) == iy {
          yisint = 2 - (j & 1)
        }
      }
    }
  }

  // special value of y
  if ly == 0 {
    if iy == 0x7ff00000 {
      // y is +-inf
      if ((ix - 0x3ff00000) | lx) == 0 {
        return y - y
      } else if ix >= 0x3ff00000 {
        return if hy >= 0 { y } else { zero }
      } else {
        return if hy < 0 { -y } else { zero }
      }
    }
    if iy == 0x3ff00000 {
      // y is  +-1
      return if hy < 0 { one / x } else { x }
    }
    if hy == 0x40000000 {
      return x * x
    }
    if hy == 0x3fe00000 {
      // y is  0.5
      if hx >= 0 {
        // x >= +0
        return x.sqrt()
      }
    }
  }

  let mut ax = fabs(x)
  // special value of x
  if lx == 0 {
    if ix == 0x7ff00000 || ix == 0 || ix == 0x3ff00000 {
      let mut z = ax
      if hy < 0 {
        z = one / z
      }
      if hx < 0 {
        if ((ix - 0x3ff00000) | yisint) == 0 {
          z = (z - z) / (z - z)
        } else if yisint == 1 {
          z = -z
        }
      }
      return z
    }
  }

  let mut n = (hx >> 31) + 1
  // (x<0)**(non-int) is NaN
  if (n | yisint) == 0 {
    return (x - x) / (x - x)
  }
  let mut s = one

  if (n | (yisint - 1)) == 0 {
    s = -one
  }

  // |y| is huge
  let mut t1 = 0.0
  let mut t2 = 0.0
  let mut u = 0.0
  let mut v = 0.0
  let mut w = 0.0
  let mut p_h = 0.0
  let mut p_l = 0.0
  let mut z_h = 0.0
  let mut z_l = 0.0
  let mut t = 0.0

  if iy > 0x41e00000 {
    // if |y| > 2**31
    if iy > 0x43f00000 {
      // if |y| > 2**64, must o/uflow
      if ix <= 0x3fefffff {
        return if hy < 0 { huge * huge } else { tiny * tiny }
      }
      if ix >= 0x3ff00000 {
        return if hy > 0 { huge * huge } else { tiny * tiny }
      }
    }
    // over/underflow if x is not close to one
    if ix < 0x3fefffff {
      return if hy < 0 { s * huge * huge } else { s * tiny * tiny }
    }
    if ix > 0x3ff00000 {
      return if hy > 0 { s * huge * huge } else { s * tiny * tiny }
    }
    // now |1-x| is tiny <= 2**-20, suffice to compute log(x) by x-x^2/2+x^3/3-x^4/4
    let t = ax - one
    // t has 20 trailing zeros
    let w = (t * t) * (0.5 - t * (0.3333333333333333333333 - t * 0.25))
    u = ivln2_h * t
    // ivln2_h has 21 sig. bits
    v = t * ivln2_l - w * ivln2
    let mut t1 = u + v
    t1 = __combineW(__hi(t1), 0)
    t2 = v - (t1 - u)
  } else {
    n = 0
    // take care subnormal number
    if ix < 0x00100000 {
      ax *= two53
      n -= 53
      ix = __hi(ax).reinterpret_as_int()
    }
    n += ((ix) >> 20) - 0x3ff
    let j = ix & 0x000fffff
    // determine interval
    ix = j | 0x3ff00000
    if j <= 0x3988E {
      k = 0
    } else if j < 0xBB67A {
      k = 1
    } else {
      k = 0
      n += 1
      ix -= 0x00100000
    }
    ax = __combineW(__hi(ax), ix.reinterpret_as_uint())

    u = ax - bp[k]
    // bp[0]=1.0, bp[1]=1.5
    v = one / (ax + bp[k])
    let ss = u * v
    let mut s_h = ss
    s_h = __combineW(__hi(s_h), 0)
    let t_h = __combineW((((ix >> 1) | 0x20000000) + 0x00080000 + (k << 18)).reinterpret_as_uint(), 0)
    let t_l = ax - (t_h - bp[k])
    let s_l = v * ((u - s_h * t_h) - s_h * t_l)
    let s2 = ss * ss
    let mut r = s2 * s2 * (l1 + s2 * (l2 + s2 * (l3 + s2 * (l4 + s2 * (l5 + s2 * l6)))))
    r += s_l * (s_h + ss)
    let s2 = s_h * s_h
    let t_h = 3.0 + s2 + r
    let t_h = __combineW(__hi(t_h), 0)
    let t_l = r - ((t_h - 3.0) - s2)
    u = s_h * t_h
    v = s_l * t_h + t_l * ss
    p_h = u + v
    p_h = __combineW(__hi(p_h), 0)
    p_l = v - (p_h - u)
    z_h = cp_h * p_h
    z_l = cp_l * p_h + p_l * cp + dp_l[k]
    t = n.to_double()
    t1 = (((z_h + z_l) + dp_h[k]) + t)
    t1 = __combineW(__hi(t1), 0)
    t2 = z_l - (((t1 - t) - dp_h[k]) - z_h)
  }

  // split up y into y1+y2 and compute (y1+y2)*(t1+t2)
  let y1 = y
  let y1 = __combineW(__hi(y1), 0)
  p_l = (y - y1) * t1 + y * t2
  p_h = y1 * t1
  let z = p_l + p_h
  let j = __hi(z)
  let i = __low(z)
  if j >= 0x40900000 {
    // z >= 1024
    if ((j - 0x40900000) | i) != 0 {
      // if z > 1024
      return s * huge * huge
    } else {
      if p_l + ovt > z - p_h {
        return s * huge * huge
      }
    }
  } else if (j & 0x7fffffff) >= 0x4090cc00 {
    // z <= -1075
    if ((j - 0xc090cc00) | i) != 0 {
      // z < -1075
      return s * tiny * tiny
    } else {
      if p_l <= z - p_h {
        return s * tiny * tiny
      }
    }
  }

  // compute 2**(p_h+p_l)
  let i = j & 0x7fffffff
  k = ((i >> 20) - 0x3ff).reinterpret_as_int()
  n = 0
  if i > 0x3fe00000 {
    // if |z| > 0.5, set n = [z+0.5]
    n = (j + (0x00100000 >> (k + 1)).reinterpret_as_uint()).reinterpret_as_int()
    k = ((n & 0x7fffffff) >> 20) - 0x3ff
    let t = __combineW((n & (if (0x000fffff >> k) > 0 {0} else {1})).reinterpret_as_uint(), 0)
    n = ((n & 0x000fffff) | 0x00100000) >> (20 - k)
    if j < 0 {
      n = -n
    }
    p_h -= t
  }

  let t = p_l + p_h

  let t = __combineW(__hi(t), 0)
  u = t * lg2_h
  v = (p_l - (t - p_h)) * lg2 + t * lg2_l
  let z = u + v
  w = v - (z - u)
  let t = z * z
  t1 = z - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))))
  let r = (z * t1) / (t1 - two) - (w + z * w)
  let mut z = one - (r - z)
  let j = __hi(z).reinterpret_as_int() + (n << 20)
  if (j >> 20) <= 0 {
    z = scalbn(z, n)
  } else {
    z = __combineW(__hi(z) + (n << 20).reinterpret_as_uint(), __low(z))
  }
  return s * z;
}

// #include "fdlibm.h"
//
// #ifdef __STDC__
// static const double one = 1.0, half=0.5, huge = 1.0e300;
// #else
// static double one = 1.0, half=0.5, huge = 1.0e300;
// #endif
//
// #ifdef __STDC__
// 	double __ieee754_cosh(double x)
// #else
// 	double __ieee754_cosh(x)
// 	double x;
// #endif
// {	
// 	double t,w;
// 	int ix;
// 	unsigned lx;
//
//     /* High word of |x|. */
// 	ix = __HI(x);
// 	ix &= 0x7fffffff;
//
//     /* x is INF or NaN */
// 	if(ix>=0x7ff00000) return x*x;	
//
//     /* |x| in [0,0.5*ln2], return 1+expm1(|x|)^2/(2*exp(|x|)) */
// 	if(ix<0x3fd62e43) {
// 	    t = expm1(fabs(x));
// 	    w = one+t;
// 	    if (ix<0x3c800000) return w;	/* cosh(tiny) = 1 */
// 	    return one+(t*t)/(w+w);
// 	}
//
//     /* |x| in [0.5*ln2,22], return (exp(|x|)+1/exp(|x|)/2; */
// 	if (ix < 0x40360000) {
// 		t = __ieee754_exp(fabs(x));
// 		return half*t+half/t;
// 	}
//
//     /* |x| in [22, log(maxdouble)] return half*exp(|x|) */
// 	if (ix < 0x40862E42)  return half*__ieee754_exp(fabs(x));
//
//     /* |x| in [log(maxdouble), overflowthresold] */
// 	lx = *( (((*(unsigned*)&one)>>29)) + (unsigned*)&x);
// 	if (ix<0x408633CE || 
// 	      (ix==0x408633ce)&&(lx<=(unsigned)0x8fb9f87d)) {
// 	    w = __ieee754_exp(half*fabs(x));
// 	    t = half*w;
// 	    return t*w;
// 	}
//
//     /* |x| > overflowthresold, cosh(x) overflow */
// 	return huge*huge;
// }

