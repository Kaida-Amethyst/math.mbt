///| Compute hyperbolic tangent function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(tanh(-0.5), -0.46211715726000974)
/// assert_eq!(tanh(0.5), 0.46211715726000974)
/// assert_eq!(tanh(0.0), 0.0)
/// assert_eq!(tanh(1), 0.7615941559557649)
/// assert_eq!(tanh(2), 0.9640275800758169)
/// ```
///
/// # Special Cases
///
/// 1. tanh(NaN) = NaN
/// 2. tanh(+inf) = 1
/// 3. tanh(-inf) = -1
///
/// # Accuracy
///
/// 2 ulp.
pub fn tanh(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if ispinf(x) {
    return 1.0
  }
  if isninf(x) {
    return -1.0
  }
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let tiny = 1.0e-300
  let z = if ix < 0x40360000 {
    if ix < 0x3c800000 {
      x * (1.0 + x)
    } else if ix >= 0x3ff00000 {
      let t = expm1(2.0 * fabs(x))
      1.0 - 2.0 / (t + 2.0)
    } else {
      let t = expm1(-2.0 * fabs(x))
      -t / (t + 2.0)
    }
  } else {
    1.0 - tiny
  }
  if x >= 0.0 {
    z
  } else {
    -z
  }
}

///|
test "tanh" {
  fn assert_tanh_ulp(input, expect) raise {
    assert_ulp(expect, tanh(input), TANH_MAX_ULP)
  }

  assert_tanh_ulp(-0.8, -0.6640367702678491)
  assert_tanh_ulp(-0.7, -0.6043677771171636)
  assert_tanh_ulp(-0.6, -0.5370495669980353)
  assert_tanh_ulp(-0.5, -0.46211715726000974)
  assert_tanh_ulp(-0.4, -0.3799489622552249)
  assert_tanh_ulp(-0.3, -0.2913126124515909)
  assert_tanh_ulp(-0.2, -0.197375320224904)
  assert_tanh_ulp(-0.1, -0.09966799462495582)
  assert_tanh_ulp(-0, -0)
  assert_tanh_ulp(-3.141592653589793, -0.99627207622075)
  assert_tanh_ulp(-1.5707963267948966, -0.9171523356672744)
  assert_tanh_ulp(-0.7853981633974483, -0.6557942026326724)
  assert_tanh_ulp(0, 0)
  assert_tanh_ulp(0.1, 0.09966799462495582)
  assert_tanh_ulp(0.2, 0.197375320224904)
  assert_tanh_ulp(0.3, 0.2913126124515909)
  assert_tanh_ulp(0.4, 0.3799489622552249)
  assert_tanh_ulp(0.5, 0.46211715726000974)
  assert_tanh_ulp(0.6, 0.5370495669980353)
  assert_tanh_ulp(0.7, 0.6043677771171636)
  assert_tanh_ulp(0.8, 0.6640367702678491)
  assert_tanh_ulp(0.9, 0.7162978701990245)
  assert_tanh_ulp(1, 0.7615941559557649)
  assert_tanh_ulp(3.141592653589793, 0.99627207622075)
  assert_tanh_ulp(1.5707963267948966, 0.9171523356672744)
  assert_tanh_ulp(0.7853981633974483, 0.6557942026326724)
  assert_tanh_ulp(-1, -0.7615941559557649)
  assert_tanh_ulp(-2, -0.9640275800758169)
  assert_tanh_ulp(-3, -0.9950547536867305)
  assert_tanh_ulp(-4, -0.999329299739067)
  assert_tanh_ulp(-5, -0.9999092042625951)
  assert_tanh_ulp(-6, -0.9999877116507956)
  assert_tanh_ulp(-7, -0.9999983369439447)
  assert_tanh_ulp(-8, -0.9999997749296758)
  assert_tanh_ulp(-9, -0.999999969540041)
  assert_tanh_ulp(1, 0.7615941559557649)
  assert_tanh_ulp(2, 0.9640275800758169)
  assert_tanh_ulp(3, 0.9950547536867305)
  assert_tanh_ulp(4, 0.999329299739067)
  assert_tanh_ulp(5, 0.9999092042625951)
  assert_tanh_ulp(6, 0.9999877116507956)
  assert_tanh_ulp(7, 0.9999983369439447)
  assert_tanh_ulp(8, 0.9999997749296758)
  assert_tanh_ulp(9, 0.999999969540041)
  assert_tanh_ulp(10, 0.9999999958776927)
  assert_tanh_ulp(100, 1)
  assert_tanh_ulp(1000, 1)
  assert_tanh_ulp(10000, 1)
  assert_tanh_ulp(2.5, 0.9866142981514303)
  assert_tanh_ulp(3.4, 0.9977749279342794)
  assert_tanh_ulp(5.3, 0.9999501692221211)
  assert_tanh_ulp(6.2, 0.9999917628565104)
  assert_tanh_ulp(7.1, 0.9999986384046582)
  assert_tanh_ulp(8.9, 0.9999999627961221)
  assert_tanh_ulp(9.8, 0.9999999938502403)
  assert_tanh_ulp(10.7, 0.9999999989834516)
  assert_tanh_ulp(101.6, 1)
  assert_tanh_ulp(1.542, 0.9124558296639592)
  assert_tanh_ulp(2.846, 0.9932769945490828)
  assert_tanh_ulp(7.881, 0.9999997144512194)
  assert_tanh_ulp(3.772, 0.9989420074167165)
  assert_tanh_ulp(-1.542, -0.9124558296639592)
  assert_tanh_ulp(-2.846, -0.9932769945490828)
  assert_tanh_ulp(-7.881, -0.9999997144512194)
  assert_tanh_ulp(-3.772, -0.9989420074167165)
  assert_tanh_ulp(-1, -0.7615941559557649)
  assert_tanh_ulp(0, 0)
  assert_tanh_ulp(-0, -0)
  assert_tanh_ulp(@double.not_a_number, @double.not_a_number)
  assert_tanh_ulp(@double.infinity, 1)
  assert_tanh_ulp(@double.neg_infinity, -1)
}
