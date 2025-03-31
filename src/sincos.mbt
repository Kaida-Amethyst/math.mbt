///| Compute the sine and cosine of a number simultaneously
///
/// # Examples
///
/// ```moonbit
/// let x = 1.0
/// let (sin_x, cos_x) = sincos(x)
/// let sin_x_directly = sin(x)
/// let cos_x_directly = cos(x)
/// assert_eq!(sin_x, sin_x_directly)
/// assert_eq!(cos_x, cos_x_directly)
/// ```
///
/// # Special Cases
///
/// 1. sincos(+-inf) = (NaN, NaN)
/// 2. sincos(NaN) = (NaN, NaN)
///
/// # Accuracy
///
/// Same as `sin` and `cos`, both are 1 ulp.
pub fn sincos(x : Double) -> (Double, Double) {
  if isinf(x) || isnan(x) {
    return (@double.not_a_number, @double.not_a_number)
  }
  let y = [0.0, 0.0]
  let z = 0.0
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  if ix <= 0x3fe921fb {
    return (__kernel_sin(x, z, 0), __kernel_cos(x, z))
  } else {
    let n = rem_pio2(x, y)
    match n & 3 {
      0 => (__kernel_sin(y[0], y[1], 1), __kernel_cos(y[0], y[1]))
      1 => (__kernel_cos(y[0], y[1]), -__kernel_sin(y[0], y[1], 1))
      2 => (-__kernel_sin(y[0], y[1], 1), -__kernel_cos(y[0], y[1]))
      _ => (-__kernel_cos(y[0], y[1]), __kernel_sin(y[0], y[1], 1))
    }
  }
}

///|
test "sincos" {
  let arr_x = [
    0.0, 1.0, 2.0, 3.0, 4.0, 0.7853981633974483, 1.5707963267948966, 3.141592653589793,
    10000.0,
  ]
  for x in arr_x {
    let sin_x = sin(x)
    let cos_x = cos(x)
    let (_sin_x, _cos_x) = sincos(x)
    assert_eq!(_sin_x, sin_x)
    assert_eq!(_cos_x, cos_x)
  }
}
