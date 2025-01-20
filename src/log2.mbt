///| Compute the base-2 logarithm of a number.
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(log2(0.1), -3.321928094887362)
/// assert_eq!(log2(1), 0)
/// assert_eq!(log2(2), 1)
/// assert_eq!(log2(3), 1.584962500721156)
/// ```
///
/// # Special Cases:
///
/// 1. log2(x) = NaN for all x < 0 (including -inf).
/// 2. log2(inf) = +inf.
/// 3. log2(0) = -inf
///
/// # Accuracy
///
/// 1 ulp.
pub fn log2(x : Double) -> Double {
  x.log2()
}

test "log2" {
  fn assert_log2_ulp!(input, expect) {
    assert_ulp!(expect, log2(input), LOG2_MAX_ULP)
  }

  assert_log2_ulp!(-0.8, double_nan)
  assert_log2_ulp!(-3.141592653589793, double_nan)
  assert_log2_ulp!(-1.5707963267948966, double_nan)
  assert_log2_ulp!(-0.7853981633974483, double_nan)
  assert_log2_ulp!(0, double_neg_inf)
  assert_log2_ulp!(0.1, -3.321928094887362)
  assert_log2_ulp!(0.2, -2.321928094887362)
  assert_log2_ulp!(0.3, -1.7369655941662063) // <- ulp = 1
  assert_log2_ulp!(0.4, -1.3219280948873622)
  assert_log2_ulp!(0.5, -1)
  assert_log2_ulp!(0.6, -0.7369655941662062)
  assert_log2_ulp!(0.7, -0.5145731728297583)
  assert_log2_ulp!(0.8, -0.3219280948873623)
  assert_log2_ulp!(0.9, -0.15200309344504995) // <- ulp = 1
  assert_log2_ulp!(1, 0)
  assert_log2_ulp!(3.141592653589793, 1.6514961294723187)
  assert_log2_ulp!(1.5707963267948966, 0.6514961294723187)
  assert_log2_ulp!(0.7853981633974483, -0.3485038705276813)
  assert_log2_ulp!(-1, double_nan)
  assert_log2_ulp!(1, 0)
  assert_log2_ulp!(2, 1)
  assert_log2_ulp!(3, 1.584962500721156)
  assert_log2_ulp!(4, 2)
  assert_log2_ulp!(5, 2.321928094887362)
  assert_log2_ulp!(6, 2.584962500721156)
  assert_log2_ulp!(7, 2.807354922057604)
  assert_log2_ulp!(8, 3)
  assert_log2_ulp!(9, 3.169925001442312)
  assert_log2_ulp!(10, 3.321928094887362)
  assert_log2_ulp!(11, 3.4594316186372973)
  assert_log2_ulp!(12, 3.584962500721156)
  assert_log2_ulp!(13, 3.700439718141092)
  assert_log2_ulp!(14, 3.807354922057604)
  assert_log2_ulp!(15, 3.9068905956085187)
  assert_log2_ulp!(16, 4)
  assert_log2_ulp!(17, 4.087462841250339)
  assert_log2_ulp!(18, 4.169925001442312)
  assert_log2_ulp!(19, 4.247927513443585)
  assert_log2_ulp!(20, 4.321928094887363)
  assert_log2_ulp!(21, 4.392317422778761) // <- ulp = 1
  assert_log2_ulp!(22, 4.459431618637297)
  assert_log2_ulp!(23, 4.523561956057013)
  assert_log2_ulp!(24, 4.584962500721156)
  assert_log2_ulp!(25, 4.643856189774724)
  assert_log2_ulp!(100, 6.643856189774724)
  assert_log2_ulp!(1000, 9.965784284662087)
  assert_log2_ulp!(10000, 13.287712379549449)
  assert_log2_ulp!(2.5, 1.3219280948873624) // <- ulp = 1
  assert_log2_ulp!(3.4, 1.765534746362977)
  assert_log2_ulp!(5.3, 2.4059923596758366) // <- ulp = 1
  assert_log2_ulp!(6.2, 2.6322682154995127)
  assert_log2_ulp!(7.1, 2.8278190246173196)
  assert_log2_ulp!(8.9, 3.1538053360790355)
  assert_log2_ulp!(9.8, 3.292781749227846) // <- ulp = 1
  assert_log2_ulp!(10.7, 3.4195388915137843)
  assert_log2_ulp!(101.6, 6.666756591884804)
  assert_log2_ulp!(1.542, 0.6248027652529473)
  assert_log2_ulp!(2.846, 1.5089356618643954)
  assert_log2_ulp!(7.881, 2.978378701192701)
  assert_log2_ulp!(3.772, 1.9153296760130094)
  assert_log2_ulp!(242.58711268945123, 7.922359099866835)
  assert_log2_ulp!(21456.774415889613, 14.389145592458236)
  assert_log2_ulp!(1123.5582229412541, 10.13385917177197)
  assert_log2_ulp!(-1.542, double_nan)
  assert_log2_ulp!(0, double_neg_inf)
  assert_log2_ulp!(-0, double_neg_inf)
  assert_log2_ulp!(double_nan, double_nan)
  assert_log2_ulp!(double_pos_inf, double_pos_inf)
  // assert_log2_ulp!(double_neg_inf, double_nan)
}
