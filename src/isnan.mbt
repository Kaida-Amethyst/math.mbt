///| Return isnan(x) for double x
///
/// if x is NaN, return true, otherwise return false
pub fn isnan(x : Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffff_ffffffffUL) > 0x7ff00000_00000000UL
}
