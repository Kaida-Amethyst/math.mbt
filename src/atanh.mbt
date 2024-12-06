///| hyperbolic arctangent of ``x``.
/// # Introduction:
///
///   atanh(x) returns the hyperbolic arctangent of x.
///
/// # Special cases:
///
/// 1. atanh(x) is NaN if |x| > 1 with signal;
/// 2. atanh(NaN) is that NaN with no signal;
/// 3. atanh(+-1) is +-INF with signal.
///
/// # Accuracy:
///
/// 1ulp (unit in the last place).
//  * Method :
//  *    1.Reduced x to positive by atanh(-x) = -atanh(x)
//  *    2.For x>=0.5
//  *                  1              2x                          x
//  *	atanh(x) = --- * log(1 + -------) = 0.5 * log1p(2 * --------)
//  *                  2             1 - x                      1 - x
//  *	
//  * 	For x<0.5
//  *	atanh(x) = 0.5*log1p(2x+2x*x/(1-x))
//  *
pub fn atanh(x: Double) -> Double {
  let hx : Int = __hi(x).reinterpret_as_int()
  let lx : Int = __low(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if (ix | ((lx | (-lx)) >> 31)) > 0x3ff00000 {
    return (x - x) / (x - x)
  }
  if ix == 0x3ff00000 {
    return x / 0.0
  }
  if ix < 0x3e300000 && (1.0e300 + x) > 0.0 {
    return x
  }
  let _x = __combineW(ix.reinterpret_as_uint(), lx.reinterpret_as_uint())
  let t = if ix < 0x3fe00000 {
    let t = x + x
    0.5 * log1p(t + t * x / (1.0 - x))
  } else {
    0.5 * log1p((x + x) / (1.0 - x))
  }
  if hx >= 0 {
    t
  } else {
    -t
  }
}
