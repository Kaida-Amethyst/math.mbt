///|
/// Computes hyperbolic arctangent of ``x``.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(atanh(0.0), 0.0);
/// assert_eq(atanh(0.5), 0.5493061443340548);
/// assert_eq(atanh(1.0), @double.infinity);
/// assert_eq(atanh(-0.5), -0.5493061443340548);
/// assert_eq(atanh(-1.0), @double.neg_infinity);
/// ```
///
/// # Accuracy:
///
/// 0 ulp (unit in the last place).
///
/// # Special cases:
///
/// 1. atanh(x) = NaN for all |x| > 1
/// 2. atanh(NaN) = NaN
/// 3. atanh(1) = +Inf
/// 4. atanh(-1) = -Inf
pub fn atanh(x : Double) -> Double {
  let hx : Int = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if fabs(x) > 1.0 {
    return @double.not_a_number
  }
  if x == 1.0 {
    return @double.infinity
  }
  if x == -1.0 {
    return @double.neg_infinity
  }
  if ix < 0x3e300000 && 1.0e300 + x > 0.0 {
    return x
  }
  let x = fabs(x)
  let t = if x <= 0.5 {
    let t = x + x
    0.5 * log1p(t + t * x / (1.0 - x))
  } else {
    0.5 * log1p((x + x) / (1.0 - x))
  }
  if hx >= 0 {
    t
  } else {
    -t
  }
}
