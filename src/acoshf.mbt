///|
/// Returns the inverse hyperbolic cosine of `input` as an IEEE 754 binary32
/// value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - A finite input below `1.0`, or negative infinity, produces NaN.
/// - An input of exactly `1.0` produces positive zero.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in the real domain, the result is within 2 ULP of
/// the exact inverse hyperbolic cosine rounded to binary32 with
/// round-to-nearest, ties-to-even. Correct rounding is not promised.
///
/// ## Verification
///
/// A 32,391-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754
/// classes, the domain boundary at `1`, every exponent boundary, implementation
/// transitions at `2` and `4096`, and fixed-seed stratified inputs. It checks
/// monotonicity over the real domain and passes in debug and release mode on
/// wasm, wasm-gc, JavaScript, and native. MoonBit Core is checked against the
/// same bound on its unaffected range `[1, 4096)`. The maximum observed error
/// is 2 ULP. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/acoshf/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The overflow-safe piecewise formulas are derived from musl
///   [`acoshf.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/acoshf.c?h=v1.2.5).
/// - The intended public behavior is compatible with MoonBit Core's `acoshf`;
///   current Core defects outside `[1, 4096)` are documented by the oracle
///   audit rather than copied into this implementation.
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(acoshf(1.0), 0.0)
///   assert_eq(acoshf(@float.infinity), @float.infinity)
/// }
/// ```
pub fn acoshf(input : Float) -> Float {
  if input.is_nan() {
    return input
  }
  if input < 1.0 {
    return @float.not_a_number
  }
  let bits = input.reinterpret_as_uint()
  let ln2 : Float = 0.693147180559945309417232121458176568
  if bits < 0x40000000U {
    let offset = input - 1.0
    return log1pf(offset + (offset * offset + (2.0 : Float) * offset).sqrt())
  }
  if bits < 0x45800000U {
    return logf(
      input * 2.0 - (1.0 : Float) / (input + (input * input - 1.0).sqrt()),
    )
  }
  logf(input) + ln2
}

///|
test "acoshf handles its domain and IEEE 754 special values" {
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(acoshf(1.0).reinterpret_as_uint(), 0x00000000U)
  assert_eq(acoshf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(acoshf(0.0).is_nan())
  assert_true(acoshf(-0.0).is_nan())
  assert_true(acoshf(-2.0).is_nan())
  assert_true(acoshf(-4096.0).is_nan())
  assert_true(acoshf(@float.neg_infinity).is_nan())
  assert_true(acoshf(quiet_nan).is_nan())
}

///|
test "acoshf is continuous across its implementation transitions" {
  let cases : Array[(UInt, UInt)] = [
    (0x3fffffffU, 0x3fa89213U),
    (0x40000000U, 0x3fa89214U),
    (0x457fffffU, 0x41102cb3U),
    (0x45800000U, 0x41102cb3U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let actual_bits = acoshf(Float::reinterpret_from_uint(input_bits)).reinterpret_as_uint()
    let error = if actual_bits >= expected_bits {
      actual_bits - expected_bits
    } else {
      expected_bits - actual_bits
    }
    assert_true(error <= 2U)
  }
}
