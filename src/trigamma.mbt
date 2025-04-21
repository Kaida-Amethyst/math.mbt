///| Computes the trigamma function of `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(trigamma(0.5), 4.93480220054468); 
/// assert_eq!(trigamma(1.0), 1.6449340668482262);
/// assert_eq!(trigamma(2.0), 0.6449340668482261);
/// assert_eq!(trigamma(3.0), 0.39493406684822613);
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

///|
test "trigamma" {
  fn assert_trigamma_ulp!(input, expect) {
    assert_ulp!(expect, trigamma(input), TRIGAMMA_MAX_ULP)
  }

  assert_trigamma_ulp!(-0.8, 27.82987720542379)
  assert_trigamma_ulp!(-0.7, 14.28618087263834)
  assert_trigamma_ulp!(-0.6, 10.05313436830737)
  assert_trigamma_ulp!(-0.5, 8.934802200544679)
  assert_trigamma_ulp!(-0.4, 9.886209670902357)
  assert_trigamma_ulp!(-0.3, 13.94516026780572)
  assert_trigamma_ulp!(-0.2, 27.2994741375017)
  assert_trigamma_ulp!(-0.1, 101.9225399594772)
  assert_trigamma_ulp!(-3.141592653589793, 53.03043874008547)
  assert_trigamma_ulp!(-1.570796326794897, 9.900216100891949)
  assert_trigamma_ulp!(-0.7853981633974483, 24.58093971587433)
  assert_trigamma_ulp!(0.1, 101.4332991507927)
  assert_trigamma_ulp!(0.2, 26.26737720542378)
  assert_trigamma_ulp!(0.3, 12.24536454610773)
  assert_trigamma_ulp!(0.4, 7.275356590529597)
  assert_trigamma_ulp!(0.5, 4.934802200544679)
  assert_trigamma_ulp!(0.6, 3.636209670902358)
  assert_trigamma_ulp!(0.7, 2.834049156694611)
  assert_trigamma_ulp!(0.8, 2.2994741375017)
  assert_trigamma_ulp!(0.9, 1.922539959477203)
  assert_trigamma_ulp!(1, 1.644934066848226)
  assert_trigamma_ulp!(3.141592653589793, 0.3742437696542005)
  assert_trigamma_ulp!(1.570796326794897, 0.8794632640771828)
  assert_trigamma_ulp!(0.7853981633974483, 2.365840259013745)
  assert_trigamma_ulp!(-1.0, @double.not_a_number)
  assert_trigamma_ulp!(-2.0, @double.not_a_number)
  assert_trigamma_ulp!(-3.0, @double.not_a_number)
  assert_trigamma_ulp!(1, 1.644934066848226)
  assert_trigamma_ulp!(2, 0.6449340668482264)
  assert_trigamma_ulp!(3, 0.3949340668482265)
  assert_trigamma_ulp!(4, 0.2838229557371153)
  assert_trigamma_ulp!(5, 0.2213229557371153)
  assert_trigamma_ulp!(6, 0.1813229557371153)
  assert_trigamma_ulp!(7, 0.1535451779593376)
  assert_trigamma_ulp!(8, 0.1331370146940314)
  assert_trigamma_ulp!(9, 0.1175120146940314)
  assert_trigamma_ulp!(10, 0.1051663356816857)
  assert_trigamma_ulp!(100, 0.01005016666333357)
  assert_trigamma_ulp!(1000, 0.001000500166666633)
  assert_trigamma_ulp!(10000, 0.0001000050001666667)
  assert_trigamma_ulp!(2.5, 0.4903577561002349)
  assert_trigamma_ulp!(3.4, 0.3415413977858333)
  assert_trigamma_ulp!(5.3, 0.2075908890224981)
  assert_trigamma_ulp!(6.2, 0.1749933498070626)
  assert_trigamma_ulp!(7.1, 0.1512275804390726)
  assert_trigamma_ulp!(8.9, 0.1189077102311898)
  assert_trigamma_ulp!(9.800000000000001, 0.1074236947760278)
  assert_trigamma_ulp!(10.7, 0.09796095101564453)
  assert_trigamma_ulp!(101.6, 0.009891116194836021)
  assert_trigamma_ulp!(1.542, 0.9011940548076367)
  assert_trigamma_ulp!(2.846, 0.4201660506084786)
  assert_trigamma_ulp!(7.881, 0.135277069665261)
  assert_trigamma_ulp!(3.772, 0.303317225833113)
  assert_trigamma_ulp!(-1.542, 9.562817390477804)
  assert_trigamma_ulp!(-2.846, 45.3187154600991)
  assert_trigamma_ulp!(-7.881, 73.88121482595784)
  assert_trigamma_ulp!(-3.772, 22.66071131391305)
  assert_trigamma_ulp!(@double.not_a_number, @double.not_a_number)
  assert_trigamma_ulp!(@double.infinity, 0)
  assert_trigamma_ulp!(@double.neg_infinity, @double.not_a_number)
}
