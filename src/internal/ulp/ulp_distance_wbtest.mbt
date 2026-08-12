///|
test "Double ULP distance for finite values" {
  let positive_one = 0x3ff0000000000000UL.reinterpret_as_double()
  let positive_one_next = 0x3ff0000000000001UL.reinterpret_as_double()
  let negative_one = 0xbff0000000000000UL.reinterpret_as_double()
  let negative_one_next = 0xbff0000000000001UL.reinterpret_as_double()
  let min_subnormal = 0x0000000000000001UL.reinterpret_as_double()
  let negative_min_subnormal = 0x8000000000000001UL.reinterpret_as_double()
  let max_finite = 0x7fefffffffffffffUL.reinterpret_as_double()
  let negative_max_finite = 0xffefffffffffffffUL.reinterpret_as_double()
  assert_eq(ulp_error(positive_one, positive_one), 0L)
  assert_eq(ulp_error(positive_one, positive_one_next), 1L)
  assert_eq(ulp_error(negative_one, negative_one_next), 1L)
  assert_eq(ulp_error(-0.0, 0.0), 0L)
  assert_eq(ulp_error(negative_min_subnormal, -0.0), 1L)
  assert_eq(ulp_error(0.0, min_subnormal), 1L)
  assert_eq(ulp_error(negative_min_subnormal, min_subnormal), 2L)
  assert_eq(ulp_error(negative_one, positive_one), 0x7fe0000000000000L)
  assert_eq(ulp_error(negative_max_finite, max_finite), ULP_INT64_MAX)
}

///|
test "Double ULP distance for special values" {
  let nan = 0x7ff8000000000000UL.reinterpret_as_double()
  let negative_nan = 0xfff8000000000001UL.reinterpret_as_double()
  assert_eq(ulp_error(nan, negative_nan), 0L)
  assert_eq(ulp_error(@double.infinity, @double.infinity), 0L)
  assert_eq(ulp_error(@double.neg_infinity, @double.neg_infinity), 0L)
  assert_eq(ulp_error(nan, 1.0), ULP_INT64_MAX)
  assert_eq(ulp_error(nan, @double.infinity), ULP_INT64_MAX)
  assert_eq(ulp_error(@double.infinity, 1.0), ULP_INT64_MAX)
  assert_eq(ulp_error(@double.infinity, @double.neg_infinity), ULP_INT64_MAX)
}

///|
test "Float ULP distance for finite values" {
  let positive_one = Float::reinterpret_from_uint(0x3f800000U)
  let positive_one_next = Float::reinterpret_from_uint(0x3f800001U)
  let negative_one = Float::reinterpret_from_uint(0xbf800000U)
  let negative_one_next = Float::reinterpret_from_uint(0xbf800001U)
  let min_subnormal = Float::reinterpret_from_uint(0x00000001U)
  let negative_min_subnormal = Float::reinterpret_from_uint(0x80000001U)
  let max_finite = Float::reinterpret_from_uint(0x7f7fffffU)
  let negative_max_finite = Float::reinterpret_from_uint(0xff7fffffU)
  assert_eq(ulp_error_f32(positive_one, positive_one), 0)
  assert_eq(ulp_error_f32(positive_one, positive_one_next), 1)
  assert_eq(ulp_error_f32(negative_one, negative_one_next), 1)
  assert_eq(ulp_error_f32((-0.0 : Float), (0.0 : Float)), 0)
  assert_eq(ulp_error_f32(negative_min_subnormal, (-0.0 : Float)), 1)
  assert_eq(ulp_error_f32((0.0 : Float), min_subnormal), 1)
  assert_eq(ulp_error_f32(negative_min_subnormal, min_subnormal), 2)
  assert_eq(ulp_error_f32(negative_one, positive_one), 0x7f000000)
  assert_eq(ulp_error_f32(negative_max_finite, max_finite), ULP_INT_MAX)
}

///|
test "Float ULP distance for special values" {
  let nan = Float::reinterpret_from_uint(0x7fc00000U)
  let negative_nan = Float::reinterpret_from_uint(0xffc00001U)
  assert_eq(ulp_error_f32(nan, negative_nan), 0)
  assert_eq(ulp_error_f32(@float.infinity, @float.infinity), 0)
  assert_eq(ulp_error_f32(@float.neg_infinity, @float.neg_infinity), 0)
  assert_eq(ulp_error_f32(nan, (1.0 : Float)), ULP_INT_MAX)
  assert_eq(ulp_error_f32(nan, @float.infinity), ULP_INT_MAX)
  assert_eq(ulp_error_f32(@float.infinity, (1.0 : Float)), ULP_INT_MAX)
  assert_eq(ulp_error_f32(@float.infinity, @float.neg_infinity), ULP_INT_MAX)
}

///|
test "ULP distances are symmetric and nonnegative" {
  let double_pairs : Array[(Double, Double)] = [
    (-1.0, 1.0),
    (-0.0, 0.0),
    (
      0x8000000000000001UL.reinterpret_as_double(),
      0x0000000000000001UL.reinterpret_as_double(),
    ),
    (
      0xffefffffffffffffUL.reinterpret_as_double(),
      0x7fefffffffffffffUL.reinterpret_as_double(),
    ),
    (@double.not_a_number, 1.0),
    (@double.infinity, @double.neg_infinity),
  ]
  for pair in double_pairs {
    let (x, y) = pair
    let forward = ulp_error(x, y)
    let reverse = ulp_error(y, x)
    assert_true(forward >= 0L)
    assert_eq(forward, reverse)
  }
  let float_pairs : Array[(Float, Float)] = [
    ((-1.0 : Float), (1.0 : Float)),
    ((-0.0 : Float), (0.0 : Float)),
    (
      Float::reinterpret_from_uint(0x80000001U),
      Float::reinterpret_from_uint(0x00000001U),
    ),
    (
      Float::reinterpret_from_uint(0xff7fffffU),
      Float::reinterpret_from_uint(0x7f7fffffU),
    ),
    (@float.not_a_number, (1.0 : Float)),
    (@float.infinity, @float.neg_infinity),
  ]
  for pair in float_pairs {
    let (x, y) = pair
    let forward = ulp_error_f32(x, y)
    let reverse = ulp_error_f32(y, x)
    assert_true(forward >= 0)
    assert_eq(forward, reverse)
  }
}
