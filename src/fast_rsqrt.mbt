///| Inverse square root approximation using the fast inverse square root algorithm.
pub fn fast_rsqrt(x : Float) -> Float {
  let threehalfs : Float = 1.5
  let x2 : Float = x * 0.5
  let mut y : Float = x
  let mut i : Int = y.reinterpret_as_int()
  i = 0x5f3759df - (i >> 1)
  y = i.reinterpret_as_float()
  y * (threehalfs - x2 * y * y)
}
