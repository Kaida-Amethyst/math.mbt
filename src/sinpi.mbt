///| Compute sin(pi*x) with high accuracy.
/// # Introduction
///
/// Compute sin(pi*x) with high accuracy.
///
/// # Accuracy
///
/// 1 ulp (1 bit error)
pub fn sinpi(x: Double) -> Double {
  if x < 0 {
    return -sinpi(-x)
  }

  if x < 0.5 {
    return sin(PI * x)
  }

  let mut invert = false
  let mut x = x
  if x < 1 {
    invert = true
    x = -x
  }
  let rem = floor(x)
  if fabs(floor(rem / 2) * 2 - rem) > double_epsilon {
    invert = not(invert)
  }
  let mut rem = x - rem
  if rem > 0.5 {
    rem = 1.0 - rem
  }

  if rem == 0.5 {
    return if invert { -1.0 } else { 1.0 }
  }

  let rem = sin(PI * rem)

  if invert {
    -rem
  } else {
    rem
  }
}
