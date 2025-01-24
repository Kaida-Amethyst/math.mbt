///|
const SQRTH : Double = 0.70710678118654752440

///|
const MAXLOG : Double = 7.09782712893383996732E2

///|
pub fn ndtr(a : Double) -> Double {
  let x = a * SQRTH
  let z = fabs(x)
  let y = if z < 1.0 {
    0.5 + 0.5 * erf(x)
  } else {
    let y = 0.5 * erfce(z)
    let z = expx2(a, -1)
    y * sqrt(z)
  }
  if x > 0.0 {
    1.0 - y
  } else {
    y
  }
}

///| Computes exp(x^2) * erfc(x)
pub fn erfce(x : Double) -> Double {
  let coef_p : Array[Double] = [
    2.46196981473530512524E-10, 5.64189564831068821977E-1, 7.46321056442269912687E0,
    4.86371970985681366614E1, 1.96520832956077098242E2, 5.26445194995477358631E2,
    9.34528527171957607540E2, 1.02755188689515710272E3, 5.57535335369399327526E2,
  ]
  let coef_q : Array[Double] = [
    1.32281951154744992508E1, 8.67072140885989742329E1, 3.54937778887819891062E2,
    9.75708501743205489753E2, 1.82390916687909736289E3, 2.24633760818710981792E3,
    1.65666309194161350182E3, 5.57535340817727675546E2,
  ]
  let coef_r : Array[Double] = [
    5.64189583547755073984E-1, 1.27536670759978104416E0, 5.01905042251180477414E0,
    6.16021097993053585195E0, 7.40974269950448939160E0, 2.97886665372100240670E0,
  ]
  let coef_s : Array[Double] = [
    2.26052863220117276590E0, 9.39603524938001434673E0, 1.20489539808096656605E1,
    1.70814450747565897222E1, 9.60896809063285878198E0, 3.36907645100081516050E0,
  ]
  let (p, q) = if x < 8.0 {
    (polevl(x, coef_p), p1evl(x, coef_q))
  } else {
    (polevl(x, coef_r), p1evl(x, coef_s))
  }
  p / q
}

///| Computes exp(x^2)
pub fn expx2(x : Double, sign : Int) -> Double {
  let m_ : Double = 128.0
  let minv : Double = 0.0078125
  let mut x = fabs(x)
  if sign < 0 {
    x = -x
  }

  // Represent x as an exact multiple of M plus a residual.
  // M is a power of 2 chosen so that exp(m * m) does not overflow
  // or underflow and so that |x - m| is small.
  let m = minv * floor(m_ * x + 0.5)
  let f = x - m

  // x^2 = m^2 + 2mf + f^2
  let mut u = m * m
  let mut u1 = 2.0 * m * f + f * f
  if sign < 0 {
    u = -u
    u1 = -u1
  }
  if u + u1 > MAXLOG {
    return @double.infinity
  }

  // u is exact, u1 is small.
  u = exp(u) * exp(u1)
  u
}

// fn erf(x: Double) -> Double {
//     if abs(x) > 1.0 {
//         return 1.0 - erfc(x)
//     }
//
//     let z = x * x
//     x * polevl(z, T, 4) / p1evl(z, U, 5)
// }
