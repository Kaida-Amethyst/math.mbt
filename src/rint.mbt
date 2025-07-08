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
/// assert_eq(rint(2.5), 2)
/// assert_eq(rint(2.5, round_mode=FE_DOWNWARD), 2.0)
/// assert_eq(rint(2.5, round_mode=FE_UPWARD), 3.0)
/// assert_eq(rint(2.5, round_mode=FE_TOWARDZERO), 2.0)
/// ```
///
/// # Note
///
/// It is equivalent to `nearbyint` function. Note that it's different with C-like languages.
pub fn rint(x : Double, round_mode~ : RoundMode = FE_TONEAREST) -> Double {
  nearbyint(x, round_mode~)
}
