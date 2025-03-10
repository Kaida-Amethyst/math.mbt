///| Compute the principal value of the arc cosine of `x`.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(acos(-0.5), 2.0943951023931957)
/// assert_eq!(acos(0.5), 1.0471975511965979)
/// assert_eq!(acos(1), 0)
/// assert_eq!(acos(0), 1.5707963267948966)
/// assert_eq!(acos(-1), 3.141592653589793)
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
pub fn acos(x : Double) -> Double {
  let one : Double = 1.0
  let pi : Double = 3.14159265358979311600
  let pio2_hi : Double = 1.57079632679489655800
  let pio2_lo : Double = 6.12323399573676603587e-17
  let ps0 : Double = 1.66666666666666657415e-01
  let ps1 : Double = -3.25565818622400915405e-01
  let ps2 : Double = 2.01212532134862925881e-01
  let ps3 : Double = -4.00555345006794114027e-02
  let ps4 : Double = 7.91534994289814532176e-04
  let ps5 : Double = 3.47933107596021167570e-05
  let qs1 : Double = -2.40339491173441421878e+00
  let qs2 : Double = 2.02094576023350569471e+00
  let qs3 : Double = -6.88283971605453293030e-01
  let qs4 : Double = 7.70381505559019352791e-02
  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff
  let absx = x.abs()
  if absx >= 1.0 {
    if absx == 1.0 {
      if x > 0 {
        return 0.0
      } else {
        return pi + 2.0 * pio2_lo
      }
    }
    return @double.not_a_number
  }
  if absx < 0.5 {
    if ix <= 0x3c600000 {
      return pio2_hi + pio2_lo
    }
    let z = x * x
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let r = p / q
    pio2_hi - (x - (pio2_lo - x * r))
  } else if x < 0 {
    let z = (one + x) * 0.5
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let s = z.sqrt()
    let r = p / q
    let w = r * s - pio2_lo
    pi - 2.0 * (s + w)
  } else {
    let z = (one - x) * 0.5
    let s = z.sqrt()
    let df = s
    let c = (z - df * df) / (s + df)
    let p = z * (ps0 + z * (ps1 + z * (ps2 + z * (ps3 + z * (ps4 + z * ps5)))))
    let q = one + z * (qs1 + z * (qs2 + z * (qs3 + z * qs4)))
    let r = p / q
    let w = r * s + c
    2.0 * (df + w)
  }
}

///|
pub impl Floating for Double with acos(self) -> Double {
  acos(self)
}

///|
test "acos" {
  fn assert_acos_ulp!(input, expect) {
    assert_ulp!(expect, acos(input), ACOS_MAX_ULP)
  }

  assert_acos_ulp!(0, 1.5707963267948966)
  assert_acos_ulp!(1, 0)
  assert_acos_ulp!(2, @double.not_a_number)
  assert_acos_ulp!(-1, 3.141592653589793)
  assert_acos_ulp!(-2, @double.not_a_number)
  assert_acos_ulp!(0.12, 1.4505064444001086)
  assert_acos_ulp!(0.23, 1.3387186439321834)
  assert_acos_ulp!(0.34, 1.2238794292677349)
  assert_acos_ulp!(0.45, 1.1040309877476002)
  assert_acos_ulp!(0.56, 0.9764105267938343)
  assert_acos_ulp!(0.67, 0.8365875393415376)
  assert_acos_ulp!(0.78, 0.6761305095606613)
  assert_acos_ulp!(0.89, 0.47345115727206616)
  assert_acos_ulp!(0.9, 0.45102681179626236)
  assert_acos_ulp!(-0.87, 2.6259986473437027)
  assert_acos_ulp!(-0.76, 2.4341094418104503)
  assert_acos_ulp!(-0.65, 2.278380763520252)
  assert_acos_ulp!(-0.54, 2.1412334361948187)
  assert_acos_ulp!(-0.43, 2.0152891037307157)
  assert_acos_ulp!(-0.32, 1.8965258140895267)
  assert_acos_ulp!(-0.21, 1.7823712865529922)
  assert_acos_ulp!(-0.1, 1.6709637479564563)
  assert_acos_ulp!(0.12345, 1.447030595701842)
  assert_acos_ulp!(0.23456, 1.3340304110004462)
  assert_acos_ulp!(0.34567, 1.2178436209004186)
  assert_acos_ulp!(0.45678, 1.0964241932520653)
  assert_acos_ulp!(0.56789, 0.966856210975062)
  assert_acos_ulp!(0.6789, 0.8245328984417092)
  assert_acos_ulp!(0.78901, 0.661600380485764)
  assert_acos_ulp!(0.89012, 0.4731879089572146)
  assert_acos_ulp!(0.90123, 0.4481967258405143)
  assert_acos_ulp!(-0.98765, 2.9842681197855034)
  assert_acos_ulp!(-0.87654, 2.639422356361353)
  assert_acos_ulp!(-0.76543, 2.442505592710677)
  assert_acos_ulp!(-0.65432, 2.2840793852039942)
  assert_acos_ulp!(-0.54321, 2.145051991929172)
  assert_acos_ulp!(-0.4321, 2.017616417853647)
  assert_acos_ulp!(-0.32109, 1.8976765338688588)
  assert_acos_ulp!(-0.21098, 1.7833737456834884)
  assert_acos_ulp!(-0.10987, 1.6808885840186583)
  assert_acos_ulp!(0.5772157, 0.9554814214475389)
  assert_acos_ulp!(0.3010299, 1.2650238606722306)
  assert_acos_ulp!(0.6931472, 0.8049501050055602)
  assert_acos_ulp!(0.4342945, 1.1215414160225383)
  assert_acos_ulp!(0.0000001, 1.5707962267948965)
  assert_acos_ulp!(@double.max_value, @double.not_a_number)
  assert_acos_ulp!(@double.min_value, @double.not_a_number)
  assert_acos_ulp!(@double.infinity, @double.not_a_number)
  assert_acos_ulp!(@double.neg_infinity, @double.not_a_number)
  assert_acos_ulp!(@double.not_a_number, @double.not_a_number)
}
