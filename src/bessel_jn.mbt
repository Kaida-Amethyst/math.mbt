///| Calculate the value of the Bessel function of the first kind of order n for the input argument.
///
/// # Special Cases
///
/// 1. jn(n, NaN) returns NaN.
/// 2. jn(n, x) returns NaN for n < 0.
/// 3. jn(n, x) returns NaN for x < 0.
/// 4. jn(n, +-0) returns 0.
///
/// # Notes
///
/// 1. For n = 0, j0(x) is called.
/// 2. For n = 1, j1(x) is called.
pub fn bessel_jn(n : Int, x : Double) -> Double {
  if isnan(x) {
    return @double.not_a_number
  }
  if n == 0 {
    return j0(x)
  }
  if n == 1 {
    return j1(x)
  }
  let (n, x) = if n < 0 { (-n, -x) } else { (n, x) }
  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let sgn = n & 1 & (hx >> 31)
  let x = fabs(x)
  let mut b = 0.0
  let mut a = 0.0
  let mut temp = 0.0
  if x == 0 || isinf(x) {
    b = 0.0
  } else if n.to_double() <= x {
    if ix >= 0x52d00000 {
      let temp = match n & 3 {
        0 => cos(x) + sin(x)
        1 => -cos(x) + sin(x)
        2 => -cos(x) - sin(x)
        3 => cos(x) - sin(x)
        _ => panic()
      }
      b = INV_SQRT_PI * temp / sqrt(x)
    } else {
      a = j0(x)
      b = j1(x)
      temp = 0.0
      for i = 0; i < n; i = i + 1 {
        temp = b
        b = (i + i).to_double() / x * b - a
        a = temp
      }
    }
  } else if ix < 0x3e100000 {
    if n > 33 {
      b = 0.0
    } else {
      temp = x * 0.5
      b = temp
      a = 1.0
      for i = 2; i <= n; i = i + 1 {
        a = a * i.to_double()
        b = b * temp
      }
      b = b / a
    }
  } else {
    let w = (n + n).to_double() / x
    let h = 2.0 / x
    let mut q0 = w
    let mut z = w + h
    let mut q1 = w * z - 1.0
    let mut k = 1
    while q1 < 1.0e9 {
      k = k + 1
      z = z + h
      let tmp = z * q1 - q0
      q0 = q1
      q1 = tmp
    }
    let m = n + n
    let mut t = 0.0
    for i = 2 * (n + k); i >= m; i = i - 2 {
      t = 1.0 / (i.to_double() / x - t)
    }
    a = t
    b = 1.0
    let tmp = n.to_double()
    let v = 2.0 / x
    let tmp = tmp * log(fabs(v * tmp))
    if tmp < 7.09782712893383973096e+02 {
      let i = n - 1
      let mut di = (i + i).to_double()
      for i = i; i > 0; i = i - 1 {
        temp = b
        b = b * di
        b = b / x - a
        a = temp
        di = di - 2.0
      }
    } else {
      let i = n - 1
      let mut di = (i + i).to_double()
      for i = i; i > 0; i = i - 1 {
        temp = b
        b = b * di
        b = b / x - a
        a = temp
        di = di - 2.0
        if b > 1.0e100 {
          a = a / b
          t = t / b
          b = 1.0
        }
      }
    }
    b = t * j0(x) / b
  }
  if sgn == 1 {
    -b
  } else {
    b
  }
}

///| `jn` is an alias for `bessel_jn`.
pub let jn : (Int, Double) -> Double = bessel_jn
