///| `log1p(x)` computes `log(1+x)`
///
/// # Examples
///
/// ```moonbit
/// assert_eq(log1p(0.1), 0.09531017980432487)
/// assert_eq(log1p(1), 0.6931471805599453)
/// assert_eq(log1p(-0.5), -0.6931471805599453)
/// ```
/// # Special Cases
///
/// 1. log1p(INF) is INF, log1p(NaN) is NaN;
/// 2. log1p(-1) is -INF with signal;
/// 3. log1p(NaN) is that NaN with no signal.
///
/// # Accuracy:
///
/// 0 ulp (unit in the last place).
pub fn log1p(x : Double) -> Double {
  if x < -1.0 || x.is_nan() {
    return @double.not_a_number
  }
  if x == -1.0 {
    return @double.neg_infinity
  }
  if x.is_inf() {
    return @double.infinity
  }
  let ln2_hi = 6.93147180369123816490e-01
  let ln2_lo = 1.90821492927058770002e-10
  let two54 = 1.80143985094819840000e+16
  let lp1 = 6.666666666666735130e-01
  let lp2 = 3.999999999940941908e-01
  let lp3 = 2.857142874366239149e-01
  let lp4 = 2.222219843214978396e-01
  let lp5 = 1.818357216161805012e-01
  let lp6 = 1.531383769920937332e-01
  let zero = 0.0
  let lp7 = 1.479819860511658591e-01
  let hx = __hi(x).reinterpret_as_int()
  let ax = hx & 0x7fffffff
  let mut f = 0.0
  let mut c = 0.0
  let mut s = 0.0
  let mut z = 0.0
  let mut r = 0.0
  let mut u = 0.0
  let mut hu = 0
  let mut k = 1
  if hx < 0x3FDA827A {
    if ax < 0x3e200000 {
      if two54 + x > zero && ax < 0x3c900000 {
        return x
      } else {
        return x - x * x * 0.5
      }
    }
    if hx > 0 || hx <= 0xbfd2bec3 {
      k = 0
      f = x
      hu = 1
    }
  }
  if k != 0 {
    if hx < 0x43400000 {
      u = 1.0 + x
      hu = __hi(u).reinterpret_as_int()
      k = (hu >> 20) - 1023
      c = if k > 0 { 1.0 - (u - x) } else { x - (u - 1.0) }
      c /= u
    } else {
      u = x
      hu = __hi(u).reinterpret_as_int()
      k = (hu >> 20) - 1023
      c = 0.0
    }
    hu = hu & 0x000fffff
    if hu < 0x6a09e {
      u = __combineW(hu.reinterpret_as_uint() | 0x3ff00000, __low(u))
    } else {
      k += 1
      u = __combineW(hu.reinterpret_as_uint() | 0x3fe00000, __low(u))
      hu = (0x00100000 - hu) >> 2
    }
    f = u - 1.0
  }
  let hfsq = 0.5 * f * f
  if hu == 0 {
    if f == zero {
      if k == 0 {
        return zero
      } else {
        c += k.to_double() * ln2_lo
        return k.to_double() * ln2_hi + c
      }
    }
    r = hfsq * (1.0 - 0.66666666666666666 * f)
    if k == 0 {
      return f - r
    } else {
      return k.to_double() * ln2_hi - (r - (k.to_double() * ln2_lo + c) - f)
    }
  }
  s = f / (2.0 + f)
  z = s * s
  r = z *
    (lp1 + z * (lp2 + z * (lp3 + z * (lp4 + z * (lp5 + z * (lp6 + z * lp7))))))
  if k == 0 {
    return f - (hfsq - s * (hfsq + r))
  } else {
    return k.to_double() * ln2_hi -
      (hfsq - (s * (hfsq + r) + (k.to_double() * ln2_lo + c)) - f)
  }
}

///| `ln_1p` is an alias for `log1p`
pub let ln_1p : (Double) -> Double = log1p

///|
test "log10" {
  fn assert_log1p_ulp(input, expect_result) raise {
    assert_ulp(expect_result, log1p(input), LOG1P_MAX_ULP)
  }

  assert_log1p_ulp(-0.8, -1.6094379124341005)
  assert_log1p_ulp(-0.7, -1.203972804325936)
  assert_log1p_ulp(-0.6, -0.916290731874155)
  assert_log1p_ulp(-0.5, -0.6931471805599453)
  assert_log1p_ulp(-0.4, -0.5108256237659907)
  assert_log1p_ulp(-0.3, -0.35667494393873234)
  assert_log1p_ulp(-0.2, -0.22314355131420976)
  assert_log1p_ulp(-0.1, -0.10536051565782631)
  assert_log1p_ulp(0.1, 0.09531017980432487)
  assert_log1p_ulp(0.2, 0.18232155679395462)
  assert_log1p_ulp(0.3, 0.26236426446749106)
  assert_log1p_ulp(0.4, 0.33647223662121295)
  assert_log1p_ulp(0.5, 0.4054651081081644)
  assert_log1p_ulp(0.6, 0.4700036292457356)
  assert_log1p_ulp(0.7, 0.5306282510621704)
  assert_log1p_ulp(0.8, 0.5877866649021191)
  assert_log1p_ulp(0.9, 0.6418538861723948)
  assert_log1p_ulp(1, 0.6931471805599453)
  assert_log1p_ulp(2, 1.0986122886681096)
  assert_log1p_ulp(3, 1.3862943611198906)
  assert_log1p_ulp(4, 1.6094379124341003)
  assert_log1p_ulp(5, 1.791759469228055)
  assert_log1p_ulp(6, 1.9459101490553132)
  assert_log1p_ulp(7, 2.0794415416798357)
  assert_log1p_ulp(8, 2.1972245773362196)
  assert_log1p_ulp(9, 2.302585092994046)
  assert_log1p_ulp(10, 2.3978952727983707)
  assert_log1p_ulp(100, 4.61512051684126)
  assert_log1p_ulp(1000, 6.90875477931522)
  assert_log1p_ulp(10000, 9.210440366976517)
  assert_log1p_ulp(2.5, 1.252762968495368)
  assert_log1p_ulp(3.4, 1.4816045409242156)
  assert_log1p_ulp(5.3, 1.840549633397487)
  assert_log1p_ulp(6.2, 1.9740810260220096)
  assert_log1p_ulp(7.1, 2.0918640616783932)
  assert_log1p_ulp(8.9, 2.2925347571405443)
  assert_log1p_ulp(9.8, 2.379546134130174)
  assert_log1p_ulp(10.7, 2.4595888418037104)
  assert_log1p_ulp(101.6, 4.630837932736669)
  assert_log1p_ulp(1.542, 0.9329511727672624)
  assert_log1p_ulp(2.846, 1.347033647166588)
  assert_log1p_ulp(7.881, 2.1839141632763672)
  assert_log1p_ulp(3.772, 1.5627655042356696)
  assert_log1p_ulp(-1.0, @double.neg_infinity)
  assert_log1p_ulp(0, 0)
  assert_log1p_ulp(-0, -0)
  assert_log1p_ulp(@double.not_a_number, @double.not_a_number)
}
