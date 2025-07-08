///| `log1p(x)` computes `log(1+x)`
///
/// # Examples
///
/// ```moonbit
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
      let fui = ui.reinterpret_as_float()
      c = if k >= 2 { one - (fui - x) } else { x - (fui - 1.0) }
      c /= ui.reinterpret_as_float()
    } else {
      c = 0.0
    }
    iu = (iu & 0x007fffff) + 0x3f3504f3
    ui = iu
    f = ui.reinterpret_as_float() - 1.0
  }
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = k.to_float()
  s * (hfsq + r) + (dk * FLOAT_LN2_LO + c) - hfsq + f + dk * FLOAT_LN2_HI
}

///| `ln_1pf` is an alias for `log1pf`
pub let ln_1pf : (Float) -> Float = log1pf

///|
test "log1pf" {
  fn assert_log1pf_ulp(input, expect) raise {
    assert_float_ulp(expect, log1pf(input), LOG1P_F_MAX_ULP)
  }

  assert_log1pf_ulp(-1, @float.neg_infinity)
  assert_log1pf_ulp(1, 0.6931471824645996)
  assert_log1pf_ulp(8, 2.1972246170043945)
  assert_log1pf_ulp(-8, @float.not_a_number)
  assert_log1pf_ulp(0, 0)
  assert_log1pf_ulp(27, 3.332204580307007)
  assert_log1pf_ulp(-27, @float.not_a_number)
  assert_log1pf_ulp(0.125, 0.11778303235769272)
  assert_log1pf_ulp(-0.125, -0.133531391620636)
  assert_log1pf_ulp(0.5, 0.40546509623527527)
  assert_log1pf_ulp(-0.5, -0.6931471824645996)
  assert_log1pf_ulp(1.5, 0.9162907600402832)
  assert_log1pf_ulp(-1.5, @float.not_a_number)
  assert_log1pf_ulp(2, 1.0986123085021973)
  assert_log1pf_ulp(-2, @float.not_a_number)
  assert_log1pf_ulp(3, 1.3862943649291992)
  assert_log1pf_ulp(-3, @float.not_a_number)
  assert_log1pf_ulp(64, 4.174387454986572)
  assert_log1pf_ulp(-64, @float.not_a_number)
  assert_log1pf_ulp(1000, 6.908754825592041)
  assert_log1pf_ulp(-1000, @float.not_a_number)
  assert_log1pf_ulp(512, 6.240275859832764)
  assert_log1pf_ulp(729, 6.593044281005859)
  assert_log1pf_ulp(3511808, 15.07164192199707)
  assert_log1pf_ulp(15.25, 2.788092851638794)
  assert_log1pf_ulp(6859, 8.833462715148926)
  assert_log1pf_ulp(68.25, 4.237723350524902)
  assert_log1pf_ulp(701.625, 6.554823398590088)
  assert_log1pf_ulp(@float.not_a_number, @float.not_a_number)
  assert_log1pf_ulp(@float.infinity, @float.infinity)
  assert_log1pf_ulp(@float.neg_infinity, @float.not_a_number)
}
