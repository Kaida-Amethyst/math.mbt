///|
const ULP_F64_SIGN_MASK : UInt64 = 0x8000000000000000UL

///|
const ULP_F64_MAGNITUDE_MASK : UInt64 = 0x7fffffffffffffffUL

///|
const ULP_F32_SIGN_MASK : UInt = 0x80000000U

///|
const ULP_F32_MAGNITUDE_MASK : UInt = 0x7fffffffU

///|
fn ulp_rank(x : Double) -> UInt64 {
  let bits = x.reinterpret_as_uint64()
  let magnitude = bits & ULP_F64_MAGNITUDE_MASK
  if (bits & ULP_F64_SIGN_MASK) != 0UL {
    ULP_F64_SIGN_MASK - magnitude
  } else {
    ULP_F64_SIGN_MASK + magnitude
  }
}

///|
fn ulp_rank_f32(x : Float) -> UInt {
  let bits = x.reinterpret_as_uint()
  let magnitude = bits & ULP_F32_MAGNITUDE_MASK
  if (bits & ULP_F32_SIGN_MASK) != 0U {
    ULP_F32_SIGN_MASK - magnitude
  } else {
    ULP_F32_SIGN_MASK + magnitude
  }
}

///|
fn ulp_error(x : Double, y : Double) -> Int64 {
  if x == y || (isnan(x) && isnan(y)) {
    0L
  } else if isnan(x) || isnan(y) || isinf(x) || isinf(y) {
    INT64_MAX
  } else {
    let x_rank = ulp_rank(x)
    let y_rank = ulp_rank(y)
    let distance = if x_rank >= y_rank {
      x_rank - y_rank
    } else {
      y_rank - x_rank
    }
    if distance > ULP_F64_MAGNITUDE_MASK {
      INT64_MAX
    } else {
      distance.reinterpret_as_int64()
    }
  }
}

///|
fn ulp_error_f32(x : Float, y : Float) -> Int {
  if x == y || (x.is_nan() && y.is_nan()) {
    0
  } else if x.is_nan() || y.is_nan() || x.is_inf() || y.is_inf() {
    INT_MAX
  } else {
    let x_rank = ulp_rank_f32(x)
    let y_rank = ulp_rank_f32(y)
    let distance = if x_rank >= y_rank {
      x_rank - y_rank
    } else {
      y_rank - x_rank
    }
    if distance > ULP_F32_MAGNITUDE_MASK {
      INT_MAX
    } else {
      distance.reinterpret_as_int()
    }
  }
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
