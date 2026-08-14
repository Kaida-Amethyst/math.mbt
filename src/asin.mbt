// Derived from FreeBSD msun / fdlibm e_asin.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunSoft, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns the arcsine of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Inputs outside `[-1.0, 1.0]`, including both infinities, produce NaN.
/// - Positive and negative zero are returned unchanged.
/// - Inputs `1.0` and `-1.0` produce positive and negative π/2.
/// - Subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in `[-1.0, 1.0]`, the result is within 1 ULP of the
/// exact arcsine rounded to binary64 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 35,303-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every signed exponent boundary, the domain endpoints, all
/// implementation transitions, and fixed-seed stratified inputs. Its observed
/// maximum error is 1 ULP; input `0xbfef3333000fcd4d` is retained as a witness.
/// An enlarged 146,463-case native audit also stays within the bound. The fixed
/// corpus checks monotonicity and bit-exact odd symmetry over the real domain in
/// debug and release mode on wasm, wasm-gc, JavaScript, and native. This is
/// testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/asin/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The endpoint reduction and rational approximation are derived from
///   FreeBSD msun
///   [`e_asin.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_asin.c)
///   distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(asin(0.0), 0.0)
///   assert_eq(asin(1.0).reinterpret_as_uint64(), 0x3ff921fb54442d18UL)
/// }
/// ```
pub fn asin(input : Double) -> Double {
  let pi_over_four_high = 7.85398163397448278999e-01
  let pi_over_two_high = 1.57079632679489655800e+00
  let pi_over_two_low = 6.12323399573676603587e-17
  let numerator_coefficients : ReadOnlyArray[Double] = [
    1.66666666666666657415e-01, -3.25565818622400915405e-01, 2.01212532134862925881e-01,
    -4.00555345006794114027e-02, 7.91534994289814532176e-04, 3.47933107596021167570e-05,
  ]
  let denominator_coefficients : ReadOnlyArray[Double] = [
    -2.40339491173441421878e+00, 2.02094576023350569471e+00, -6.88283971605453293030e-01,
    7.70381505559019352791e-02,
  ]
  fn rational(square : Double) -> Double {
    let numerator = square *
      (
        numerator_coefficients[0] +
        square *
        (
          numerator_coefficients[1] +
          square *
          (
            numerator_coefficients[2] +
            square *
            (
              numerator_coefficients[3] +
              square *
              (numerator_coefficients[4] + square * numerator_coefficients[5])
            )
          )
        )
      )
    let denominator = 1.0 +
      square *
      (
        denominator_coefficients[0] +
        square *
        (
          denominator_coefficients[1] +
          square *
          (denominator_coefficients[2] + square * denominator_coefficients[3])
        )
      )
    numerator / denominator
  }

  let raw_bits = input.reinterpret_as_uint64()
  let magnitude = raw_bits & 0x7fffffffffffffffUL
  if magnitude >= 0x3ff0000000000000UL {
    if magnitude == 0x3ff0000000000000UL {
      return input * pi_over_two_high + input * pi_over_two_low
    }
    return @double.not_a_number
  }
  if magnitude < 0x3fe0000000000000UL {
    if magnitude < 0x3e50000000000000UL {
      return input
    }
    let square = input * input
    return input + input * rational(square)
  }
  let half_distance = (1.0 - input.abs()) * 0.5
  let root = sqrt(half_distance)
  let correction = rational(half_distance)
  let result = if magnitude >= 0x3fef333300000000UL {
    pi_over_two_high - (2.0 * (root + root * correction) - pi_over_two_low)
  } else {
    let root_high = @fpbits.from_words(@fpbits.high_word(root), 0U)
    let root_low = (half_distance - root_high * root_high) / (root + root_high)
    let polynomial = 2.0 * root * correction -
      (pi_over_two_low - 2.0 * root_low)
    let reduced = pi_over_four_high - 2.0 * root_high
    pi_over_four_high - (polynomial - reduced)
  }
  if raw_bits >> 63 != 0UL {
    -result
  } else {
    result
  }
}

///|
test "asin handles its domain, endpoints, and signed zero" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(asin(positive_zero).reinterpret_as_uint64(), 0x0000000000000000UL)
  assert_eq(asin(negative_zero).reinterpret_as_uint64(), 0x8000000000000000UL)
  assert_eq(asin(1.0).reinterpret_as_uint64(), 0x3ff921fb54442d18UL)
  assert_eq(asin(-1.0).reinterpret_as_uint64(), 0xbff921fb54442d18UL)
  assert_true(asin(0x3ff0000000000001UL.reinterpret_as_double()).is_nan())
  assert_true(asin(0xbff0000000000001UL.reinterpret_as_double()).is_nan())
  assert_true(asin(@double.infinity).is_nan())
  assert_true(asin(@double.neg_infinity).is_nan())
  assert_true(asin(quiet_nan).is_nan())
}

///|
test "asin preserves tiny inputs and covers reduction transitions" {
  let tiny_positive = 0x3e4fffffffffffffUL.reinterpret_as_double()
  let tiny_negative = 0xbe4fffffffffffffUL.reinterpret_as_double()
  assert_eq(asin(tiny_positive).reinterpret_as_uint64(), 0x3e4fffffffffffffUL)
  assert_eq(asin(tiny_negative).reinterpret_as_uint64(), 0xbe4fffffffffffffUL)
  assert_eq(asin(0.5).reinterpret_as_uint64(), 0x3fe0c152382d7366UL)
  assert_eq(asin(-0.5).reinterpret_as_uint64(), 0xbfe0c152382d7366UL)
}
