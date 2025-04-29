///| Compute hyperbolic tangent function of a single-precision floating point number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(tanhf(-0.5), -0.46211713552474976) 
/// assert_eq!(tanhf(0.5), 0.46211713552474976)
/// assert_eq!(tanhf(0.0), 0.0)
/// assert_eq!(tanhf(1), 0.7615941559557649)
/// assert_eq!(tanhf(2), 0.9640275800758169)
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
  let sign = (ix >> 31) != 0
  ix = ix & 0x7fffffff
  let x = ix.reinterpret_as_float()
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

///|
test "tanhf" {
  fn assert_tanhf_ulp!(input, expect) {
    assert_float_ulp!(expect, tanhf(input), TANH_F_MAX_ULP)
  }

  assert_tanhf_ulp!(-1, -0.7615941762924194)
  assert_tanhf_ulp!(1, 0.7615941762924194)
  assert_tanhf_ulp!(8, 0.9999997615814209)
  assert_tanhf_ulp!(-8, -0.9999997615814209)
  assert_tanhf_ulp!(0, 0)
  assert_tanhf_ulp!(27, 1)
  assert_tanhf_ulp!(-27, -1)
  assert_tanhf_ulp!(0.125, 0.12435300648212433)
  assert_tanhf_ulp!(-0.125, -0.12435300648212433)
  assert_tanhf_ulp!(0.5, 0.46211713552474976)
  assert_tanhf_ulp!(-0.5, -0.46211713552474976)
  assert_tanhf_ulp!(1.5, 0.9051482677459717)
  assert_tanhf_ulp!(-1.5, -0.9051482677459717)
  assert_tanhf_ulp!(2, 0.9640275835990906)
  assert_tanhf_ulp!(-2, -0.9640275835990906)
  assert_tanhf_ulp!(3, 0.9950547814369202)
  assert_tanhf_ulp!(-3, -0.9950547814369202)
  assert_tanhf_ulp!(64, 1)
  assert_tanhf_ulp!(-64, -1)
  assert_tanhf_ulp!(1000, 1)
  assert_tanhf_ulp!(-1000, -1)
  assert_tanhf_ulp!(512, 1)
  assert_tanhf_ulp!(729, 1)
  assert_tanhf_ulp!(3511808, 1)
  assert_tanhf_ulp!(15.25, 1)
  assert_tanhf_ulp!(6859, 1)
  assert_tanhf_ulp!(68.25, 1)
  assert_tanhf_ulp!(701.625, 1)
  assert_tanhf_ulp!(@float.not_a_number, @float.not_a_number)
  assert_tanhf_ulp!(@float.infinity, 1)
  assert_tanhf_ulp!(@float.neg_infinity, -1)
}
