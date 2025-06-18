// asinh(x)
// Method :
// Based on 
// 	asinh(x) = sign(x) * log [ |x| + sqrt(x*x+1) ]
// we have
// asinh(x) := x  if  1+x*x=1,
// 	 := sign(x)*(log(x)+ln2)) for large |x|, else
// 	 := sign(x)*log(2|x|+1/(|x|+sqrt(x*x+1))) if|x|>2, else
// 	 := sign(x)*log1p(|x| + x^2/(1 + sqrt(1+x^2)))

///| Compute the inverse hyperbolic sine of `x`.
///
/// Computes the inverse hyperbolic sine of `x`. The inverse hyperbolic sine is defined as:
/// $$\text{asinh}(x) = \log(x + \sqrt{x^2 + 1})$$
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(asinh(-1), -0.881373587019543)
/// assert_eq!(asinh(-2), -1.4436354751788103)
/// assert_eq!(asinh(1), 0.881373587019543)
/// assert_eq!(asinh(2), 1.4436354751788103)
/// ```
///
/// # Special Cases
///
/// 1. asinh(NaN) = NaN.
/// 2. asinh(±0) = ±0.
/// 3. asinh(±∞) = ±∞.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
pub fn asinh(x : Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }
  let one : Double = 1.0
  let ln2 : Double = 6.93147180559945286227e-01
  let huge : Double = 1.0e300
  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix < 0x3e300000 {
    if huge + x > one {
      return x
    }
  }
  let w : Double = if ix > 0x41b00000 {
    log(fabs(x)) + ln2
  } else if ix > 0x40000000 {
    let t = fabs(x)
    log(2.0 * t + one / (sqrt(x * x + one) + t))
  } else {
    let t = x * x
    log1p(fabs(x) + t / (one + sqrt(one + t)))
  }
  if hx > 0 {
    w
  } else {
    -w
  }
}

///|
test "asinh" {
  fn assert_asinh_ulp(input, expect) raise {
    assert_ulp(expect, asinh(input), ASINH_MAX_ULP)
  }

  assert_asinh_ulp(-1, -0.881373587019543)
  assert_asinh_ulp(-2, -1.4436354751788103)
  assert_asinh_ulp(-3, -1.8184464592320668)
  assert_asinh_ulp(-4, -2.0947125472611012)
  assert_asinh_ulp(-5, -2.3124383412727525)
  assert_asinh_ulp(-6, -2.491779852644912)
  assert_asinh_ulp(-7, -2.644120761058629)
  assert_asinh_ulp(-8, -2.7764722807237177)
  assert_asinh_ulp(-9, -2.8934439858858716)
  assert_asinh_ulp(1, 0.881373587019543)
  assert_asinh_ulp(2, 1.4436354751788103)
  assert_asinh_ulp(3, 1.8184464592320668)
  assert_asinh_ulp(4, 2.0947125472611012)
  assert_asinh_ulp(5, 2.3124383412727525)
  assert_asinh_ulp(6, 2.491779852644912)
  assert_asinh_ulp(7, 2.644120761058629)
  assert_asinh_ulp(8, 2.7764722807237177)
  assert_asinh_ulp(9, 2.8934439858858716)
  assert_asinh_ulp(10, 2.99822295029797)
  assert_asinh_ulp(100, 5.298342365610589)
  assert_asinh_ulp(1000, 7.600902709541988)
  assert_asinh_ulp(10000, 9.903487555036127)
  assert_asinh_ulp(2.5, 1.6472311463710958)
  assert_asinh_ulp(3.4, 1.9378792776645006)
  assert_asinh_ulp(5.3, 2.3696374478085054)
  assert_asinh_ulp(6.2, 2.524137570200328)
  assert_asinh_ulp(7.1, 2.658164806954139)
  assert_asinh_ulp(8.9, 2.8823397863009728)
  assert_asinh_ulp(9.8, 2.9781225426278812)
  assert_asinh_ulp(10.7, 3.0655674012135137)
  assert_asinh_ulp(101.6, 5.314214933622987)
  assert_asinh_ulp(1.542, 1.2178370752124148)
  assert_asinh_ulp(2.846, 1.7685886800290045)
  assert_asinh_ulp(7.881, 2.761602999110176)
  assert_asinh_ulp(3.772, 2.0378777304008615)
  assert_asinh_ulp(-1.542, -1.2178370752124148)
  assert_asinh_ulp(-2.846, -1.7685886800290045)
  assert_asinh_ulp(-7.881, -2.761602999110176)
  assert_asinh_ulp(-3.772, -2.0378777304008615)
  assert_asinh_ulp(-1, -0.881373587019543)
  assert_asinh_ulp(0, 0)
  assert_asinh_ulp(-0, -0)
  assert_asinh_ulp(@double.not_a_number, @double.not_a_number)
  assert_asinh_ulp(@double.infinity, @double.infinity)
  assert_asinh_ulp(@double.neg_infinity, @double.neg_infinity)
}
