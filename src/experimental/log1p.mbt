///|
/// `log1p(x)` computes `log(1+x)`
///
/// # Examples
///
/// ```moonbit nocheck
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

///|
/// `ln_1p` is an alias for `log1p`
pub let ln_1p : (Double) -> Double = log1p
