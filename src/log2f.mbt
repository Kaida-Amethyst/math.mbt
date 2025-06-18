///| The base 2 logarithm of `x` (Float).
pub fn log2f(x : Float) -> Float {
  let mut x = x
  let ivln2hi : Float = 1.4428710938e+00 // 0x3fb8b000 */
  let ivln2lo : Float = -1.7605285393e-04 // 0xb9389ad4 */
  let lg1 : Float = 0.66666662693 // 0xaaaaaa.0p-24 */
  let lg2 : Float = 0.40000972152 // 0xccce13.0p-25 */
  let lg3 : Float = 0.28498786688 // 0x91e9ee.0p-25 */
  let lg4 : Float = 0.24279078841 // 0xf89e26.0p-26 */
  let mut ui : UInt = x.reinterpret_as_uint()
  let mut ix = ui
  let mut k = 0
  if ix < 0x00800000 || ix >> 31 > 0 {
    // x < 2**-126  */
    if ix << 1 == 0 {
      return -recipf(x * x)
    } // log(+-0)=-inf */
    if ix >> 31 > 0 {
      return (x - x) / 0.0
    } // log(-#) = NaN */
    // subnormal number, scale up x */
    k -= 25
    x *= 0x1.0p25
    ui = x.reinterpret_as_uint()
    ix = ui
  } else if ix >= 0x7f800000 {
    return x
  } else if ix == 0x3f800000 {
    return 0.0
  }

  // reduce x into [sqrt(2)/2, sqrt(2)] */
  ix += 0x3f800000U - 0x3f3504f3U
  k += (ix >> 23).reinterpret_as_int() - 0x7f
  ix = (ix & 0x007fffff) + 0x3f3504f3
  ui = ix
  x = ui.reinterpret_as_float()
  let f = x - 1.0
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let t1 = w * (lg2 + w * lg4)
  let t2 = z * (lg1 + w * lg3)
  let r = t2 + t1
  let hfsq = f * f * 0.5
  let hi = f - hfsq
  let ui = hi.reinterpret_as_uint() & 0xfffff000
  let hi = ui.reinterpret_as_float()
  let lo = f - hi - hfsq + s * (hfsq + r)
  (lo + hi) * ivln2lo + lo * ivln2hi + hi * ivln2hi + k.to_float()
}
