///|
/// Computes the exponential of `x` minus one.
///
/// # Special cases
///
/// 1. expm1(INF) is INF
/// 2. expm1(NaN) is NaN
/// 3. expm1(-INF) is -1
/// 4. for finite argument, only expm1(0) is exact.
/// 5. if x > 7.09782712893383973096e+02 then expm1(x) overflows
///
/// # Accuracy
///
/// 0 ulp (unit in the last place).
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(expm1(1.0), 1.718281828459045)
/// assert_eq(expm1(0.0), 0.0)
/// assert_eq(expm1(-1.0), -0.6321205588285577)
/// assert_eq(expm1(2.0), 6.38905609893065)
/// ```
pub fn expm1(x : Double) -> Double {
  if x.is_nan() {
    return @double.not_a_number
  }
  let o_threshold = 7.09782712893383973096e+02
  if x > o_threshold {
    return @double.infinity
  }
  if x.is_inf() {
    return -1.0
  }
  let one = 1.0
  let huge = 1.0e+300
  let tiny = 1.0e-300
  let ln2_hi = 6.93147180369123816490e-01
  let ln2_lo = 1.90821492927058770002e-10
  let invln2 = 1.44269504088896338700e+00
  let q1 = -3.33333333333331316428e-02
  let q2 = 1.58730158725481460165e-03
  let q3 = -7.93650757867487942473e-05
  let q4 = 4.00821782732936239552e-06
  let q5 = -2.01099218183624371326e-07
  let mut x = x
  let mut hx = __hi(x)
  let xsb : Int = (hx & 0x80000000).reinterpret_as_int()
  let mut y : Double = if xsb == 0 { x } else { -x }
  hx = hx & 0x7fffffff
  if hx >= 0x4043687A {
    if xsb != 0 {
      if x + tiny < 0.0 {
        return tiny - one
      }
    }
  }
  let mut hi = 0.0
  let mut lo = 0.0
  let mut k = 0
  let mut c = 0.0
  let mut t = 0.0
  if hx > 0x3fd62e42 {
    if hx < 0x3FF0A2B2 {
      hi = if xsb == 0 { x - ln2_hi } else { x + ln2_hi }
      lo = if xsb == 0 { ln2_lo } else { -ln2_lo }
      k = if xsb == 0 { 1 } else { -1 }
    } else {
      k = (invln2 * x + (if xsb == 0 { 0.5 } else { -0.5 })).to_int()
      t = k.to_double()
      hi = x - t * ln2_hi
      lo = t * ln2_lo
    }
    x = hi - lo
    c = hi - x - lo
  } else if hx < 0x3c900000 {
    t = huge + x
    return x - (t - (huge + x))
  } else {
    k = 0
  }
  let hfx : Double = 0.5 * x
  let hxs : Double = x * hfx
  let r1 : Double = one +
    hxs * (q1 + hxs * (q2 + hxs * (q3 + hxs * (q4 + hxs * q5))))
  let t : Double = 3.0 - r1 * hfx
  let e : Double = hxs * ((r1 - t) / (6.0 - x * t))
  if k == 0 {
    return x - (x * e - hxs)
  } else {
    let e : Double = x * (e - c) - c
    let e : Double = e - hxs
    if k == -1 {
      return 0.5 * (x - e) - 0.5
    }
    if k == 1 {
      return if x < -0.25 {
        -2.0 * (e - (x + 0.5))
      } else {
        one + 2.0 * (x - e)
      }
    }
    if k <= -2 || k > 56 {
      y = one - (e - x)
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
      return y - one
    }
    let mut t : Double = one
    if k < 20 {
      t = __combineW((0x3ff00000 - (0x200000 >> k)).reinterpret_as_uint(), 0)
      y = t - (e - x)
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
    } else {
      t = __combineW(((0x3ff - k) << 20).reinterpret_as_uint(), 0)
      y = x - (e + t) + one
      y = __combineW(__hi(y) + (k << 20).reinterpret_as_uint(), __low(y))
    }
  }
  y
}
