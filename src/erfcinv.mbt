///| Calculate the inverse complementary error function of the input argument.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(erfcinv(0.5), 0.4769362895959522)
/// assert_eq!(erfcinv(0.9), 0.08885598888653257)
/// assert_eq!(erfcinv(1), 0)
/// assert_eq!(erfcinv(1.542), -0.5247751634041989)
/// let double_neg_inf = -1.0 / 0.0
/// assert_eq!(erfcinv(2), double_neg_inf)
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
///
/// 1. erfcinv(+-0) = +Inf
/// 2. erfcinv(2) = -inf
/// 3. erfcinv(x) returns NaN for `x` outside [0, 2]
/// 4. erfcinv(NaN) = NaN
pub fn erfcinv(a: Double) -> Double {
  if a <= 0.0 {
    return double_pos_inf
  }

  if a >= 2.0 {
    return double_neg_inf
  }

  let mut t = 2.0 - a;
  let mut p = 0.0
  if a >= 2.1875e-3 && a <= 1.998125 {
    t = t * a
    t = - log2(t)
    p = -2.00998329e-10
    p = fma(p, t, 7.63788321e-09)
    p = fma(p, t, -9.44120231e-08)
    p = fma(p, t, 1.27279494e-08)
    p = fma(p, t, 8.98369126e-06)
    p = fma(p, t, -3.40910883e-05)
    p = fma(p, t, -7.70850747e-04)
    p = fma(p, t, 5.54407062e-03)
    p = fma(p, t, 1.60820886e-01)
    t = fma(p, t, 8.86226892e-01)
    t = fma(t, -a, t)
  } else {
    t = if a > 1 { t } else { a }
    t = log2(t)
    t = rsqrt(-t)
    p = 1.16093750e+2
    p = fma(p, t, -2.26577423e+2)
    p = fma(p, t, 1.96353668e+2)
    p = fma(p, t, -1.00602257e+2)
    p = fma(p, t, 3.46447067e+1)
    p = fma(p, t, -9.10134983e+0)
    p = fma(p, t, 2.65257812e+0)
    p = fma(p, t, 4.29913402e-2)
    p = fma(p, t, -4.46814462e-4)
    p = fma(1.201122409, t, p * t)
    if a > 1 { p = -p }
    t = 1.0 / p
  }
  return t
}

const ERFCINV_MAX_ULP: Int = 505787246

test "erfcinv" {
  fn assert_erfcinv_ulp!(input, expect) {
    assert_ulp!(expect, erfcinv(input), ERFCINV_MAX_ULP);
  }
  assert_erfcinv_ulp!(-0.8, double_pos_inf)
  assert_erfcinv_ulp!(-0.2, double_pos_inf)
  assert_erfcinv_ulp!(-0.1, double_pos_inf)
  assert_erfcinv_ulp!(-0, double_pos_inf)
  assert_erfcinv_ulp!(-3.141592653589793, double_pos_inf)
  assert_erfcinv_ulp!(-1.5707963267948966, double_pos_inf)
  assert_erfcinv_ulp!(-0.7853981633974483, double_pos_inf)
  assert_erfcinv_ulp!(0, double_pos_inf)
  assert_erfcinv_ulp!(0.1, 1.1630871536766738)
  assert_erfcinv_ulp!(0.2, 0.9061938024368232)
  assert_erfcinv_ulp!(0.3, 0.7328690779592169)
  assert_erfcinv_ulp!(0.4, 0.5951160814499948)
  assert_erfcinv_ulp!(0.5, 0.4769362762044699)
  assert_erfcinv_ulp!(0.6, 0.37080715859355795)
  assert_erfcinv_ulp!(0.7, 0.27246271472675443)
  assert_erfcinv_ulp!(0.8, 0.17914345462129164)
  assert_erfcinv_ulp!(0.9, 0.08885599049425767)
  assert_erfcinv_ulp!(1, 0)
  assert_erfcinv_ulp!(3.141592653589793, double_neg_inf)
  assert_erfcinv_ulp!(1.5707963267948966, -0.5590068522631568)
  assert_erfcinv_ulp!(0.7853981633974483, 0.19253891596997583)
  assert_erfcinv_ulp!(-1, double_pos_inf)
  assert_erfcinv_ulp!(-2, double_pos_inf)
  assert_erfcinv_ulp!(1, 0)
  assert_erfcinv_ulp!(2, double_neg_inf)
  assert_erfcinv_ulp!(3, double_neg_inf)
  assert_erfcinv_ulp!(4, double_neg_inf)
  assert_erfcinv_ulp!(1.542, -0.52477516419095)
  assert_erfcinv_ulp!(2.846, double_neg_inf)
  assert_erfcinv_ulp!(3.772, double_neg_inf)
  assert_erfcinv_ulp!(-1.542, double_pos_inf)
  assert_erfcinv_ulp!(-2.846, double_pos_inf)
  assert_erfcinv_ulp!(-1, double_pos_inf)
  assert_erfcinv_ulp!(0, double_pos_inf)
  assert_erfcinv_ulp!(-0, double_pos_inf)
  assert_erfcinv_ulp!(double_nan, double_nan)
  assert_erfcinv_ulp!(double_pos_inf, double_neg_inf)
  assert_erfcinv_ulp!(double_neg_inf, double_pos_inf)
}
