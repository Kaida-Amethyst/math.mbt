///| Compute arctangent of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(atanf(0), 0)
/// assert_eq!(atanf(1), 0.7853981633974483)
/// assert_eq!(atanf(2), 1.1071487177940904)
/// assert_eq!(atanf(-1),-0.7853981633974483)
/// assert_eq!(atanf(-2),-1.1071487177940904)
/// assert_eq!(atanf(@float.infinity), 1.570796251296997)
/// assert_eq!(atanf(@float.neg_infinity), -1.570796251296997)
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
/// 
/// 1. atanf(NaN) = NaN
/// 2. atanf(+Inf) = +π/2
/// 3. atanf(-Inf) = -π/2
pub fn atanf(x : Float) -> Float {
  let atanhi : Array[Float] = [
    4.6364760399e-01, 7.8539812565e-01, 9.8279368877e-01, 1.5707962513e+00,
  ]
  let atanlo : Array[Float] = [
    5.0121582440e-09, 3.7748947079e-08, 3.4473217170e-08, 7.5497894159e-08,
  ]
  let a_t : Array[Float] = [
    3.3333328366e-01, -1.9999158382e-01, 1.4253635705e-01, -1.0648017377e-01, 6.1687607318e-02,
  ]
  let ix = x.reinterpret_as_int()
  let sign = ix >> 31
  let ix = ix & 0x7fffffff
  let mut id = 0
  let mut x = x
  let one : Float = 1.0
  let two : Float = 2.0
  if ix >= 0x4c800000 {
    if x.is_nan() {
      return x
    }
    let z = atanhi[3] + 0x1.0p-120
    let z = if sign != 0 { -z } else { z }
    return z
  }
  if ix < 0x3ee00000 {
    if ix < 0x39800000 {
      return x
    }
    id = -1
  } else {
    x = x.abs()
    if ix < 0x3f980000 {
      if ix < 0x3f300000 {
        id = 0
        x = (two * x - one) / (two + x)
      } else {
        id = 1
        x = (x - one) / (x + one)
      }
    } else if ix < 0x401c0000 {
      id = 2
      x = (x - 1.5) / (one + x * 1.5)
    } else {
      id = 3
      x = -one / x
    }
  }
  let z = x * x
  let w = z * z
  let s1 = z * (a_t[0] + w * (a_t[2] + w * a_t[4]))
  let s2 = w * (a_t[1] + w * a_t[3])
  if id < 0 {
    return x - x * (s1 + s2)
  }
  let z = atanhi[id] - (x * (s1 + s2) - atanlo[id] - x)
  if sign != 0 {
    -z
  } else {
    z
  }
}

///|
test "atanf" {
  fn assert_atanf_ulp(input, expect) raise {
    assert_float_ulp(expect, atanf(input), ATAN_F_MAX_ULP)
  }

  assert_atanf_ulp(-1, -0.7853981852531433)
  assert_atanf_ulp(1, 0.7853981852531433)
  assert_atanf_ulp(8, 1.4464412927627563)
  assert_atanf_ulp(-8, -1.4464412927627563)
  assert_atanf_ulp(0, 0)
  assert_atanf_ulp(27, 1.5337761640548706)
  assert_atanf_ulp(-27, -1.5337761640548706)
  assert_atanf_ulp(0.125, 0.12435499578714371)
  assert_atanf_ulp(-0.125, -0.12435499578714371)
  assert_atanf_ulp(0.5, 0.46364760398864746)
  assert_atanf_ulp(-0.5, -0.46364760398864746)
  assert_atanf_ulp(1.5, 0.9827937483787537)
  assert_atanf_ulp(-1.5, -0.9827937483787537)
  assert_atanf_ulp(2, 1.1071487665176392)
  assert_atanf_ulp(-2, -1.1071487665176392)
  assert_atanf_ulp(3, 1.249045729637146)
  assert_atanf_ulp(-3, -1.249045729637146)
  assert_atanf_ulp(64, 1.5551725625991821)
  assert_atanf_ulp(-64, -1.5551725625991821)
  assert_atanf_ulp(1000, 1.5697963237762451)
  assert_atanf_ulp(-1000, -1.5697963237762451)
  assert_atanf_ulp(512, 1.5688432455062866)
  assert_atanf_ulp(729, 1.5694246292114258)
  assert_atanf_ulp(3511808, 1.570796012878418)
  assert_atanf_ulp(15.25, 1.5053162574768066)
  assert_atanf_ulp(6859, 1.570650577545166)
  assert_atanf_ulp(68.25, 1.5561453104019165)
  assert_atanf_ulp(701.625, 1.5693711042404175)
  assert_atanf_ulp(@float.not_a_number, @float.not_a_number)
  assert_atanf_ulp(@float.infinity, 1.570796251296997)
  assert_atanf_ulp(@float.neg_infinity, -1.570796251296997)
}
