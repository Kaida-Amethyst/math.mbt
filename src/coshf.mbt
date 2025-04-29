///| Compute hyperbolic cosine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(coshf(0), 1)
/// assert_eq!(coshf(1), 1.5430805683135986) 
/// assert_eq!(coshf(2), 3.7621958255767822) 
/// assert_eq!(coshf(3), 10.067661995777765)
/// assert_eq!(coshf(-1), 1.5430805683135986)
/// ```
///
/// # Special Cases
///
/// 1. coshf(x) is |x| if x is +INF, -INF, or NaN.
/// 2. Only coshf(0)=1 is exact for finite x.
///
/// # Accuracy
///
/// 0 ulp.
pub fn coshf(x : Float) -> Float {
  let mut x = x
  // |x| */
  let mut ix = x.reinterpret_as_uint()
  ix = ix & 0x7fffffff
  x = ix.reinterpret_as_float()
  let w = ix

  // |x| < log(2) */
  if w < 0x3f317217 {
    if w < 0x3f800000U - (12U << 23) {
      return 1.0
    }
    //force_eval!(x + 0x1.0p120);
    let t = expm1f(x)
    return (1.0 : Float) + t * t / ((2.0 : Float) * (t + 1.0))
  }

  // |x| < log(FLT_MAX) */
  if w < 0x42b17217 {
    let t = expf(x)
    return (t + recipf(t)) * 0.5
  }

  // |x| > log(FLT_MAX) or nan */
  k_expo2f(x)
}

///|
test "coshf" {
  fn assert_coshf_ulp!(input, expect) {
    assert_float_ulp!(expect, coshf(input), COSH_F_MAX_ULP)
  }

  assert_coshf_ulp!(-1, 1.5430805683135986)
  assert_coshf_ulp!(1, 1.5430805683135986)
  assert_coshf_ulp!(8, 1490.4791259765625)
  assert_coshf_ulp!(-8, 1490.4791259765625)
  assert_coshf_ulp!(0, 1)
  assert_coshf_ulp!(27, 266024124416)
  assert_coshf_ulp!(-27, 266024124416)
  assert_coshf_ulp!(0.125, 1.0078226327896118)
  assert_coshf_ulp!(-0.125, 1.0078226327896118)
  assert_coshf_ulp!(0.5, 1.1276259422302246)
  assert_coshf_ulp!(-0.5, 1.1276259422302246)
  assert_coshf_ulp!(1.5, 2.352409601211548)
  assert_coshf_ulp!(-1.5, 2.352409601211548)
  assert_coshf_ulp!(2, 3.7621958255767822)
  assert_coshf_ulp!(-2, 3.7621958255767822)
  assert_coshf_ulp!(3, 10.067662239074707)
  assert_coshf_ulp!(-3, 10.067662239074707)
  assert_coshf_ulp!(64, 3.11757471602483e+27)
  assert_coshf_ulp!(-64, 3.11757471602483e+27)
  assert_coshf_ulp!(1000, @float.infinity)
  assert_coshf_ulp!(-1000, @float.infinity)
  assert_coshf_ulp!(512, @float.infinity)
  assert_coshf_ulp!(729, @float.infinity)
  assert_coshf_ulp!(3511808, @float.infinity)
  assert_coshf_ulp!(15.25, 2098750.75)
  assert_coshf_ulp!(6859, @float.infinity)
  assert_coshf_ulp!(68.25, 2.1855884661877316e+29)
  assert_coshf_ulp!(701.625, @float.infinity)
}
