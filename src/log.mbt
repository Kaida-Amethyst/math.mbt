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
///| Return the logrithm of x
/// # Introduction:
///
///  Return the logrithm of x
///
/// # Special cases:
///
/// 1. log(x) is NaN with signal if x < 0 (including -INF).
/// 2. log(+INF) is +INF.
/// 3. log(0) is -INF with signal.
///
/// # Accuracy:
/// 
/// according to an error analysis, the error is always less than
/// 
/// 1 ulp (unit in the last place).
pub fn log(input: Double) -> Double {
  let mut x = input
  let ln2_hi = 6.93147180369123816490e-01
  let ln2_lo = 1.90821492927058770002e-10
  let two54 = 1.80143985094819840000e+16
  let lg1 = 6.666666666666735130e-01
  let lg2 = 3.999999999940941908e-01
  let lg3 = 2.857142874366239149e-01
  let lg4 = 2.222219843214978396e-01
  let lg5 = 1.818357216161805012e-01
  let lg6 = 1.531383769920937332e-01
  let lg7 = 1.479819860511658591e-01
  let zero = 0.0

  let mut hx = __hi(x)
  let lx = __low(x)

  let mut k :UInt = 0
  if hx < 0x00100000 {
    if ((hx & 0x7fffffff) | lx) == 0 {
      return -two54 / zero
    }
    if hx < 0 {
      return (x - x) / zero
    }
    k -= 54
    x *= two54
    hx = __hi(x)
  }
  if hx >= 0x7ff00000 {
    return x + x
  }
  k += (hx >> 20) - 1023
  hx = hx & 0x000fffff
  let i = (hx + 0x95f64) & 0x100000
  x = __combine((hx|(i ^ 0x3ff00000)).to_uint64(), lx.to_uint64());
  k += (i >> 20)
  let f = x - 1.0
  if (0x000fffff & (2 + hx.reinterpret_as_int())) < 3 {
    if f == zero {
      if k == 0 {
        return zero
      } else {
        let dk = k.to_uint64().to_double()
        return dk * ln2_hi + dk * ln2_lo
      }
    }
    let r = f * f * (0.5 - 0.33333333333333333 * f)
    if k == 0 {
      return f - r
    } else {
      let dk = k.to_uint64().to_double()
      return dk * ln2_hi - ((r - dk * ln2_lo) - f)
    }
  }
  let s = f / (2.0 + f)
  let dk = k.to_uint64().to_double()
  let z = s * s
  let mut i = hx - 0x6147a
  let w = z * z
  let j = 0x6b851 - hx.reinterpret_as_int()
  let t1 = w * (lg2 + w * (lg4 + w * lg6))
  let t2 = z * (lg1 + w * (lg3 + w * (lg5 + w * lg7)))
  i = i | j.reinterpret_as_uint()
  let r = t2 + t1
  if i > 0 {
    let hfsq = 0.5 * f * f
    if k == 0 {
      return f - (hfsq - s * (hfsq + r))
    } else {
      return dk * ln2_hi - ((hfsq - (s * (hfsq + r) + dk * ln2_lo)) - f)
    }
  } else {
    if k == 0 {
      return f - s * (f - r)
    } else {
      return dk * ln2_hi - ((s * (f - r) - dk * ln2_lo) - f)
    }
  }
}

test "log" {
  fn assert_log_ulp(input: Double, expect_result: Double) -> Unit!Error {
    assert_ulp!(expect_result, log(input), log_max_ulp)
  }
  assert_log_ulp!(1, 0)
  assert_log_ulp!(2, 0.6931471805599453)
  assert_log_ulp!(3, 1.0986122886681098)
  assert_log_ulp!(4, 1.3862943611198906)
  assert_log_ulp!(5, 1.6094379124341003)
  assert_log_ulp!(6, 1.791759469228055)
  assert_log_ulp!(7, 1.9459101490553132)
  assert_log_ulp!(8, 2.0794415416798357)
  assert_log_ulp!(9, 2.1972245773362196)
  assert_log_ulp!(10, 2.302585092994046)
  assert_log_ulp!(100, 4.605170185988092)
  assert_log_ulp!(1000, 6.907755278982137)
  assert_log_ulp!(10000, 9.210340371976184)
  assert_log_ulp!(2.5, 0.9162907318741551)
  assert_log_ulp!(3.4, 1.2237754316221157)
  assert_log_ulp!(5.3, 1.667706820558076)
  assert_log_ulp!(6.2, 1.824549292051046)
  assert_log_ulp!(7.1, 1.9600947840472698)
  assert_log_ulp!(8.9, 2.186051276738094)
  assert_log_ulp!(9.8, 2.2823823856765264)
  assert_log_ulp!(10.7, 2.3702437414678603)
  assert_log_ulp!(101.6, 4.6210435351443815)
  assert_log_ulp!(1.542, 0.4330802751411378)
  assert_log_ulp!(2.846, 1.0459144996676606)
  assert_log_ulp!(7.881, 2.0644547993715126)
  assert_log_ulp!(3.772, 1.327605364771211)
  // assert_log_ulp!(-1, double_nan)
  assert_log_ulp!(0, double_neg_inf)
  // assert_log_ulp!(-0, double_neg_inf)
  assert_log_ulp!(double_nan, double_nan)
}
