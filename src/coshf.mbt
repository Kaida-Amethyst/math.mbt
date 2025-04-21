///|
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
