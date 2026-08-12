///|
test "nearbyint" {
  assert_eq(nearbyint(2.5), 2.0)
  assert_eq(nearbyint(2.5, round_mode=FE_DOWNWARD), 2.0)
  assert_eq(nearbyint(2.5, round_mode=FE_UPWARD), 3.0)
  assert_eq(nearbyint(2.5, round_mode=FE_TOWARDZERO), 2.0)
}
