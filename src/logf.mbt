///|
const LG1_F : Float = 0.66666662693

///|
const LG2_F : Float = 0.40000972152

///|
const LG3_F : Float = 0.28498786688

///|
const LG4_F : Float = 0.24279078841

///|
/// Returns the natural logarithm of `input` as an IEEE 754 binary32 value.
///
/// ## Domain and special values
///
/// - A NaN input produces NaN; no NaN payload is promised.
/// - Positive infinity produces positive infinity.
/// - Positive and negative zero produce negative infinity.
/// - A negative finite input or negative infinity produces NaN.
/// - `logf(1.0)` is positive zero.
/// - Positive subnormal inputs are supported.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every positive finite input, the result is within 1 ULP of the exact
/// natural logarithm rounded to binary32 with round-to-nearest, ties-to-even.
/// Correct rounding is not promised.
///
/// ## Verification
///
/// A 25,794-case fixed corpus generated with an independent MPFR oracle covers
/// IEEE 754 classes, every exponent boundary, argument-reduction boundaries,
/// the neighborhood of `1.0`, and fixed-seed stratified inputs. It passes in
/// debug and release mode on wasm, wasm-gc, JavaScript, and native, with a
/// maximum observed error of 1 ULP; MoonBit Core's `lnf` is checked against the
/// same bound. This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/logf/README.md) for the corpus design,
/// observed maximum error, and reproduction commands.
///
/// ## References
///
/// - The range reduction and approximation are derived from the FreeBSD msun
///   [`e_logf.c`](https://github.com/JuliaMath/openlibm/blob/82e90aef0657289192efe77be89791c07dea0775/src/e_logf.c)
///   implementation distributed by OpenLibm.
/// - The public behavior is compatible with
///   [MoonBit Core `math.lnf`](https://github.com/moonbitlang/core/blob/ace5c88416720bbed83b1c55f2ab93d2ed68a8c2/math/log.mbt).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(logf(1.0), 0.0)
///   assert_eq(logf(0.0), @float.neg_infinity)
/// }
/// ```
pub fn logf(input : Float) -> Float {
  let float_ln2_hi : Float = 6.9314575195e-01
  let float_ln2_lo : Float = 1.4286067653e-06
  let mut x = input
  let x1p25 = Float::reinterpret_from_int(0x4c000000)
  let mut ix = x.reinterpret_as_int()
  let mut k = 0
  if ix < 0x00800000 || ix >> 31 != 0 {
    if ix << 1 == 0 {
      return (-1.0 : Float) / (x * x)
    }
    if ix >> 31 != 0 {
      return (x - x) / 0.0
    }
    k -= 25
    x *= x1p25
    ix = x.reinterpret_as_int()
  } else if ix >= 0x7f800000 {
    return x
  } else if ix == 0x3f800000 {
    return 0.0
  }
  ix += 0x3f800000 - 0x3f3504f3
  k += (ix >> 23) - 0x7f
  ix = (ix & 0x007fffff) + 0x3f3504f3
  x = Float::reinterpret_from_int(ix)
  let f = x - 1.0
  let s = f / ((2.0 : Float) + f)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = Float::from_int(k)
  s * (hfsq + r) + dk * float_ln2_lo - hfsq + f + dk * float_ln2_hi
}

///|
test "logf handles its domain and IEEE 754 special values" {
  let positive_zero = Float::reinterpret_from_uint(0x00000000U)
  let negative_zero = Float::reinterpret_from_uint(0x80000000U)
  let quiet_nan = Float::reinterpret_from_uint(0x7fc00001U)
  assert_eq(logf(positive_zero).reinterpret_as_uint(), 0xff800000U)
  assert_eq(logf(negative_zero).reinterpret_as_uint(), 0xff800000U)
  assert_eq(logf(1.0).reinterpret_as_uint(), 0x00000000U)
  assert_eq(logf(@float.infinity).reinterpret_as_uint(), 0x7f800000U)
  assert_true(logf(-1.0).is_nan())
  assert_true(logf(@float.neg_infinity).is_nan())
  assert_true(logf(quiet_nan).is_nan())
}

///|
test "logf covers subnormal and ordinary inputs" {
  let cases : Array[(UInt, UInt)] = [
    (0x00000001U, 0xc2ce8ed0U),
    (0x3f000000U, 0xbf317218U),
    (0x40000000U, 0x3f317218U),
    (0x7f7fffffU, 0x42b17218U),
  ]
  for pair in cases {
    let (input_bits, expected_bits) = pair
    let input = Float::reinterpret_from_uint(input_bits)
    assert_eq(logf(input).reinterpret_as_uint(), expected_bits)
  }
}
