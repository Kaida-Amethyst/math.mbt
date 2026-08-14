// Derived from FreeBSD msun / fdlibm e_sinh.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

// The scaled-exponential helper is derived from FreeBSD msun k_exp.c.
//
// Copyright (c) 2011 David Schultz <das@FreeBSD.ORG>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

///|
fn hyperbolic_scaled_exp(input : Double, exponent : Int) -> Double {
  let reduction = 1799
  let reduction_ln2 = 1246.97177782734161156
  let reduced_exp = exp(input - reduction_ln2)
  let reduced_bits = reduced_exp.reinterpret_as_uint64()
  let reduced_exponent = ((reduced_bits >> 52) & 0x7ffUL).to_int()
  let scale_exponent = reduced_exponent - (0x3ff + 1023) + reduction + exponent
  let normalized_bits = (reduced_bits & 0x000fffffffffffffUL) |
    0x7fe0000000000000UL
  let normalized = normalized_bits.reinterpret_as_double()
  normalized * scalbn(1.0, scale_exponent)
}

///|
/// Returns the hyperbolic sine of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity produces negative infinity.
/// - Positive and negative zero are returned unchanged.
/// - Overflow produces an infinity with the sign of `input`; tiny finite
///   inputs, including subnormals, are returned unchanged.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact hyperbolic
/// sine rounded to binary64 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A fixed corpus of 14,151 inputs generated with an independent MPFR oracle
/// covers IEEE 754 classes, implementation branches, analytic overflow
/// transitions, and fixed-seed stratified inputs. It checks odd symmetry and
/// monotonicity in debug and release mode on wasm, wasm-gc, JavaScript, and
/// native. An enlarged audit of 100,162 inputs also passed on native. The
/// observed maximum error is 2 ULP; input bits `0xbfeabc3c7931e986` are a fixed
/// witness and produce the same result in the pinned OpenLibm implementation.
/// MoonBit Core stays within 2 ULP over the fixed corpus. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/sinh/README.md) for the corpus design
/// and reproduction commands.
///
/// ## References
///
/// - The piecewise formulas are derived from FreeBSD msun
///   [`e_sinh.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_sinh.c)
///   distributed by OpenLibm.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(sinh(0.0), 0.0)
///   assert_eq(sinh(@double.infinity), @double.infinity)
///   assert_eq(sinh(@double.neg_infinity), @double.neg_infinity)
/// }
/// ```
pub fn sinh(input : Double) -> Double {
  let raw_bits = input.reinterpret_as_uint64()
  let negative = raw_bits >> 63 != 0UL
  let magnitude = raw_bits & 0x7fffffffffffffffUL
  if magnitude >= 0x7ff0000000000000UL {
    return input
  }
  if magnitude < 0x3e30000000000000UL {
    return input
  }
  let absolute = input.abs()
  let half = if negative { -0.5 } else { 0.5 }
  if magnitude < 0x4036000000000000UL {
    let t = expm1(absolute)
    if magnitude < 0x3ff0000000000000UL {
      return half * (2.0 * t - t * t / (t + 1.0))
    }
    return half * (t + t / (t + 1.0))
  }
  if magnitude < 0x40862e4200000000UL {
    return half * exp(absolute)
  }
  if magnitude <= 0x408633ce8fb9f87dUL {
    let result = hyperbolic_scaled_exp(absolute, -1)
    return if negative { -result } else { result }
  }
  if negative {
    @double.neg_infinity
  } else {
    @double.infinity
  }
}

///|
test "sinh handles IEEE 754 special values" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_eq(sinh(positive_zero).reinterpret_as_uint64(), 0x0000000000000000UL)
  assert_eq(sinh(negative_zero).reinterpret_as_uint64(), 0x8000000000000000UL)
  assert_eq(
    sinh(@double.infinity).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_eq(
    sinh(@double.neg_infinity).reinterpret_as_uint64(),
    0xfff0000000000000UL,
  )
  assert_true(sinh(quiet_nan).is_nan())
}

///|
test "sinh preserves minimum subnormal inputs" {
  let minimum_subnormal = 0x0000000000000001UL.reinterpret_as_double()
  let negative_minimum_subnormal = 0x8000000000000001UL.reinterpret_as_double()
  assert_eq(
    sinh(minimum_subnormal).reinterpret_as_uint64(),
    0x0000000000000001UL,
  )
  assert_eq(
    sinh(negative_minimum_subnormal).reinterpret_as_uint64(),
    0x8000000000000001UL,
  )
}
