///| Return the cube root of `x` with single precision.
///
/// # Example
///
/// ```moonbit
/// assert_eq(cbrtf(3), 1.4422495703074083)
/// assert_eq(cbrtf(-3), -1.4422495703074083)
/// assert_eq(cbrtf(0), 0)
/// assert_eq(cbrtf(1), 1)
/// assert_eq(cbrtf(1000), 10)
/// ````
///
/// # Accuracy
///
/// 0 ulp (unit in the last place).
///
/// # Special Cases
///
/// 1. If `x` is NaN, the result is NaN.
/// 2. If `x` is ±0, the result is ±0.
pub fn cbrtf(x : Float) -> Float {
  let b1 : UInt = 709958130 // B1 = (127-127.0/3-0.03306235651)*2**23 */
  let b2 : UInt = 642849266 // B2 = (127-127.0/3-24/3-0.03306235651)*2**23 */
  let mut ui : UInt = x.reinterpret_as_uint()
  let mut hx : UInt = ui & 0x7fffffff
  if hx >= 0x7f800000 {
    // cbrt(NaN,INF) is itself
    return x + x
  }

  // rough cbrt to 5 bits
  if hx < 0x00800000 {
    // zero or subnormal?
    if hx == 0 {
      return x
    } // cbrt(+-0) is itself
    ui = (x * (0x1.0p24 : Float)).reinterpret_as_uint()
    hx = ui & 0x7fffffff
    hx = hx / 3 + b2
  } else {
    hx = hx / 3 + b1
  }
  ui = ui & 0x80000000
  ui = ui | hx

  //
  // First step Newton iteration (solving t*t-x/t == 0) to 16 bits.  In
  // double precision so that its terms can be arranged for efficiency
  // without causing overflow or underflow.
  //
  let dx = x.to_double()
  let t = ui.reinterpret_as_float().to_double()
  let r = t * t * t
  let t = t * (dx + dx + r) / (dx + r + r)

  //
  // Second step Newton iteration to 47 bits.  In double precision for
  // efficiency and accuracy.
  //
  let r = t * t * t
  let t = t * (dx + dx + r) / (dx + r + r)

  // rounding to 24 bits is perfect in round-to-nearest mode
  t.to_float()
}

///|
test "cbrtf" {
  fn assert_cbrtf_ulp(input, expect) raise {
    assert_float_ulp(expect, cbrtf(input), CBRT_F_MAX_ULP)
  }

  assert_cbrtf_ulp(-1, -1)
  assert_cbrtf_ulp(1, 1)
  assert_cbrtf_ulp(8, 2)
  assert_cbrtf_ulp(-8, -2)
  assert_cbrtf_ulp(0, 0)
  assert_cbrtf_ulp(27, 3)
  assert_cbrtf_ulp(-27, -3)
  assert_cbrtf_ulp(0.125, 0.5)
  assert_cbrtf_ulp(-0.125, -0.5)
  assert_cbrtf_ulp(0.5, 0.7937005162239075)
  assert_cbrtf_ulp(-0.5, -0.7937005162239075)
  assert_cbrtf_ulp(1.5, 1.1447142362594604)
  assert_cbrtf_ulp(-1.5, -1.1447142362594604)
  assert_cbrtf_ulp(2, 1.2599210739135742)
  assert_cbrtf_ulp(-2, -1.2599210739135742)
  assert_cbrtf_ulp(3, 1.4422495365142822)
  assert_cbrtf_ulp(-3, -1.4422495365142822)
  assert_cbrtf_ulp(64, 4)
  assert_cbrtf_ulp(-64, -4)
  assert_cbrtf_ulp(1000, 10)
  assert_cbrtf_ulp(-1000, -10)
  assert_cbrtf_ulp(512, 8)
  assert_cbrtf_ulp(729, 9)
  assert_cbrtf_ulp(3511808, 152)
  assert_cbrtf_ulp(15.25, 2.4798378944396973)
  assert_cbrtf_ulp(6859, 19)
  assert_cbrtf_ulp(68.25, 4.086650848388672)
  assert_cbrtf_ulp(701.625, 8.885905265808105)
}
