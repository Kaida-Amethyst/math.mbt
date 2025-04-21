///| Compute cos(pi*x) with high accuracy.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(cospi(0), 1);
/// assert_eq!(cospi(1), -1);
/// assert_eq!(cospi(0.5), 0);
/// assert_eq!(cospi(-1), -1);
/// assert_eq!(cospi(-0.5), 0);
/// ```
/// 
/// # Accuracy
///
/// 49 ulp (1 bit error)
///
/// # Special Cases
///
/// 1. cospi(NaN) = NaN
/// 2. cospi(±∞) = NaN
pub fn cospi(x : Double) -> Double {
  let mut invert = false
  if fabs(x) < 0.25 {
    return cos(DOUBLE_PI * x)
  }
  let mut x = x
  if x < 0 {
    x = -x
  }
  let mut rem = floor(x)
  if fabs(floor(rem / 2) * 2 - rem) > double_epsilon {
    invert = not(invert)
  }
  rem = x - rem
  if rem > 0.5 {
    rem = 1.0 - rem
    invert = not(invert)
  }
  if rem == 0.5 {
    return 0.0
  }
  if rem > 0.25 {
    rem = 0.5 - rem
    rem = sin(DOUBLE_PI * rem)
  } else {
    rem = cos(DOUBLE_PI * rem)
  }
  if invert {
    -rem
  } else {
    rem
  }
}

///|
test "cospi" {
  fn assert_cospi_ulp!(input, expect) {
    assert_ulp!(expect, cospi(input), COSPI_MAX_ULP)
  }

  assert_cospi_ulp!(-0.8, -0.8090169943749475)
  assert_cospi_ulp!(-0.7, -0.587785252292473)
  assert_cospi_ulp!(-0.6, -0.3090169943749473)
  assert_cospi_ulp!(-0.5, 0)
  assert_cospi_ulp!(-0.4, 0.3090169943749473)
  assert_cospi_ulp!(-0.3, 0.5877852522924731)
  assert_cospi_ulp!(-0.2, 0.8090169943749475)
  assert_cospi_ulp!(-0.1, 0.9510565162951535)
  assert_cospi_ulp!(-0, 1)
  assert_cospi_ulp!(-3.141592653589793, -0.9026853619330713)
  assert_cospi_ulp!(-1.570796326794897, 0.2205840407496979)
  assert_cospi_ulp!(-0.7853981633974483, -0.7812118921104881)
  assert_cospi_ulp!(0, 1)
  assert_cospi_ulp!(0.1, 0.9510565162951535)
  assert_cospi_ulp!(0.2, 0.8090169943749475)
  assert_cospi_ulp!(0.3, 0.5877852522924731)
  assert_cospi_ulp!(0.4, 0.3090169943749473)
  assert_cospi_ulp!(0.5, 0)
  assert_cospi_ulp!(0.6, -0.3090169943749473)
  assert_cospi_ulp!(0.7, -0.587785252292473)
  assert_cospi_ulp!(0.8, -0.8090169943749475)
  assert_cospi_ulp!(0.9, -0.9510565162951536)
  assert_cospi_ulp!(1, -1)
  assert_cospi_ulp!(3.141592653589793, -0.9026853619330713)
  assert_cospi_ulp!(1.570796326794897, 0.2205840407496979)
  assert_cospi_ulp!(0.7853981633974483, -0.7812118921104881)
  assert_cospi_ulp!(-1, -1)
  assert_cospi_ulp!(-2, 1)
  assert_cospi_ulp!(-3, -1)
  assert_cospi_ulp!(-4, 1)
  assert_cospi_ulp!(-5, -1)
  assert_cospi_ulp!(-6, 1)
  assert_cospi_ulp!(-7, -1)
  assert_cospi_ulp!(-8, 1)
  assert_cospi_ulp!(-9, -1)
  assert_cospi_ulp!(1, -1)
  assert_cospi_ulp!(2, 1)
  assert_cospi_ulp!(3, -1)
  assert_cospi_ulp!(4, 1)
  assert_cospi_ulp!(5, -1)
  assert_cospi_ulp!(6, 1)
  assert_cospi_ulp!(7, -1)
  assert_cospi_ulp!(8, 1)
  assert_cospi_ulp!(9, -1)
  assert_cospi_ulp!(10, 1)
  assert_cospi_ulp!(100, 1)
  assert_cospi_ulp!(1000, 1)
  assert_cospi_ulp!(10000, 1)
  assert_cospi_ulp!(2.5, 0)
  assert_cospi_ulp!(3.4, -0.3090169943749477)
  assert_cospi_ulp!(5.3, -0.5877852522924736)
  assert_cospi_ulp!(6.2, 0.8090169943749471)
  assert_cospi_ulp!(7.1, -0.9510565162951539)
  assert_cospi_ulp!(8.9, -0.9510565162951539)
  assert_cospi_ulp!(9.800000000000001, 0.8090169943749488)
  assert_cospi_ulp!(10.7, -0.5877852522924714)
  assert_cospi_ulp!(101.6, 0.3090169943749305)
  assert_cospi_ulp!(1.542, 0.1315643590922826)
  assert_cospi_ulp!(2.846, -0.8852313113324554)
  assert_cospi_ulp!(7.881, 0.930928393116936)
  assert_cospi_ulp!(3.772, 0.7542513807361034)
  assert_cospi_ulp!(-1.542, 0.1315643590922826)
  assert_cospi_ulp!(-2.846, -0.8852313113324554)
  assert_cospi_ulp!(-7.881, 0.930928393116936)
  assert_cospi_ulp!(-3.772, 0.7542513807361034)
  assert_cospi_ulp!(-1, -1)
  assert_cospi_ulp!(0, 1)
  assert_cospi_ulp!(-0, 1)
  assert_cospi_ulp!(@double.not_a_number, @double.not_a_number)
  assert_cospi_ulp!(@double.infinity, @double.not_a_number)
  assert_cospi_ulp!(@double.neg_infinity, @double.not_a_number)
}
