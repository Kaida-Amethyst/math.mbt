///|
pub fn sinhf(x : Float) -> Float {
  let mut h : Float = 0.5
  let mut ix = x.reinterpret_as_uint()
  if (ix >> 31) != 0 {
    h = -h
  }
  // |x|
  ix = ix & 0x7fffffff
  let absx = ix.reinterpret_as_float()
  let w = ix

  // |x| < log(FLT_MAX)
  if w < 0x42b17217 {
    let t = expm1f(absx)
    if w < 0x3f800000 {
      if w < 0x3f800000U - (12U << 23) {
        return x
      }
      return h * ((2.0 : Float) * t - t * t / (t + 1.0))
    }
    return h * (t + t / (t + 1.0))
  }

  // |x| > logf(FLT_MAX) or nan
  h * k_expo2f(absx) * 2.0
}
