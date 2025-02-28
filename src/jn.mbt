///| Calculate the value of the Bessel function of the second kind of order n for the input argument.
///
/// # Special Cases
///
/// 1. yn(n, x) returns NaN for n < 0.
/// 2. yn(n, +-0) returns NaN.
/// 3. yn(n, x) returns NaN for x < 0.
/// 4. yn(n, +inf) returns +0.
/// 5. yn(n, NaN) returns NaN.
///
/// # Note
///
/// 1. For n = 0, y0(x) is called.
/// 2. For n = 1, y1(x) is called.
pub fn yn(n : Int, x : Double) -> Double {
  if isnan(x) {
    return double_nan
  }
  if ispinf(x) {
    return 0.0
  }
  if n < 0 {
    return double_nan
  }
  if x == 0.0 {
    return double_nan
  }
  if x < 0 {
    return double_nan
  }
  let (n, sign) = if n < 0 { (-n, 1 - ((n & 1) << 1)) } else { (n, 1) }
  if n == 0 {
    return y0(x)
  }
  if n == 1 {
    return sign.to_double() * y1(x)
  }
  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let mut a = 0.0
  let mut b = 0.0
  let mut temp = 0.0
  if ix >= 0x52d00000 {
    temp = match n & 3 {
      0 => sin(x) - cos(x)
      1 => -sin(x) - cos(x)
      2 => -sin(x) + cos(x)
      3 => sin(x) + cos(x)
      _ => panic()
    }
    b = INV_SQRT_PI * temp / sqrt(x)
  } else {
    a = y0(x)
    b = y1(x)
    for i = 1; i < n && __hi(b) != 0xfff00000; i = i + 1 {
      temp = b
      b = (i + i).to_double() / x * b - a
      a = temp
    }
  }
  if sign > 0 {
    b
  } else {
    -b
  }
}
