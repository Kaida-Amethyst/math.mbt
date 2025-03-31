///| Compute the tangent of double-precision floating-point number `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(tan(-1.0), -1.5574077246549023)
/// assert_eq!(tan(3.141592653589793), -0.00000000000000012246467991473532)
/// assert_eq!(tan(1.5707963267948966), 16331239353195370)
/// assert_eq!(tan(0.7853981633974483), 0.9999999999999999)
/// assert_eq!(tan(0.0), 0)
/// assert_eq!(tan(10000), 0.3209711346238147)
/// ```
///
/// # Special Cases
///
/// 1. tan(+-inf) = NaN
/// 2. tan(NaN) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn tan(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return @double.not_a_number
  }
  let y = Array::make(2, 0.0)
  let z = 0.0
  if fabs(x) <= PI_OVER_4 {
    __kernel_tan(x, z, 1)
  } else {
    let n = rem_pio2(x, y)
    __kernel_tan(y[0], y[1], 1 - ((n & 1) << 1))
  }
}

///|
test "tan" {
  fn assert_tan_ulp!(input, expect) {
    assert_ulp!(expect, tan(input), TAN_MAX_ULP)
  }

  assert_tan_ulp!(-0.8, -1.0296385570503641)
  assert_tan_ulp!(-0.7, -0.8422883804630794)
  assert_tan_ulp!(-0.6, -0.6841368083416923)
  assert_tan_ulp!(-0.5, -0.5463024898437905)
  assert_tan_ulp!(-0.4, -0.4227932187381618)
  assert_tan_ulp!(-0.3, -0.30933624960962325)
  assert_tan_ulp!(-0.2, -0.2027100355086725)
  assert_tan_ulp!(-0.1, -0.10033467208545055)
  assert_tan_ulp!(-3.141592653589793, 1.2246467991473532e-16)
  assert_tan_ulp!(-1.5707963267948966, -1.633123935319537e+16)
  assert_tan_ulp!(-0.7853981633974483, -0.9999999999999999)
  assert_tan_ulp!(0.1, 0.10033467208545055)
  assert_tan_ulp!(0.2, 0.2027100355086725)
  assert_tan_ulp!(0.3, 0.30933624960962325)
  assert_tan_ulp!(0.4, 0.4227932187381618)
  assert_tan_ulp!(0.5, 0.5463024898437905)
  assert_tan_ulp!(0.6, 0.6841368083416923)
  assert_tan_ulp!(0.7, 0.8422883804630794)
  assert_tan_ulp!(0.8, 1.0296385570503641)
  assert_tan_ulp!(0.9, 1.2601582175503392)
  assert_tan_ulp!(1, 1.5574077246549023)
  assert_tan_ulp!(3.141592653589793, -1.2246467991473532e-16)
  assert_tan_ulp!(1.5707963267948966, 1.633123935319537e+16)
  assert_tan_ulp!(0.7853981633974483, 0.9999999999999999)
  assert_tan_ulp!(-1, -1.5574077246549023)
  assert_tan_ulp!(-2, 2.185039863261519)
  assert_tan_ulp!(-3, 0.1425465430742778)
  assert_tan_ulp!(-4, -1.1578212823495777)
  assert_tan_ulp!(-5, 3.380515006246586)
  assert_tan_ulp!(-6, 0.29100619138474915)
  assert_tan_ulp!(-7, -0.8714479827243187)
  assert_tan_ulp!(-8, 6.799711455220379)
  assert_tan_ulp!(-9, 0.45231565944180985)
  assert_tan_ulp!(1, 1.5574077246549023)
  assert_tan_ulp!(2, -2.185039863261519)
  assert_tan_ulp!(3, -0.1425465430742778)
  assert_tan_ulp!(4, 1.1578212823495777)
  assert_tan_ulp!(5, -3.380515006246586)
  assert_tan_ulp!(6, -0.29100619138474915)
  assert_tan_ulp!(7, 0.8714479827243187)
  assert_tan_ulp!(8, -6.799711455220379)
  assert_tan_ulp!(9, -0.45231565944180985)
  assert_tan_ulp!(10, 0.6483608274590866)
  assert_tan_ulp!(100, -0.5872139151569291)
  assert_tan_ulp!(1000, 1.4703241557027185)
  assert_tan_ulp!(10000, 0.3209711346238147)
  assert_tan_ulp!(27185679891.54321, 0.3461913239510597)
  assert_tan_ulp!(31415926535897.9323846, 0.0012091241554056254)
  assert_tan_ulp!(516974365183497.332244, 8.895931061160688)
  assert_tan_ulp!(2.5, -0.7470222972386603)
  assert_tan_ulp!(3.4, 0.26431690086742515)
  assert_tan_ulp!(5.3, -1.50127339580693)
  assert_tan_ulp!(6.2, -0.08337771486592861)
  assert_tan_ulp!(7.1, 1.0648931268833821)
  assert_tan_ulp!(8.9, -0.578923587933547)
  assert_tan_ulp!(9.8, 0.3938830407517425)
  assert_tan_ulp!(10.7, 3.2841408053775507)
  assert_tan_ulp!(101.6, 1.8228497299403925)
  assert_tan_ulp!(1.542, 34.71705201708467)
  assert_tan_ulp!(2.846, -0.3045137125920165)
  assert_tan_ulp!(7.881, -37.00285415158369)
  assert_tan_ulp!(3.772, 0.7297388097669394)
  assert_tan_ulp!(-1.542, -34.71705201708467)
  assert_tan_ulp!(-2.846, 0.3045137125920165)
  assert_tan_ulp!(-7.881, 37.00285415158369)
  assert_tan_ulp!(-3.772, -0.7297388097669394)
  assert_tan_ulp!(-15749436813364.748916, 0.2044851060744427)
  assert_tan_ulp!(0, 0)
  assert_tan_ulp!(-0, -0)
  assert_tan_ulp!(@double.not_a_number, @double.not_a_number)
  assert_tan_ulp!(@double.infinity, @double.not_a_number)
  assert_tan_ulp!(@double.neg_infinity, @double.not_a_number)
}
