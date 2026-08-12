///|
/// Compute the gamma function of x.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(gamma(1.0), 1.0)
/// assert_eq(gamma(2.0), 1.0)
/// assert_eq(gamma(3.0), 2.0)
/// assert_eq(gamma(6.0), 120.0)
/// assert_eq(gamma(10.0), 362880.0)
/// assert_eq(gamma(-0.5), -3.5449077018110318)
/// assert_eq(gamma(0.5), 1.7724538509055159)
/// assert_eq(gamma(9.8), 231791.87991967567)
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
      z = q * sin(DOUBLE_PI * z)
      if z == 0.0 {
        return sgngam.to_double() * @double.infinity
      }
      z = DOUBLE_PI / (z * stirf(q))
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
