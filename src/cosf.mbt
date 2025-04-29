///|
pub fn cosf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return 1.0
  }
  let (x, q) = trig_reduce(x, COS_SWITCHOVER)
  sin_cos_core(x, q + 1)
}
