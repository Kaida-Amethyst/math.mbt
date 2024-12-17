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
/// rint(2.5) // Returns 2.0 (FE_TONEAREST mode)
/// rint(2.5, FE_DOWNWARD) // Returns 2.0 (FE_DOWNWARD mode)
/// rint(2.5, FE_UPWARD) // Returns 3.0 (FE_UPWARD mode)
/// rint(2.5, FE_TOWARDZERO) // Returns 2.0 (FE_TOWARDZERO mode)
/// ```
///
/// # Note
///
/// It is equivalent to `nearbyint` function. Note that it's different with C-like languages.
pub fn rint(x : Double, round_mode~: RoundMode = FE_TONEAREST) -> Double {
  nearbyint(x, round_mode~)
}
