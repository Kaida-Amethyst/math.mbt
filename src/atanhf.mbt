///|
pub fn atanhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let sign = (u >> 31) != 0

  // |x| */
  let u = u & 0x7fffffff
  let x = u.reinterpret_as_float()
  let x = if u < 0x3f800000U - (1U << 23) {
    if u < 0x3f800000U - (32U << 23) {
      x
    } else {
      // |x| < 0.5, up to 1.7ulp error */
      log1pf(x * 2.0 + x * 2.0 * x / ((1.0 : Float) - x)) * 0.5
    }
  } else {
    // avoid overflow */
    log1pf(x / ((1.0 : Float) - x) * 2.0) * 0.5
  }
  if sign {
    -x
  } else {
    x
  }
}
