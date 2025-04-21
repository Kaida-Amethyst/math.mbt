///|
fn k_expo2f(x : Float) -> Float {
  let k = 235
  let k_ln2 = (0x4322e3bc).reinterpret_as_float()
  // note that k is odd and scale*scale overflows */
  let scale = ((0x7f + k / 2) << 23).reinterpret_as_float()
  // exp(x - k ln2) * 2**(k-1) */
  expf(x - k_ln2) * scale * scale
}
