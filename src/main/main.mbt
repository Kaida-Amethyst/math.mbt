fn main {
  let double_pos_inf = 0x7ff0_0000_0000_0000UL
  let double_pos_inf = double_pos_inf.reinterpret_as_double()
  println(@math.atan(double_pos_inf))
}
