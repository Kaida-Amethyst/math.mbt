///| roundeven is a function that rounds a number to the nearest even integer.
///
/// # Special Cases
///
/// 1. roundeven(NaN) = NaN
/// 2. roundeven(±∞) = ±∞
///
/// # Examples
///
/// ```
/// let x = 1.4; assert_eq!(roundeven(x), 1.0);
/// let x = 1.5; assert_eq!(roundeven(x), 2.0);
/// let x = 1.6; assert_eq!(roundeven(x), 2.0);
/// let x = 2.4; assert_eq!(roundeven(x), 2.0);
/// let x = 2.5; assert_eq!(roundeven(x), 2.0);
/// let x = 2.6; assert_eq!(roundeven(x), 3.0);
/// ```
pub fn roundeven(x : Double) -> Double {
  if isnan(x) {
    return @double.not_a_number
  }
  if isinf(x) {
    return x
  }
  let i : Double = trunc(x)
  let f : Double = x - i
  if f > 0.5 {
    i + 1.0
  } else if f < 0.5 {
    i
  } else if i.to_int() % 2 == 0 {
    i
  } else {
    i + 1.0
  }
}

///|
test "roundeven" {
  fn assert_roundeven(x : Double, expected : Double) raise {
    if isnan(x) && isnan(expected) {
      return assert_eq(true, true)
    }
    assert_eq(roundeven(x), expected)
  }

  assert_roundeven(1.4, 1.0)
  assert_roundeven(1.5, 2.0)
  assert_roundeven(1.6, 2.0)
  assert_roundeven(2.4, 2.0)
  assert_roundeven(2.5, 2.0)
  assert_roundeven(2.6, 3.0)
  assert_roundeven(3.4, 3.0)
  assert_roundeven(3.5, 4.0)
  assert_roundeven(@double.not_a_number, @double.not_a_number)
  assert_roundeven(@double.infinity, @double.infinity)
  assert_roundeven(@double.neg_infinity, @double.neg_infinity)
}
