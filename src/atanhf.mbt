///| Computes hyperbolic arctangent of ``x`` with single-precision floating-point.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(atanhf(0.0), 0.0);
/// assert_eq!(atanhf(0.5), 0.5493061443340548);
/// assert_eq!(atanhf(1.0), @float.infinity);
/// assert_eq!(atanhf(-0.5), -0.5493061443340548);
/// assert_eq!(atanhf(-1.0), @float.neg_infinity);
/// ```
///
/// # Accuracy:
///
/// 0 ulp (unit in the last place).
///
/// # Special cases:
///
/// 1. atanhf(x) = NaN for all |x| > 1
/// 2. atanhf(NaN) = NaN
/// 3. atanhf(1) = +Inf
/// 4. atanhf(-1) = -Inf
pub fn atanhf(x : Float) -> Float {
  let u = x.reinterpret_as_uint()
  let sign = u >> 31 != 0
  let u = u & 0x7fffffff
  let x = u.reinterpret_as_float()
  let x = if u < 0x3f800000U - (1U << 23) {
    if u < 0x3f800000U - (32U << 23) {
      x
    } else {
      // |x| < 0.5, up to 1.7ulp error
      log1pf(x * 2.0 + x * 2.0 * x / ((1.0 : Float) - x)) * 0.5
    }
  } else {
    // avoid overflow
    log1pf(x / ((1.0 : Float) - x) * 2.0) * 0.5
  }
  if sign {
    -x
  } else {
    x
  }
}

///|
test "atanhf" {
  fn assert_atanhf_ulp(input, expect) raise {
    assert_float_ulp(expect, atanhf(input), ATANH_F_MAX_ULP)
  }

  assert_atanhf_ulp(-1, @float.neg_infinity)
  assert_atanhf_ulp(1, @float.infinity)
  assert_atanhf_ulp(8, @float.not_a_number)
  assert_atanhf_ulp(-8, @float.not_a_number)
  assert_atanhf_ulp(0, 0)
  assert_atanhf_ulp(27, @float.not_a_number)
  assert_atanhf_ulp(-27, @float.not_a_number)
  assert_atanhf_ulp(0.125, 0.12565721571445465)
  assert_atanhf_ulp(-0.125, -0.12565721571445465)
  assert_atanhf_ulp(0.5, 0.5493061542510986)
  assert_atanhf_ulp(-0.5, -0.5493061542510986)
  assert_atanhf_ulp(1.5, @float.not_a_number)
  assert_atanhf_ulp(-1.5, @float.not_a_number)
  assert_atanhf_ulp(2, @float.not_a_number)
  assert_atanhf_ulp(-2, @float.not_a_number)
  assert_atanhf_ulp(3, @float.not_a_number)
  assert_atanhf_ulp(-3, @float.not_a_number)
  assert_atanhf_ulp(64, @float.not_a_number)
  assert_atanhf_ulp(-64, @float.not_a_number)
  assert_atanhf_ulp(1000, @float.not_a_number)
  assert_atanhf_ulp(-1000, @float.not_a_number)
  assert_atanhf_ulp(512, @float.not_a_number)
  assert_atanhf_ulp(729, @float.not_a_number)
  assert_atanhf_ulp(3511808, @float.not_a_number)
  assert_atanhf_ulp(15.25, @float.not_a_number)
  assert_atanhf_ulp(6859, @float.not_a_number)
  assert_atanhf_ulp(68.25, @float.not_a_number)
  assert_atanhf_ulp(701.625, @float.not_a_number)
  assert_atanhf_ulp(@float.not_a_number, @float.not_a_number)
  assert_atanhf_ulp(@float.infinity, @float.not_a_number)
  assert_atanhf_ulp(@float.neg_infinity, @float.not_a_number)
}
