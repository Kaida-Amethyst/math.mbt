///|
/// Compute hyperbolic cosine function of a double-precision floating point number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(coshf(0), 1)
/// assert_eq(coshf(1), 1.5430805683135986)
/// assert_eq(coshf(2), 3.7621958255767822)
/// assert_eq(coshf(3), 10.067661995777765)
/// assert_eq(coshf(-1), 1.5430805683135986)
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
  x = Float::reinterpret_from_uint(ix)
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
    let t = @math.expf(x)
    return (t + recipf(t)) * 0.5
  }

  // |x| > log(FLT_MAX) or nan */
  k_expo2f(x)
}
