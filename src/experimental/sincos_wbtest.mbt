///|
test "sincos" {
  let arr_x = [
    0.0, 1.0, 2.0, 3.0, 4.0, 0.7853981633974483, 1.5707963267948966, 3.141592653589793,
    10000.0,
  ]
  for x in arr_x {
    let sin_x = sin(x)
    let cos_x = cos(x)
    let (_sin_x, _cos_x) = sincos(x)
    assert_eq(_sin_x, sin_x)
    assert_eq(_cos_x, cos_x)
  }
}
