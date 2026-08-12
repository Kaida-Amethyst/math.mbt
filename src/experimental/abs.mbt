///|
fn fabs(x : Double) -> Double {
  (x.reinterpret_as_uint64() & 0x7fff_ffff_ffff_ffffUL).reinterpret_as_double()
}

// fn fabsf(x: Float) -> Float {
//   Float::reinterpret_from_uint(x.reinterpret_as_uint() & 0x7fff_ffffU)
// }
