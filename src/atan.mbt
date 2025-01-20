///|
fn xatan(x : Double) -> Double {
  let z = x * x
  x *
  (
    z *
    (
      (((atan_p[0] * z + atan_p[1]) * z + atan_p[2]) * z + atan_p[3]) * z +
      atan_p[4]
    ) /
    (
      ((((z + atan_q[0]) * z + atan_q[1]) * z + atan_q[2]) * z + atan_q[3]) * z +
      atan_q[4]
    )
  ) +
  x
}

///|
let atan_p = [
  -8.750608600031904122785e-01, -1.615753718733365076637e+01, -7.500855792314704667340e+01,
  -1.228866684490136173410e+02, -6.485021904942025371773e+01,
]

///|
let atan_q = [
  2.485846490142306297962e+01, 1.650270098316988542046e+02, 4.328810604912902668951e+02,
  4.853903996359136964868e+02, 1.945506571482613964425e+02,
]

///|
let morebits = 6.123233995736765886130e-17

///|
let tan3pio8 = 2.41421356237309504880

///|
fn satan(x : Double) -> Double {
  if x <= 0.66 {
    xatan(x)
  } else if x > tan3pio8 {
    PI / 2.0 - xatan(1.0 / x) + morebits
  } else {
    PI / 4.0 + xatan((x - 1.0) / (x + 1.0)) + 0.5 * morebits
  }
}

///| Compute arctangent of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(atan(0), 0)
/// assert_eq!(atan(1), 0.7853981633974483)
/// assert_eq!(atan(2), 1.1071487177940904)
/// assert_eq!(atan(-1),-0.7853981633974483)
/// assert_eq!(atan(-2),-1.1071487177940904)
/// let (pinf, ninf) = (1.0/0.0, -1.0/0.0)
/// assert_eq!(atan(pinf), 1.5707963267948966)
/// assert_eq!(atan(ninf), -1.5707963267948966)
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
/// 
/// 1. atan(NaN) = NaN
/// 2. atan(+Inf) = +π/2
/// 3. atan(-Inf) = -π/2
pub fn atan(x : Double) -> Double {
  if isnan(x) || x == 0.0 {
    x
  } else if x > 0.0 {
    satan(x)
  } else {
    -satan(-x)
  }
}

test "atan" {
  fn assert_atan_ulp!(input, expect) {
    assert_ulp!(expect, atan(input), ATAN_MAX_ULP)
  }

  assert_atan_ulp!(-1, -0.7853981633974483)
  assert_atan_ulp!(-2, -1.1071487177940904)
  assert_atan_ulp!(-3, -1.2490457723982544)
  assert_atan_ulp!(-4, -1.3258176636680326)
  assert_atan_ulp!(-5, -1.373400766945016)
  assert_atan_ulp!(-6, -1.4056476493802699)
  assert_atan_ulp!(-7, -1.4288992721907328)
  assert_atan_ulp!(-8, -1.446441332248135)
  assert_atan_ulp!(-9, -1.460139105621001)
  assert_atan_ulp!(1, 0.7853981633974483)
  assert_atan_ulp!(2, 1.1071487177940904)
  assert_atan_ulp!(3, 1.2490457723982544)
  assert_atan_ulp!(4, 1.3258176636680326)
  assert_atan_ulp!(5, 1.373400766945016)
  assert_atan_ulp!(6, 1.4056476493802699)
  assert_atan_ulp!(7, 1.4288992721907328)
  assert_atan_ulp!(8, 1.446441332248135)
  assert_atan_ulp!(9, 1.460139105621001)
  assert_atan_ulp!(10, 1.4711276743037347)
  assert_atan_ulp!(100, 1.5607966601082315)
  assert_atan_ulp!(1000, 1.5697963271282298)
  assert_atan_ulp!(10000, 1.5706963267952299)
  assert_atan_ulp!(2.5, 1.1902899496825317)
  assert_atan_ulp!(3.4, 1.2847448850775784)
  assert_atan_ulp!(5.3, 1.3843094251276797)
  assert_atan_ulp!(6.2, 1.4108832036366774)
  assert_atan_ulp!(7.1, 1.4308716562207788)
  assert_atan_ulp!(8.9, 1.4589060606232205)
  assert_atan_ulp!(9.8, 1.4691074750318196)
  assert_atan_ulp!(10.7, 1.4776090650260174)
  assert_atan_ulp!(101.6, 1.560954124923385)
  assert_atan_ulp!(1.542, 0.9954703758916351)
  assert_atan_ulp!(2.846, 1.2329012326696813)
  assert_atan_ulp!(7.881, 1.4445833528722425)
  assert_atan_ulp!(3.772, 1.3116465586544106)
  assert_atan_ulp!(-1.542, -0.9954703758916351)
  assert_atan_ulp!(-2.846, -1.2329012326696813)
  assert_atan_ulp!(-7.881, -1.4445833528722425)
  assert_atan_ulp!(-3.772, -1.3116465586544106)
  assert_atan_ulp!(-1, -0.7853981633974483)
  assert_atan_ulp!(0, 0)
  assert_atan_ulp!(-0, -0)
  assert_atan_ulp!(double_nan, double_nan)
  assert_atan_ulp!(double_pos_inf, 1.5707963267948966)
  assert_atan_ulp!(double_neg_inf, -1.5707963267948966)
}
