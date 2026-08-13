///|
/// Returns the base-e exponential of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity produces positive zero.
/// - Positive and negative zero both produce exactly `1.0`.
/// - Overflow produces positive infinity; underflow may produce a positive
///   subnormal value or positive zero.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact exponential
/// rounded to binary32 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 17,772-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every argument-reduction cell, implementation branches,
/// analytic rounding transitions, and fixed-seed stratified inputs. Its maximum
/// observed error is 1 ULP. The corpus passes in debug and release mode on wasm,
/// wasm-gc, JavaScript, and native; MoonBit Core is checked against the same
/// bound. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/expf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from the FreeBSD msun
///   [`e_expf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_expf.c)
///   implementation.
/// - The public behavior is compatible with
///   [MoonBit Core `math.expf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/exp.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(expf(0.0), 1.0)
///   assert_eq(expf(@float.neg_infinity), 0.0)
/// }
/// ```
pub fn expf(input : Float) -> Float {
  let float_ln2_hi : Float = 6.9314575195e-01
  let float_ln2_lo : Float = 1.4286067653e-06
  let float_inv_ln2 : Float = 1.4426950216e+00
  let mut x = input
  let p1 : Float = 1.6666625440e-1
  let p2 : Float = -2.7667332906e-3
  let mut hx = x.reinterpret_as_uint()
  let sign = (hx >> 31).reinterpret_as_int()
  let negative = sign != 0
  hx = hx & 0x7fffffff
  if hx >= 0x42aeac50 {
    if hx > 0x7f800000 {
      return x
    }
    if hx >= 0x42b17218 && !negative {
      x *= (0x1.0p127 : Float)
      return x
    }
    if negative && hx >= 0x42cff1b5 {
      return 0.0
    }
  }
  let half : ReadOnlyArray[Float] = [0.5, -0.5]
  let mut k = 0
  let mut hi : Float = 0.0
  let mut lo : Float = 0.0
  if hx > 0x3eb17218 {
    if hx > 0x3f851592 {
      k = (float_inv_ln2 * x + half[sign]).to_int()
    } else {
      k = 1 - sign - sign
    }
    let kf = Float::from_int(k)
    hi = x - kf * float_ln2_hi
    lo = kf * float_ln2_lo
    x = hi - lo
  } else if hx > 0x39000000 {
    hi = x
  } else {
    return (1.0 : Float) + x
  }
  let xx = x * x
  let c = x - xx * (p1 + xx * p2)
  let y = (1.0 : Float) + (x * c / ((2.0 : Float) - c) - lo + hi)
  if k == 0 {
    y
  } else {
    scalbnf(y, k)
  }
}

///|
test "expf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  assert_eq(expf(positive_zero).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(expf(negative_zero).reinterpret_as_uint(), 0x3f800000U)
  assert_eq(expf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(expf(@float.neg_infinity).reinterpret_as_uint(), 0x00000000U)
  assert_true(expf(quiet_nan).is_nan())
  assert_true(expf(signaling_nan).is_nan())
}

///|
test "expf rounds underflow and overflow transitions" {
  let cases : Array[(UInt, UInt)] = [
    // Last input that rounds to the minimum positive subnormal, then zero.
    (0xc2cff1b4U, 0x00000001U),
    (0xc2cff1b5U, 0x00000000U),
    // Last finite result, then positive infinity.
    (0x42b17217U, 0x7f7fff84U),
    (0x42b17218U, 0x7f800000U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())
    assert_eq(expf(input).reinterpret_as_uint(), expected_bits)
  }
}
