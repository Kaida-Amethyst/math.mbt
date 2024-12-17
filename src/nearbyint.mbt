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
/// nearbyint(2.5) // Returns 2.0 (FE_TONEAREST mode)
/// nearbyint(2.5, FE_DOWNWARD) // Returns 2.0 (FE_DOWNWARD mode)
/// nearbyint(2.5, FE_UPWARD) // Returns 3.0 (FE_UPWARD mode)
/// nearbyint(2.5, FE_TOWARDZERO) // Returns 2.0 (FE_TOWARDZERO mode)
/// ```
///
/// # Note
///
/// It is equivalent to `rint` function. Note that it's different with C-like languages.
pub fn nearbyint(x : Double, round_mode~: RoundMode = FE_TONEAREST) -> Double {
  match round_mode {
    FE_TONEAREST => roundeven(x)
    FE_DOWNWARD => floor(x)
    FE_UPWARD => ceil(x)
    FE_TOWARDZERO => trunc(x)
  }
}
