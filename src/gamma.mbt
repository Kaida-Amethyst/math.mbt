///| Compute the gamma function of x.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(gamma(1.0), 1.0)
/// assert_eq!(gamma(2.0), 1.0)
/// assert_eq!(gamma(3.0), 2.0)
/// assert_eq!(gamma(6.0), 120.0)
/// assert_eq!(gamma(10.0), 362880.0)
/// assert_eq!(gamma(-0.5), -3.5449077018110318)
/// assert_eq!(gamma(0.5), 1.7724538509055159)
/// assert_eq!(gamma(9.8), 231791.87991967567)
/// ```
///
/// # Special Cases
///
/// 1. gamma(NaN) = NaN
/// 2. gamma(+inf) = +inf
/// 3. gamma(-inf) = -inf
///
/// # Accuracy
///
/// 4 ulp.
pub fn gamma(x : Double) -> Double {
  if isnan(x) || isinf(x) {
    return x
  }
  let mut p : Double = 0.0
  let mut q : Double = 0.0
  let mut z : Double = 0.0
  let mut i : Int = 0
  let mut sgngam : Int = 1
  let coef_p : Array[Double] = [
    1.60119522476751861407E-4, 1.19135147006586384913E-3, 1.04213797561761569935E-2,
    4.76367800457137231464E-2, 2.07448227648435975150E-1, 4.94214826801497100753E-1,
    9.99999999999999996796E-1,
  ]
  let coef_q : Array[Double] = [
    -2.31581873324120129819E-5, 5.39605580493303397842E-4, -4.45641913851797240494E-3,
    1.18139785222060435552E-2, 3.58236398605498653373E-2, -2.34591795718243348568E-1,
    7.14304917030273074085E-2, 1.00000000000000000320E0,
  ]
  q = fabs(x)
  if q > 33.0 {
    if x < 0.0 {
      p = floor(q)
      if p == q {
        return @double.not_a_number
      }
      i = p.to_int()
      if (i & 1) == 0 {
        sgngam = -1
      }
      z = q - p
      if z > 0.5 {
        p += 1.0
        z = q - p
      }
      z = q * sin(PI * z)
      if z == 0.0 {
        return sgngam.to_double() * @double.infinity
      }
      z = PI / (z * stirf(q))
    } else {
      z = stirf(x)
    }
    return sgngam.to_double() * z
  }
  z = 1.0
  let mut x = x
  while x >= 3.0 {
    x -= 1.0
    z *= x
  }
  while x < 0.0 {
    if x > -1.0E-9 {
      return z / ((1.0 + 0.5772156649015329 * x) * x)
    }
    z /= x
    x += 1.0
  }
  while x < 2.0 {
    if x < 1.0E-9 {
      return z / ((1.0 + 0.5772156649015329 * x) * x)
    }
    z /= x
    x += 1.0
  }
  if x == 2.0 {
    return z
  }
  x -= 2.0
  p = polevl(x, coef_p)
  q = polevl(x, coef_q)
  z * p / q
}

///|
fn stirf(x : Double) -> Double {
  let sqtpi : Double = 2.50662827463100050242E0
  let maxstir : Double = 143.01608
  let stir : Array[Double] = [
    7.87311395793093628397E-4, -2.29549961613378126380E-4, -2.68132617805781232825E-3,
    3.47222221605458667310E-3, 8.33333333333482257126E-2,
  ]
  let w = 1.0 / x
  let w = 1.0 + w * polevl(w, stir)
  let y = exp(x)
  let y = if x > maxstir {
    let v = pow(x, 0.5 * x - 0.25)
    v * (v / y)
  } else {
    pow(x, x - 0.5) / y
  }
  sqtpi * y * w
}

///|
test "tgamma" {
  fn assert_gamma_ulp!(input, expect) {
    assert_ulp!(expect, gamma(input), TGAMMA_MAX_ULP)
  }

  assert_gamma_ulp!(-0.8, -5.738554639998505)
  assert_gamma_ulp!(-0.7, -4.273669982410843)
  assert_gamma_ulp!(-0.6, -3.69693257292948)
  assert_gamma_ulp!(-0.5, -3.544907701811032)
  assert_gamma_ulp!(-0.4, -3.722980622032042)
  assert_gamma_ulp!(-0.3, -4.326851108825193)
  assert_gamma_ulp!(-0.2, -5.821148568626517)
  assert_gamma_ulp!(-0.1, -10.68628702119319)
  assert_gamma_ulp!(-3.141592653589793, 1.015697144460219)
  assert_gamma_ulp!(-1.570796326794897, 2.302490707537118)
  assert_gamma_ulp!(-0.7853981633974483, -5.425310390867353)
  assert_gamma_ulp!(0.1, 9.513507698668731)
  assert_gamma_ulp!(0.2, 4.590843711998803)
  assert_gamma_ulp!(0.3, 2.991568987687591)
  assert_gamma_ulp!(0.4, 2.218159543757688)
  assert_gamma_ulp!(0.5, 1.772453850905516)
  assert_gamma_ulp!(0.6, 1.489192248812817)
  assert_gamma_ulp!(0.7, 1.298055332647558)
  assert_gamma_ulp!(0.8, 1.164229713725303)
  assert_gamma_ulp!(0.9, 1.068628702119319)
  assert_gamma_ulp!(1, 1)
  assert_gamma_ulp!(3.141592653589793, 2.288037795340032)
  assert_gamma_ulp!(1.570796326794897, 0.8905608903815393)
  assert_gamma_ulp!(0.7853981633974483, 1.181043114925474)
  assert_gamma_ulp!(1, 1)
  assert_gamma_ulp!(2, 1)
  assert_gamma_ulp!(3, 2)
  assert_gamma_ulp!(4, 6)
  assert_gamma_ulp!(5, 24)
  assert_gamma_ulp!(6, 120)
  assert_gamma_ulp!(7, 720)
  assert_gamma_ulp!(8, 5040)
  assert_gamma_ulp!(9, 40320)
  assert_gamma_ulp!(10, 362880)
  assert_gamma_ulp!(100, 9.332621544394415e+155)
  assert_gamma_ulp!(2.5, 1.329340388179137)
  assert_gamma_ulp!(3.4, 2.981206426810333)
  assert_gamma_ulp!(5.3, 38.07797644995235)
  assert_gamma_ulp!(6.2, 169.406099461723)
  assert_gamma_ulp!(7.1, 868.9568588006398)
  assert_gamma_ulp!(8.9, 32569.40492585501)
  assert_gamma_ulp!(9.8, 231791.8799196757)
  assert_gamma_ulp!(10.7, 1799844.078931372)
  assert_gamma_ulp!(101.6, 1.486211638228605e+159)
  assert_gamma_ulp!(1.542, 0.888309360094435)
  assert_gamma_ulp!(2.846, 1.743366861718904)
  assert_gamma_ulp!(7.881, 3968.913713991595)
  assert_gamma_ulp!(3.772, 4.539900655157358)
  assert_gamma_ulp!(double_nan, double_nan)
}
