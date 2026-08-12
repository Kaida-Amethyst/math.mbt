// Constants
// let int_max : Int = 0x7fffffff

///|
// pub let double_max : Double = (0x7fefffffffffffffUL).reinterpret_as_double()
// pub let double_pi : Double = pi

// epsilon

///|
let double_epsilon : Double = 0x0.0000000000001P-1022
// const DoubleEpsilon : Double = 0x0.0000000000001P-1022

// Computation Utilities

///|
fn __hi(x : Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

///|
fn __low(x : Double) -> UInt {
  x.reinterpret_as_uint64().to_uint()
}

///|
fn __combine(hi : UInt64, low : UInt64) -> Double {
  ((hi << 32) | low).reinterpret_as_double()
}

///|
fn __combineQ(hi : UInt64, low : UInt64) -> Double {
  ((hi << 32) | low).reinterpret_as_double()
}

///|
fn __combineW(hi : UInt, low : UInt) -> Double {
  __combineQ(hi.to_uint64(), low.to_uint64())
}

///|
fn copysign(x : Double, y : Double) -> Double {
  let hx : UInt = __hi(x)
  let hy : UInt = __hi(y)
  __combineW((hx & 0x7fffffff) | (hy & 0x80000000), __low(x))
}

///|
fn max_element(elements : Array[Double]) -> (Double, Int) {
  let mut max_val = elements[0]
  let mut idx = 0
  for i, v in elements {
    if v > max_val {
      max_val = v
      idx = i
    }
  }
  (max_val, idx)
}

///|
fn absmaximum(vec : Array[Double]) -> Double {
  let mut max : Double = 0.0
  for p in vec {
    let ap = fabs(p)
    if ap > max {
      max = ap
    }
  }
  max
}

///|
fn square(x : Double) -> Double {
  x * x
}
