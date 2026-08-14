// Derived from FreeBSD msun / fdlibm e_atan2.c.
//
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunSoft, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.

///|
/// Returns the polar angle of the vector (`x`, `y`) as an IEEE 754 binary64
/// value in `[-π, π]`.
///
/// ## Domain and special values
///
/// - If either input is NaN, the result is NaN; no NaN payload is promised.
/// - `atan2(+0.0, x)` and `atan2(-0.0, x)` preserve the sign of zero when `x`
///   is positive, and return positive and negative π when `x` is negative.
///   This includes the four signed-zero pairs.
/// - A nonzero `y` with either signed zero as `x` returns π/2 with the sign of
///   `y`.
/// - Finite `y` with positive or negative infinity as `x` returns signed zero
///   or signed π respectively. Infinite `y` returns the corresponding signed
///   π/2, π/4, or 3π/4 result according to the sign of `x`.
/// - Subnormal inputs are supported. No floating-point status flags or `errno`
///   behavior is promised.
///
/// ## Accuracy
///
/// For finite inputs, the result is within 1 ULP of the exact two-argument
/// arctangent rounded to binary64 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 156,560-pair fixed corpus generated with an independent MPFR `atan2`
/// oracle covers IEEE 754 classes, all four quadrants, the signed-zero branch
/// cut, exponent differences, ratio transitions at `2^-60` and `2^60`, and
/// fixed-seed paired inputs. Its observed maximum error is 1 ULP; the pair
/// `y=0x0005555555555555`, `x=0x003aaaaaaaaaaaaa` is retained as a witness. An
/// enlarged 299,912-pair native audit also stays within the bound. The fixed
/// corpus checks the result range and bit-exact reflection across the x-axis in
/// debug and release mode on wasm, wasm-gc, JavaScript, and native. This is
/// testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/atan2/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range and special-value semantics follow
///   [POSIX `atan2`](https://pubs.opengroup.org/onlinepubs/009695299/functions/atan2.html).
/// - The special-value dispatch, ratio reduction, and quadrant reconstruction
///   are derived from FreeBSD msun
///   [`e_atan2.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_atan2.c)
///   distributed by OpenLibm.
/// - The reduced ratio is evaluated by this package's independently certified
///   [`atan`](#atan).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(atan2(1.0, 1.0).reinterpret_as_uint64(), 0x3fe921fb54442d18UL)
///   assert_eq(atan2(-1.0, 1.0).reinterpret_as_uint64(), 0xbfe921fb54442d18UL)
/// }
/// ```
pub fn atan2(y : Double, x : Double) -> Double {
  if x.is_nan() || y.is_nan() {
    return @double.not_a_number
  }
  let tiny = 1.0e-300
  let zero = 0.0
  let pi_over_4 = 7.8539816339744827900e-01
  let pi_over_2 = 1.5707963267948965580e+00
  let pi = 3.1415926535897931160e+00
  let pi_low = 1.2246467991473531772e-16
  let x_bits = x.reinterpret_as_uint64()
  let y_bits = y.reinterpret_as_uint64()
  let x_magnitude = x_bits & 0x7fffffffffffffffUL
  let y_magnitude = y_bits & 0x7fffffffffffffffUL
  if x_bits == 0x3ff0000000000000UL {
    return atan(y)
  }
  let mut quadrant = ((y_bits >> 63) & 1UL) | ((x_bits >> 62) & 2UL)
  if y_magnitude == 0UL {
    match quadrant {
      0UL | 1UL => return y
      2UL => return pi + tiny
      _ => return -pi - tiny
    }
  }
  if x_magnitude == 0UL {
    return if (y_bits & 0x8000000000000000UL) != 0UL {
      -pi_over_2 - tiny
    } else {
      pi_over_2 + tiny
    }
  }
  if x_magnitude == 0x7ff0000000000000UL {
    if y_magnitude == 0x7ff0000000000000UL {
      match quadrant {
        0UL => return pi_over_4 + tiny
        1UL => return -pi_over_4 - tiny
        2UL => return 3.0 * pi_over_4 + tiny
        _ => return -3.0 * pi_over_4 - tiny
      }
    } else {
      match quadrant {
        0UL => return zero
        1UL => return -zero
        2UL => return pi + tiny
        _ => return -pi - tiny
      }
    }
  }
  if y_magnitude == 0x7ff0000000000000UL {
    return if (y_bits & 0x8000000000000000UL) != 0UL {
      -pi_over_2 - tiny
    } else {
      pi_over_2 + tiny
    }
  }
  let x_high = (x_magnitude >> 32).to_int()
  let y_high = (y_magnitude >> 32).to_int()
  let exponent_gap = (y_high - x_high) >> 20
  let angle = if exponent_gap > 60 {
    quadrant = quadrant & 1UL
    pi_over_2 + 0.5 * pi_low
  } else if (x_bits & 0x8000000000000000UL) != 0UL && exponent_gap < -60 {
    0.0
  } else {
    atan((y / x).abs())
  }
  match quadrant {
    0UL => angle
    1UL => -angle
    2UL => pi - (angle - pi_low)
    _ => angle - pi_low - pi
  }
}

///|
test "atan2 handles signed zeros and the coordinate axes" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  assert_eq(
    atan2(positive_zero, 1.0).reinterpret_as_uint64(),
    0x0000000000000000UL,
  )
  assert_eq(
    atan2(negative_zero, 1.0).reinterpret_as_uint64(),
    0x8000000000000000UL,
  )
  assert_eq(
    atan2(positive_zero, -1.0).reinterpret_as_uint64(),
    0x400921fb54442d18UL,
  )
  assert_eq(
    atan2(negative_zero, -1.0).reinterpret_as_uint64(),
    0xc00921fb54442d18UL,
  )
  assert_eq(
    atan2(1.0, positive_zero).reinterpret_as_uint64(),
    0x3ff921fb54442d18UL,
  )
  assert_eq(
    atan2(-1.0, negative_zero).reinterpret_as_uint64(),
    0xbff921fb54442d18UL,
  )
}

///|
test "atan2 handles infinities and NaN" {
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  assert_true(atan2(quiet_nan, 1.0).is_nan())
  assert_true(atan2(1.0, quiet_nan).is_nan())
  let cases : Array[(Double, Double, UInt64)] = [
    (@double.infinity, @double.infinity, 0x3fe921fb54442d18UL),
    (@double.neg_infinity, @double.infinity, 0xbfe921fb54442d18UL),
    (@double.infinity, @double.neg_infinity, 0x4002d97c7f3321d2UL),
    (@double.neg_infinity, @double.neg_infinity, 0xc002d97c7f3321d2UL),
    (1.0, @double.infinity, 0x0000000000000000UL),
    (-1.0, @double.infinity, 0x8000000000000000UL),
    (1.0, @double.neg_infinity, 0x400921fb54442d18UL),
    (-1.0, @double.neg_infinity, 0xc00921fb54442d18UL),
  ]
  for item in cases {
    let (case_y, case_x, expected_bits) = item
    assert_eq(atan2(case_y, case_x).reinterpret_as_uint64(), expected_bits)
  }
}

///|
test "atan2 handles extreme exponent gaps in every quadrant" {
  let huge = 0x7fe0000000000000UL.reinterpret_as_double()
  let tiny = 0x0010000000000000UL.reinterpret_as_double()
  assert_eq(atan2(huge, -tiny).reinterpret_as_uint64(), 0x3ff921fb54442d18UL)
  assert_eq(atan2(-huge, -tiny).reinterpret_as_uint64(), 0xbff921fb54442d18UL)
  assert_eq(atan2(tiny, -huge).reinterpret_as_uint64(), 0x400921fb54442d18UL)
  assert_eq(atan2(-tiny, -huge).reinterpret_as_uint64(), 0xc00921fb54442d18UL)
}
