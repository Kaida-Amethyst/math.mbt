///| Computes the exponential of `x` minus one.
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
/// ```moonbit
/// assert_eq!(expm1(1.0), 1.718281828459045)
/// assert_eq!(expm1(0.0), 0.0)
/// assert_eq!(expm1(-1.0), -0.6321205588285577)
/// assert_eq!(expm1(2.0), 6.38905609893065)
/// ```
pub fn expm1(x : Double) -> Double {
  if x.is_nan() {
    return @double.not_a_number
  }
  let o_threshold = 7.09782712893383973096e+02
  if x > o_threshold {
    return double_pos_inf
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

test "expm1" {
  fn assert_expm1_ulp!(input, expect) {
    assert_ulp!(expect, expm1(input), EXPM1_MAX_ULP)
  }

  assert_expm1_ulp!(-0.8, -0.5506710358827784)
  assert_expm1_ulp!(-0.7, -0.5034146962085905)
  assert_expm1_ulp!(-0.6, -0.45118836390597356)
  assert_expm1_ulp!(-0.5, -0.3934693402873666)
  assert_expm1_ulp!(-0.4, -0.32967995396436073)
  assert_expm1_ulp!(-0.3, -0.2591817793182821)
  assert_expm1_ulp!(-0.2, -0.18126924692201815)
  assert_expm1_ulp!(-0.1, -0.09516258196404043)
  assert_expm1_ulp!(-0, -0)
  assert_expm1_ulp!(-3.141592653589793, -0.9567860817362277)
  assert_expm1_ulp!(-1.5707963267948966, -0.7921204236492381)
  assert_expm1_ulp!(-0.7853981633974483, -0.5440618722340037)
  assert_expm1_ulp!(0, 0)
  assert_expm1_ulp!(0.1, 0.10517091807564763)
  assert_expm1_ulp!(0.2, 0.22140275816016985)
  assert_expm1_ulp!(0.3, 0.3498588075760031)
  assert_expm1_ulp!(0.4, 0.49182469764127035)
  assert_expm1_ulp!(0.5, 0.6487212707001282)
  assert_expm1_ulp!(0.6, 0.8221188003905089)
  assert_expm1_ulp!(0.7, 1.0137527074704764)
  assert_expm1_ulp!(0.8, 1.2255409284924677)
  assert_expm1_ulp!(0.9, 1.4596031111569499)
  assert_expm1_ulp!(1, 1.718281828459045)
  assert_expm1_ulp!(3.141592653589793, 22.140692632779267)
  assert_expm1_ulp!(1.5707963267948966, 3.8104773809653514)
  assert_expm1_ulp!(0.7853981633974483, 1.1932800507380155)
  assert_expm1_ulp!(-1, -0.6321205588285577)
  assert_expm1_ulp!(-2, -0.8646647167633873)
  assert_expm1_ulp!(-3, -0.950212931632136)
  assert_expm1_ulp!(-4, -0.9816843611112658)
  assert_expm1_ulp!(-5, -0.9932620530009145)
  assert_expm1_ulp!(-6, -0.9975212478233336)
  assert_expm1_ulp!(-7, -0.9990881180344455)
  assert_expm1_ulp!(-8, -0.9996645373720975)
  assert_expm1_ulp!(-9, -0.9998765901959134)
  assert_expm1_ulp!(1, 1.718281828459045)
  assert_expm1_ulp!(2, 6.38905609893065)
  assert_expm1_ulp!(3, 19.085536923187668)
  assert_expm1_ulp!(4, 53.598150033144236)
  assert_expm1_ulp!(5, 147.4131591025766)
  assert_expm1_ulp!(6, 402.4287934927351)
  assert_expm1_ulp!(7, 1095.6331584284585)
  assert_expm1_ulp!(8, 2979.9579870417283)
  assert_expm1_ulp!(9, 8102.083927575384)
  assert_expm1_ulp!(10, 22025.465794806718)
  assert_expm1_ulp!(100, 26881171418161356000000000000000000000000000)
  assert_expm1_ulp!(1000, double_pos_inf)
  assert_expm1_ulp!(10000, double_pos_inf)
  assert_expm1_ulp!(2.5, 11.182493960703473)
  assert_expm1_ulp!(3.4, 28.96410004739701)
  assert_expm1_ulp!(5.3, 199.33680997479166)
  assert_expm1_ulp!(6.2, 491.7490410932563)
  assert_expm1_ulp!(7.1, 1210.9670744925763)
  assert_expm1_ulp!(8.9, 7330.973539155995)
  assert_expm1_ulp!(9.8, 18032.744927828524)
  assert_expm1_ulp!(10.7, 44354.85513029784)
  assert_expm1_ulp!(101.6, 133143313639875650000000000000000000000000000)
  assert_expm1_ulp!(1.542, 3.673928786933209)
  assert_expm1_ulp!(2.846, 16.218768831241345)
  assert_expm1_ulp!(7.881, 2645.517754639287)
  assert_expm1_ulp!(3.772, 42.466911783522)
  assert_expm1_ulp!(-1.542, -0.7860472322993718)
  assert_expm1_ulp!(-2.846, -0.9419238384694716)
  assert_expm1_ulp!(-7.881, -0.9996221449872207)
  assert_expm1_ulp!(-3.772, -0.9769939947659431)
  assert_expm1_ulp!(-1, -0.6321205588285577)
  assert_expm1_ulp!(0, 0)
  assert_expm1_ulp!(-0, -0)
  assert_expm1_ulp!(double_nan, double_nan)
  assert_expm1_ulp!(double_pos_inf, double_pos_inf)
  assert_expm1_ulp!(double_neg_inf, -1)
}
