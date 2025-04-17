///|
const FLOAT_LN2_HI : Float = 6.9314575195e-01 // 0x3f317200

///|
const FLOAT_LN2_LO : Float = 1.4286067653e-06 // 0x35bfbe8e

///|
const FLOAT_INV_LN2 : Float = 1.4426950216e+00 // 0x3fb8aa3b

///|
const FLOAT_P1 : Float = 1.6666625440e-1 //  0xaaaa8f.0p-26

///|
const FLOAT_P2 : Float = -2.7667332906e-3 // -0xb55215.0p-32

///|
pub fn expf(x : Float) -> Float {
  let mut x = x
  let x1p127 = (0x7f000000).reinterpret_as_float() // 0x1p127f === 2 ^ 127
  let mut hx = x.reinterpret_as_uint()
  let sign = (hx >> 31).reinterpret_as_int() // sign bit of x */
  let signb : Bool = sign != 0
  hx = hx & 0x7fffffff // high word of |x| */

  // special cases */
  if hx >= 0x42aeac50 {
    // if |x| >= -87.33655f or NaN */
    if hx > 0x7f800000 {
      // NaN */
      return x
    }
    if hx >= 0x42b17218 && not(signb) {
      // x >= 88.722839f */
      // overflow */
      x *= x1p127
      return x
    }
    if signb {
      // underflow */
      if hx >= 0x42cff1b5 {
        // x <= -103.972084f */
        return 0.0
      }
    }
  }
  let float_half : Array[Float] = [0.5, -0.5]

  // argument reduction */
  let mut k : Int = 0
  let mut hi : Float = 0.0
  let mut lo : Float = 0.0
  if hx > 0x3eb17218 {
    // if |x| > 0.5 ln2 */
    if hx > 0x3f851592 {
      // if |x| > 1.5 ln2 */
      k = (FLOAT_INV_LN2 * x + float_half[sign]).to_int()
    } else {
      k = 1 - sign - sign
    }
    let kf = k.to_float()
    hi = x - kf * FLOAT_LN2_HI // k*ln2hi is exact here
    lo = kf * FLOAT_LN2_LO
    x = hi - lo
  } else if hx > 0x39000000 {
    // |x| > 2**-14 */
    k = 0
    hi = x
    lo = 0.0
  } else {
    // raise inexact */
    return (1.0 : Float) + x
  }

  // x is now in primary range */
  let xx = x * x
  let c = x - xx * (FLOAT_P1 + xx * FLOAT_P2)
  let y = (1.0 : Float) + (x * c / ((2.0 : Float) - c) - lo + hi)
  if k == 0 {
    y
  } else {
    scalbnf(y, k)
  }
}
