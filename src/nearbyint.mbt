///|
pub(all) enum RoundMode {
  FE_TONEAREST
  FE_DOWNWARD
  FE_UPWARD
  FE_TOWARDZERO
}

///| Rounds the input floating-point number to the nearest integer according to the specified rounding mode.
///
/// # Arguments
/// - `x`: The floating-point number to be rounded.
/// - `round_mode`: The rounding mode to use. Defaults to `FE_TONEAREST` (round to nearest, ties to even).
///
/// # Rounding Modes
/// - `FE_TONEAREST`: Rounds to the nearest integer. If the value is exactly halfway between two integers,
///   it rounds to the nearest even integer. This is the default behavior.
/// - `FE_DOWNWARD`: Rounds towards negative infinity (equivalent to `floor`).
/// - `FE_UPWARD`: Rounds towards positive infinity (equivalent to `ceil`).
/// - `FE_TOWARDZERO`: Rounds towards zero (equivalent to `trunc`).
///
/// # Returns
/// The rounded floating-point number.
///
/// # Example
/// ```
/// assert_eq!(nearbyint(2.5), 2.0)
/// assert_eq!(nearbyint(2.5, round_mode=FE_DOWNWARD), 2.0)
/// assert_eq!(nearbyint(2.5, round_mode=FE_UPWARD), 3.0)
/// assert_eq!(nearbyint(2.5, round_mode=FE_TOWARDZERO), 2.0)
/// ```
///
/// # Note
///
/// It is equivalent to `rint` function. Note that it's different with C-like languages.
pub fn nearbyint(x : Double, round_mode~ : RoundMode = FE_TONEAREST) -> Double {
  match round_mode {
    FE_TONEAREST => roundeven(x)
    FE_DOWNWARD => floor(x)
    FE_UPWARD => ceil(x)
    FE_TOWARDZERO => trunc(x)
  }
}

test "nearbyint" {
  assert_eq!(nearbyint(2.5), 2.0)
  assert_eq!(nearbyint(2.5, round_mode=FE_DOWNWARD), 2.0)
  assert_eq!(nearbyint(2.5, round_mode=FE_UPWARD), 3.0)
  assert_eq!(nearbyint(2.5, round_mode=FE_TOWARDZERO), 2.0)
}
