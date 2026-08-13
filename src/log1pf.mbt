///|
/// Returns `log(1 + input)` as an IEEE 754 binary32 value, retaining accuracy
/// when `input` is close to zero. The same function is also exported as
/// `ln_1pf` for compatibility with MoonBit Core.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Negative infinity or a finite input below `-1.0` produces NaN.
/// - An input of exactly `-1.0` produces negative infinity.
/// - Positive and negative zero are returned unchanged.
/// - Subnormal inputs are supported and retain their sign.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input in the real domain, the result is within 1 ULP of
/// the exact value rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 33,225-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, the domain and implementation branch boundaries,
/// argument-reduction boundaries, cancellation near zero, and fixed-seed
/// stratified inputs. It passes in debug and release mode on wasm, wasm-gc,
/// JavaScript, and native, with a maximum observed error of 1 ULP; MoonBit
/// Core's `ln_1pf` is checked against the same bound. This is testing evidence,
/// not a formal proof. See the
/// [oracle documentation](../tools/oracle/log1pf/README.md) for the corpus
/// design, observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from the FreeBSD msun
///   [`s_log1pf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/s_log1pf.c)
///   implementation distributed by OpenLibm.
/// - The `ln_1pf` alias and public behavior are compatible with
///   [MoonBit Core `math.ln_1pf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/log.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(log1pf(0.0), 0.0)
///   assert_eq(log1pf(-1.0), @float.neg_infinity)
/// }
/// ```
#alias(ln_1pf)
pub fn log1pf(input : Float) -> Float {
  let float_ln2_hi : Float = 6.9314575195e-01
  let float_ln2_lo : Float = 1.4286067653e-06
  let mut ui : UInt = input.reinterpret_as_uint()
  let mut f : Float = 0.0
  let mut c : Float = 0.0
  let mut iu : UInt = 0U
  let one : Float = 1.0
  let mut k = 1
  if ui < 0x3ed413d0 || ui >> 31 > 0 {
    if ui >= 0xbf800000 {
      if input == -1.0 {
        return input / 0.0
      }
      return (input - input) / 0.0
    }
    if ui << 1 < 0x33800000U << 1 {
      return input
    }
    if ui <= 0xbe95f619 {
      k = 0
      c = 0.0
      f = input
    }
  } else if ui >= 0x7f800000 {
    return input
  }
  if k > 0 {
    ui = (one + input).reinterpret_as_uint()
    iu = ui
    iu += 0x3f800000U - 0x3f3504f3U
    k = (iu >> 23).reinterpret_as_int() - 0x7f
    if k < 25 {
      let fui = Float::reinterpret_from_uint(ui)
      c = if k >= 2 { one - (fui - input) } else { input - (fui - 1.0) }
      c /= Float::reinterpret_from_uint(ui)
    } else {
      c = 0.0
    }
    iu = (iu & 0x007fffff) + 0x3f3504f3
    ui = iu
    f = Float::reinterpret_from_uint(ui) - 1.0
  }
  let s = f / (f + 2.0)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = Float::from_int(k)
  s * (hfsq + r) + (dk * float_ln2_lo + c) - hfsq + f + dk * float_ln2_hi
}

///|
test "log1pf handles its domain and IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(log1pf(positive_zero).reinterpret_as_uint(), 0x00000000U)
  assert_eq(log1pf(negative_zero).reinterpret_as_uint(), 0x80000000U)
  assert_eq(log1pf(-1.0).reinterpret_as_uint(), 0xff800000U)
  assert_eq(log1pf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(log1pf(-1.0000001).is_nan())
  assert_true(log1pf(@float.neg_infinity).is_nan())
  assert_true(log1pf(quiet_nan).is_nan())
}

///|
test "log1pf preserves tiny inputs and ordinary reference values" {
  let cases : Array[(UInt, UInt)] = [
    (0x00000001U, 0x00000001U),
    (0x80000001U, 0x80000001U),
    (0xbf000000U, 0xbf317218U),
    (0x3f000000U, 0x3ecf991fU),
    (0x3f800000U, 0x3f317218U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = Float::reinterpret_from_uint(input_bits)
    assert_eq(log1pf(input).reinterpret_as_uint(), expected_bits)
  }
}
