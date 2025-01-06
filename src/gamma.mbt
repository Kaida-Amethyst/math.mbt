const TWO_SQRT_E_OVER_PI: Double = 1.8603827342052657173362492472666631120594218414085755

///| Compute the gamma function of x.
pub fn tgamma(x: Double) -> Double {
  let gamma_r = 10.900511
  let gamma_dk = [
    2.48574089138753565546e-5,
    1.05142378581721974210,
    -3.45687097222016235469,
    4.51227709466894823700,
    -2.98285225323576655721,
    1.05639711577126713077,
    -1.95428773191645869583e-1,
    1.70970543404441224307e-2,
    -5.71926117404305781283e-4,
    4.63399473359905636708e-6,
    -2.71994908488607703910e-9,
  ]

  if x < 0.5 {
    let mut s = gamma_dk[0]
    for i = 1; i < gamma_dk.length(); i = i + 1 {
        s = s + gamma_dk[i] / (i.to_double() - x)
    }

    PI / (sinpi(x) * s * TWO_SQRT_E_OVER_PI * ((0.5 - x + gamma_r) / E).pow(0.5 - x))
  } else {
    let mut s = gamma_dk[0]
    for i = 1; i < gamma_dk.length(); i = i + 1 {
        s = s + gamma_dk[i] / (x + i.to_double() - 1.0)
    }

    s * TWO_SQRT_E_OVER_PI * pow((x - 0.5 + gamma_r) / E, x - 0.5)
  }
}

///| Compute the gamma function of x, alias for `tgamma`.
pub fn gamma(x: Double) -> Double {
  tgamma(x)
}
