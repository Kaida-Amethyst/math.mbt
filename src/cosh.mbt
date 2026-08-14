// Derived from FreeBSD msun / fdlibm e_cosh.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns the hyperbolic cosine of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity both produce positive infinity.
/// - Positive and negative zero both produce exactly `1.0`.
/// - Overflow produces positive infinity.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact hyperbolic
/// cosine rounded to binary64 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A fixed corpus of 14,156 inputs generated with an independent MPFR oracle
/// covers IEEE 754 classes, implementation branches, analytic overflow
/// transitions, and fixed-seed stratified inputs. It checks even symmetry and
/// the result range in debug and release mode on wasm, wasm-gc, JavaScript, and
/// native. An enlarged audit of 100,172 inputs also passed on native. The
/// observed maximum error is 1 ULP; input bits `0xc08633ce8fb9f87d` are a fixed
/// witness. MoonBit Core stays within 2 ULP over the fixed corpus. This is
/// testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/cosh/README.md) for the corpus design
/// and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from FreeBSD msun
///   [`e_cosh.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_cosh.c)
///   distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(cosh(0.0), 1.0)
///   assert_eq(cosh(@double.infinity), @double.infinity)
///   assert_eq(cosh(@double.neg_infinity), @double.infinity)
/// }
/// ```
pub fn cosh(input : Double) -> Double {
  let magnitude = input.reinterpret_as_uint64() & 0x7fffffffffffffffUL
  if magnitude >= 0x7ff0000000000000UL {
    return if input.is_nan() { input } else { @double.infinity }
  }
  let absolute = magnitude.reinterpret_as_double()
  if magnitude < 0x3fd62e4300000000UL {
    let t = expm1(absolute)
    let exp_absolute = 1.0 + t
    if magnitude < 0x3c80000000000000UL {
      return exp_absolute
    }
    return 1.0 + t * t / (exp_absolute + exp_absolute)
  }
  if magnitude < 0x4036000000000000UL {
    let exp_absolute = exp(absolute)
    return 0.5 * exp_absolute + 0.5 / exp_absolute
  }
  if magnitude < 0x40862e4200000000UL {
    return 0.5 * exp(absolute)
  }
  if magnitude <= 0x408633ce8fb9f87dUL {
    return hyperbolic_scaled_exp(absolute, -1)
  }
  @double.infinity
}

///|
test "cosh handles IEEE 754 special values" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(cosh(positive_zero).reinterpret_as_uint64(), 0x3ff0000000000000UL)
  assert_eq(cosh(negative_zero).reinterpret_as_uint64(), 0x3ff0000000000000UL)
  assert_eq(
    cosh(@double.infinity).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_eq(
    cosh(@double.neg_infinity).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_true(cosh(quiet_nan).is_nan())
}
