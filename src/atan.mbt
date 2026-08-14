// Derived from FreeBSD msun / fdlibm s_atan.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns the arctangent of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce positive and negative π/2.
/// - Positive and negative zero are returned unchanged.
/// - Every finite input is in the real domain; subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact arctangent
/// rounded to binary64 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 35,875-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, signed exponent boundaries, every implementation
/// transition, and fixed-seed stratified inputs. Its observed maximum error is
/// 1 ULP; `atan(-228.0)` is retained as a witness. An enlarged 147,109-case
/// native audit also stays within the bound. The fixed corpus checks
/// monotonicity and bit-exact odd symmetry in debug and release mode on wasm,
/// wasm-gc, JavaScript, and native. This is testing evidence, not a formal
/// proof. See the
/// [oracle documentation](../tools/oracle/atan/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and polynomial approximation are derived from the
///   FreeBSD msun
///   [`s_atan.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_atan.c)
///   implementation distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(atan(0.0), 0.0)
///   assert_eq(atan(1.0).reinterpret_as_uint64(), 0x3fe921fb54442d18UL)
/// }
/// ```
pub fn atan(input : Double) -> Double {
  let atan_high : ReadOnlyArray[Double] = [
    4.63647609000806093515e-01, 7.85398163397448278999e-01, 9.82793723247329054082e-01,
    1.57079632679489655800e+00,
  ]
  let atan_low : ReadOnlyArray[Double] = [
    2.26987774529616870924e-17, 3.06161699786838301793e-17, 1.39033110312309984516e-17,
    6.12323399573676603587e-17,
  ]
  let coefficients : ReadOnlyArray[Double] = [
    3.33333333333329318027e-01, -1.99999999998764832476e-01, 1.42857142725034663711e-01,
    -1.11111104054623557880e-01, 9.09088713343650656196e-02, -7.69187620504482999495e-02,
    6.66107313738753120669e-02, -5.83357013379057348645e-02, 4.97687799461593236017e-02,
    -3.65315727442169155270e-02, 1.62858201153657823623e-02,
  ]
  let high_word = @fpbits.high_word(input).reinterpret_as_int()
  let sign = high_word >> 31
  let magnitude = high_word & 0x7fffffff
  let mut reduction = 0
  let mut x = input
  if magnitude >= 0x44100000 {
    if x.is_nan() {
      return x
    }
    let result = atan_high[3] + atan_low[3]
    return if sign != 0 { -result } else { result }
  }
  if magnitude < 0x3fdc0000 {
    if magnitude < 0x3e400000 {
      return x
    }
    reduction = -1
  } else {
    x = x.abs()
    if magnitude < 0x3ff30000 {
      if magnitude < 0x3fe60000 {
        reduction = 0
        x = (2.0 * x - 1.0) / (2.0 + x)
      } else {
        reduction = 1
        x = (x - 1.0) / (x + 1.0)
      }
    } else if magnitude < 0x40038000 {
      reduction = 2
      x = (x - 1.5) / (1.0 + 1.5 * x)
    } else {
      reduction = 3
      x = -1.0 / x
    }
  }
  let square = x * x
  let fourth_power = square * square
  let odd_terms = square *
    (
      coefficients[0] +
      fourth_power *
      (
        coefficients[2] +
        fourth_power *
        (
          coefficients[4] +
          fourth_power *
          (
            coefficients[6] +
            fourth_power * (coefficients[8] + fourth_power * coefficients[10])
          )
        )
      )
    )
  let even_terms = fourth_power *
    (
      coefficients[1] +
      fourth_power *
      (
        coefficients[3] +
        fourth_power *
        (
          coefficients[5] +
          fourth_power * (coefficients[7] + fourth_power * coefficients[9])
        )
      )
    )
  if reduction < 0 {
    return x - x * (odd_terms + even_terms)
  }
  let result = atan_high[reduction] -
    (x * (odd_terms + even_terms) - atan_low[reduction] - x)
  if sign != 0 {
    -result
  } else {
    result
  }
}

///|
test "atan handles IEEE 754 special values and signed zero" {
  let positive_zero = 0x00000000_00000000UL.reinterpret_as_double()
  let negative_zero = 0x80000000_00000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff80000_00000001UL.reinterpret_as_double()
  assert_eq(atan(positive_zero).reinterpret_as_uint64(), 0x00000000_00000000UL)
  assert_eq(atan(negative_zero).reinterpret_as_uint64(), 0x80000000_00000000UL)
  assert_eq(
    atan(@double.infinity).reinterpret_as_uint64(),
    0x3ff921fb_54442d18UL,
  )
  assert_eq(
    atan(@double.neg_infinity).reinterpret_as_uint64(),
    0xbff921fb_54442d18UL,
  )
  assert_true(atan(quiet_nan).is_nan())
}

///|
test "atan preserves tiny inputs and representative exact results" {
  let tiny_positive = 0x3e3fffff_ffffffffUL.reinterpret_as_double()
  let tiny_negative = 0xbe3fffff_ffffffffUL.reinterpret_as_double()
  assert_eq(
    atan(tiny_positive).reinterpret_as_uint64(),
    tiny_positive.reinterpret_as_uint64(),
  )
  assert_eq(
    atan(tiny_negative).reinterpret_as_uint64(),
    tiny_negative.reinterpret_as_uint64(),
  )
  assert_eq(atan(1.0).reinterpret_as_uint64(), 0x3fe921fb_54442d18UL)
  assert_eq(atan(-1.0).reinterpret_as_uint64(), 0xbfe921fb_54442d18UL)
}
