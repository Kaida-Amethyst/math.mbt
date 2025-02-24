///| Calculate the square root of the sum of squares of any number of coordinates.
/// Calculate the length of a vector p, dimension of which is passed as an argument without undue overflow or underflow.
///
/// # Special Cases
///
/// 1. If one of the coordinates is infinite, the result is infinite.
/// 2. If one of the coordinates is NaN, the result is NaN.
pub fn norm(vec : Array[Double]) -> Double {
  let max = absmaximum(vec)
  let mut ssum : Double = 0.0
  for p in vec {
    ssum += square(fabs(p) / max)
  }
  max * sqrt(ssum)
}
