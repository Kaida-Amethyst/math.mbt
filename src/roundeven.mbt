///| roundeven is a function that rounds a number to the nearest even integer.
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
  let i : Double = trunc(x)
  let f: Double = x - i
  if f > 0.5 {
    i + 1.0
  } else if f < 0.5 {
    i
  } else {
    if i.to_int() % 2 == 0 {
      i
    } else {
      i + 1.0
    }
  }
}
