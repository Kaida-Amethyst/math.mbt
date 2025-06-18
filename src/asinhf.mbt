///| Compute the inverse hyperbolic sine of `x` with single-precision floating-point.
///
/// Computes the inverse hyperbolic sine of `x`. The inverse hyperbolic sine is defined as:
/// $$\text{asinh}(x) = \log(x + \sqrt{x^2 + 1})$$
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(asinhf(-1), -0.881373587019543)
/// assert_eq!(asinhf(-2), -1.4436354751788103)
/// assert_eq!(asinhf(1), 0.881373587019543)
/// assert_eq!(asinhf(2), 1.4436354751788103)
/// ```
///
/// # Special Cases
///
/// 1. asinhf(NaN) = NaN.
/// 2. asinhf(±0) = ±0.
/// 3. asinhf(±∞) = ±∞.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
pub fn asinhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let i = u & 0x7fffffff
  let sign = u >> 31 != 0
  let ln2 : Float = 0.693147180559945309417232121458176568

  // |x| */
  let x = i.reinterpret_as_float()
  let x = if i >= 0x3f800000U + (12U << 23) {
    // |x| >= 0x1p12 or inf or nan */
    logf(x) + ln2
  } else if i >= 0x3f800000U + (1U << 23) {
    // |x| >= 2 */
    logf(x * 2.0 + recipf(sqrtf(x * x + 1.0) + x))
  } else if i >= 0x3f800000U - (12U << 23) {
    // |x| >= 0x1p-12, up to 1.6ulp error in [0.125,0.5] */
    log1pf(x + x * x / (sqrtf(x * x + 1.0) + 1.0))
  } else {
    // |x| < 0x1p-12, raise inexact if x!=0 */
    // x + 0x1.0p120
    x
  }
  if sign {
    -x
  } else {
    x
  }
}

///|
test "asinhf" {
  fn assert_asinhf_ulp(input, expect) raise {
    assert_float_ulp(expect, asinhf(input), ASINH_F_MAX_ULP)
  }

  assert_asinhf_ulp(-1, -0.8813735842704773)
  assert_asinhf_ulp(1, 0.8813735842704773)
  assert_asinhf_ulp(8, 2.776472330093384)
  assert_asinhf_ulp(-8, -2.776472330093384)
  assert_asinhf_ulp(0, 0)
  assert_asinhf_ulp(27, 3.9893267154693604)
  assert_asinhf_ulp(-27, -3.9893267154693604)
  assert_asinhf_ulp(0.125, 0.12467674911022186)
  assert_asinhf_ulp(-0.125, -0.12467674911022186)
  assert_asinhf_ulp(0.5, 0.4812118411064148)
  assert_asinhf_ulp(-0.5, -0.4812118411064148)
  assert_asinhf_ulp(1.5, 1.19476318359375)
  assert_asinhf_ulp(-1.5, -1.19476318359375)
  assert_asinhf_ulp(2, 1.4436354637145996)
  assert_asinhf_ulp(-2, -1.4436354637145996)
  assert_asinhf_ulp(3, 1.818446397781372)
  assert_asinhf_ulp(-3, -1.818446397781372)
  assert_asinhf_ulp(64, 4.852091312408447)
  assert_asinhf_ulp(-64, -4.852091312408447)
  assert_asinhf_ulp(1000, 7.600902557373047)
  assert_asinhf_ulp(-1000, -7.600902557373047)
  assert_asinhf_ulp(512, 6.9314727783203125)
  assert_asinhf_ulp(729, 7.284821510314941)
  assert_asinhf_ulp(3511808, 15.764789581298828)
  assert_asinhf_ulp(15.25, 3.418799877166748)
  assert_asinhf_ulp(6859, 9.526464462280273)
  assert_asinhf_ulp(68.25, 4.916378498077393)
  assert_asinhf_ulp(701.625, 7.246546745300293)
  assert_asinhf_ulp(@float.not_a_number, @float.not_a_number)
  assert_asinhf_ulp(@float.infinity, @float.infinity)
  assert_asinhf_ulp(@float.neg_infinity, @float.neg_infinity)
}
