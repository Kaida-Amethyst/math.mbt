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
fn abs_i64(x : Int64) -> Int64 {
  if x < 0 {
    -x
  } else {
    x
  }
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

// Ulp Error
// 1. if x is Nan, y is Nan, return 0
// 2. if x is +inf, y is +inf, return 0
// 3. if x is -inf, y is -inf, return 0
// 4. if x/y is NaN, y/x is not NaN, return INT_MAX
// 5. if x/y is +inf, y/x is not +inf, return INT_MAX
// 6. if x/y is -inf, y/x is not -inf, return INT_MAX
// 7. if x/y not inf, nan, return IEEE754(x) - IEEE754(y) |> abs

///|
pub fn ulp_error(x : Double, y : Double) -> Int64 {
  let xisnan : Bool = isnan(x)
  let yisnan : Bool = isnan(y)
  let xispinf : Bool = isinf(x) && x > 0
  let yispinf : Bool = isinf(y) && y > 0
  let xisninf : Bool = isinf(x) && x < 0
  let yisninf : Bool = isinf(y) && y < 0
  if xisnan && yisnan {
    return 0
  }
  if xispinf && yispinf {
    return 0
  }
  if xisninf && yisninf {
    return 0
  }
  if xisnan && not(yisnan) {
    return INT64_MAX
  }
  if yisnan && not(xisnan) {
    return INT64_MAX
  }
  if xispinf && not(yispinf) {
    return INT64_MAX
  }
  if yispinf && not(xispinf) {
    return INT64_MAX
  }
  if xisninf && not(yisninf) {
    return INT64_MAX
  }
  if yisninf && not(xisninf) {
    return INT64_MAX
  }
  let xi : Int64 = x.reinterpret_as_int64()
  let yi : Int64 = y.reinterpret_as_int64()
  let diff = xi - yi
  abs_i64(diff)
}

///|
pub fn ulp_error_f32(x : Float, y : Float) -> Int {
  let xisnan : Bool = x.is_nan()
  let yisnan : Bool = y.is_nan()
  let xispinf : Bool = x.is_inf() && x > 0
  let yispinf : Bool = y.is_inf() && y > 0
  let xisninf : Bool = x.is_inf() && x < 0
  let yisninf : Bool = y.is_inf() && y < 0
  if x == 0 && y == 0 { // -0 and +0 are equal
    return 0
  }
  if xisnan && yisnan {
    return 0
  }
  if xispinf && yispinf {
    return 0
  }
  if xisninf && yisninf {
    return 0
  }
  if xisnan && not(yisnan) {
    return INT_MAX
  }
  if yisnan && not(xisnan) {
    return INT_MAX
  }
  if xispinf && not(yispinf) {
    return INT_MAX
  }
  if yispinf && not(xispinf) {
    return INT_MAX
  }
  if xisninf && not(yisninf) {
    return INT_MAX
  }
  if yisninf && not(xisninf) {
    return INT_MAX
  }
  let xi : Int = x.reinterpret_as_int()
  let yi : Int = y.reinterpret_as_int()
  let diff = xi - yi
  diff.abs()
}

///|
fn assert_ulp(
  expect : Double,
  actual : Double,
  max_ulp : Int,
) -> Unit raise Error {
  let ulp_err = ulp_error(expect, actual)
  if ulp_err > max_ulp.to_int64() {
    println(
      "expect: \{expect}, actual: \{actual}, ulp error: \{ulp_err}, max ulp: \{max_ulp}",
    )
    assert_eq(1, 0)
  }
}

///|
fn assert_float_ulp(
  expect : Float,
  actual : Float,
  max_ulp : Int,
) -> Unit raise Error {
  let ulp_err = ulp_error_f32(expect, actual)
  if ulp_err > max_ulp {
    println(
      "expect: \{expect}, actual: \{actual}, ulp error: \{ulp_err}, max ulp: \{max_ulp}",
    )
    assert_eq(1, 0)
  }
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
