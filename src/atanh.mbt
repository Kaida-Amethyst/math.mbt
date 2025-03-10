///| Computes hyperbolic arctangent of ``x``.
///
/// # Examples
///
/// ```moonbit
/// let double_pos_inf = 1.0 / 0.0
/// let double_neg_inf = -1.0 / 0.0
/// assert_eq!(atanh(0.0), 0.0);
/// assert_eq!(atanh(0.5), 0.5493061443340548);
/// assert_eq!(atanh(1.0), double_pos_inf);
/// assert_eq!(atanh(-0.5), -0.5493061443340548);
/// assert_eq!(atanh(-1.0), double_neg_inf);
/// ```
///
/// # Accuracy:
///
/// 0 ulp (unit in the last place).
///
/// # Special cases:
///
/// 1. atanh(x) = NaN for all |x| > 1
/// 2. atanh(NaN) = NaN
/// 3. atanh(1) = +Inf
/// 4. atanh(-1) = -Inf
pub fn atanh(x : Double) -> Double {
  let hx : Int = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if fabs(x) > 1.0 {
    return double_nan
  }
  if x == 1.0 {
    return double_pos_inf
  }
  if x == -1.0 {
    return double_neg_inf
  }
  if ix < 0x3e300000 && 1.0e300 + x > 0.0 {
    return x
  }
  let x = fabs(x)
  let t = if x <= 0.5 {
    let t = x + x
    0.5 * log1p(t + t * x / (1.0 - x))
  } else {
    0.5 * log1p((x + x) / (1.0 - x))
  }
  if hx >= 0 {
    t
  } else {
    -t
  }
}

///|
pub impl Floating for Double with atanh(self) -> Double {
  atanh(self)
}

///|
test "atanh" {
  fn assert_atanh_ulp!(input, expect) {
    assert_ulp!(expect, atanh(input), ATANH_MAX_ULP)
  }

  assert_atanh_ulp!(-0.8, -1.0986122886681098)
  assert_atanh_ulp!(-0.7, -0.8673005276940531)
  assert_atanh_ulp!(-0.6, -0.6931471805599453)
  assert_atanh_ulp!(-0.5, -0.5493061443340548)
  assert_atanh_ulp!(-0.4, -0.42364893019360184)
  assert_atanh_ulp!(-0.3, -0.30951960420311175)
  assert_atanh_ulp!(-0.2, -0.2027325540540822)
  assert_atanh_ulp!(-0.1, -0.10033534773107558)
  assert_atanh_ulp!(-0, -0)
  assert_atanh_ulp!(-3.141592653589793, double_nan)
  assert_atanh_ulp!(-1.5707963267948966, double_nan)
  assert_atanh_ulp!(-0.7853981633974483, -1.0593061708232432)
  assert_atanh_ulp!(0, 0)
  assert_atanh_ulp!(0.1, 0.10033534773107558)
  assert_atanh_ulp!(0.2, 0.2027325540540822)
  assert_atanh_ulp!(0.3, 0.30951960420311175)
  assert_atanh_ulp!(0.4, 0.42364893019360184)
  assert_atanh_ulp!(0.5, 0.5493061443340548)
  assert_atanh_ulp!(0.6, 0.6931471805599453)
  assert_atanh_ulp!(0.7, 0.8673005276940531)
  assert_atanh_ulp!(0.8, 1.0986122886681098)
  assert_atanh_ulp!(0.9, 1.4722194895832204)
  assert_atanh_ulp!(1, double_pos_inf)
  assert_atanh_ulp!(3.141592653589793, double_nan)
  assert_atanh_ulp!(1.5707963267948966, double_nan)
  assert_atanh_ulp!(0.7853981633974483, 1.0593061708232432)
  assert_atanh_ulp!(double_nan, double_nan)
  assert_atanh_ulp!(double_pos_inf, double_nan)
  assert_atanh_ulp!(double_neg_inf, double_nan)
}
