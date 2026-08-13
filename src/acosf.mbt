///|
/// Returns the principal arc cosine of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Inputs outside `[-1.0, 1.0]`, including both infinities, produce NaN.
/// - Both positive and negative zero produce positive π/2.
/// - Inputs `1.0` and `-1.0` produce positive zero and positive π.
/// - Subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in `[-1.0, 1.0]`, the result is within 1 ULP of the
/// exact arc cosine rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 28,405-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every signed exponent boundary, the domain endpoints,
/// implementation transitions at `2^-26` and `0.5`, and fixed-seed stratified
/// inputs. It checks sampled monotonicity and range and passes in debug and
/// release mode on wasm, wasm-gc, JavaScript, and native, with a maximum observed
/// error of 1 ULP; MoonBit Core is checked against the same independent reference.
/// This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/acosf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reductions and rational approximation are derived from the
///   FreeBSD msun
///   [`e_acosf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_acosf.c)
///   implementation distributed by OpenLibm.
/// - The public behavior is compatible with
///   [MoonBit Core `math.acosf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/trig.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(acosf(1.0), 0.0)
///   assert_eq(acosf(0.0).reinterpret_as_uint(), 0x3fc90fdbU)
/// }
/// ```
pub fn acosf(input : Float) -> Float {
  let pi : Float = 3.1415925026
  let pio2_hi : Float = 1.5707962513
  let pio2_lo : Float = 7.5497894159e-08
  let ps0 : Float = 1.6666586697e-01
  let ps1 : Float = -4.2743422091e-02
  let ps2 : Float = -8.6563630030e-03
  let qs1 : Float = -7.0662963390e-01
  let one : Float = 1.0
  let two : Float = 2.0
  fn r(z : Float) -> Float {
    let p = z * (ps0 + z * (ps1 + z * ps2))
    let q = z * qs1 + 1.0
    p / q
  }

  let hx = input.reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix >= 0x3f800000 {
    if ix == 0x3f800000 {
      if hx >> 31 != 0 {
        return pi + two * pio2_lo
      }
      return 0.0
    }
    return @float.not_a_number
  }
  if ix < 0x3f000000 {
    if ix <= 0x32800000 {
      return pio2_hi + pio2_lo
    }
    return pio2_hi - (input - (pio2_lo - input * r(input * input)))
  }
  if hx >> 31 != 0 {
    let z = (input + 1.0) * 0.5
    let s = z.sqrt()
    let w = r(z) * s - pio2_lo
    return pi - two * (s + w)
  }
  let z = (one - input) * 0.5
  let s = z.sqrt()
  let df = Float::reinterpret_from_uint(s.reinterpret_as_uint() & 0xfffff000U)
  let c = (z - df * df) / (s + df)
  let w = r(z) * s + c
  two * (df + w)
}

///|
test "acosf handles its domain, endpoints, and zeros" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(acosf(positive_zero).reinterpret_as_uint(), 0x3fc90fdbU)
  assert_eq(acosf(negative_zero).reinterpret_as_uint(), 0x3fc90fdbU)
  assert_eq(acosf(1.0).reinterpret_as_uint(), 0x00000000U)
  assert_eq(acosf(-1.0).reinterpret_as_uint(), 0x40490fdbU)
  assert_true(acosf(Float::reinterpret_from_uint(0x3f800001U)).is_nan())
  assert_true(acosf(Float::reinterpret_from_uint(0xbf800001U)).is_nan())
  assert_true(acosf(@float.infinity).is_nan())
  assert_true(acosf(@float.neg_infinity).is_nan())
  assert_true(acosf(quiet_nan).is_nan())
}

///|
test "acosf covers its approximation transitions" {
  assert_eq(
    acosf(Float::reinterpret_from_uint(0x32800000U)).reinterpret_as_uint(),
    0x3fc90fdbU,
  )
  assert_eq(acosf(0.5).reinterpret_as_uint(), 0x3f860a92U)
  assert_eq(acosf(-0.5).reinterpret_as_uint(), 0x40060a92U)
}
