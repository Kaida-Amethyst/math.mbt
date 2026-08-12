///|
/// Compute cos(pi*x) with high accuracy.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(cospi(0), 1);
/// assert_eq(cospi(1), -1);
/// assert_eq(cospi(0.5), 0);
/// assert_eq(cospi(-1), -1);
/// assert_eq(cospi(-0.5), 0);
/// ```
///
/// # Accuracy
///
/// 49 ulp (1 bit error)
///
/// # Special Cases
///
/// 1. cospi(NaN) = NaN
/// 2. cospi(±∞) = NaN
pub fn cospi(x : Double) -> Double {
  let mut invert = false
  if fabs(x) < 0.25 {
    return cos(DOUBLE_PI * x)
  }
  let mut x = x
  if x < 0 {
    x = -x
  }
  let mut rem = floor(x)
  if fabs(floor(rem / 2) * 2 - rem) > double_epsilon {
    invert = !invert
  }
  rem = x - rem
  if rem > 0.5 {
    rem = 1.0 - rem
    invert = !invert
  }
  if rem == 0.5 {
    return 0.0
  }
  if rem > 0.25 {
    rem = 0.5 - rem
    rem = sin(DOUBLE_PI * rem)
  } else {
    rem = cos(DOUBLE_PI * rem)
  }
  if invert {
    -rem
  } else {
    rem
  }
}
