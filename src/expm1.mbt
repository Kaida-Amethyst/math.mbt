// Derived from FreeBSD msun / fdlibm s_expm1.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns `e` raised to `input` minus one as an IEEE 754 binary64 value.
/// This form retains accuracy when `input` is close to zero.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity produces exactly `-1.0`.
/// - Positive and negative zero are returned unchanged.
/// - Overflow produces positive infinity; tiny finite inputs may produce a
///   subnormal result.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact value of
/// `exp(input) - 1` rounded to binary64 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A fixed corpus of 31,384 inputs generated with an independent MPFR oracle
/// covers IEEE 754 classes, every relevant argument-reduction cell,
/// implementation branches, analytic rounding transitions, and fixed-seed
/// stratified inputs. It checks the lower range bound and monotonicity in debug
/// and release mode on wasm, wasm-gc, JavaScript, and native. An enlarged audit
/// of 117,400 inputs also passed on native. The observed maximum error is 1 ULP;
/// input bits `0xc01205966f2b4f0f` are a fixed witness. This is testing evidence,
/// not a formal proof. See the [oracle documentation](../tools/oracle/expm1/README.md)
/// for the corpus design and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from FreeBSD msun
///   [`s_expm1.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_expm1.c)
///   distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(expm1(0.0), 0.0)
///   assert_eq(expm1(@double.neg_infinity), -1.0)
/// }
/// ```
pub fn expm1(input : Double) -> Double {
  let overflow_threshold = 7.09782712893383973096e+02
  let ln2_high = 6.93147180369123816490e-01
  let ln2_low = 1.90821492927058770002e-10
  let inverse_ln2 = 1.44269504088896338700e+00
  let q1 = -3.33333333333331316428e-02
  let q2 = 1.58730158725481460165e-03
  let q3 = -7.93650757867487942473e-05
  let q4 = 4.00821782732936239552e-06
  let q5 = -2.01099218183624371326e-07
  let mut x = input
  let raw_bits = x.reinterpret_as_uint64()
  let negative = raw_bits >> 63 != 0UL
  let magnitude = raw_bits & 0x7fffffffffffffffUL
  if magnitude >= 0x4043687a00000000UL {
    if magnitude >= 0x7ff0000000000000UL {
      if x.is_nan() {
        return x
      }
      return if negative { -1.0 } else { x }
    }
    if !negative && x > overflow_threshold {
      return @double.infinity
    }
    if negative {
      return -1.0
    }
  }
  let mut high = 0.0
  let mut low = 0.0
  let mut reduction = 0
  let mut correction = 0.0
  if magnitude >= 0x3fd62e4300000000UL {
    if magnitude < 0x3ff0a2b200000000UL {
      high = if negative { x + ln2_high } else { x - ln2_high }
      low = if negative { -ln2_low } else { ln2_low }
      reduction = if negative { -1 } else { 1 }
    } else {
      let rounding_offset = if negative { -0.5 } else { 0.5 }
      reduction = (inverse_ln2 * x + rounding_offset).to_int()
      let multiple = reduction.to_double()
      high = x - multiple * ln2_high
      low = multiple * ln2_low
    }
    x = high - low
    correction = high - x - low
  } else if magnitude < 0x3c90000000000000UL {
    return x
  }
  let half = 0.5 * x
  let half_square = x * half
  let polynomial = 1.0 +
    half_square *
    (
      q1 +
      half_square *
      (q2 + half_square * (q3 + half_square * (q4 + half_square * q5)))
    )
  let denominator = 3.0 - polynomial * half
  let mut error = half_square *
    ((polynomial - denominator) / (6.0 - x * denominator))
  if reduction == 0 {
    return x - (x * error - half_square)
  }
  error = x * (error - correction) - correction - half_square
  if reduction == -1 {
    return 0.5 * (x - error) - 0.5
  }
  if reduction == 1 {
    return if x < -0.25 {
      -2.0 * (error - (x + 0.5))
    } else {
      1.0 + 2.0 * (x - error)
    }
  }
  if reduction <= -2 || reduction > 56 {
    let scaled = scalbn(1.0 - (error - x), reduction)
    return scaled - 1.0
  }
  if reduction < 20 {
    let offset = 1.0 - scalbn(1.0, -reduction)
    scalbn(offset - (error - x), reduction)
  } else {
    let offset = scalbn(1.0, -reduction)
    scalbn(x - (error + offset) + 1.0, reduction)
  }
}

///|
test "expm1 handles IEEE 754 special values" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(expm1(positive_zero).reinterpret_as_uint64(), 0x0000000000000000UL)
  assert_eq(expm1(negative_zero).reinterpret_as_uint64(), 0x8000000000000000UL)
  assert_eq(
    expm1(@double.infinity).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_eq(
    expm1(@double.neg_infinity).reinterpret_as_uint64(),
    0xbff0000000000000UL,
  )
  assert_true(expm1(quiet_nan).is_nan())
}

///|
test "expm1 preserves tiny inputs and handles the overflow edge" {
  let minimum_subnormal = 0x0000000000000001UL.reinterpret_as_double()
  let negative_minimum_subnormal = 0x8000000000000001UL.reinterpret_as_double()
  assert_eq(
    expm1(minimum_subnormal).reinterpret_as_uint64(),
    0x0000000000000001UL,
  )
  assert_eq(
    expm1(negative_minimum_subnormal).reinterpret_as_uint64(),
    0x8000000000000001UL,
  )
  assert_true(expm1(0x40862e42fefa39f0UL.reinterpret_as_double()).is_inf())
}
