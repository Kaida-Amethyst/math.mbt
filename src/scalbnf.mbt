///|
/// Returns `input * 2^exponent` as an IEEE 754 binary32 value, without first
/// computing `2^exponent` as a `Float`.
///
/// ## Domain and special values
///
/// - Positive and negative zero are returned unchanged.
/// - Positive and negative infinity are returned unchanged.
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Overflow produces infinity with the sign of `input`.
/// - Underflow may produce a subnormal value or zero with the sign of `input`.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the exact product is rounded to binary32 with
/// round-to-nearest, ties-to-even. This includes results in the subnormal range.
///
/// ## Verification
///
/// A 15,922-case fixed corpus generated with an independent MPFR oracle checks
/// exact result bits across normal, subnormal, underflow, and overflow
/// transitions, including extreme `Int` exponents. Its maximum observed error is
/// 0 ULP. The corpus passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native and is also compared with MoonBit Core. This is testing
/// evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/scalbnf/README.md) for the corpus
/// design and reproduction commands.
///
/// ## References
///
/// - The public behavior follows
///   [POSIX `scalbnf`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/scalbn.html)
///   for binary32 under round-to-nearest, ties-to-even.
/// - The staged scaling algorithm is derived from
///   [musl `scalbnf.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/scalbnf.c).
/// - The implementation is compatible with
///   [MoonBit Core `math.scalbnf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/scalbn.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(scalbnf(1.5, 2), 6.0)
///   assert_eq(scalbnf(1.0, -149).reinterpret_as_uint(), 1U)
/// }
/// ```
pub fn scalbnf(input : Float, exponent : Int) -> Float {
  let mut y = input
  let mut n = exponent
  if n > 127 {
    y *= (0x1.0p127 : Float)
    n -= 127
    if n > 127 {
      y *= (0x1.0p127 : Float)
      n -= 127
      if n > 127 {
        n = 127
      }
    }
  } else if n < -126 {
    // Stage through a normal 2^-102 factor so a subnormal result is rounded once.
    y *= (0x1.0p-126 : Float) * 0x1.0p24
    n += 126 - 24
    if n < -126 {
      y *= (0x1.0p-126 : Float) * 0x1.0p24
      n += 126 - 24
      if n < -126 {
        n = -126
      }
    }
  }
  let scale_bits = (0x7f + n) << 23
  return y * Float::reinterpret_from_int(scale_bits)
}

///|
test "scalbnf preserves signed zero, infinities, and NaN classification" {
  let positive_zero = Float::reinterpret_from_int(0x00000000)
  let negative_zero = Float::reinterpret_from_int(
    0x80000000U.reinterpret_as_int(),
  )
  let positive_infinity = Float::reinterpret_from_int(0x7f800000)
  let negative_infinity = Float::reinterpret_from_int(
    0xff800000U.reinterpret_as_int(),
  )
  let quiet_nan = Float::reinterpret_from_int(0x7fc00001)
  let signaling_nan = Float::reinterpret_from_int(0x7f800001)
  for exponent in [-2147483648, -149, 0, 128, 2147483647] {
    assert_eq(
      scalbnf(positive_zero, exponent).reinterpret_as_uint(),
      0x00000000U,
    )
    assert_eq(
      scalbnf(negative_zero, exponent).reinterpret_as_uint(),
      0x80000000U,
    )
    assert_eq(
      scalbnf(positive_infinity, exponent).reinterpret_as_uint(),
      0x7f800000U,
    )
    assert_eq(
      scalbnf(negative_infinity, exponent).reinterpret_as_uint(),
      0xff800000U,
    )
    assert_true(scalbnf(quiet_nan, exponent).is_nan())
    assert_true(scalbnf(signaling_nan, exponent).is_nan())
  }
}

///|
test "scalbnf rounds normal and subnormal transitions to exact bits" {
  let cases : Array[(UInt, Int, UInt)] = [
    // Minimum normal scaled into the subnormal range.
    (0x00800000U, -1, 0x00400000U),
    // Maximum subnormal scaled into the normal range.
    (0x007fffffU, 1, 0x00fffffeU),
    // Exact minimum subnormal and the halfway value below it.
    (0x3f800000U, -149, 0x00000001U),
    (0x3f800000U, -150, 0x00000000U),
    // 3 * 2^-150 is halfway and rounds to the even second subnormal.
    (0x40400000U, -150, 0x00000002U),
    // Negative underflow preserves the sign of zero.
    (0xbf800000U, -150, 0x80000000U),
    // Maximum finite scaled upward overflows with its sign.
    (0x7f7fffffU, 1, 0x7f800000U),
    (0xff7fffffU, 1, 0xff800000U),
  ]
  for item in cases {
    let (input_bits, exponent, expected_bits) = item
    let input = Float::reinterpret_from_int(input_bits.reinterpret_as_int())
    assert_eq(scalbnf(input, exponent).reinterpret_as_uint(), expected_bits)
  }
}

///|
test "scalbnf handles the full Int exponent range" {
  assert_eq(scalbnf(1.0, 2147483647).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(scalbnf(-1.0, 2147483647).reinterpret_as_uint(), 0xff800000U)
  assert_eq(scalbnf(1.0, -2147483648).reinterpret_as_uint(), 0x00000000U)
  assert_eq(scalbnf(-1.0, -2147483648).reinterpret_as_uint(), 0x80000000U)
}
