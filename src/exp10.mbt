///| Compute 10 raised to the power of x.
///
/// # Examples
///
/// ```moonbit
/// assert_eq(exp10(-1), 0.1);
/// assert_eq(exp10(-2), 0.01);
/// assert_eq(exp10(0), 1.0);
/// assert_eq(exp10(1), 10.0);
/// assert_eq(exp10(2), 100.0);
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place)
///
/// # Special Cases
///
/// 1. exp10(NaN) = NaN
/// 2. exp10(+Inf) = +Inf
/// 3. exp10(-Inf) = 0
pub fn exp10(x : Double) -> Double {
  pow(10.0, x)
}

///|
test "exp10" {
  fn assert_exp10_ulp(input, expect) raise {
    assert_ulp(expect, exp10(input), EXP10_MAX_ULP)
  }

  assert_exp10_ulp(-1, 0.1)
  assert_exp10_ulp(-2, 0.01)
  assert_exp10_ulp(-3, 0.001)
  assert_exp10_ulp(-4, 0.0001)
  assert_exp10_ulp(-5, 0.00001)
  assert_exp10_ulp(-6, 0.000001)
  assert_exp10_ulp(-7, 0.0000001)
  assert_exp10_ulp(-8, 0.00000001)
  assert_exp10_ulp(-9, 0.000000001)
  assert_exp10_ulp(1, 10)
  assert_exp10_ulp(2, 100)
  assert_exp10_ulp(3, 1000)
  assert_exp10_ulp(4, 10000)
  assert_exp10_ulp(5, 100000)
  assert_exp10_ulp(6, 1000000)
  assert_exp10_ulp(7, 10000000)
  assert_exp10_ulp(8, 100000000)
  assert_exp10_ulp(9, 1000000000)
  assert_exp10_ulp(10, 10000000000)
  assert_exp10_ulp(1000, @double.infinity)
  assert_exp10_ulp(10000, @double.infinity)
  assert_exp10_ulp(2.5, 316.22776601683796)
  assert_exp10_ulp(3.4, 2511.88643150958)
  assert_exp10_ulp(5.3, 199526.2314968879)
  assert_exp10_ulp(6.2, 1584893.1924611141)
  assert_exp10_ulp(7.1, 12589254.117941663)
  assert_exp10_ulp(8.9, 794328234.7242821)
  assert_exp10_ulp(9.8, 6309573444.801943)
  assert_exp10_ulp(10.7, 50118723362.72715)
  assert_exp10_ulp(1.542, 34.83373150360118)
  assert_exp10_ulp(2.846, 701.4552984199714)
  assert_exp10_ulp(7.881, 76032627.69401823)
  assert_exp10_ulp(3.772, 5915.616341754737)
  assert_exp10_ulp(-1.542, 0.028707805820246905)
  assert_exp10_ulp(-2.846, 0.001425607593602188)
  assert_exp10_ulp(-7.881, 0.000000013152248321922376)
  assert_exp10_ulp(-3.772, 0.0001690440931643265)
  assert_exp10_ulp(-1, 0.1)
  assert_exp10_ulp(0, 1)
  assert_exp10_ulp(-0, 1)
  assert_exp10_ulp(@double.not_a_number, @double.not_a_number)
  assert_exp10_ulp(@double.infinity, @double.infinity)
  assert_exp10_ulp(@double.neg_infinity, 0)
}
