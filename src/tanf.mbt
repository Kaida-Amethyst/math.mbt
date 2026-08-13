///|
fn tanf_poly(input : Float, reciprocal_branch : Bool) -> Float {
  let x = input.to_double()
  let coefficients : FixedArray[Double] = [
    0.333331395030791399758, 0.133392002712976742718, 0.0533812378445670393523, 0.0245283181166547278873,
    0.00297435743359967304927, 0.00946564784943673166728,
  ]
  let square = x * x
  let mut high_order = coefficients[4] + square * coefficients[5]
  let middle = coefficients[2] + square * coefficients[3]
  let fourth_power = square * square
  let cube = square * x
  let low_order = coefficients[0] + square * coefficients[1]
  high_order = x +
    cube * low_order +
    cube * fourth_power * (middle + fourth_power * high_order)
  Float::from_double(
    if reciprocal_branch {
      -1.0 / high_order
    } else {
      high_order
    },
  )
}

///|
/// Returns the tangent of `input` radians as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce NaN.
/// - Positive and negative zero are returned unchanged.
/// - Subnormal inputs are supported. Since no binary32 value is an exact odd
///   multiple of π/2, every finite binary32 input has a finite mathematical
///   tangent.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact tangent
/// rounded to binary32 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 28,972-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, neighborhoods of the poles,
/// quadrant landmarks, the range reduction transition at `142.90625`, and
/// fixed-seed stratified inputs. An enlarged 171,784-case audit also passed in
/// native debug and release mode. The fixed corpus checks bit-exact odd symmetry
/// and passes in debug and release mode on wasm, wasm-gc, JavaScript, and native,
/// with a maximum observed error of 2 ULP; MoonBit Core is checked against the
/// same independent reference. This is testing evidence, not a formal proof.
/// See the [oracle documentation](../tools/oracle/tanf/README.md) for the corpus
/// design, maximum-error witness, and reproduction commands.
///
/// ## References
///
/// - The reduced-interval polynomial is derived from FreeBSD msun
///   [`k_tanf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/k_tanf.c)
///   as distributed by OpenLibm.
/// - The public behavior and implementation structure are compatible with
///   [MoonBit Core `math.tanf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Reference results are generated independently with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(tanf(0.0), 0.0)
///   assert_eq(tanf(1.0).reinterpret_as_uint(), 0x3fc75923U)
/// }
/// ```
pub fn tanf(input : Float) -> Float {
  if input.is_nan() || input.is_inf() {
    return @float.not_a_number
  }
  if input == 0.0 {
    return input
  }
  let (reduced, quadrant) = trig_reduce(input, COS_SWITCHOVER)
  tanf_poly(reduced, (quadrant & 1) != 0)
}

///|
test "tanf handles non-finite values and signed zero" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(tanf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(tanf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_true(tanf(@float.infinity).is_nan())
  assert_true(tanf(@float.neg_infinity).is_nan())
  assert_true(tanf(quiet_nan).is_nan())
}

///|
test "tanf covers poles, range reduction, and its 2 ULP witness" {
  assert_eq(tanf(1.0).reinterpret_as_uint(), 0x3fc75923U)
  assert_eq(
    tanf(Float::reinterpret_from_uint(0x3fc90fdbU)).reinterpret_as_uint(),
    0xcbae8a4bU,
  )
  assert_eq(
    tanf(Float::reinterpret_from_uint(0x430ee800U)).reinterpret_as_uint(),
    0x41dccd47U,
  )
  assert_eq(
    tanf(Float::reinterpret_from_uint(0xfd000002U)).reinterpret_as_uint(),
    0xbfe6c2d1U,
  )
}
