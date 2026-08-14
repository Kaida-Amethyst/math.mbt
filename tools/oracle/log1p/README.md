# `log1p` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `log1p(Double) -> Double` implementation and its `ln_1p` alias.

The generator evaluates `log1p` with MPFR using downward and upward rounding.
It increases precision until both interval endpoints round to the same IEEE
754 binary64 value under round-to-nearest, ties-to-even.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. It checks this library against a 1 ULP bound, checks MoonBit Core's
`ln_1p` against a separately stated 2 ULP comparison bound, verifies that both
library names are bit-identical, and checks monotonicity over the real domain.
MPFR and the C toolchain are needed only to regenerate or verify the corpus;
ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus covers IEEE 754 classes, both sides of the `x=-1` domain
boundary, all binary64 binades, implementation thresholds and neighboring
inputs, logarithmic reduction boundaries of `1+x`, cancellation near zero,
positive and valid-negative exponent strata, raw finite inputs, and fixed
maximum-error witnesses.

## Prerequisites and reproduction

```sh
brew install mpfr pkg-config
make -C tools/oracle/log1p generate
make -C tools/oracle/log1p verify
```

For a larger audit:

```sh
make -C tools/oracle/log1p generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 75,772 unique inputs generated with
MPFR 4.2.2. It passed within 1 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core stayed within 2 ULP on the same corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 247,800 unique inputs. It passed in native debug and release mode.
The following fixed input demonstrates the observed one-ULP error:

```text
input bits    = 0xbfefffffffffff45
MPFR result   = 0xc03f8175071f391b
actual result = 0xc03f8175071f391c
error         = 1 ULP
```

This disproves a correctly-rounded claim. The stable contract promises at most
1 ULP, and the committed corpus is the default-sized one.
