# `tanh` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `tanh(Double) -> Double` implementation.

The generator evaluates `tanh` with MPFR using downward and upward rounding.
It increases precision until both directed-rounding interval endpoints round
to the same IEEE 754 binary64 value under round-to-nearest, ties-to-even.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. It checks this library and MoonBit Core against independently stated
2 ULP bounds, then verifies bit-exact odd symmetry, monotonicity, and the closed
range `[-1, 1]`. MPFR and the C toolchain are needed only to regenerate or
verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus covers IEEE 754 classes, all implementation thresholds and
their neighboring inputs, the analytic transitions where results round to
`-1.0` or `1.0`, deterministic value-uniform and exponent-stratified inputs,
branch-stratified inputs, and fixed maximum-error witnesses.

## Prerequisites and reproduction

```sh
brew install mpfr pkg-config
make -C tools/oracle/tanh generate
make -C tools/oracle/tanh verify
```

For a larger audit:

```sh
make -C tools/oracle/tanh generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 12,704 unique inputs generated with
MPFR 4.2.2. It passed within 2 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core stayed within 2 ULP on the same corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 98,720 unique inputs. It passed in native debug and release mode. The
following fixed input demonstrates the observed two-ULP error:

```text
input bits    = 0xbfe033d8e590f821
MPFR result   = 0xbfdde4a38fca2ebe
actual result = 0xbfdde4a38fca2ebc
error         = 2 ULP
```

The pinned OpenLibm implementation produces the same output bits for this
input. The stable contract therefore promises at most 2 ULP; correct rounding
is not claimed. The committed corpus is the default-sized one.
