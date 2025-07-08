///| Compute Square Root of a number
///
/// # Examples
///
/// ```moonbit
/// assert_eq(sqrt(0), 0);
/// assert_eq(sqrt(1), 1);
/// assert_eq(sqrt(2), 1.4142135623730951);
/// assert_eq(sqrt(3), 1.7320508075688772);
/// ```
///
/// # Special Cases
///
/// 1. sqrt(NaN) = NaN
/// 2. sqrt(x) = NaN if x < 0
/// 3. sqrt(+inf) = +inf
/// 4. sqrt(-inf) = NaN
///
/// # Accuracy
///
/// 0 ulp.
pub fn sqrt(x : Double) -> Double {
  x.sqrt()
}

///|
test "sqrt" {
  fn assert_sqrt_ulp(input, expect) raise {
    assert_ulp(expect, sqrt(input), SQRT_MAX_ULP)
  }

  assert_sqrt_ulp(-0.8, @double.not_a_number)
  assert_sqrt_ulp(-0.7, @double.not_a_number)
  assert_sqrt_ulp(-0, -0)
  assert_sqrt_ulp(-0.7853981633974483, @double.not_a_number)
  assert_sqrt_ulp(0, 0)
  assert_sqrt_ulp(0.1, 0.31622776601683794)
  assert_sqrt_ulp(0.2, 0.4472135954999579)
  assert_sqrt_ulp(0.3, 0.5477225575051661)
  assert_sqrt_ulp(0.4, 0.6324555320336759)
  assert_sqrt_ulp(0.5, 0.7071067811865476)
  assert_sqrt_ulp(0.6, 0.7745966692414834)
  assert_sqrt_ulp(0.7, 0.8366600265340756)
  assert_sqrt_ulp(0.8, 0.8944271909999159)
  assert_sqrt_ulp(0.9, 0.9486832980505138)
  assert_sqrt_ulp(1, 1)
  assert_sqrt_ulp(3.141592653589793, 1.7724538509055159)
  assert_sqrt_ulp(1.5707963267948966, 1.2533141373155001)
  assert_sqrt_ulp(0.7853981633974483, 0.8862269254527579)
  assert_sqrt_ulp(-1, @double.not_a_number)
  assert_sqrt_ulp(-2, @double.not_a_number)
  assert_sqrt_ulp(-3, @double.not_a_number)
  assert_sqrt_ulp(-4, @double.not_a_number)
  assert_sqrt_ulp(-5, @double.not_a_number)
  assert_sqrt_ulp(-6, @double.not_a_number)
  assert_sqrt_ulp(-7, @double.not_a_number)
  assert_sqrt_ulp(-8, @double.not_a_number)
  assert_sqrt_ulp(-9, @double.not_a_number)
  assert_sqrt_ulp(1, 1)
  assert_sqrt_ulp(2, 1.4142135623730951)
  assert_sqrt_ulp(3, 1.7320508075688772)
  assert_sqrt_ulp(4, 2)
  assert_sqrt_ulp(5, 2.23606797749979)
  assert_sqrt_ulp(6, 2.449489742783178)
  assert_sqrt_ulp(7, 2.6457513110645907)
  assert_sqrt_ulp(8, 2.8284271247461903)
  assert_sqrt_ulp(9, 3)
  assert_sqrt_ulp(10, 3.1622776601683795)
  assert_sqrt_ulp(100, 10)
  assert_sqrt_ulp(1000, 31.622776601683793)
  assert_sqrt_ulp(10000, 100)
  assert_sqrt_ulp(2.5, 1.5811388300841898)
  assert_sqrt_ulp(3.4, 1.8439088914585775)
  assert_sqrt_ulp(5.3, 2.3021728866442674)
  assert_sqrt_ulp(6.2, 2.4899799195977463)
  assert_sqrt_ulp(7.1, 2.6645825188948455)
  assert_sqrt_ulp(8.9, 2.9832867780352594)
  assert_sqrt_ulp(9.8, 3.1304951684997055)
  assert_sqrt_ulp(10.7, 3.271085446759225)
  assert_sqrt_ulp(101.6, 10.079682534683322)
  assert_sqrt_ulp(1.542, 1.241772926102031)
  assert_sqrt_ulp(2.846, 1.6870091878825082)
  assert_sqrt_ulp(7.881, 2.8073118814980282)
  assert_sqrt_ulp(3.772, 1.9421637418096342)
  assert_sqrt_ulp(0, 0)
  assert_sqrt_ulp(-0, -0)
  assert_sqrt_ulp(@double.not_a_number, @double.not_a_number)
  assert_sqrt_ulp(@double.infinity, @double.infinity)
  assert_sqrt_ulp(@double.neg_infinity, @double.not_a_number)
}
