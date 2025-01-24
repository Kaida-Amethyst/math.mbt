///|
const MACHEP : Double = 1.1102230246251565E-16

///|
const BIG : Double = 4.503599627370496e15

///|
const BIGINV : Double = 2.22044604925031308085e-16

///| Upper Incomplete Gamma Function
fn igamc(a : Double, x : Double) -> Double {
  if x <= 0.0 || a <= 0.0 {
    return 1.0
  }
  if x < 1.0 || x < a {
    return 1.0 - igam(a, x)
  }
  let ax = a * log(x) - x - lgamma(a)
  if ax < -MAXLOG {
    return 0.0
  }
  let ax = exp(ax)

  // Continued fraction
  let mut y = 1.0 - a
  let mut z = x + y + 1.0
  let mut c = 0.0
  let mut pkm2 = 1.0
  let mut qkm2 = x
  let mut pkm1 = x + 1.0
  let mut qkm1 = z * x
  let mut ans = pkm1 / qkm1
  while true {
    c += 1.0
    y += 1.0
    z += 2.0
    let yc = y * c
    let pk = pkm1 * z - pkm2 * yc
    let qk = qkm1 * z - qkm2 * yc
    let t = if qk != 0.0 { fabs((ans - pk / qk) / (pk / qk)) } else { 1.0 }
    ans = if qk != 0.0 { pk / qk } else { ans }
    pkm2 = pkm1
    pkm1 = pk
    qkm2 = qkm1
    qkm1 = qk
    if fabs(pk) > BIG {
      pkm2 *= BIGINV
      pkm1 *= BIGINV
      qkm2 *= BIGINV
      qkm1 *= BIGINV
    }
    if t <= MACHEP {
      break
    }
  }
  ans * ax
}

///| Lower Incomplete Gamma Function
pub fn igam(a : Double, x : Double) -> Double {
  if x <= 0.0 || a <= 0.0 {
    return 0.0
  }
  if x > 1.0 && x > a {
    return 1.0 - igamc(a, x)
  }

  // Compute x^a * exp(-x) / gamma(a)
  let ax = a * log(x) - x - lgamma(a)
  if ax < -MAXLOG {
    return 0.0
  }
  let ax = exp(ax)

  // Power series
  let mut r = a
  let mut c = 1.0
  let mut ans = 1.0
  while true {
    r += 1.0
    c *= x / r
    ans += c
    if c / ans <= MACHEP {
      break
    }
  }
  ans * ax / a
}

// fn lgam(x: Double) -> Double {
//     // Implementation of lgam function
//     unimplemented()
// }
