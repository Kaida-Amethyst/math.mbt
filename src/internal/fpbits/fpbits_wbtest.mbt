///|
test "split and reconstruct Double words" {
  let cases : Array[UInt64] = [
    0x0000000000000000UL, 0x8000000000000000UL, 0x0000000000000001UL, 0x3ff0000000000000UL,
    0x7fefffffffffffffUL, 0x7ff8000000000001UL,
  ]
  for bits in cases {
    let value = bits.reinterpret_as_double()
    let high = high_word(value)
    let low = low_word(value)
    assert_eq(high, (bits >> 32).to_uint())
    assert_eq(low, bits.to_uint())
    assert_eq(from_words(high, low).reinterpret_as_uint64(), bits)
  }
}
