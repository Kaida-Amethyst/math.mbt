///|
/// Returns `input * 2^exponent` as an IEEE 754 binary64 value, without first
/// computing `2^exponent` as a `Double`. The same function is also exported as
/// `ldexp`; because `Double` is a binary format, the two names have identical
/// semantics.
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
/// For every finite input, the exact product is rounded to binary64 with
/// round-to-nearest, ties-to-even. This includes results in the subnormal range.
///
/// ## Verification
///
/// A 15,646-case fixed corpus generated with an independent MPFR oracle checks
/// exact result bits through both the `scalbn` and `ldexp` names across normal,
/// subnormal, underflow, and overflow transitions, including extreme `Int`
/// exponents. Its maximum observed error is 0 ULP. The corpus passes in debug and
/// release mode on wasm, wasm-gc, JavaScript, and native and is also compared
/// with MoonBit Core. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/scalbn/README.md) for the corpus design
/// and reproduction commands.
///
/// ## References
///
/// - The public behavior follows POSIX
///   [`scalbn`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/scalbn.html)
///   and [`ldexp`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/ldexp.html)
///   for binary64 under round-to-nearest, ties-to-even.
/// - The staged scaling algorithm is derived from
///   [musl `scalbn.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/scalbn.c).
/// - The implementation is compatible with
///   [MoonBit Core `math.scalbn`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/scalbn.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(scalbn(1.5, 2), 6.0)
///   assert_eq(scalbn(1.0, -1074).reinterpret_as_uint64(), 1UL)
/// }
/// ```
#alias(ldexp)
pub fn scalbn(input : Double, exponent : Int) -> Double {
  let mut n = exponent
  let mut y = input
  if n > 1023 {
    y *= 0x1.0p1023
    n -= 1023
    if n > 1023 {
      y *= 0x1.0p1023
      n -= 1023
      if n > 1023 {
        n = 1023
      }
    }
  } else if n < -1022 {
    // Keep the final scale below 2^-53 so a subnormal result is rounded once.
    y *= 0x1.0p-1022 * 0x1.0p53
    n += 1022 - 53
    if n < -1022 {
      y *= 0x1.0p-1022 * 0x1.0p53
      n += 1022 - 53
      if n < -1022 {
        n = -1022
      }
    }
  }
  let scale_bits = (0x3ff + n).to_uint64() << 52
  return y * scale_bits.reinterpret_as_double()
}

///|
test "scalbn preserves signed zero, infinities, and NaN classification" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  let signaling_nan = 0x7ff0000000000001UL.reinterpret_as_double()
  for exponent in [-2147483648, -1074, 0, 1024, 2147483647] {
    assert_eq(
      scalbn(positive_zero, exponent).reinterpret_as_uint64(),
      0x0000000000000000UL,
    )
    assert_eq(
      scalbn(negative_zero, exponent).reinterpret_as_uint64(),
      0x8000000000000000UL,
    )
    assert_eq(
      scalbn(@double.infinity, exponent).reinterpret_as_uint64(),
      0x7ff0000000000000UL,
    )
    assert_eq(
      scalbn(@double.neg_infinity, exponent).reinterpret_as_uint64(),
      0xfff0000000000000UL,
    )
    assert_true(scalbn(quiet_nan, exponent).is_nan())
    assert_true(scalbn(signaling_nan, exponent).is_nan())
  }
}

///|
test "scalbn rounds normal and subnormal transitions to exact bits" {
  let cases : Array[(UInt64, Int, UInt64)] = [
    // Minimum normal scaled into the subnormal range.
    (0x0010000000000000UL, -1, 0x0008000000000000UL),
    // Maximum subnormal scaled into the normal range.
    (0x000fffffffffffffUL, 1, 0x001ffffffffffffeUL),
    // Exact minimum subnormal and the halfway value below it.
    (0x3ff0000000000000UL, -1074, 0x0000000000000001UL),
    (0x3ff0000000000000UL, -1075, 0x0000000000000000UL),
    // 3 * 2^-1075 is halfway and rounds to the even second subnormal.
    (0x4008000000000000UL, -1075, 0x0000000000000002UL),
    // Negative underflow preserves the sign of zero.
    (0xbff0000000000000UL, -1075, 0x8000000000000000UL),
    // Maximum finite scaled upward overflows with its sign.
    (0x7fefffffffffffffUL, 1, 0x7ff0000000000000UL),
    (0xffefffffffffffffUL, 1, 0xfff0000000000000UL),
  ]
  for item in cases {
    let (input_bits, exponent, expected_bits) = item
    assert_eq(
      scalbn(input_bits.reinterpret_as_double(), exponent).reinterpret_as_uint64(),
      expected_bits,
    )
  }
}

///|
test "scalbn handles the full Int exponent range" {
  assert_eq(
    scalbn(1.0, 2147483647).reinterpret_as_uint64(),
    0x7ff0000000000000UL,
  )
  assert_eq(
    scalbn(-1.0, 2147483647).reinterpret_as_uint64(),
    0xfff0000000000000UL,
  )
  assert_eq(
    scalbn(1.0, -2147483648).reinterpret_as_uint64(),
    0x0000000000000000UL,
  )
  assert_eq(
    scalbn(-1.0, -2147483648).reinterpret_as_uint64(),
    0x8000000000000000UL,
  )
}
