///| Return isinf(x) for double x
///
/// if x is infinite, return 1, otherwise return 0
pub fn isinf(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffff_ffffffffUL) == 0x7ff00000_00000000UL
}

