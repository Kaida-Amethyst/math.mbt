///|
/// Computes the trigamma function of `x`.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(trigamma(0.5), 4.93480220054468);
/// assert_eq(trigamma(1.0), 1.6449340668482262);
/// assert_eq(trigamma(2.0), 0.6449340668482261);
/// assert_eq(trigamma(3.0), 0.39493406684822613);
/// ```
///
/// # Special Cases
///
/// 1. trigamma(NaN) = NaN
/// 2. trigamma(0) = NaN
/// 3. trigamma(x) = NaN for x < 0 and x is an integer
/// 4. trigamma(+inf) = 0
/// 5. trigamma(-inf) = NaN
///
/// # Accuracy
///
/// 14 ulp.
pub fn trigamma(x : Double) -> Double {
  if isnan(x) {
    return x
  }
  if x == 0.0 || (x < 0.0 && x == floor(x)) {
    return @double.not_a_number
  }
  fn eval_polynomial(x : Double, coefficients : Array[Double]) -> Double {
    coefficients.rev_iter().fold(init=0.0, fn(sum, c) { x * sum + c })
  }

  let mut x = x
  if x <= 0.0 {
    return powi(DOUBLE_PI * recip(sinpi(x)), 2) - trigamma(1.0 - x)
  }
  let mut psi = 0.0
  if x < 8.0 {
    let n = (8.0 - floor(x)).to_int()
    psi += powi(recip(x), 2)
    for v in 1..<n {
      psi += powi(recip(x + v.to_double()), 2)
    }
    x += n.to_double()
  }
  let t = recip(x)
  let w = t * t
  psi += t + 0.5 * w
  let coef = [
    0.16666666666666666, -0.03333333333333333, 0.023809523809523808, -0.03333333333333333,
    0.07575757575757576, -0.2531135531135531, 1.1666666666666667, -7.092156862745098,
  ]
  psi + t * w * eval_polynomial(w, coef)
}
