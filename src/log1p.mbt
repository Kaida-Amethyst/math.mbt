// Derived from FreeBSD msun / fdlibm s_log1p.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns `log(1 + input)` as an IEEE 754 binary64 value, retaining accuracy
/// when `input` is close to zero. The same function is also exported as
/// `ln_1p` for compatibility with MoonBit Core.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity or a finite input below `-1.0` produces NaN.
/// - An input of exactly `-1.0` produces negative infinity.
/// - Positive and negative zero are returned unchanged.
/// - Subnormal inputs are supported and retain their sign.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in the real domain, the result is within 1 ULP of
/// the exact value rounded to binary64 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A fixed corpus of 75,772 inputs generated with an independent MPFR oracle
/// covers IEEE 754 classes, the domain and implementation branch boundaries,
/// logarithmic reduction boundaries, cancellation near zero, and fixed-seed
/// stratified inputs. It checks the `ln_1p` alias and monotonicity over the real
/// domain in debug and release mode on wasm, wasm-gc, JavaScript, and native.
/// An enlarged audit of 247,800 inputs also passed on native. The observed
/// maximum error is 1 ULP; input bits `0xbfefffffffffff45` are a fixed witness.
/// MoonBit Core stays within 2 ULP over the fixed corpus. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/log1p/README.md) for the corpus design
/// and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from FreeBSD msun
///   [`s_log1p.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_log1p.c)
///   distributed by OpenLibm.
/// - The `ln_1p` alias and public behavior are compatible with MoonBit Core.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(log1p(0.0), 0.0)
///   assert_eq(log1p(-1.0), @double.neg_infinity)
/// }
/// ```
#alias(ln_1p)
pub fn log1p(input : Double) -> Double {
  if input.is_nan() {
    return input
  }
  if input < -1.0 {
    return @double.not_a_number
  }
  if input == -1.0 {
    return @double.neg_infinity
  }
  if input.is_inf() {
    return input
  }
  let ln2_high = 6.93147180369123816490e-01
  let ln2_low = 1.90821492927058770002e-10
  let lp1 = 6.666666666666735130e-01
  let lp2 = 3.999999999940941908e-01
  let lp3 = 2.857142874366239149e-01
  let lp4 = 2.222219843214978396e-01
  let lp5 = 1.818357216161805012e-01
  let lp6 = 1.531383769920937332e-01
  let lp7 = 1.479819860511658591e-01
  let high_word = @fpbits.high_word(input)
  let negative = high_word >> 31 != 0U
  let magnitude_high = high_word & 0x7fffffffU
  let mut f = 0.0
  let mut correction = 0.0
  let mut reduced_high = 0U
  let mut reduction = 1
  if negative || high_word < 0x3fda827aU {
    if magnitude_high < 0x3e200000U {
      if magnitude_high < 0x3c900000U {
        return input
      }
      return input - input * input * 0.5
    }
    if !negative || high_word <= 0xbfd2bec4U {
      reduction = 0
      f = input
      reduced_high = 1U
    }
  }
  if reduction != 0 {
    let mut reduced = 0.0
    if input < 0x1.0p53 {
      reduced = 1.0 + input
      reduced_high = @fpbits.high_word(reduced)
      reduction = (reduced_high >> 20).reinterpret_as_int() - 1023
      correction = if reduction > 0 {
        1.0 - (reduced - input)
      } else {
        input - (reduced - 1.0)
      }
      correction /= reduced
    } else {
      reduced = input
      reduced_high = @fpbits.high_word(reduced)
      reduction = (reduced_high >> 20).reinterpret_as_int() - 1023
    }
    reduced_high = reduced_high & 0x000fffffU
    if reduced_high < 0x6a09eU {
      reduced = @fpbits.from_words(
        reduced_high | 0x3ff00000U,
        @fpbits.low_word(reduced),
      )
    } else {
      reduction += 1
      reduced = @fpbits.from_words(
        reduced_high | 0x3fe00000U,
        @fpbits.low_word(reduced),
      )
      reduced_high = (0x00100000U - reduced_high) >> 2
    }
    f = reduced - 1.0
  }
  let half_square = 0.5 * f * f
  let reduction_as_double = reduction.to_double()
  if reduced_high == 0U {
    if f == 0.0 {
      if reduction == 0 {
        return 0.0
      }
      correction += reduction_as_double * ln2_low
      return reduction_as_double * ln2_high + correction
    }
    let remainder = half_square * (1.0 - 0.66666666666666666 * f)
    if reduction == 0 {
      return f - remainder
    }
    return reduction_as_double * ln2_high -
      (remainder - (reduction_as_double * ln2_low + correction) - f)
  }
  let s = f / (2.0 + f)
  let z = s * s
  let remainder = z *
    (lp1 + z * (lp2 + z * (lp3 + z * (lp4 + z * (lp5 + z * (lp6 + z * lp7))))))
  if reduction == 0 {
    f - (half_square - s * (half_square + remainder))
  } else {
    reduction_as_double * ln2_high -
    (
      half_square -
      (
        s * (half_square + remainder) +
        (reduction_as_double * ln2_low + correction)
      ) -
      f
    )
  }
}

///|
test "log1p handles its domain and IEEE 754 special values" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(log1p(positive_zero).reinterpret_as_uint64(), 0x0000000000000000UL)
  assert_eq(log1p(negative_zero).reinterpret_as_uint64(), 0x8000000000000000UL)
  assert_eq(log1p(-1.0).reinterpret_as_uint64(), 0xfff0000000000000UL)
  assert_eq(
    log1p(@double.infinity).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_true(log1p(-1.0000000000000002).is_nan())
  assert_true(log1p(@double.neg_infinity).is_nan())
  assert_true(log1p(quiet_nan).is_nan())
}

///|
test "log1p preserves tiny inputs and exposes an exact alias" {
  let cases : Array[(UInt64, UInt64)] = [
    (0x0000000000000001UL, 0x0000000000000001UL),
    (0x8000000000000001UL, 0x8000000000000001UL),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = input_bits.reinterpret_as_double()
    assert_eq(log1p(input).reinterpret_as_uint64(), expected_bits)
    assert_eq(ln_1p(input).reinterpret_as_uint64(), expected_bits)
  }
}
