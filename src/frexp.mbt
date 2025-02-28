///|
fn normalize(f : Double) -> (Double, Int) {
  if f.abs() < DOUBLE_MIN_POSITIVE {
    return (f * (1L << 52).to_double(), -52)
  }
  (f, 0)
}

///| Extract mantissa and exponent of a floating-point value.
pub fn frexp(f : Double) -> (Double, Int) {
  if f == 0.0 || f.is_inf() || f.is_nan() {
    return (f, 0)
  }
  let (norm_f, exp) = normalize(f)
  let u = norm_f.reinterpret_as_uint64()
  let exp = exp + ((u >> 52) & 0x7FF).to_int() - 1022
  let frac = ((u & (0x7FFUL << 52).lnot()) | (1022UL << 52)).reinterpret_as_double()
  return (frac, exp)
}
