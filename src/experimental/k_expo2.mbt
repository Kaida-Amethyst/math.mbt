///|
fn k_expo2f(x : Float) -> Float {
  let k = 235
  let k_ln2 = Float::reinterpret_from_int(0x4322e3bc)
  // note that k is odd and scale*scale overflows */
  let scale = Float::reinterpret_from_int((0x7f + k / 2) << 23)
  // exp(x - k ln2) * 2**(k-1) */
  @math.expf(x - k_ln2) * scale * scale
}
