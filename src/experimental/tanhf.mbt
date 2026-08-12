///|
/// Compute hyperbolic tangent function of a single-precision floating point number.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(tanhf(-0.5), -0.46211713552474976)
/// assert_eq(tanhf(0.5), 0.46211713552474976)
/// assert_eq(tanhf(0.0), 0.0)
/// assert_eq(tanhf(1), 0.7615941559557649)
/// assert_eq(tanhf(2), 0.9640275800758169)
/// ```
///
/// # Special Cases
///
/// 1. tanhf(NaN) = NaN
/// 2. tanhf(+inf) = 1
/// 3. tanhf(-inf) = -1
///
/// # Accuracy
///
/// 2 ulp.
pub fn tanhf(x : Float) -> Float {
  // x = |x| */
  let mut ix = x.reinterpret_as_uint()
  let sign = ix >> 31 != 0
  ix = ix & 0x7fffffff
  let x = Float::reinterpret_from_uint(ix)
  let w = ix
  let tt = if w > 0x3f0c9f54 {
    // |x| > log(3)/2 ~= 0.5493 or nan */
    if w > 0x41200000 {
      // |x| > 10 */
      (1.0 : Float) + (0.0 : Float) / x
    } else {
      let t = expm1f(x * 2.0)
      (1.0 : Float) - (2.0 : Float) / (t + 2.0)
    }
  } else if w > 0x3e82c578 {
    // |x| > log(5/3)/2 ~= 0.2554 */
    let t = expm1f(x * 2.0)
    t / (t + 2.0)
  } else if w >= 0x00800000 {
    // |x| >= 0x1p-126 */
    let t = expm1f(x * -2.0)
    -t / (t + 2.0)
  } else {
    // |x| is subnormal */
    //force_eval!(x * x);
    x
  }
  if sign {
    -tt
  } else {
    tt
  }
}
