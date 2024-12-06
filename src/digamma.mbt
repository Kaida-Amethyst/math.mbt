
///| digamma(x) computes the digamma function of x.
pub fn digamma(x: Double) -> Double {
  let pi: Double = 3.14159265358979323846;
  let pos_inf: Double = (0x7ff0_0000_0000_0000UL).reinterpret_as_double();
  let mut x = x

  if x == 0.0 {
    return copysign(pos_inf, -x)
  }

  let mut result = 0.0;
  if x < 0.0 {
    let x_is_integer = x == x.trunc();
    if x_is_integer {
      return double_nan
    }

    // double q, r;
    // r = modf(x, &q);
    let r = x - x.trunc();
    result = -pi / tan(pi * r);
    x = 1.0 - x;
  }

  while x < 10.0 {
    result -= 1.0 / x;
    x += 1.0;
  }

  if x == 10.0 {
    return result + 2.25175258906672110764;
  }

  let mut y = 0.0;
  if x < 1.0e17 {
    let a = [
      8.33333333333333333333E-2,
      -2.10927960927960927961E-2,
      7.57575757575757575758E-3,
      -4.16666666666666666667E-3,
      3.96825396825396825397E-3,
      -8.33333333333333333333E-3,
      8.33333333333333333333E-2,
    ];

    let z = 1.0 / (x * x);

    let mut polevl_result = 0.0;
    for i = 0; i <=6; i = i + 1{
      polevl_result = polevl_result * z + a[i];
    }
    y = z * polevl_result;
  }
  log(x) - (0.5 / x) - y + result;
}
