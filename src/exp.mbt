///|
/// Returns the base-e exponential of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - `exp(NaN)` is NaN; no NaN payload is promised.
/// - `exp(+infinity)` is positive infinity.
/// - `exp(-infinity)` is positive zero.
/// - `exp(+0.0)` and `exp(-0.0)` are exactly `1.0`.
/// - Overflow produces positive infinity; underflow may produce a positive
///   subnormal value or positive zero.
/// - No floating-point status flags or `errno` behavior is promised.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact exponential
/// rounded to binary64 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Properties
///
/// A finite input produces a nonnegative result.
///
/// ## Verification
///
/// A 24,697-case fixed corpus was generated with an independent MPFR oracle.
/// Its maximum observed error is 1 ULP, and it passes in debug and release mode
/// on wasm, wasm-gc, JavaScript, and native. A pinned CORE-MATH hard-case audit
/// checked 1,129,371 non-NaN inputs on native in debug mode with the same bound.
/// This is testing evidence, not a formal proof. See the
/// [oracle documentation](../tools/oracle/exp/README.md) for the generation method,
/// known worst case, and reproduction commands.
///
/// ## References
///
/// - The range reduction and polynomial approximation are derived from
///   [fdlibm `e_exp.c`](https://android.googlesource.com/platform/bionic/+/4032c1e/libm/src/e_exp.c).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
/// - The hard-case audit uses the pinned
///   [CORE-MATH binary64 `exp` corpus](https://gitlab.inria.fr/core-math/core-math/-/blob/07cf01e12a42b82cc478341982936cad7f3f9bdc/src/binary64/exp/exp.wc).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(exp(0.0), 1.0)
///   assert_eq(exp(@double.neg_infinity), 0.0)
/// }
/// ```
pub fn exp(input : Double) -> Double {
  let mut x = input
  let one = 1.0
  let halF = [0.5, -0.5]
  let o_threshold = 7.09782712893383973096e+02
  let u_threshold = -7.45133219101941108420e+02
  let ln2HI = [6.93147180369123816490e-01, -6.93147180369123816490e-01]
  let ln2LO = [1.90821492927058770002e-10, -1.90821492927058770002e-10]
  let invln2 = 1.44269504088896338700e+00
  let p1 = 1.66666666666666019037e-01
  let p2 = -2.77777777770155933842e-03
  let p3 = 6.61375632143793436117e-05
  let p4 = -1.65339022054652515390e-06
  let p5 = 4.13813679705723846039e-08
  let e = 2.718281828459045
  let mut hi = 0.0
  let mut lo = 0.0
  let huge = 1.0e+300
  let twom1000 = 9.33263618503218878990e-302
  let two1023 = 8.988465674311579539e307
  let mut k : Int = 0
  let mut hx : UInt = @fpbits.high_word(input)
  let xsb : Int = ((hx >> 31) & 1).reinterpret_as_int()
  hx = hx & 0x7FFFFFFF
  if hx >= 0x40862E42 {
    if hx >= 0x7FF00000 {
      let lx : UInt = @fpbits.low_word(input)
      if ((hx & 0xFFFFF) | lx) != 0 {
        return input + input
      } else if xsb == 0 {
        return input
      } else {
        return 0.0
      }
    }
    if input > o_threshold {
      return huge * huge
    }
    if input < u_threshold {
      return twom1000 * twom1000
    }
  }
  if hx > 0x3FD62E42 {
    if hx < 0x3FF0A2B2 {
      if input == 1.0 {
        return e
      }
      hi = input - ln2HI[xsb]
      lo = ln2LO[xsb]
      k = 1 - xsb - xsb
    } else {
      k = (invln2 * input + halF[xsb]).to_int()
      let t = k.to_double()
      hi = input - t * ln2HI[0]
      lo = t * ln2LO[0]
    }
    x = hi - lo
  } else if hx < 0x3E300000 {
    if huge + x > one {
      return one + x
    }
  } else {
    k = 0
  }
  let t = x * x
  let twopk = if k >= -1021 {
    @fpbits.from_words(
      (0x3FF00000 + (k.reinterpret_as_uint() << 20).reinterpret_as_int()).reinterpret_as_uint(),
      0,
    )
  } else {
    @fpbits.from_words(
      0x3FF00000U + ((k + 1000).reinterpret_as_uint() << 20),
      0,
    )
  }
  let c = x - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))))
  if k == 0 {
    return one - (x * c / (c - 2.0) - x)
  }
  let y = one - (lo - x * c / (2.0 - c) - hi)
  if k >= -1021 {
    if k == 1024 {
      return y * 2.0 * two1023
    } else {
      return y * twopk
    }
  } else {
    return y * twopk * twom1000
  }
}

///|
test "exp special values follow the binary64 contract" {
  let positive_zero = 0x0000000000000000UL.reinterpret_as_double()
  let negative_zero = 0x8000000000000000UL.reinterpret_as_double()
  let quiet_nan = 0x7ff8000000000001UL.reinterpret_as_double()
  let signaling_nan = 0x7ff0000000000001UL.reinterpret_as_double()
  assert_eq(exp(positive_zero).reinterpret_as_uint64(), 0x3ff0000000000000UL)
  assert_eq(exp(negative_zero).reinterpret_as_uint64(), 0x3ff0000000000000UL)
  assert_eq(exp(@double.infinity).reinterpret_as_uint64(), 0x7ff0000000000000UL)
  assert_eq(
    exp(@double.neg_infinity).reinterpret_as_uint64(),
    0x0000000000000000UL,
  )
  assert_true(exp(quiet_nan).is_nan())
  assert_true(exp(signaling_nan).is_nan())
}

///|
test "exp finite extrema overflow and underflow with a positive sign" {
  let maximum_finite = 0x7fefffffffffffffUL.reinterpret_as_double()
  let negative_maximum_finite = 0xffefffffffffffffUL.reinterpret_as_double()
  assert_eq(exp(maximum_finite).reinterpret_as_uint64(), 0x7ff0000000000000UL)
  assert_eq(
    exp(negative_maximum_finite).reinterpret_as_uint64(),
    0x0000000000000000UL,
  )
}

///|
test "exp rounding transitions agree with the MPFR-derived bit patterns" {
  let transition_cases : Array[(UInt64, UInt64)] = [
    // One input step separates rounding to +0 from the minimum subnormal.
    (0xc0874910d52d3052UL, 0x0000000000000000UL),
    (0xc0874910d52d3051UL, 0x0000000000000001UL),
    // One input step separates the largest finite result from overflow.
    (0x40862e42fefa39efUL, 0x7fefffffffffff2aUL),
    (0x40862e42fefa39f0UL, 0x7ff0000000000000UL),
  ]
  for pair in transition_cases {
    let (input_bits, expect_bits) = pair
    assert_eq(
      exp(input_bits.reinterpret_as_double()).reinterpret_as_uint64(),
      expect_bits,
    )
  }
}
