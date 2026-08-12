///|
/// Compute Log Gamma function
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(lgamma(1.0), 0.0)
/// assert_eq(lgamma(10.0), 12.801827480081469)
/// assert_eq(lgamma(100.0), 359.1342053695754)
/// assert_eq(lgamma(1000.0), 5905.220423209181)
/// assert_eq(lgamma(1.542), -0.11843521817493691)
/// ```
///
/// # Special Cases
///
/// 1. lgamma(NaN) = NaN
/// 2. lgamma(+inf) = +inf
/// 3. lgamma(-inf) = +inf
///
/// # Accuracy
///
/// 23 ulp.
const LS2PI : Double = 0.91893853320467274178

///|
const MAXLGM : Double = 2.556348e305

///|
pub fn lgamma(x : Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }
  let coef_a : Array[Double] = [
    8.11614167470508450300E-4, -5.95061904284301438324E-4, 7.93650340457716943945E-4,
    -2.77777777730099687205E-3, 8.33333333333331927722E-2,
  ]
  let coef_b : Array[Double] = [
    -1.37825152569120859100E3, -3.88016315134637840924E4, -3.31612992738871184744E5,
    -1.16237097492762307383E6, -1.72173700820839662146E6, -8.53555664245765465627E5,
  ]
  let coef_c : Array[Double] = [
    -3.51815701436523470549E2, -1.70642106651881159223E4, -2.20528590553854454839E5,
    -1.13933444367982507207E6, -2.53252307177582951285E6, -2.01889141433532773231E6,
  ]
  let mut p : Double = 0.0
  let mut q : Double = 0.0
  let mut u : Double = 0.0
  let mut w : Double = 0.0
  let mut z : Double = 0.0
  let mut i : Int = 0
  let mut sgngam = 1
  if x < -34.0 {
    q = -x
    w = lgamma(q)
    p = floor(q)
    if p == q {
      return @double.infinity
    }
    i = p.to_int()
    if (i & 1) == 0 {
      sgngam = -1
    } else {
      sgngam = 1
    }
    z = q - p
    if z > 0.5 {
      p += 1.0
      z = p - q
    }
    z = q * sin(DOUBLE_PI * z)
    if z == 0.0 {
      return @double.infinity
    }
    z = LOGPI - log(z) - w
    return z
  }
  if x < 13.0 {
    z = 1.0
    p = 0.0
    u = x
    while u >= 3.0 {
      p -= 1.0
      u = x + p
      z *= u
    }
    while u < 2.0 {
      if u == 0.0 {
        return @double.infinity
      }
      z /= u
      p += 1.0
      u = x + p
    }
    if z < 0.0 {
      sgngam = -1
      z = -z
    } else {
      sgngam = 1
    }
    if u == 2.0 {
      return log(z)
    }
    p -= 2.0
    let x = x + p
    p = x * polevl(x, coef_b) / p1evl(x, coef_c)
    return log(z) + p
  }
  if x > MAXLGM {
    return sgngam.to_double() * @double.infinity
  }
  q = (x - 0.5) * log(x) - x + LS2PI
  if x > 1.0e8 {
    return q
  }
  p = 1.0 / (x * x)
  if x >= 1000.0 {
    q += (
        (7.9365079365079365079365e-4 * p - 2.7777777777777777777778e-3) * p +
        0.0833333333333333333333
      ) /
      x
  } else {
    q += polevl(p, coef_a) / x
  }
  q
}

///|
/// Compute the natural logarithm of the gamma function, alias for lgamma.
pub fn ln_gamma(x : Double) -> Double {
  lgamma(x)
}
