

fn fabs(x: Double) -> Double {
  (x.reinterpret_as_uint64() & 0x7fff_ffff_ffff_ffffUL).reinterpret_as_double()
}
