///|
const LG1_F : Float = 0.66666662693

///|
const LG2_F : Float = 0.40000972152

///|
const LG3_F : Float = 0.28498786688

///|
const LG4_F : Float = 0.24279078841

///|
pub fn logf(x : Float) -> Float {
  let mut x = x
  let x1p25 = (0x4c000000).reinterpret_as_float()
  let mut ix = x.reinterpret_as_int()
  let mut k = 0
  if ix < 0x00800000 || (ix >> 31) != 0 {
    if (ix << 1) == 0 {
      return (-1.0 : Float) / (x * x)
    }
    if (ix >> 31) != 0 {
      return (x - x) / 0.0
    }
    k -= 25
    x *= x1p25
    ix = x.reinterpret_as_int()
  } else if ix >= 0x7f800000 {
    return x
  } else if ix == 0x3f800000 {
    return 0.0
  }
  ix += 0x3f800000 - 0x3f3504f3
  k += (ix >> 23) - 0x7f
  ix = (ix & 0x007fffff) + 0x3f3504f3
  x = ix.reinterpret_as_float()
  let f = x - 1.0
  let s = f / ((2.0 : Float) + f)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = k.to_float()
  s * (hfsq + r) + dk * FLOAT_LN2_LO - hfsq + f + dk * FLOAT_LN2_HI
}

///|
test "logf" {
  fn assert_logf_ulp!(input, expect) {
    assert_float_ulp!(expect, logf(input), LOG_F_MAX_ULP)
  }

  assert_logf_ulp!(-1, @float.not_a_number)
  assert_logf_ulp!(1, 0)
  assert_logf_ulp!(8, 2.079441547393799)
  assert_logf_ulp!(-8, @float.not_a_number)
  assert_logf_ulp!(0, @float.neg_infinity)
  assert_logf_ulp!(27, 3.295836925506592)
  assert_logf_ulp!(-27, @float.not_a_number)
  assert_logf_ulp!(0.125, -2.079441547393799)
  assert_logf_ulp!(-0.125, @float.not_a_number)
  assert_logf_ulp!(0.5, -0.6931471824645996)
  assert_logf_ulp!(-0.5, @float.not_a_number)
  assert_logf_ulp!(1.5, 0.40546509623527527)
  assert_logf_ulp!(-1.5, @float.not_a_number)
  assert_logf_ulp!(2, 0.6931471824645996)
  assert_logf_ulp!(-2, @float.not_a_number)
  assert_logf_ulp!(3, 1.0986123085021973)
  assert_logf_ulp!(-3, @float.not_a_number)
  assert_logf_ulp!(64, 4.158883094787598)
  assert_logf_ulp!(-64, @float.not_a_number)
  assert_logf_ulp!(1000, 6.907755374908447)
  assert_logf_ulp!(-1000, @float.not_a_number)
  assert_logf_ulp!(512, 6.2383246421813965)
  assert_logf_ulp!(729, 6.591673851013184)
  assert_logf_ulp!(3511808, 15.07164192199707)
  assert_logf_ulp!(15.25, 2.7245795726776123)
  assert_logf_ulp!(6859, 8.833316802978516)
  assert_logf_ulp!(68.25, 4.223177433013916)
  assert_logf_ulp!(701.625, 6.553399085998535)
  assert_logf_ulp!(@float.not_a_number, @float.not_a_number)
  assert_logf_ulp!(@float.infinity, @float.infinity)
  assert_logf_ulp!(@float.neg_infinity, @float.not_a_number)
}
