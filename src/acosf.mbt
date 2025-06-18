///| Compute the principal value of the arc cosine of `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(acosf(-0.5), 2.0943951023931957)
/// assert_eq!(acosf(0.5), 1.0471975511965979)
/// assert_eq!(acosf(1), 0)
/// assert_eq!(acosf(0), 1.570796251296997)
/// assert_eq!(acosf(-1), 3.141592502593994)
/// ```
///
/// # Accruacy
///
/// 1 ulp (unit in the last place).
///
/// # Special cases
///
/// 1. If `x` is NaN, a NaN is returned.
/// 2. If |x| > 1, a NaN is returned with the invalid signal raised.
pub fn acosf(x : Float) -> Float {
  let pio2_hi : Float = 1.5707962513
  let pio2_lo : Float = 7.5497894159e-08
  let ps0 : Float = 1.6666586697e-01
  let ps1 : Float = -4.2743422091e-02
  let ps2 : Float = -8.6563630030e-03
  let qs1 : Float = -7.0662963390e-01
  let one : Float = 1.0
  let two : Float = 2.0
  fn r(z : Float) -> Float {
    let p = z * (ps0 + z * (ps1 + z * ps2))
    let q = z * qs1 + 1.0
    p / q
  }

  let hx = x.reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix >= 0x3f800000 {
    if ix == 0x3f800000 {
      if hx >> 31 != 0 {
        return two * pio2_hi + 0x1.0p-120
      }
      return 0.0
    }
    return @float.not_a_number
  }
  if ix < 0x3f000000 {
    if ix <= 0x32800000 {
      return pio2_hi + 0x1.0p-120
    }
    return pio2_hi - (x - (pio2_lo - x * r(x * x)))
  }
  if hx >> 31 != 0 {
    let z = (x + 1.0) * 0.5
    let s = z.sqrt()
    let w = r(z) * s - pio2_lo
    return two * (pio2_hi - (s + w))
  }
  let z = (one - x) * 0.5
  let s = z.sqrt()
  let df = s
  let c = (z - df * df) / (s + df)
  let w = r(z) * s + c
  two * (df + w)
}

///|
test "acosf" {
  fn assert_acosf_ulp(input, expect) raise {
    assert_float_ulp(expect, acosf(input), ACOS_F_MAX_ULP)
  }

  assert_acosf_ulp(-1, 3.141592502593994)
  assert_acosf_ulp(1, 0)
  assert_acosf_ulp(0.5, 1.0471975803375244)
  assert_acosf_ulp(-0.5, 2.094395160675049)
  assert_acosf_ulp(0.25, 1.3181160688400269)
  assert_acosf_ulp(-0.25, 1.8234765529632568)
  assert_acosf_ulp(-0.125, 1.6961241960525513)
  assert_acosf_ulp(0.125, 1.445468544960022)
  assert_acosf_ulp(0.0625, 1.5082556009292603)
  assert_acosf_ulp(-0.0625, 1.633337140083313)
  assert_acosf_ulp(0.625, 0.8956647515296936)
  assert_acosf_ulp(-0.625, 2.2459278106689453)
  assert_acosf_ulp(0.75, 0.722734272480011)
  assert_acosf_ulp(-0.75, 2.418858528137207)
  assert_acosf_ulp(0.875, 0.50536048412323)
  assert_acosf_ulp(-0.875, 2.6362321376800537)
  assert_acosf_ulp(0.9375, 0.3554212152957916)
  assert_acosf_ulp(-0.9375, 2.7861714363098145)
  assert_acosf_ulp(0.03125, 1.539541244506836)
  assert_acosf_ulp(-0.03125, 1.6020513772964478)
  assert_acosf_ulp(0.015625, 1.5551706552505493)
  assert_acosf_ulp(-0.015625, 1.5864219665527344)
  assert_acosf_ulp(0.0078125, 1.562983751296997)
  assert_acosf_ulp(-0.0078125, 1.5786088705062866)
  assert_acosf_ulp(10, @float.not_a_number)
  assert_acosf_ulp(-10, @float.not_a_number)
  assert_acosf_ulp(@float.not_a_number, @float.not_a_number)
  assert_acosf_ulp(@float.infinity, @float.not_a_number)
  assert_acosf_ulp(@float.neg_infinity, @float.not_a_number)
}
