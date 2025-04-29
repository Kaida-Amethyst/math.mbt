///|
fn tanf_poly(x : Float, odd : Bool) -> Float {
  let x = x.to_double()
  let coef : FixedArray[Double] = [
    0.333331395030791399758, // 0x15554d3418c99f.0p-54 */
     0.133392002712976742718, // 0x1112fd38999f72.0p-55 */
     0.0533812378445670393523, // 0x1b54c91d865afe.0p-57 */
     0.0245283181166547278873, // 0x191df3908c33ce.0p-58 */
     0.00297435743359967304927, // 0x185dadfcecf44e.0p-61 */
     0.00946564784943673166728, // 0x1362b9bf971bcd.0p-59 */
  ]
  let z = x * x
  let mut r = coef[4] + z * coef[5]
  let t = coef[2] + z * coef[3]
  let w = z * z
  let s = z * x
  let u = coef[0] + z * coef[1]
  r = x + s * u + s * w * (t + w * r)
  (if odd { -1.0 / r } else { r }).to_float()
}

///|
pub fn tanf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return x
  }
  let (x, q) = trig_reduce(x, COS_SWITCHOVER)
  tanf_poly(x, (q & 1) != 0)
}
