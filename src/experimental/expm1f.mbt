///|
const INV_LN2 : Float = 1.4426950216e+00 // 0x3fb8aa3b
//
// Domain [-0.34568, 0.34568], range ~[-6.694e-10, 6.696e-10]:
// |6 / x * (1 + 2 * (1 / (exp(x) - 1) - 1 / x)) - q(x)| < 2**-30.04
// Scaled coefficients: Qn_here = 2**n * Qn_for_q (see s_expm1.c):
//

///|
/// Computes the exponential of `x` minus one.
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(expm1f(1.0), 1.7182817459106445)
/// assert_eq(expm1f(0.0), 0.0)
/// assert_eq(expm1f(-1.0), -0.6321205588285577)
/// assert_eq(expm1f(2.0), 6.38905609893065)
/// ```
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
pub fn expm1f(x : Float) -> Float {
  let mut x = x
  let q1 : Float = -3.3333212137e-2 // -0x888868.0p-28
  let q2 : Float = 1.5807170421e-3 //  0xcf3010.0p-33
  let mut hx = x.reinterpret_as_uint()
  let sign = hx >> 31 != 0
  hx = hx & 0x7fffffff

  // filter out huge and non-finite argument
  if hx >= 0x4195b844 {
    // if |x|>=27*ln2
    if hx > 0x7f800000 {
      // NaN
      return x
    }
    if sign {
      return -1.0
    }
    if hx > 0x42b17217 {
      x *= (0x1.0p127 : Float)
      return x
    }
  }
  let mut k : Int = 0
  let mut hi : Float = 0
  let mut lo : Float = 0
  let mut c : Float = 0
  // argument reduction
  if hx > 0x3eb17218 {
    // if  |x| > 0.5 ln2
    if hx < 0x3F851592 {
      // and |x| < 1.5 ln2
      if !sign {
        hi = x - FLOAT_LN2_HI
        lo = FLOAT_LN2_LO
        k = 1
      } else {
        hi = x + FLOAT_LN2_HI
        lo = -FLOAT_LN2_LO
        k = -1
      }
    } else {
      k = (INV_LN2 * x + (if sign { -0.5 } else { 0.5 })).to_int()
      let t = Float::from_int(k)
      hi = x - t * FLOAT_LN2_HI // t*ln2_hi is exact here
      lo = t * FLOAT_LN2_LO
    }
    x = hi - lo
    c = hi - x - lo
  } else if hx < 0x33000000 {
    // when |x|<2**-25, return x
    //if hx < 0x00800000 {
    //    force_eval!(x * x);
    //}
    return x
  } else {
    k = 0
  }

  // x is now in primary range
  let hfx = (0.5 : Float) * x
  let hxs = x * hfx
  let r1 = (1.0 : Float) + hxs * (q1 + hxs * q2)
  let t = (3.0 : Float) - r1 * hfx
  let mut e = hxs * ((r1 - t) / ((6.0 : Float) - x * t))
  if k == 0 {
    // c is 0
    return x - (x * e - hxs)
  }
  e = x * (e - c) - c
  e -= hxs
  // exp(x) ~ 2^k (x_reduced - e + 1)
  if k == -1 {
    return (0.5 : Float) * (x - e) - 0.5
  }
  if k == 1 {
    if x < -0.25 {
      return -(2.0 : Float) * (e - (x + 0.5))
    }
    return (1.0 : Float) + (2.0 : Float) * (x - e)
  }
  let twopk = Float::reinterpret_from_int((0x7f + k) << 23) // 2^k
  if !(k is (0..=56)) {
    // suffice to return exp(x)-1
    let mut y = x - e + 1.0
    if k == 128 {
      y = y * 2.0 * (0x1.0p127 : Float)
    } else {
      y = y * twopk
    }
    return y - 1.0
  }
  let uf = Float::reinterpret_from_int((0x7f - k) << 23) // 2^-k
  if k < 23 {
    (x - e + ((1.0 : Float) - uf)) * twopk
  } else {
    (x - (e + uf) + 1.0) * twopk
  }
}
