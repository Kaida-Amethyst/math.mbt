
///|
pub fn sinf_cody_waite(x: Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }

  if x == 0.0 {
    return x
  }

  let (x, q) = trig_reduce(x, SIN_SWITCHOVER);
  sin_cos_core_cody_waite(x, q)
}

