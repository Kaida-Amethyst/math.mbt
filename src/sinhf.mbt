///| Compute hyperbolic sine function of a single-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq(sinhf(-0.5), -0.5210953054937474)
/// assert_eq(sinhf(0.0), 0.0)
/// assert_eq(sinhf(0.5), 0.5210953054937474)
/// assert_eq(sinhf(1.0), 1.1752011936438014)
/// ```
///
/// # Special Cases
///
/// 1. sinhf(NaN) = NaN
/// 2. sinhf(+inf) = +inf
/// 3. sinhf(-inf) = -inf
///
/// # Accuracy
///
/// 0 ulp.
pub fn sinhf(x : Float) -> Float {
  let mut h : Float = 0.5
  let mut ix = x.reinterpret_as_uint()
  if ix >> 31 != 0 {
    h = -h
  }
  // |x|
  ix = ix & 0x7fffffff
  let absx = ix.reinterpret_as_float()
  let w = ix

  // |x| < log(FLT_MAX)
  if w < 0x42b17217 {
    let t = expm1f(absx)
    if w < 0x3f800000 {
      if w < 0x3f800000U - (12U << 23) {
        return x
      }
      return h * ((2.0 : Float) * t - t * t / (t + 1.0))
    }
    return h * (t + t / (t + 1.0))
  }

  // |x| > logf(FLT_MAX) or nan
  h * k_expo2f(absx) * 2.0
}

///|
test "sinhf" {
  fn assert_sinhf_ulp(input, expect) raise {
    assert_float_ulp(expect, sinhf(input), SINH_F_MAX_ULP)
  }

  assert_sinhf_ulp(-1, -1.175201177597046)
  assert_sinhf_ulp(1, 1.175201177597046)
  assert_sinhf_ulp(8, 1490.4788818359375)
  assert_sinhf_ulp(-8, -1490.4788818359375)
  assert_sinhf_ulp(0, 0)
  assert_sinhf_ulp(27, 266024124416)
  assert_sinhf_ulp(-27, -266024124416)
  assert_sinhf_ulp(0.125, 0.1253257691860199)
  assert_sinhf_ulp(-0.125, -0.1253257691860199)
  assert_sinhf_ulp(0.5, 0.5210952758789062)
  assert_sinhf_ulp(-0.5, -0.5210952758789062)
  assert_sinhf_ulp(1.5, 2.129279375076294)
  assert_sinhf_ulp(-1.5, -2.129279375076294)
  assert_sinhf_ulp(2, 3.6268603801727295)
  assert_sinhf_ulp(-2, -3.6268603801727295)
  assert_sinhf_ulp(3, 10.017874717712402)
  assert_sinhf_ulp(-3, -10.017874717712402)
  assert_sinhf_ulp(64, 3.11757471602483e+27)
  assert_sinhf_ulp(-64, -3.11757471602483e+27)
  assert_sinhf_ulp(1000, @float.infinity)
  assert_sinhf_ulp(-1000, @float.neg_infinity)
  assert_sinhf_ulp(512, @float.infinity)
  assert_sinhf_ulp(729, @float.infinity)
  assert_sinhf_ulp(3511808, @float.infinity)
  assert_sinhf_ulp(15.25, 2098750.75)
  assert_sinhf_ulp(6859, @float.infinity)
  assert_sinhf_ulp(68.25, 2.1855884661877316e+29)
  assert_sinhf_ulp(701.625, @float.infinity)
}
