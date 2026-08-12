///|
/// `log1p(x)` computes `log(1+x)`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(log1pf(0.1), 0.09531017980432487)
/// assert_eq(log1pf(1), 0.6931471805599453)
/// assert_eq(log1pf(-0.5), -0.6931471805599453)
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
pub fn log1pf(x : Float) -> Float {
  let mut ui : UInt = x.reinterpret_as_uint()
  let mut f : Float = 0
  let mut c : Float = 0
  let mut iu : UInt = 0
  let one : Float = 1.0
  let mut k = 1
  if ui < 0x3ed413d0 || ui >> 31 > 0 {
    if ui >= 0xbf800000 {
      if x == -1.0 {
        return x / 0.0
      }
      return (x - x) / 0.0
    }
    if ui << 1 < 0x33800000U << 1 {
      return x
    }
    if ui <= 0xbe95f619 {
      k = 0
      c = 0.0
      f = x
    }
  } else if ui >= 0x7f800000 {
    return x
  }
  if k > 0 {
    ui = (one + x).reinterpret_as_uint()
    iu = ui
    iu += 0x3f800000U - 0x3f3504f3U
    k = (iu >> 23).reinterpret_as_int() - 0x7f
    if k < 25 {
      let fui = Float::reinterpret_from_uint(ui)
      c = if k >= 2 { one - (fui - x) } else { x - (fui - 1.0) }
      c /= Float::reinterpret_from_uint(ui)
    } else {
      c = 0.0
    }
    iu = (iu & 0x007fffff) + 0x3f3504f3
    ui = iu
    f = Float::reinterpret_from_uint(ui) - 1.0
  }
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = Float::from_int(k)
  s * (hfsq + r) + (dk * FLOAT_LN2_LO + c) - hfsq + f + dk * FLOAT_LN2_HI
}

///|
/// `ln_1pf` is an alias for `log1pf`
pub let ln_1pf : (Float) -> Float = log1pf
