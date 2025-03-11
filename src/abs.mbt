///|
fn fabs(x : Double) -> Double {
  (x.reinterpret_as_uint64() & 0x7fff_ffff_ffff_ffffUL).reinterpret_as_double()
}


// fn fabsf(x: Float) -> Float {
//   (x.reinterpret_as_uint() & 0x7fff_ffffU).to_float()
// }
