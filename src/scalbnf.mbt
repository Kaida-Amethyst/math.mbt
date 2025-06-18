///| Compute x * 2 **n where x is a double and n is an integer.
/// # Introcution:
///
/// Compute x * 2 **n without computing 2 ** n.
///
/// # Accruacy:
///
/// 1 ulp (unit in the last place).
pub fn scalbnf(x : Float, n : Int) -> Float {
  let mut y = x
  let mut n = n
  if n > 127 {
    y *= (0x1.0p127 : Float)
    n -= 127
    if n > 127 {
      y *= (0x1.0p127 : Float)
      n -= 127
      if n > 127 {
        n = 127
      }
    }
  } else if n < -126 {
    y *= (0x1.0p-126 : Float) * 0x1.0p24
    n += 126 - 24
    if n < -126 {
      y *= (0x1.0p-126 : Float) * 0x1.0p24
      n += 126 - 24
      if n < -126 {
        n = -126
      }
    }
  }
  let u = (0x7f + n) << 23
  let x = y * u.reinterpret_as_float()
  return x
}

///|
test "scalbnf" {
  fn assert_scalbnf_ulp(input1, input2, expect) raise {
    assert_float_ulp(expect, scalbnf(input1, input2), SCALBN_F_MAX_ULP)
  }

  assert_scalbnf_ulp(1, 1, 2)
  assert_scalbnf_ulp(3, 5, 96)
  assert_scalbnf_ulp(-2, 1, -4)
  assert_scalbnf_ulp(-5, 3, -40)
  assert_scalbnf_ulp(9, 6, 576)
  assert_scalbnf_ulp(7, 11, 14336)
  assert_scalbnf_ulp(6.5, -3, 0.8125)
  assert_scalbnf_ulp(-7.25, 8, -1856)
  assert_scalbnf_ulp(-52.5, -625, 0)
  assert_scalbnf_ulp(12, 13, 98304)
  assert_scalbnf_ulp(7, 16, 458752)
  assert_scalbnf_ulp(19, 33, 163208757248)
  assert_scalbnf_ulp(@float.infinity, 11, @float.infinity)
  assert_scalbnf_ulp(@float.neg_infinity, 11, @float.neg_infinity)
  assert_scalbnf_ulp(@float.not_a_number, 0, @float.not_a_number)
}
