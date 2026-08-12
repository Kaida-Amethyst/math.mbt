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

///|
/// Compute hyperbolic cosine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(cosh(0), 1)
/// assert_eq(cosh(1), 1.5430806348152437)
/// assert_eq(cosh(2), 3.7621956910836314)
/// assert_eq(cosh(3), 10.067661995777765)
/// assert_eq(cosh(-1), 1.5430806348152437)
/// ```
///
/// # Special Cases
///
/// 1. cosh(x) is |x| if x is +INF, -INF, or NaN.
/// 2. Only cosh(0)=1 is exact for finite x.
///
/// # Accuracy
///
/// 0 ulp.
pub fn cosh(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if isinf(x) {
    return @double.infinity
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  if ix < 0x3fd62e43 {
    let t = expm1(fabs(x))
    let w = 1.0 + t
    if ix < 0x3c800000 {
      return w
    }
    return 1.0 + t * t / (w + w)
  }
  if ix < 0x40360000 {
    let t = @math.exp(fabs(x))
    return 0.5 * t + 0.5 / t
  }
  if ix < 0x40862E42 {
    return 0.5 * @math.exp(fabs(x))
  }
  let lx = __low(x).reinterpret_as_int()
  if ix < 0x408633ce || (ix == 0x408633ce && lx <= 0x8fb9f87d) {
    let w = @math.exp(0.5 * fabs(x))
    let t = 0.5 * w
    return t * w
  }
  @double.infinity
}
