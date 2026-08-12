///|
pub fn high_word(value : Double) -> UInt {
  (value.reinterpret_as_uint64() >> 32).to_uint()
}

///|
pub fn low_word(value : Double) -> UInt {
  value.reinterpret_as_uint64().to_uint()
}

///|
pub fn from_words(high : UInt, low : UInt) -> Double {
  ((high.to_uint64() << 32) | low.to_uint64()).reinterpret_as_double()
}
