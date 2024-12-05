fn __hi(x: Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

fn __low(x: Double) -> UInt {
  (x.reinterpret_as_uint64()).to_uint()
}

fn __combine(hi: UInt64, low: UInt64) -> Double {
  (hi << 32 | low).reinterpret_as_double()
}
