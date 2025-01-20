///| Compute the Riemann zeta function of two arguments.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(zeta(2.0, 2.0), 0.6449340668482266)
/// assert_eq!(zeta(2.0, 3.14159), 0.3742441373024457)
/// assert_eq!(zeta(3.14159, 2.71828), 0.08044299178527513)
/// assert_eq!(zeta(2, -0.0027818), 129227.143674529)
/// ```
/// # Special Cases
///
/// 1. zeta(+inf, 1.0) = 1.0
/// 2. zeta(1.0, y) = +inf for any y
/// 3. zeta(x, y) = NaN if x < 1.0
/// 4. zeta(x, y) = +inf if y <= 0.0 and y is an integer
/// 5. zeta(x, y) = NaN if y <= 0.0 and x is not an integer
///
/// # Accuracy
///
/// 3 ulp
pub fn zeta(x : Double, y : Double) -> Double {
  let machep = 1.11022302462515654042e-16
  let ns = [
    12.0, -720.0, 30240.0, -1209600.0, 47900160.0, -1.8924375803183791606e9, 7.47242496e10,
    -2.950130727918164224e12, 1.1646782814350067249e14, -4.5979787224074726105e15,
    1.8152105401943546773e17, -7.1661652561756670113e18,
  ]
  let mut i = 0
  let mut a = 0.0
  let mut b = 0.0
  let mut k = 0.0
  let mut s = 0.0
  let mut t = 0.0
  let mut w = 0.0
  let mut e = 0.0
  let mut f = 0.0
  if ispinf(x) && y == 1.0 {
    return 1.0
  }
  if x == 1.0 {
    return double_pos_inf
  }
  if x < 1.0 {
    return double_nan
  }
  if y <= 0.0 {
    if y == floor(y) {
      return double_pos_inf
    }
    if x != floor(x) {
      return double_nan
    }
  }
  s = pow(y, -x)
  a = y
  b = 0.0
  while i < 9 || a <= 9.0 {
    i += 1
    a += 1.0
    b = pow(a, -x)
    s += b
    if -machep * s < b && b < machep * s {
      return s
    }
  }
  w = a
  e = b * w / (x - 1.0)
  s += e
  f = 0.5 * b
  s = s - f
  a = 1.0
  k = 0.0
  for i = 0; i < 12; i = i + 1 {
    a *= x + k
    b /= w
    t = a * b / ns[i]
    s += t
    t = fabs(t / s)
    if t < machep {
      return s
    }
    k += 1.0
    a *= x + k
    b /= w
    k += 1.0
  }
  s
}

test "zeta" {
  fn assert_zeta_ulp!(input1, input2, expect) {
    assert_ulp!(expect, zeta(input1, input2), ZETA_MAX_ULP)
  }

  assert_zeta_ulp!(0, 0, double_nan)
  assert_zeta_ulp!(0, -0, double_nan)
  assert_zeta_ulp!(-0, double_nan, double_nan)
  assert_zeta_ulp!(1, 0, double_pos_inf)
  assert_zeta_ulp!(1, double_nan, double_pos_inf)
  assert_zeta_ulp!(-1, 0, double_nan)
  assert_zeta_ulp!(-1, -0, double_nan)
  assert_zeta_ulp!(-1, 1, double_nan)
  assert_zeta_ulp!(-1, -1, double_nan)
  assert_zeta_ulp!(-1, 2, double_nan)
  assert_zeta_ulp!(-1, double_neg_inf, double_nan)
  assert_zeta_ulp!(-1, double_nan, double_nan)
  assert_zeta_ulp!(2, 0, double_pos_inf)
  assert_zeta_ulp!(2, -0, double_pos_inf)
  assert_zeta_ulp!(2, 1, 1.644934066848227)
  assert_zeta_ulp!(2, -1, double_pos_inf)
  assert_zeta_ulp!(2, 2, 0.6449340668482266)
  assert_zeta_ulp!(2, -2, double_pos_inf)
  assert_zeta_ulp!(2, 3.14159, 0.3742441373024457)
  assert_zeta_ulp!(2, -3.14159, 53.03230296609727)
  assert_zeta_ulp!(2, -2.71828, 16.16869330055435)
  assert_zeta_ulp!(2, 2.71828, 0.4436391802745055)
  assert_zeta_ulp!(2, 10000000, 1.000000050000002e-07)
  assert_zeta_ulp!(2, -10000000, double_pos_inf)
  assert_zeta_ulp!(2, 0.5, 4.93480220054468)
  assert_zeta_ulp!(2, -0.5, 8.934802200544679)
  assert_zeta_ulp!(2, 5.0e-05, 400000001.6448138)
  assert_zeta_ulp!(2, -5.0e-05, 400000001.6450542)
  assert_zeta_ulp!(2, 0.0027818, 129227.1302988228)
  assert_zeta_ulp!(2, -0.0027818, 129227.143674529)
  assert_zeta_ulp!(2, double_pos_inf, double_nan)
  assert_zeta_ulp!(2, double_neg_inf, double_pos_inf)
  assert_zeta_ulp!(2, double_nan, double_nan)
  assert_zeta_ulp!(-2, 0, double_nan)
  assert_zeta_ulp!(-2, -0, double_nan)
  assert_zeta_ulp!(-2, double_nan, double_nan)
  assert_zeta_ulp!(3.14159, 0, double_pos_inf)
  assert_zeta_ulp!(3.14159, -0, double_pos_inf)
  assert_zeta_ulp!(3.14159, 1, 1.176242183133132)
  assert_zeta_ulp!(3.14159, -1, double_pos_inf)
  assert_zeta_ulp!(3.14159, 2, 0.1762421831331325)
  assert_zeta_ulp!(3.14159, -2, double_pos_inf)
  assert_zeta_ulp!(3.14159, 3.14159, 0.05615577992575627)
  assert_zeta_ulp!(3.14159, -3.14159, double_nan)
  assert_zeta_ulp!(3.14159, -2.71828, double_nan)
  assert_zeta_ulp!(3.14159, 2.71828, 0.08044299178527513)
  assert_zeta_ulp!(3.14159, 10000000, 4.765776991518263e-16)
  assert_zeta_ulp!(3.14159, -10000000, double_pos_inf)
  assert_zeta_ulp!(3.14159, 0.5, 9.204049909506169)
  assert_zeta_ulp!(3.14159, -0.5, double_nan)
  assert_zeta_ulp!(3.14159, 5.0e-05, 32514181377625.38)
  assert_zeta_ulp!(3.14159, -5.0e-05, double_nan)
  assert_zeta_ulp!(3.14159, 0.0027818, 106876000.1256451)
  assert_zeta_ulp!(3.14159, -0.0027818, double_nan)
  assert_zeta_ulp!(3.14159, double_pos_inf, double_nan)
  assert_zeta_ulp!(3.14159, double_neg_inf, double_pos_inf)
  assert_zeta_ulp!(3.14159, double_nan, double_nan)
  assert_zeta_ulp!(-3.14159, 0, double_nan)
  assert_zeta_ulp!(-3.14159, 0.5, double_nan)
  assert_zeta_ulp!(-2.71828, double_neg_inf, double_nan)
  assert_zeta_ulp!(-2.71828, double_nan, double_nan)
  assert_zeta_ulp!(2.71828, 0, double_pos_inf)
  assert_zeta_ulp!(2.71828, -0, double_pos_inf)
  assert_zeta_ulp!(2.71828, 1, 1.269010123435276)
  assert_zeta_ulp!(2.71828, -1, double_pos_inf)
  assert_zeta_ulp!(2.71828, 2, 0.2690101234352756)
  assert_zeta_ulp!(2.71828, -2, double_pos_inf)
  assert_zeta_ulp!(2.71828, 3.14159, 0.1067931437511536)
  assert_zeta_ulp!(2.71828, -3.14159, double_nan)
  assert_zeta_ulp!(2.71828, -2.71828, double_nan)
  assert_zeta_ulp!(2.71828, 2.71828, 0.1426898137577874)
  assert_zeta_ulp!(2.71828, 10000000, 5.456901343854609e-13)
  assert_zeta_ulp!(2.71828, -10000000, double_pos_inf)
  assert_zeta_ulp!(2.71828, 0.5, 7.08219023609503)
  assert_zeta_ulp!(2.71828, -0.5, double_nan)
  assert_zeta_ulp!(2.71828, 5.0e-05, 491364545431.0044)
  assert_zeta_ulp!(2.71828, -5.0e-05, double_nan)
  assert_zeta_ulp!(2.71828, 0.0027818, 8851927.470588319)
  assert_zeta_ulp!(2.71828, -0.0027818, double_nan)
  assert_zeta_ulp!(2.71828, double_pos_inf, double_nan)
  assert_zeta_ulp!(2.71828, double_neg_inf, double_pos_inf)
  assert_zeta_ulp!(2.71828, double_nan, double_nan)
  assert_zeta_ulp!(10000000, 0, double_pos_inf)
  assert_zeta_ulp!(10000000, -0, double_pos_inf)
  assert_zeta_ulp!(10000000, 1, 1)
  assert_zeta_ulp!(10000000, -1, double_pos_inf)
  assert_zeta_ulp!(10000000, 2, 0)
  assert_zeta_ulp!(10000000, -2, double_pos_inf)
  assert_zeta_ulp!(10000000, 3.14159, 0)
  assert_zeta_ulp!(10000000, -3.14159, double_pos_inf)
  assert_zeta_ulp!(10000000, -2.71828, double_pos_inf)
  assert_zeta_ulp!(10000000, 2.71828, 0)
  assert_zeta_ulp!(10000000, 10000000, 0)
  assert_zeta_ulp!(10000000, -10000000, double_pos_inf)
  assert_zeta_ulp!(10000000, 0.5, double_pos_inf)
  assert_zeta_ulp!(10000000, -0.5, double_pos_inf)
  assert_zeta_ulp!(10000000, 0.0027818, double_pos_inf)
  assert_zeta_ulp!(10000000, -0.0027818, double_pos_inf)
  assert_zeta_ulp!(10000000, double_pos_inf, double_nan)
  assert_zeta_ulp!(10000000, double_neg_inf, double_pos_inf)
  assert_zeta_ulp!(10000000, double_nan, double_nan)
  assert_zeta_ulp!(-10000000, 0, double_nan)
  assert_zeta_ulp!(-10000000, double_pos_inf, double_nan)
  assert_zeta_ulp!(-10000000, double_neg_inf, double_nan)
  assert_zeta_ulp!(-10000000, double_nan, double_nan)
  assert_zeta_ulp!(0.5, 0, double_nan)
  assert_zeta_ulp!(0.5, -0, double_nan)
  assert_zeta_ulp!(-0.0027818, -0, double_nan)
  assert_zeta_ulp!(-0.0027818, double_nan, double_nan)
  assert_zeta_ulp!(double_pos_inf, 0, double_pos_inf)
  assert_zeta_ulp!(double_pos_inf, -0, double_pos_inf)
  assert_zeta_ulp!(double_pos_inf, 1, 1)
  assert_zeta_ulp!(double_pos_inf, -1, double_pos_inf)
  assert_zeta_ulp!(double_pos_inf, 2, double_nan)
  assert_zeta_ulp!(double_pos_inf, double_pos_inf, double_nan)
  assert_zeta_ulp!(double_pos_inf, double_neg_inf, double_pos_inf)
  assert_zeta_ulp!(double_pos_inf, double_nan, double_nan)
  assert_zeta_ulp!(double_neg_inf, 0, double_nan)
  assert_zeta_ulp!(double_neg_inf, -0, double_nan)
  assert_zeta_ulp!(double_neg_inf, 10000000, double_nan)
  assert_zeta_ulp!(double_neg_inf, -10000000, double_nan)
  assert_zeta_ulp!(double_neg_inf, 0.5, double_nan)
  assert_zeta_ulp!(double_neg_inf, -0.5, double_nan)
  assert_zeta_ulp!(double_neg_inf, double_nan, double_nan)
  assert_zeta_ulp!(double_nan, 0, double_pos_inf)
  assert_zeta_ulp!(double_nan, -0, double_pos_inf)
}
