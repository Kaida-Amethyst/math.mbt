///| Return the cube root of `x`.
/// # Introduction
///
/// Return the cube root of `x`.
///
/// # Special Cases
///
/// 1. If `x` is NaN, the result is NaN.
/// 2. If `x` is ±0, the result is ±0.
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
pub fn cbrt(x: Double) -> Double {
  let b1 : UInt = 715094163 // B1 = (682-0.03306235651)*2**20
  let b2 : UInt = 696219795 // B2 = (664-0.03306235651)*2**20
  let c =  5.42857142857142815906e-01 // 19/35     = 0x3FE15F15, 0xF15F15F1
  let d = -7.05306122448979611050e-01 // -864/1225 = 0xBFE691DE, 0x2532C834
  let e =  1.41428571428571436819e+00 // 99/70     = 0x3FF6A0EA, 0x0EA0EA0F
  let f =  1.60714285714285720630e+00 // 45/28     = 0x3FF9B6DB, 0x6DB6DB6E
  let g =  3.57142857142857150787e-01 // 5/14      = 0x3FD6DB6D, 0xB6DB6DB7

  let mut x = x
  let mut hx = __hi(x).reinterpret_as_int()
  let sign = hx & 0x80000000 // sign= sign(x)
  hx = hx ^ sign
  if hx >= 0x7ff00000 {
    return x + x // cbrt(NaN,INF) is itself
  }
  if (hx | __low(x).reinterpret_as_int()) == 0 {
    return x // cbrt(0) is itself
  }
  x = __combineW(hx.reinterpret_as_uint(), __low(x))
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
  __combineW(__hi(t) | sign.reinterpret_as_uint(), __low(t))
}
