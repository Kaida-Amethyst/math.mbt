fn __hi(x: Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

fn __low(x: Double) -> UInt {
  (x.reinterpret_as_uint64()).to_uint()
}

fn __combine(hi: UInt64, low: UInt64) -> Double {
  (hi << 32 | low).reinterpret_as_double()
}

fn __combineQ(hi: UInt64, low: UInt64) -> Double {
  (hi << 32 | low).reinterpret_as_double()
}

fn __combineW(hi: UInt, low: UInt) -> Double {
  __combineQ(hi.to_uint64(), low.to_uint64())
}

fn copysign(x: Double, y: Double) -> Double {
  let hx : UInt = __hi(x)
  let hy : UInt = __hi(y)
  __combine((hx & 0x7fffffff | hy & 0x80000000).to_uint64(), __low(x).to_uint64())
}

let double_nan : Double = (0x7fffffff_ffffffffUL).reinterpret_as_double()
// pub let double_max : Double = (0x7fefffffffffffffUL).reinterpret_as_double()
// pub let pi : Double = 3.14159265358979323846
// pub let double_pi : Double = pi
// pub let e : Double = 2.71828182845904523536
// pub let double_e : Double = e
