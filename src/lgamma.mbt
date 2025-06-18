///| Compute Log Gamma function
///
/// # Examples
///
/// ```moonbit
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

///| Compute the natural logarithm of the gamma function, alias for lgamma.
pub fn ln_gamma(x : Double) -> Double {
  lgamma(x)
}

///|
test "lgamma" {
  fn assert_lgamma_ulp(input, expect) raise {
    assert_ulp(expect, lgamma(input), LGAMMA_MAX_ULP)
  }

  assert_lgamma_ulp(-0.8, 1.747207373744994)
  assert_lgamma_ulp(-0.7, 1.452472938756808)
  assert_lgamma_ulp(-0.6, 1.307503441467774)
  assert_lgamma_ulp(-0.5, 1.265512123484645)
  assert_lgamma_ulp(-0.4, 1.31452458994339)
  assert_lgamma_ulp(-0.3, 1.464840050857602)
  assert_lgamma_ulp(-0.2, 1.761497590833938)
  assert_lgamma_ulp(-0.1, 2.368961332728789)
  assert_lgamma_ulp(-3.141592653589793, 0.01557521855857812)
  assert_lgamma_ulp(-1.570796326794897, 0.8339914533246828)
  assert_lgamma_ulp(-0.7853981633974483, 1.691075112696238)
  assert_lgamma_ulp(0.1, 2.252712651734206)
  assert_lgamma_ulp(0.2, 1.524063822430785)
  assert_lgamma_ulp(0.3, 1.095797994818076)
  assert_lgamma_ulp(0.4, 0.7966778177017837)
  assert_lgamma_ulp(0.5, 0.5723649429247001)
  assert_lgamma_ulp(0.6, 0.3982338580692349)
  assert_lgamma_ulp(0.7, 0.2608672465316665)
  assert_lgamma_ulp(0.8, 0.1520596783998376)
  assert_lgamma_ulp(0.9, 0.06637623973474295)
  assert_lgamma_ulp(1, 0)
  assert_lgamma_ulp(3.141592653589793, 0.827694592323437)
  assert_lgamma_ulp(1.570796326794897, -0.1159038008455024)
  assert_lgamma_ulp(0.7853981633974483, 0.1663980436830424)
  assert_lgamma_ulp(1, 0)
  assert_lgamma_ulp(2, 0)
  assert_lgamma_ulp(3, 0.6931471805599453)
  assert_lgamma_ulp(4, 1.791759469228055)
  assert_lgamma_ulp(5, 3.178053830347946)
  assert_lgamma_ulp(6, 4.787491742782046)
  assert_lgamma_ulp(7, 6.579251212010101)
  assert_lgamma_ulp(8, 8.525161361065415)
  assert_lgamma_ulp(9, 10.60460290274525)
  assert_lgamma_ulp(10, 12.80182748008147)
  assert_lgamma_ulp(100, 359.1342053695754)
  assert_lgamma_ulp(1000, 5905.220423209181)
  assert_lgamma_ulp(10000, 82099.71749644238)
  assert_lgamma_ulp(2.5, 0.2846828704729192)
  assert_lgamma_ulp(3.4, 1.092328059802741)
  assert_lgamma_ulp(5.3, 3.639636069066686)
  assert_lgamma_ulp(6.2, 5.132298787837295)
  assert_lgamma_ulp(7.1, 6.767293479384771)
  assert_lgamma_ulp(8.9, 10.39112862748179)
  assert_lgamma_ulp(9.800000000000001, 12.35359517872923)
  assert_lgamma_ulp(10.7, 14.40321059629852)
  assert_lgamma_ulp(101.6, 366.5072601436269)
  assert_lgamma_ulp(1.542, -0.118435218174937)
  assert_lgamma_ulp(2.846, 0.5558182215673224)
  assert_lgamma_ulp(7.881, 8.286247712559748)
  assert_lgamma_ulp(3.772, 1.51290512968991)
  assert_lgamma_ulp(@double.not_a_number, @double.not_a_number)
}
