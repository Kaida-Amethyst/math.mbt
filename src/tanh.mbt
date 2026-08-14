// Derived from FreeBSD msun / fdlibm s_tanh.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns the hyperbolic tangent of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces exactly `1.0`.
/// - Negative infinity produces exactly `-1.0`.
/// - Positive and negative zero are returned unchanged.
/// - Every finite result lies in the closed interval `[-1.0, 1.0]`.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact hyperbolic
/// tangent rounded to binary64 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A fixed corpus of 12,704 inputs generated with an independent MPFR oracle
/// covers IEEE 754 classes, implementation branches, analytic saturation
/// transitions, and fixed-seed stratified inputs. It checks odd symmetry,
/// monotonicity, and the result range in debug and release mode on wasm,
/// wasm-gc, JavaScript, and native. An enlarged audit of 98,720 inputs also
/// passed on native. The observed maximum error is 2 ULP; input bits
/// `0xbfe033d8e590f821` are a fixed witness and produce the same result in the
/// pinned OpenLibm implementation. MoonBit Core stays within 2 ULP over the
/// fixed corpus. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/tanh/README.md) for the corpus design
/// and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from FreeBSD msun
///   [`s_tanh.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_tanh.c)
///   distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(tanh(0.0), 0.0)
///   assert_eq(tanh(@double.infinity), 1.0)
///   assert_eq(tanh(@double.neg_infinity), -1.0)
/// }
/// ```
pub fn tanh(input : Double) -> Double {
  let raw_bits = input.reinterpret_as_uint64()
  let negative = raw_bits >> 63 != 0UL
  let magnitude = raw_bits & 0x7fffffffffffffffUL
  if magnitude >= 0x7ff0000000000000UL {
    if input.is_nan() {
      return input
    }
    return if negative { -1.0 } else { 1.0 }
  }
  if magnitude < 0x3e30000000000000UL {
    return input
  }
  let absolute = magnitude.reinterpret_as_double()
  let result = if magnitude < 0x4036000000000000UL {
    if magnitude >= 0x3ff0000000000000UL {
      let t = expm1(2.0 * absolute)
      1.0 - 2.0 / (t + 2.0)
    } else {
      let t = expm1(-2.0 * absolute)
      -t / (t + 2.0)
    }
  } else {
    1.0
  }
  if negative {
    -result
  } else {
    result
  }
}

///|
test "tanh handles IEEE 754 special values" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(tanh(positive_zero).reinterpret_as_uint64(), 0x0000000000000000UL)
  assert_eq(tanh(negative_zero).reinterpret_as_uint64(), 0x8000000000000000UL)
  assert_eq(
    tanh(@double.infinity).reinterpret_as_uint64(),
    0x3ff0000000000000UL,
  )
  assert_eq(
    tanh(@double.neg_infinity).reinterpret_as_uint64(),
    0xbff0000000000000UL,
  )
  assert_true(tanh(quiet_nan).is_nan())
}

///|
test "tanh preserves minimum subnormal inputs" {
  let minimum_subnormal = 0x0000000000000001UL.reinterpret_as_double()
  let negative_minimum_subnormal = 0x8000000000000001UL.reinterpret_as_double()
  assert_eq(
    tanh(minimum_subnormal).reinterpret_as_uint64(),
    0x0000000000000001UL,
  )
  assert_eq(
    tanh(negative_minimum_subnormal).reinterpret_as_uint64(),
    0x8000000000000001UL,
  )
}
