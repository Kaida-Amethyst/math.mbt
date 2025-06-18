///| Returns the square root of the sum of the squares of its arguments, hypot(x, y) = sqrt(x*x, y*y)
/// # Notes
///
/// `hypotf` return the square root of the sum of the squares of its arguments, the formula is:
///
/// $$hypot(x) = \sqrt{x^2 + y^2}$$
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(hypotf(3, 4), 5)
/// assert_eq!(hypotf(6, 8), 10)
/// assert_eq!(hypotf(5, 12), 13)
/// assert_eq!(hypotf(7, 24), 25)
/// assert_eq!(hypotf(3.14, -2.71), 4.147734642028809) 
/// assert_eq!(hypotf(-3.14, 2.71), 4.147734642028809)
/// ```
///
/// # Accuracy
///
/// 2 ulps (units in the last place)
///
/// # Special cases
///
/// 1. If x or y is NaN, return NaN
/// 2. If x or y is inf, return +inf
pub fn hypotf(x : Float, y : Float) -> Float {
  let x = x.abs()
  let y = y.abs()
  if x.is_inf() || y.is_inf() {
    return @float.infinity
  }
  let (x, y) = if y > x { (y, x) } else { (x, y) }
  if x * FLOAT_EPSILON >= y {
    return x
  }
  let rat = y / x
  x * (rat * rat + 1.0).sqrt()
}

///|
test "hypotf" {
  fn assert_hypotf_ulp(input1, input2, expect) raise {
    assert_float_ulp(expect, hypotf(input1, input2), HYPOT_F_MAX_ULP)
  }

  assert_hypotf_ulp(1, 1, 1.4142135381698608)
  assert_hypotf_ulp(3, 5, 5.830951690673828)
  assert_hypotf_ulp(-2, 1, 2.2360680103302)
  assert_hypotf_ulp(-5, 3, 5.830951690673828)
  assert_hypotf_ulp(9, 6, 10.816654205322266)
  assert_hypotf_ulp(7, 11, 13.03840446472168)
  assert_hypotf_ulp(6.5, -3.25, 7.267220973968506)
  assert_hypotf_ulp(-7.25, 8.625, 11.267348289489746)
  assert_hypotf_ulp(-52.5, -625.5, 627.6994018554688)
  assert_hypotf_ulp(12, 13, 17.69180679321289)
  assert_hypotf_ulp(7, 16, 17.464248657226562)
  assert_hypotf_ulp(19, 33, 38.07886505126953)
  assert_hypotf_ulp(@float.infinity, 11, @float.infinity)
  assert_hypotf_ulp(13, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, -10.5, @float.infinity)
  assert_hypotf_ulp(-12.5, @float.neg_infinity, @float.infinity)
  assert_hypotf_ulp(@float.not_a_number, 0, @float.not_a_number)
  assert_hypotf_ulp(0, @float.not_a_number, @float.not_a_number)
  assert_hypotf_ulp(@float.infinity, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.infinity, @float.neg_infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, @float.infinity, @float.infinity)
  assert_hypotf_ulp(@float.neg_infinity, @float.neg_infinity, @float.infinity)
}
