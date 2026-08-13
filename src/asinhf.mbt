///|
/// Returns the inverse hyperbolic sine of `input` as an IEEE 754 binary32
/// value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity are returned unchanged.
/// - Positive and negative zero are returned unchanged.
/// - Every finite input is in the real domain; subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact inverse
/// hyperbolic sine rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 28,413-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, the implementation transitions
/// at `2^-12`, `2`, and `4096`, and fixed-seed stratified inputs. It checks
/// monotonicity and bit-exact odd symmetry and passes in debug and release mode
/// on wasm, wasm-gc, JavaScript, and native; MoonBit Core is checked against the
/// same bound. The maximum observed error is 1 ULP. This is testing evidence,
/// not a formal proof. See the
/// [oracle documentation](../tools/oracle/asinhf/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The overflow-safe piecewise formulas are derived from musl
///   [`asinhf.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/asinhf.c?h=v1.2.5).
/// - The public behavior is compatible with
///   [MoonBit Core `math.asinhf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/hyperbolic.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(asinhf(0.0), 0.0)
///   assert_eq(asinhf(@float.infinity), @float.infinity)
/// }
/// ```
pub fn asinhf(input : Float) -> Float {
  let bits = input.reinterpret_as_uint()
  let magnitude = bits & 0x7fffffff
  let negative = bits >> 31 != 0
  let ln2 : Float = 0.693147180559945309417232121458176568
  let absolute = Float::reinterpret_from_uint(magnitude)
  let result = if magnitude >= 0x45800000U {
    // Avoid overflow in the formulas that square or double the input.
    logf(absolute) + ln2
  } else if magnitude >= 0x40000000U {
    logf(
      absolute * 2.0 +
      (1.0 : Float) / (sqrtf(absolute * absolute + 1.0) + absolute),
    )
  } else if magnitude >= 0x39800000U {
    log1pf(
      absolute + absolute * absolute / (sqrtf(absolute * absolute + 1.0) + 1.0),
    )
  } else {
    absolute
  }
  if negative {
    -result
  } else {
    result
  }
}

///|
test "asinhf handles IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(asinhf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(asinhf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(asinhf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_eq(asinhf(@float.neg_infinity).reinterpret_as_uint(), 0xff800000U)
  assert_true(asinhf(quiet_nan).is_nan())
}

///|
test "asinhf covers all implementation transitions" {
  let cases : Array[(UInt, UInt)] = [
    (0x397fffffU, 0x397fffffU),
    (0x39800000U, 0x39800000U),
    (0x3fffffffU, 0x3fb8c90cU),
    (0x40000000U, 0x3fb8c90cU),
    (0x457fffffU, 0x41102cb3U),
    (0x45800000U, 0x41102cb3U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = Float::reinterpret_from_uint(input_bits)
    let actual_bits = asinhf(input).reinterpret_as_uint()
    let positive_error = if actual_bits >= expected_bits {
      actual_bits - expected_bits
    } else {
      expected_bits - actual_bits
    }
    let negative_expected_bits = expected_bits | 0x80000000U
    let negative_actual_bits = asinhf(-input).reinterpret_as_uint()
    let negative_error = if negative_actual_bits >= negative_expected_bits {
      negative_actual_bits - negative_expected_bits
    } else {
      negative_expected_bits - negative_actual_bits
    }
    assert_true(positive_error <= 1U)
    assert_true(negative_error <= 1U)
  }
}
