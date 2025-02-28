///| Return double `x` is finite and is not nan
///
/// if x is finite and not nan, return 1, otherwise return 0
pub fn isfinite(x : Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffff_ffffffffUL) < 0x7ff00000_00000000UL
}
