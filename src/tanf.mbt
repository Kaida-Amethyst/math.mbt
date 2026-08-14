///|
/// Returns the tangent of `input` radians as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive and negative infinity produce NaN.
/// - Positive and negative zero are returned unchanged.
/// - Subnormal inputs are supported. Since no binary32 value is an exact odd
///   multiple of π/2, every finite binary32 input has a finite mathematical
///   tangent.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 2 ULP of the exact tangent
/// rounded to binary32 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 30,005-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, neighborhoods of the poles,
/// quadrant landmarks, the musl direct-dispatch boundaries, the medium/large
/// reduction transition, and fixed-seed stratified inputs. It checks bit-exact
/// odd symmetry and passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native, with a maximum observed error of 1 ULP. An enlarged
/// 173,006-case native debug audit passed the same bound. MoonBit Core is checked
/// against the same independent reference. This is testing evidence, not a
/// formal proof.
/// See the [oracle documentation](../tools/oracle/tanf/README.md) for the corpus
/// design, maximum-error witness, and reproduction commands.
///
/// ## References
///
/// - The binary64 kernel and argument-reduction implementation are derived from
///   musl libc
///   [`tanf.c`](https://git.musl-libc.org/cgit/musl/tree/src/math/tanf.c?id=f21a96538f78fa8e2040831b4209b35f2fb581da)
///   and its private helpers at commit
///   `f21a96538f78fa8e2040831b4209b35f2fb581da`; the large reducer is specialized
///   to its binary32 caller while retaining musl's constants and arithmetic.
/// - The public behavior is compatible with
///   [MoonBit Core `math.tanf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Reference results are generated independently with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(tanf(0.0), 0.0)
///   assert_eq(tanf(1.0).reinterpret_as_uint(), 0x3fc75923U)
/// }
/// ```
pub fn tanf(input : Float) -> Float {
  let bits = input.reinterpret_as_uint()
  let sign = bits >> 31 != 0U
  let magnitude = bits & 0x7fffffffU
  let x = input.to_double()
  let pi_over_two = 0x1.921fb54442d18p0
  if magnitude <= 0x3f490fdaU {
    if magnitude < 0x39800000U {
      return input
    }
    return musl_tandf(x, false)
  }
  if magnitude <= 0x407b53d1U {
    if magnitude <= 0x4016cbe3U {
      return musl_tandf(
        if sign {
          x + pi_over_two
        } else {
          x - pi_over_two
        },
        true,
      )
    }
    return musl_tandf(
      if sign {
        x + 2.0 * pi_over_two
      } else {
        x - 2.0 * pi_over_two
      },
      false,
    )
  }
  if magnitude <= 0x40e231d5U {
    if magnitude <= 0x40afeddfU {
      return musl_tandf(
        if sign {
          x + 3.0 * pi_over_two
        } else {
          x - 3.0 * pi_over_two
        },
        true,
      )
    }
    return musl_tandf(
      if sign {
        x + 4.0 * pi_over_two
      } else {
        x - 4.0 * pi_over_two
      },
      false,
    )
  }
  if magnitude >= 0x7f800000U {
    return input - input
  }
  let (remainder, quadrant) = musl_rem_pio2f(input)
  musl_tandf(remainder, (quadrant & 1) != 0)
}

///|
test "tanf handles non-finite values and signed zero" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(tanf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(tanf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_true(tanf(@float.infinity).is_nan())
  assert_true(tanf(@float.neg_infinity).is_nan())
  assert_true(tanf(quiet_nan).is_nan())
}

///|
test "tanf covers poles and musl range-reduction boundaries" {
  assert_eq(tanf(1.0).reinterpret_as_uint(), 0x3fc75923U)
  assert_eq(
    tanf(Float::reinterpret_from_uint(0x3fc90fdbU)).reinterpret_as_uint(),
    0xcbae8a4aU,
  )
  assert_eq(
    tanf(Float::reinterpret_from_uint(0x40e231d5U)).reinterpret_as_uint(),
    0x3f7ffff0U,
  )
  assert_eq(
    tanf(Float::reinterpret_from_uint(0x4dc90fdbU)).reinterpret_as_uint(),
    0xbf8cb742U,
  )
}
