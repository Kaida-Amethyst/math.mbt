///| Return true if x is a normal number, false otherwise.
pub fn isnormal(x : Double) -> Bool {
  let ix : UInt64 = x.reinterpret_as_uint64() & 0x7fff_ffff_ffff_ffff
  ix < 0x7ff0_0000_0000_0000 && ix >= 0x0010_0000_0000_0000
}
