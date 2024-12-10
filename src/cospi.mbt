///| Compute cos(pi*x) with high accuracy.
/// # Introduction
///
/// Compute cos(pi*x) with high accuracy.
///
/// # Accuracy
///
/// 1 ulp (1 bit error)
pub fn cospi(x: Double) -> Double {
  let mut invert = false
  if fabs(x) < 0.25 {
    return cos(PI * x)
  }

  let mut x = x
  if x < 0 {
    x = -x
  }
  let mut rem = floor(x)
  if fabs(floor(rem / 2) * 2 - rem) > double_epsilon {
    invert = not(invert)
  }

  rem = x - rem
  if rem > 0.5 {
    rem = 1.0 - rem
    invert = not(invert)
  }
  if rem == 0.5 {
    return 0.0
  }
  if rem > 0.25 {
    rem = 0.5 - rem
    rem = sin(PI * rem)
  } else {
    rem = cos(PI * rem)
  }

  if invert {
    -rem
  } else {
    rem
  }
}
