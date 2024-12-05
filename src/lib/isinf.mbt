pub fn isinf(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffff_ffffffffUL) == 0x7ff00000_00000000UL
}

