///|
const FLOAT_LN2_HI : Float = 6.9314575195e-01 // 0x3f317200

///|
const FLOAT_LN2_LO : Float = 1.4286067653e-06 // 0x35bfbe8e

///|
const FLOAT_INV_LN2 : Float = 1.4426950216e+00 // 0x3fb8aa3b

///|
pub fn expf(x : Float) -> Float {
  let mut x = x
  let p1 : Float = 1.6666625440e-1 // 0xaaaa8f.0p-26
  let p2 : Float = -2.7667332906e-3 // -0xb55215.0p-32
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
      x *= (0x1.0p127 : Float)
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
  let c = x - xx * (p1 + xx * p2)
  let y = (1.0 : Float) + (x * c / ((2.0 : Float) - c) - lo + hi)
  if k == 0 {
    y
  } else {
    scalbnf(y, k)
  }
}

test "expf" {
  fn assert_expf_ulp!(input, expect) {
    assert_float_ulp!(expect, expf(input), EXP_F_MAX_ULP)
  }
  assert_expf_ulp!(-1, 0.3678794503211975)
  assert_expf_ulp!(1, 2.7182817459106445)
  assert_expf_ulp!(8, 2980.9580078125)
  assert_expf_ulp!(-8, 0.000335462624207139)
  assert_expf_ulp!(0, 1)
  assert_expf_ulp!(27, 532048248832)
  assert_expf_ulp!(-27, 1.8795288676126676e-12)
  assert_expf_ulp!(0.125, 1.133148431777954)
  assert_expf_ulp!(-0.125, 0.8824968934059143)
  assert_expf_ulp!(0.5, 1.6487212181091309)
  assert_expf_ulp!(-0.5, 0.6065306663513184)
  assert_expf_ulp!(1.5, 4.481688976287842)
  assert_expf_ulp!(-1.5, 0.22313016653060913)
  assert_expf_ulp!(2, 7.389056205749512)
  assert_expf_ulp!(-2, 0.1353352814912796)
  assert_expf_ulp!(3, 20.08553695678711)
  assert_expf_ulp!(-3, 0.049787066876888275)
  assert_expf_ulp!(64, 6.23514943204966e+27)
  assert_expf_ulp!(-64, 1.6038109389511792e-28)
  assert_expf_ulp!(1000, @float.infinity)
  assert_expf_ulp!(-1000, 0)
  assert_expf_ulp!(512, @float.infinity)
  assert_expf_ulp!(729, @float.infinity)
  assert_expf_ulp!(3511808, @float.infinity)
  assert_expf_ulp!(15.25, 4197501.5)
  assert_expf_ulp!(6859, @float.infinity)
  assert_expf_ulp!(68.25, 4.371176932375463e+29)
  assert_expf_ulp!(701.625, @float.infinity)
  assert_expf_ulp!(@float.not_a_number, @float.not_a_number)
  assert_expf_ulp!(@float.infinity, @float.infinity)
  assert_expf_ulp!(@float.neg_infinity, 0)
}
