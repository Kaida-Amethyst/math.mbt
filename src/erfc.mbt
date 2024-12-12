///| Compute the error function of x
/// # Special Cases
///
/// 1. erfc(0) = 1
/// 2. erfc(inf) = 0
/// 3. erfc(-inf) = 2
/// 4. erfc(NaN) = NaN
pub fn erfc(x: Double) -> Double {
  if isnan(x) {
    return double_nan
  }

  if isinf(x) {
    return if x > 0 { 0.0 } else { 2.0 }
  }

  let tiny = 1.0e-300
  let erx = 8.45062911510467529297e-01
  let pp0 = 1.28379167095512558561e-01
  let pp1 = -3.25042107247001499370e-01
  let pp2 = -2.84817495755985104766e-02
  let pp3 = -5.77027029648944159157e-03
  let pp4 = -2.37630166566501626084e-05
  let qq1 = 3.97917223959155352819e-01
  let qq2 = 6.50222499887672944485e-02
  let qq3 = 5.08130628187576562776e-03
  let qq4 = 1.32494738004321644526e-04
  let qq5 = -3.96022827877536812320e-06

  let pa0 = -2.36211856075265944077e-03
  let pa1 = 4.14856118683748331666e-01
  let pa2 = -3.72207876035701323847e-01
  let pa3 = 3.18346619901161753674e-01
  let pa4 = -1.10894694282396677476e-01
  let pa5 = 3.54783043256182359371e-02
  let pa6 = -2.16637559486879084300e-03
  let qa1 = 1.06420880400844228286e-01
  let qa2 = 5.40397917702171048937e-01
  let qa3 = 7.18286544141962662868e-02
  let qa4 = 1.26171219808761642112e-01
  let qa5 = 1.36370839120290507362e-02
  let qa6 = 1.19844998467991074170e-02
  let ra0 = -9.86494403484714822705e-03
  let ra1 = -6.93858572707181764372e-01
  let ra2 = -1.05586262253232909814e+01
  let ra3 = -6.23753324503260060396e+01
  let ra4 = -1.62396669462573470355e+02
  let ra5 = -1.84605092906711035994e+02
  let ra6 = -8.12874355063065934246e+01
  let ra7 = -9.81432934416914548592e+00
  let sa1 = 1.96512716674392571292e+01
  let sa2 = 1.37657754143519042600e+02
  let sa3 = 4.34565877475229228821e+02
  let sa4 = 6.45387271733267880336e+02
  let sa5 = 4.29008140027567833386e+02
  let sa6 = 1.08635005541779435134e+02
  let sa7 = 6.57024977031928170135e+00
  let sa8 = -6.04244152148580987438e-02

  let rb0 = -9.86494292470009928597e-03
  let rb1 = -7.99283237680523006574e-01
  let rb2 = -1.77579549177547519889e+01
  let rb3 = -1.60636384855821916062e+02
  let rb4 = -6.37566443368389627722e+02
  let rb5 = -1.02509513161107724954e+03
  let rb6 = -4.83519191608651397019e+02
  let sb1 = 3.03380607434824582924e+01
  let sb2 = 3.25792512996573918826e+02
  let sb3 = 1.53672958608443695994e+03
  let sb4 = 3.19985821950859553908e+03
  let sb5 = 2.55305040643316442583e+03
  let sb6 = 4.74528541206955367215e+02
  let sb7 = -2.24409524465858183362e+01

  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff

  if ix < 0x3feb0000 {
    if ix < 0x3c700000 {
      return 1.0 - x
    }
    let z = x * x
    let r = pp0 + z * (pp1 + z * (pp2 + z * (pp3 + z * pp4)))
    let s = 1.0 + z * (qq1 + z * (qq2 + z * (qq3 + z * (qq4 + z * qq5))))
    let y = r / s
    if hx < 0x3fd00000 {
      return 1.0 - (x + x * y)
    } else {
      let r = x * y
      let r = r + (x - 0.5)
      return 0.5 - r
    }
  }

  if ix < 0x3ff40000 {
    let s = fabs(x) - 1.0
    let p = pa0 + s * (pa1 + s * (pa2 + s * (pa3 + s * (pa4 + s * (pa5 + s * pa6)))))
    let q = 1.0 + s * (qa1 + s * (qa2 + s * (qa3 + s * (qa4 + s * (qa5 + s * qa6)))))
    if hx >= 0 {
      let z = 1.0 - erx
      return z - p / q
    } else {
      let z = erx + p / q
      return 1.0 + z
    }
  }

  if ix < 0x403c0000 {
    let x = fabs(x)
    let s = 1.0 / (x * x)
    let (r, s) = if ix < 0x4006DB6D {
      let r = ra0 + s * (ra1 + s * (ra2 + s * (ra3 + s * (ra4 + s * (ra5 + s * (ra6 + s * ra7))))))
      let s = 1.0 + s * (sa1 + s * (sa2 + s * (sa3 + s * (sa4 + s * (sa5 + s * (sa6 + s * (sa7 + s * sa8)))))))
      (r, s)
    } else {
      if hx < 0 && ix >= 0x40180000 {
        return 2.0 - tiny
      }
      let r = rb0 + s * (rb1 + s * (rb2 + s * (rb3 + s * (rb4 + s * (rb5 + s * rb6)))))
      let s = 1.0 + s * (sb1 + s * (sb2 + s * (sb3 + s * (sb4 + s * (sb5 + s * (sb6 + s * sb7))))))
      (r, s)
    }

    let z = x
    let z = __combineW(__hi(z), 0)
    let r = exp(-z * z - 0.5625) * exp((z - x) * (z + x) + r / s)
    if hx > 0 {
      return r / x
    } else {
      return 2.0 - r / x
    }
  } else {
    if hx > 0 {
      return tiny * tiny
    } else {
      return 2.0 - tiny
    }
  }

}

