///|
/// Returns the real cube root of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity are returned unchanged.
/// - Positive and negative zero are returned unchanged.
/// - Every nonzero finite input produces a finite result with the same sign.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact real cube
/// root rounded to binary32 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 20,525-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, exact cubes, implementation
/// branches, and fixed-seed stratified inputs. Its maximum observed error is
/// 0 ULP. The corpus passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native; MoonBit Core is checked against the same bound. This
/// is testing evidence, not a formal proof or a correct-rounding claim. See the
/// [oracle documentation](../tools/oracle/cbrtf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The initial approximation and two Halley iterations are derived from the
///   FreeBSD msun
///   [`s_cbrtf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_cbrtf.c)
///   implementation distributed by OpenLibm.
/// - The public behavior is compatible with
///   [MoonBit Core `math.cbrtf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/algebraic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(cbrtf(27.0), 3.0)
///   assert_eq(cbrtf(-8.0), -2.0)
/// }
/// ```
pub fn cbrtf(input : Float) -> Float {
  let b1 : UInt = 709958130
  let b2 : UInt = 642849266
  let mut bits = input.reinterpret_as_uint()
  let mut magnitude = bits & 0x7fffffff
  if magnitude >= 0x7f800000 {
    return input + input
  }
  if magnitude < 0x00800000 {
    if magnitude == 0 {
      return input
    }
    bits = (input * (0x1.0p24 : Float)).reinterpret_as_uint()
    magnitude = (bits & 0x7fffffff) / 3 + b2
  } else {
    magnitude = magnitude / 3 + b1
  }
  bits = (bits & 0x80000000) | magnitude
  let x = input.to_double()
  let estimate = Float::reinterpret_from_uint(bits).to_double()
  let cube = estimate * estimate * estimate
  let estimate = estimate * (x + x + cube) / (x + cube + cube)
  let cube = estimate * estimate * estimate
  let estimate = estimate * (x + x + cube) / (x + cube + cube)
  Float::from_double(estimate)
}

///|
test "cbrtf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(cbrtf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(cbrtf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(cbrtf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(cbrtf(@float.neg_infinity).reinterpret_as_uint(), 0xff800000U)
  assert_true(cbrtf(quiet_nan).is_nan())
  assert_true(cbrtf(signaling_nan).is_nan())
}

///|
test "cbrtf returns exact representable integer roots" {
  let cases : Array[(Float, Float)] = [
    (-1000.0, -10.0),
    (-8.0, -2.0),
    (-1.0, -1.0),
    (1.0, 1.0),
    (8.0, 2.0),
    (27.0, 3.0),
    (1000.0, 10.0),
  ]
  for pair in cases {
    let (input, expected) = pair
    assert_eq(
      cbrtf(input).reinterpret_as_uint(),
      expected.reinterpret_as_uint(),
    )
  }
}
