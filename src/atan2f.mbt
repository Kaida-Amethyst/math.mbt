// Derived from musl libc src/math/atan2f.c at commit
// f21a96538f78fa8e2040831b4209b35f2fb581da.
//
// origin: FreeBSD msun / SunPro
// ====================================================
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.
// ====================================================

///|
/// Returns the polar angle of the vector (`x`, `y`) as an IEEE 754 binary32
/// value in `[-π, π]`.
///
/// ## Domain and special values
///
/// - If either input is NaN, the result is NaN; no NaN payload is promised.
/// - `atan2f(+0.0, x)` and `atan2f(-0.0, x)` preserve the sign of zero when
///   `x` is positive, and return positive and negative π when `x` is negative.
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
/// For finite inputs, the result is within 2 ULP of the exact two-argument
/// arctangent rounded to binary32 with round-to-nearest, ties-to-even. Correct
/// rounding is not promised.
///
/// ## Verification
///
/// A 42,560-pair fixed corpus generated with an independent MPFR `atan2` oracle
/// covers IEEE 754 classes, all four quadrants, the signed-zero branch cut,
/// exponent differences, ratio transitions at `2^-26` and `2^26`, and
/// fixed-seed paired inputs. Its maximum observed error is 2 ULP. It checks the
/// result range and bit-exact reflection across the x-axis in debug and release
/// mode on wasm, wasm-gc, JavaScript, and native. An enlarged 185,823-pair
/// audit passed in native debug mode with the same bound. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/atan2f/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range and special-value semantics follow
///   [POSIX `atan2`](https://pubs.opengroup.org/onlinepubs/009695299/functions/atan2.html).
/// - The special-value dispatch, ratio reduction, and quadrant reconstruction
///   are derived from musl libc
///   [`atan2f.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/atan2f.c?id=f21a96538f78fa8e2040831b4209b35f2fb581da).
/// - The reduced ratio is evaluated by this package's independently certified
///   [`atanf`](#atanf).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(atan2f(1.0, 1.0).reinterpret_as_uint(), 0x3f490fdbU)
///   assert_eq(atan2f(-1.0, 1.0).reinterpret_as_uint(), 0xbf490fdbU)
/// }
/// ```
pub fn atan2f(y : Float, x : Float) -> Float {
  if x.is_nan() || y.is_nan() {
    return @float.not_a_number
  }
  let pi : Float = 3.1415927410e+00
  let pi_lo : Float = -8.7422776573e-08
  let ix = x.reinterpret_as_uint()
  let iy = y.reinterpret_as_uint()
  if ix == 0x3f800000U {
    return atanf(y)
  }
  let quadrant = ((iy >> 31) & 1U) | ((ix >> 30) & 2U)
  let ix = ix & 0x7fffffffU
  let iy = iy & 0x7fffffffU
  if iy == 0U {
    match quadrant {
      0U | 1U => return y
      2U => return pi
      _ => return -pi
    }
  }
  if ix == 0U {
    return if (quadrant & 1U) != 0U { -pi / 2.0 } else { pi / 2.0 }
  }
  if ix == 0x7f800000U {
    if iy == 0x7f800000U {
      match quadrant {
        0U => return pi / 4.0
        1U => return -pi / 4.0
        2U => return pi * 3.0 / 4.0
        _ => return -pi * 3.0 / 4.0
      }
    } else {
      match quadrant {
        0U => return 0.0
        1U => return -0.0
        2U => return pi
        _ => return -pi
      }
    }
  }
  if ix + (26U << 23) < iy || iy == 0x7f800000U {
    return if (quadrant & 1U) != 0U { -pi / 2.0 } else { pi / 2.0 }
  }
  let angle : Float = if (quadrant & 2U) != 0U && iy + (26U << 23) < ix {
    0.0
  } else {
    let ratio : Float = y / x
    atanf(ratio.abs())
  }
  match quadrant {
    0U => angle
    1U => -angle
    2U => pi - (angle - pi_lo)
    _ => angle - pi_lo - pi
  }
}

///|
test "atan2f handles signed zeros and the coordinate axes" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  assert_eq(atan2f(positive_zero, 1.0).reinterpret_as_uint(), 0x00000000U)
  assert_eq(atan2f(negative_zero, 1.0).reinterpret_as_uint(), 0x80000000U)
  assert_eq(atan2f(positive_zero, -1.0).reinterpret_as_uint(), 0x40490fdbU)
  assert_eq(atan2f(negative_zero, -1.0).reinterpret_as_uint(), 0xc0490fdbU)
  assert_eq(atan2f(1.0, positive_zero).reinterpret_as_uint(), 0x3fc90fdbU)
  assert_eq(atan2f(-1.0, negative_zero).reinterpret_as_uint(), 0xbfc90fdbU)
}

///|
test "atan2f places finite inputs in the correct quadrant" {
  let cases : Array[(Float, Float, UInt)] = [
    (3.0, 5.0, 0x3f0a58efU),
    (-5.0, 3.0, 0xbf83e363U),
    (6.5, -3.25, 0x40023454U),
    (-7.25, 8.625, 0xbf32f1a3U),
    (-52.5, -625.5, 0xc043b3eaU),
  ]
  for item in cases {
    let (y, x, expected_bits) = item
    assert_eq(atan2f(y, x).reinterpret_as_uint(), expected_bits)
  }
}

///|
test "atan2f handles infinities and NaN" {
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_true(atan2f(quiet_nan, 1.0).is_nan())
  assert_true(atan2f(1.0, quiet_nan).is_nan())
  let cases : Array[(Float, Float, UInt)] = [
    (@float.infinity, @float.infinity, 0x3f490fdbU),
    (@float.neg_infinity, @float.infinity, 0xbf490fdbU),
    (@float.infinity, @float.neg_infinity, 0x4016cbe4U),
    (@float.neg_infinity, @float.neg_infinity, 0xc016cbe4U),
    (1.0, @float.infinity, 0x00000000U),
    (-1.0, @float.infinity, 0x80000000U),
    (1.0, @float.neg_infinity, 0x40490fdbU),
    (-1.0, @float.neg_infinity, 0xc0490fdbU),
  ]
  for item in cases {
    let (y, x, expected_bits) = item
    assert_eq(atan2f(y, x).reinterpret_as_uint(), expected_bits)
  }
}
