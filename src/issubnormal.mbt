///| Return true if x is subnormal, false otherwise.
pub fn issubnormal(x: Double) -> Bool {
  let ix : UInt64 = x.reinterpret_as_uint64() & 0x7fff_ffff_ffff_ffff;

  ix > 0 && ix < 0x0010_0000_0000_0000
}
