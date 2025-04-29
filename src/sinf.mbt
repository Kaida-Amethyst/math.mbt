///|
pub fn sinf(x : Float) -> Float {
  if x.is_nan() || x.is_inf() {
    return @float.not_a_number
  }
  if x == 0.0 {
    return x
  }
  let (x, q) = trig_reduce(x, SIN_SWITCHOVER)
  sin_cos_core(x, q)
}

///|
//test "sinf" {
//  fn assert_sinf_ulp!(input, expect) {
//    assert_float_ulp!(expect, sinf(input), SIN_F_MAX_ULP)
//  }
//
//  assert_sinf_ulp!(-1, @float.neg_infinity)
//  assert_sinf_ulp!(1, 0.8414709568023682)
//  assert_sinf_ulp!(8, 0.9893582463264465)
//  assert_sinf_ulp!(-8, @float.neg_infinity)
//  assert_sinf_ulp!(0, 0)
//  assert_sinf_ulp!(27, 0.9563759565353394)
//  assert_sinf_ulp!(-27, @float.neg_infinity)
//  assert_sinf_ulp!(0.125, 0.1246747300028801)
//  assert_sinf_ulp!(-0.125, -0.1246747300028801)
//  assert_sinf_ulp!(0.5, 0.4794255495071411)
//  assert_sinf_ulp!(-0.5, -0.4794255495071411)
//  assert_sinf_ulp!(1.5, 0.9974949955940247)
//  assert_sinf_ulp!(-1.5, @float.neg_infinity)
//  assert_sinf_ulp!(2, 0.9092974066734314)
//  assert_sinf_ulp!(-2, @float.neg_infinity)
//  assert_sinf_ulp!(3, 0.14112000167369843)
//  assert_sinf_ulp!(-3, @float.neg_infinity)
//  assert_sinf_ulp!(64, 0.9200260639190674)
//  assert_sinf_ulp!(-64, @float.neg_infinity)
//  assert_sinf_ulp!(1000, 0.8268795013427734)
//  assert_sinf_ulp!(-1000, -0.8268795013427734)
//  assert_sinf_ulp!(512, 0.07951848953962326)
//  assert_sinf_ulp!(729, 0.14993681013584137)
//  assert_sinf_ulp!(3511808, -0.5998656749725342)
//  assert_sinf_ulp!(15.25, 0.4421221613883972)
//  assert_sinf_ulp!(6859, -0.7853350639343262)
//  assert_sinf_ulp!(68.25, -0.7611201405525208)
//  assert_sinf_ulp!(701.625, -0.8673427104949951)
//  assert_sinf_ulp!(@float.not_a_number, @float.not_a_number)
//  assert_sinf_ulp!(@float.infinity, @float.not_a_number)
//  assert_sinf_ulp!(@float.neg_infinity, @float.not_a_number)
//}
