///|
/// Returns `e` raised to `input` minus one as an IEEE 754 binary32 value.
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
/// `exp(input) - 1` rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 15,541-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every relevant argument-reduction cell, implementation
/// branches, analytic rounding transitions, and fixed-seed stratified inputs.
/// Its maximum observed error is 1 ULP. The corpus passes in debug and release
/// mode on wasm, wasm-gc, JavaScript, and native; MoonBit Core is checked
/// against the same bound. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/expm1f/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from the FreeBSD msun
///   [`s_expm1f.c`](https://github.com/ifduyue/musl/blob/f21a96538f78fa8e2040831b4209b35f2fb581da/src/math/expm1f.c)
///   implementation distributed by musl.
/// - The public behavior is compatible with
///   [MoonBit Core `math.expm1f`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/exp.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(expm1f(0.0), 0.0)
///   assert_eq(expm1f(@float.neg_infinity), -1.0)
/// }
/// ```
pub fn expm1f(input : Float) -> Float {
  let float_ln2_hi : Float = 6.9313812256e-01
  let float_ln2_lo : Float = 9.0580006145e-06
  let inv_ln2 : Float = 1.4426950216e+00
  let mut x = input
  let q1 : Float = -3.3333212137e-2
  let q2 : Float = 1.5807170421e-3
  let mut hx = x.reinterpret_as_uint()
  let sign = hx >> 31 != 0
  hx = hx & 0x7fffffff
  if hx >= 0x4195b844 {
    if hx > 0x7f800000 {
      return x
    }
    if sign {
      return -1.0
    }
    if hx > 0x42b17217 {
      x *= (0x1.0p127 : Float)
      return x
    }
  }
  let mut k = 0
  let mut hi : Float = 0.0
  let mut lo : Float = 0.0
  let mut c : Float = 0.0
  if hx > 0x3eb17218 {
    if hx < 0x3f851592 {
      if !sign {
        hi = x - float_ln2_hi
        lo = float_ln2_lo
        k = 1
      } else {
        hi = x + float_ln2_hi
        lo = -float_ln2_lo
        k = -1
      }
    } else {
      k = (inv_ln2 * x + (if sign { -0.5 } else { 0.5 })).to_int()
      let t = Float::from_int(k)
      hi = x - t * float_ln2_hi
      lo = t * float_ln2_lo
    }
    x = hi - lo
    c = hi - x - lo
  } else if hx < 0x33000000 {
    return x
  } else {
    k = 0
  }
  let hfx = (0.5 : Float) * x
  let hxs = x * hfx
  let r1 = (1.0 : Float) + hxs * (q1 + hxs * q2)
  let t = (3.0 : Float) - r1 * hfx
  let mut e = hxs * ((r1 - t) / ((6.0 : Float) - x * t))
  if k == 0 {
    return x - (x * e - hxs)
  }
  e = x * (e - c) - c
  e -= hxs
  if k == -1 {
    return (0.5 : Float) * (x - e) - 0.5
  }
  if k == 1 {
    if x < -0.25 {
      return -(2.0 : Float) * (e - (x + 0.5))
    }
    return (1.0 : Float) + (2.0 : Float) * (x - e)
  }
  let twopk = Float::reinterpret_from_int((0x7f + k) << 23)
  if !(k is (0..=56)) {
    let mut y = x - e + 1.0
    if k == 128 {
      y = y * 2.0 * (0x1.0p127 : Float)
    } else {
      y = y * twopk
    }
    return y - 1.0
  }
  let uf = Float::reinterpret_from_int((0x7f - k) << 23)
  if k < 23 {
    (x - e + ((1.0 : Float) - uf)) * twopk
  } else {
    (x - (e + uf) + 1.0) * twopk
  }
}

///|
test "expm1f handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(expm1f(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(expm1f(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(expm1f(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(expm1f(@float.neg_infinity).reinterpret_as_uint(), 0xbf800000U)
  assert_true(expm1f(quiet_nan).is_nan())
  assert_true(expm1f(signaling_nan).is_nan())
}

///|
test "expm1f preserves tiny inputs" {
  let minimum_subnormal = Float::reinterpret_from_int(0x00000001)
  let negative_minimum_subnormal = Float::reinterpret_from_int(
    0x80000001U.reinterpret_as_int(),
  )
  assert_eq(
    expm1f(minimum_subnormal).reinterpret_as_uint(),
    minimum_subnormal.reinterpret_as_uint(),
  )
  assert_eq(
    expm1f(negative_minimum_subnormal).reinterpret_as_uint(),
    negative_minimum_subnormal.reinterpret_as_uint(),
  )
}
