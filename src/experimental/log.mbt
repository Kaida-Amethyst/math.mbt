//Method :
//
//  1. Argument Reduction: find k and f such that
//
// 		x = 2^k * (1+f),
//
//    where  sqrt(2)/2 < 1+f < sqrt(2) .
//  2. Approximation of log(1+f).
// Let s = f/(2+f) ; based on log(1+f) = log(1+s) - log(1-s)
// 	 = 2s + 2/3 s**3 + 2/5 s**5 + .....,
//      	 = 2s + s*R
//     We use a special Reme algorithm on [0,0.1716] to generate
//	a polynomial of degree 14 to approximate R The maximum error
// of this polynomial approximation is bounded by 2**-58.45. In
// other words,
// 	        2      4      6      8      10      12      14
//     R(z) ~ Lg1*s +Lg2*s +Lg3*s +Lg4*s +Lg5*s  +Lg6*s  +Lg7*s
// 	(the values of Lg1 to Lg7 are listed in the program)
// and
//     |      2          14          |     -58.45
//     | Lg1*s +...+Lg7*s    -  R(z) | <= 2
//     |                             |
// Note that 2s = f - s*f = f - hfsq + s*hfsq, where hfsq = f*f/2.
// In order to guarantee error in log below 1ulp, we compute log
// by
// 	log(1+f) = f - s*(f - R)	(if f is not too large)
// 	log(1+f) = f - (hfsq - s*(hfsq+R)).	(better accuracy)
// 3. Finally,  log(x) = k*ln2 + log(1+f).
// 		    = k*ln2_hi+(f-(hfsq-(s*(hfsq+R)+k*ln2_lo)))
//    Here ln2 is split into two floating point number:
// 		ln2_hi + ln2_lo,
//    where n*ln2_hi is always exact for |n| < 2000.
//
//Special cases:
// log(x) is NaN with signal if x < 0 (including -INF) ;
// log(+INF) is +INF; log(0) is -INF with signal;
// log(NaN) is that NaN with no signal.
//

///|
/// Return the logarithm of x
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(log(0.1), -2.3025850929940455)
/// assert_eq(log(1), 0)
/// assert_eq(log(2), 0.6931471805599453)
/// ```
///
/// # Special cases:
///
/// 1. log(x) = NaN for all x < 0 (including -inf).
/// 2. log(+inf) = +inf.
/// 3. log(+-0) = -inf
///
/// # Accuracy:
///
/// 0 ulp
pub fn log(x : Double) -> Double {
  let l1 = 6.666666666666735130e-01 // 3FE55555 55555593
  let l2 = 3.999999999940941908e-01 // 3FD99999 9997FA04
  let l3 = 2.857142874366239149e-01 // 3FD24924 94229359
  let l4 = 2.222219843214978396e-01 // 3FCC71C5 1D8E78AF
  let l5 = 1.818357216161805012e-01 // 3FC74664 96CB03DE
  let l6 = 1.531383769920937332e-01 // 3FC39A09 D078C69F
  let l7 = 1.479819860511658591e-01 // 3FC2F112 DF3E5244
  let ln2_hi = 6.93147180369123816490e-01 // 3fe62e42 fee00000
  let ln2_lo = 1.90821492927058770002e-10 // 3dea39ef 35793c76
  if x < 0.0 {
    return @double.not_a_number
  } else if x.is_nan() || x.is_inf() {
    return x
  } else if x == 0.0 {
    return @double.neg_infinity
  }
  let (f1, ki) = frexp(x)
  let (f, k) = if f1 < SQRT2 / 2.0 {
    (f1 * 2.0 - 1.0, (ki - 1).to_double())
  } else {
    (f1 - 1.0, ki.to_double())
  }
  let s = f / (2.0 + f)
  let s2 = s * s
  let s4 = s2 * s2
  let t1 = s2 * (l1 + s4 * (l3 + s4 * (l5 + s4 * l7)))
  let t2 = s4 * (l2 + s4 * (l4 + s4 * l6))
  let r = t1 + t2
  let hfsq = 0.5 * f * f
  k * ln2_hi - (hfsq - (s * (hfsq + r) + k * ln2_lo) - f)
}

///|
pub let ln : (Double) -> Double = log
