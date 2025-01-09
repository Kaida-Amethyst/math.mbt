///| Return the cube root of `x`.
///
/// # Example
///
/// ```moonbit
/// assert_eq!(cbrt(3), 1.4422495703074083)
/// assert_eq!(cbrt(-3), -1.4422495703074083)
/// assert_eq!(cbrt(0), 0)
/// assert_eq!(cbrt(1), 1)
/// assert_eq!(cbrt(1000), 10)
/// ````
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
///
/// 1. If `x` is NaN, the result is NaN.
/// 2. If `x` is ±0, the result is ±0.
pub fn cbrt(x: Double) -> Double {
  if isinf(x) || isnan(x) || x == 0.0 {
    return x
  }

  let b1 : UInt = 715094163 // B1 = (682-0.03306235651)*2**20
  let b2 : UInt = 696219795 // B2 = (664-0.03306235651)*2**20
  let c =  5.42857142857142815906e-01 // 19/35     = 0x3FE15F15, 0xF15F15F1
  let d = -7.05306122448979611050e-01 // -864/1225 = 0xBFE691DE, 0x2532C834
  let e =  1.41428571428571436819e+00 // 99/70     = 0x3FF6A0EA, 0x0EA0EA0F
  let f =  1.60714285714285720630e+00 // 45/28     = 0x3FF9B6DB, 0x6DB6DB6E
  let g =  3.57142857142857150787e-01 // 5/14      = 0x3FD6DB6D, 0xB6DB6DB7

  let hx = __hi(x).reinterpret_as_int()
  let sign = if x < 0.0 { true } else { false }
  let x = fabs(x)
  // rough cbrt to 5 bits
  let t = if hx < 0x00100000 {
    // subnormal number
    let _t : UInt64 = 0x43500000_00000000
    let _t : Double = _t.reinterpret_as_double()
    let _t = _t * x
    __combineW(__hi(_t) / 3 + b2, 0)
  } else {
    __combineW((hx.reinterpret_as_uint() / 3 + b1), 0)
  }
  let r = t * t / x
  let s = c + r * t
  let t = t * (g + f / (s + e + d / s))
  // chopped to 20 bits and make it larger than cbrt(x)
  let t = __combineW(__hi(t) + 0x00000001, 0)
  // one step newton iteration to 53 bits with error less than 0.667 ulps
  let s = t * t
  let r = x / s
  let w = t + t
  let r = (r - t) / (w + r)
  let t = t + t * r
  // retore the sign bit
  if sign {
    -t
  } else {
    t
  }
}


test "cbrt" {
  fn assert_cbrt_ulp!(input, expect) {
    assert_ulp!(expect, cbrt(input), CBRT_MAX_ULP)
  }

  assert_cbrt_ulp!(-1, -1)
  assert_cbrt_ulp!(-2, -1.2599210498948734)
  assert_cbrt_ulp!(-3, -1.4422495703074083)
  assert_cbrt_ulp!(-4, -1.5874010519681996)
  assert_cbrt_ulp!(-5, -1.7099759466766968)
  assert_cbrt_ulp!(-6, -1.8171205928321394)
  assert_cbrt_ulp!(-7, -1.9129311827723894)
  assert_cbrt_ulp!(-8, -2)
  assert_cbrt_ulp!(-9, -2.080083823051904)
  assert_cbrt_ulp!(-27, -3.0000000000000004)
  assert_cbrt_ulp!(1, 1)
  assert_cbrt_ulp!(2, 1.2599210498948734)
  assert_cbrt_ulp!(3, 1.4422495703074083)
  assert_cbrt_ulp!(4, 1.5874010519681996)
  assert_cbrt_ulp!(5, 1.7099759466766968)
  assert_cbrt_ulp!(6, 1.8171205928321394)
  assert_cbrt_ulp!(7, 1.9129311827723894)
  assert_cbrt_ulp!(8, 2)
  assert_cbrt_ulp!(9, 2.080083823051904)
  assert_cbrt_ulp!(27, 3.0000000000000004)
  assert_cbrt_ulp!(10, 2.1544346900318834)
  assert_cbrt_ulp!(100, 4.641588833612778)
  assert_cbrt_ulp!(1000, 10)
  assert_cbrt_ulp!(10000, 21.54434690031884)
  assert_cbrt_ulp!(2.5, 1.3572088082974532)
  assert_cbrt_ulp!(3.4, 1.5036945962049748)
  assert_cbrt_ulp!(5.3, 1.743513401265128)
  assert_cbrt_ulp!(6.2, 1.8370905500142276)
  assert_cbrt_ulp!(7.1, 1.9219973427746715)
  assert_cbrt_ulp!(8.9, 2.0723510980592614)
  assert_cbrt_ulp!(9.8, 2.139974961130159)
  assert_cbrt_ulp!(10.7, 2.2035754532216254)
  assert_cbrt_ulp!(101.6, 4.666213107846952)
  assert_cbrt_ulp!(1.542, 1.1553000476063058)
  assert_cbrt_ulp!(2.846, 1.4171363302434639)
  assert_cbrt_ulp!(7.881, 1.990033752783906)
  assert_cbrt_ulp!(3.772, 1.556648513825142)
  assert_cbrt_ulp!(-1, -1)
  assert_cbrt_ulp!(0, 0)
  assert_cbrt_ulp!(-0, -0)
  assert_cbrt_ulp!(double_nan, double_nan)
}
