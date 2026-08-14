# `atan2f` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `atan2f(Float, Float) -> Float` implementation.

The generator evaluates `atan2(y, x)` with MPFR using downward and upward
rounding. It raises the working precision until both interval endpoints round
to the same IEEE 754 binary32 value under round-to-nearest, ties-to-even. The
generated MoonBit test contains only fixed input and expected `UInt` bit
patterns, so ordinary builds and tests remain pure MoonBit.

The corpus checks this library within 2 ULP. It also checks the `[-pi, pi]`
range and bit-exact reflection across the x-axis. Signed-zero, infinity, and
NaN combinations have small bit-level contract tests in `src/atan2f.mbt`.

## Corpus design

The fixed corpus includes:

- Cartesian combinations of signed zeros, subnormals, finite extrema,
  infinities, and NaN encodings;
- all four quadrants and the negative-x branch cut;
- every binary32 exponent field with representative mantissas and exponent
  gaps around 25, 26, and 27 bits, exercising both ratio shortcuts;
- neighborhoods of the implementation transitions at `|y/x| = 2^-26` and
  `|y/x| = 2^26`;
- the finite-quadrant regression cases fixed during promotion and the published
  large-error input pair for musl/OpenLibm, in both argument orders and all
  sign combinations;
- deterministic raw-bit, same-binade, transition-gap, extreme-gap, and
  branch-cut random pairs.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/atan2f generate
make -C tools/oracle/atan2f verify
```

For an enlarged audit:

```sh
make -C tools/oracle/atan2f generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
moon fmt
moon test --target native --package Kaida-Amethyst/math/test/atan2f --deny-warn
make -C tools/oracle/atan2f generate
moon fmt
```

The last two commands restore the standard corpus afterward.

## Audit record

On 2026-08-14, the default corpus contained 42,560 unique input pairs generated
with MPFR 4.2.2. The maximum observed error was 2 ULP. The witness
`y=0x7d508080`, `x=0x7e4cf8bf` rounded to `0x3e7f00f4` in MPFR while this
implementation returned `0x3e7f00f6`; it is retained as a fixed regression
case. Tightening the generated test to 1 ULP therefore fails as intended.

The standard corpus passed in debug and release mode on wasm, wasm-gc,
JavaScript, and native. An enlarged deterministic audit used 32,768 samples in
each random stratum, producing 185,823 unique pairs, and passed the 2 ULP bound
in native debug mode.

This is not an exhaustive enumeration of all binary32 input pairs and is not a
formal proof. A [published cross-library
search](https://members.loria.fr/PZimmermann/papers/accuracy.pdf) reports a
largest known real-ULP error of 1.55 for musl 1.2.5 and OpenLibm 0.8.7
`atan2f`; because a bivariate binary32 function has up to `2^64` input pairs,
that result is also a search lower bound rather than an exhaustive upper bound.
The public integer-ULP contract therefore remains the independently reproduced
2 ULP bound over the documented corpora.
