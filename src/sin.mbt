///| Compute sine of double-precision floating-point number `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(sin(-1.0), -0.8414709848078965)
/// assert_eq!(sin(0.0), 0)
/// assert_eq!(sin(1.5707963267948966), 1.0)
/// assert_eq!(sin(3.141592653589793), 0.00000000000000012246467991473532)
/// assert_eq!(sin(10000), -0.30561438888825215)
/// ```
///
/// # Special Cases
///
/// 1. sin(+-inf) = NaN
/// 2. sin(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn sin(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = [0.0, 0.0]
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
    return __kernel_sin(x, z, 0)
  } else {
    let n = rem_pio2(x, y)
    match n & 3 {
      0 => __kernel_sin(y[0], y[1], 1)
      1 => __kernel_cos(y[0], y[1])
      2 => -__kernel_sin(y[0], y[1], 1)
      _ => -__kernel_cos(y[0], y[1])
    }
  }
}

///|
test "sin" {
  fn assert_sin_ulp!(input, expect) {
    assert_ulp!(expect, sin(input), SIN_MAX_ULP)
  }

  assert_sin_ulp!(-0.8, -0.7173560908995228)
  assert_sin_ulp!(-0.7, -0.644217687237691)
  assert_sin_ulp!(-0.6, -0.5646424733950354)
  assert_sin_ulp!(-0.5, -0.479425538604203)
  assert_sin_ulp!(-0.4, -0.3894183423086505)
  assert_sin_ulp!(-0.3, -0.29552020666133955)
  assert_sin_ulp!(-0.2, -0.19866933079506122)
  assert_sin_ulp!(-0.1, -0.09983341664682815)
  assert_sin_ulp!(-3.141592653589793, -1.2246467991473532e-16)
  assert_sin_ulp!(-1.570796326794897, -1)
  assert_sin_ulp!(-0.7853981633974483, -0.7071067811865475)
  assert_sin_ulp!(0.1, 0.09983341664682815)
  assert_sin_ulp!(0.2, 0.19866933079506122)
  assert_sin_ulp!(0.3, 0.29552020666133955)
  assert_sin_ulp!(0.4, 0.3894183423086505)
  assert_sin_ulp!(0.5, 0.479425538604203)
  assert_sin_ulp!(0.6, 0.5646424733950354)
  assert_sin_ulp!(0.7, 0.644217687237691)
  assert_sin_ulp!(0.8, 0.7173560908995228)
  assert_sin_ulp!(0.9, 0.7833269096274834)
  assert_sin_ulp!(1, 0.8414709848078965)
  assert_sin_ulp!(3.141592653589793, 1.2246467991473532e-16)
  assert_sin_ulp!(1.570796326794897, 1)
  assert_sin_ulp!(0.7853981633974483, 0.7071067811865475)
  assert_sin_ulp!(-1, -0.8414709848078965)
  assert_sin_ulp!(-2, -0.9092974268256817)
  assert_sin_ulp!(-3, -0.1411200080598672)
  assert_sin_ulp!(-4, 0.7568024953079282)
  assert_sin_ulp!(-5, 0.9589242746631385)
  assert_sin_ulp!(-6, 0.27941549819892586)
  assert_sin_ulp!(-7, -0.6569865987187891)
  assert_sin_ulp!(-8, -0.9893582466233818)
  assert_sin_ulp!(-9, -0.4121184852417566)
  assert_sin_ulp!(1, 0.8414709848078965)
  assert_sin_ulp!(2, 0.9092974268256817)
  assert_sin_ulp!(3, 0.1411200080598672)
  assert_sin_ulp!(4, -0.7568024953079282)
  assert_sin_ulp!(5, -0.9589242746631385)
  assert_sin_ulp!(6, -0.27941549819892586)
  assert_sin_ulp!(7, 0.6569865987187891)
  assert_sin_ulp!(8, 0.9893582466233818)
  assert_sin_ulp!(9, 0.4121184852417566)
  assert_sin_ulp!(10, -0.5440211108893698)
  assert_sin_ulp!(100, -0.5063656411097588)
  assert_sin_ulp!(1000, 0.8268795405320025)
  assert_sin_ulp!(10000, -0.30561438888825215)
  assert_sin_ulp!(27185679891.54321, 0.32714218977159853)
  assert_sin_ulp!(31415926535897.9323846, 0.0012091232715481885)
  assert_sin_ulp!(516974365183497.3, 0.9937411440812564)
  assert_sin_ulp!(2.5, 0.5984721441039564)
  assert_sin_ulp!(3.4, -0.2555411020268312)
  assert_sin_ulp!(5.3, -0.8322674422239013)
  assert_sin_ulp!(6.2, -0.0830894028174964)
  assert_sin_ulp!(7.1, 0.7289690401258759)
  assert_sin_ulp!(8.9, 0.5010208564578846)
  assert_sin_ulp!(9.800000000000001, -0.3664791292519284)
  assert_sin_ulp!(10.7, -0.9566350162701879)
  assert_sin_ulp!(101.6, 0.8767368169734758)
  assert_sin_ulp!(1.542, 0.9995854144315939)
  assert_sin_ulp!(2.846, 0.2913068512553354)
  assert_sin_ulp!(7.881, 0.9996350261518016)
  assert_sin_ulp!(3.772, -0.5894738561593085)
  assert_sin_ulp!(-1.542, -0.9995854144315939)
  assert_sin_ulp!(-2.846, -0.2913068512553354)
  assert_sin_ulp!(-7.881, -0.9996350261518016)
  assert_sin_ulp!(-3.772, 0.5894738561593085)
  assert_sin_ulp!(-15749436813364.748916, -0.20033948519409467)
  assert_sin_ulp!(0, 0)
  assert_sin_ulp!(-0, -0)
  assert_sin_ulp!(@double.not_a_number, @double.not_a_number)
  assert_sin_ulp!(@double.infinity, @double.not_a_number)
  assert_sin_ulp!(@double.neg_infinity, @double.not_a_number)
}

// let sin_coef: Array[Double] = [
//     1.58962301576546568060E-10,
//     -2.50507477628578072866E-8,
//     2.75573136213857245213E-6,
//     -1.98412698295895385996E-4,
//     8.33333333332211858878E-3,
//     -1.66666666666666307295E-1,
// ]
//
// let cos_coef: Array[Double] = [
//     -1.13585365213876817300E-11,
//     2.08757008419747316778E-9,
//     -2.75573141792967388112E-7,
//     2.48015872888517045348E-5,
//     -1.38888888888730564116E-3,
//     4.16666666666665929218E-2,
// ]
//
// const DP1: Double = 7.85398125648498535156E-1
// const DP2: Double = 3.77489470793079817668E-8
// const DP3: Double = 2.69515142907905952645E-15
// const LOSS_TH: Double = 1.073741824e9
//
// pub fn cephes_sin(x: Double) -> Double {
//     let mut y: Double = 0.0
//     let mut z: Double = 0.0
//     let mut zz: Double = 0.0
//     let mut j: Int = 0
//     let mut sign: Int = 1
//
//     if isnan(x) || isinf(x) {
//         return @double.not_a_number
//     }
//
//     let mut x = x
//     if x < 0.0 {
//         x = -x
//         sign = -1
//     }
//
//     if x > LOSS_TH {
//         return 0.0
//     }
//
//     y = floor(x / PI_OVER_4)
//     z = ldexp(y, -4)
//     z = floor(z)
//     z = y - ldexp(z, 4)
//
//     j = z.to_int()
//     if (j & 1) != 0 {
//         j += 1
//         y += 1.0
//     }
//     j = j & 7
//
//     if j > 3 {
//         sign = -sign
//         j -= 4
//     }
//
//     z = ((x - y * DP1) - y * DP2) - y * DP3
//     zz = z * z
//
//     if (j == 1) || (j == 2) {
//         y = 1.0 - zz * 0.5 + zz * zz * polevl(zz, cos_coef)
//     } else {
//         y = z + z * z * z * polevl(zz, sin_coef)
//     }
//
//     if sign < 0 {
//         y = -y
//     }
//
//     y
// }
//
// fn cephes_cos(x: Double) -> Double {
//     let mut y: Double = 0.0
//     let mut z: Double = 0.0
//     let mut zz: Double = 0.0
//     let mut i: Int = 0
//     let mut j: Int = 0
//     let mut sign: Int = 1
//
//     if isnan(x) && isinf(x) {
//         return @double.not_a_number
//     }
//
//     let mut x = x
//     if x < 0.0 {
//         x = -x
//     }
//
//     if x > LOSS_TH {
//         return 0.0
//     }
//
//     y = floor(x / (DOUBLE_PI / 4.0))
//     z = floor(y / 16.0)
//     z = y - z * 16.0
//
//     i = z.to_int()
//     if (i & 1) != 0 {
//         i += 1
//         y += 1.0
//     }
//     j = i & 7
//
//     if j > 3 {
//         j -= 4
//         sign = -sign
//     }
//
//     if j > 1 {
//         sign = -sign
//     }
//
//     z = ((x - y * DP1) - y * DP2) - y * DP3
//     zz = z * z
//
//     if (j == 1) || (j == 2) {
//         y = z + z * z * z * polevl(zz, sin_coef)
//     } else {
//         y = 1.0 - zz / 2.0 + zz * zz * polevl(zz, cos_coef)
//     }
//
//     if sign < 0 {
//         y = -y
//     }
//
//     y
// }
