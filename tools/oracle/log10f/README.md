# `log10f` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `log10f(Float) -> Float` implementation.

The generator evaluates `log10` with MPFR using directed-rounding intervals
until both endpoints round to the same IEEE 754 binary32 value. The generated
MoonBit test contains only fixed input and expected `UInt` bit patterns. MPFR,
GMP, a C compiler, `pkg-config`, and `make` are development-only dependencies;
ordinary builds and tests stay pure MoonBit.

MoonBit Core does not currently expose a binary32 base-10 logarithm, so MPFR is
the independent accuracy reference and no Core comparison is manufactured.

## Corpus design

The corpus covers IEEE 754 classes, every positive exponent boundary, every
argument-reduction boundary, the neighborhood of `1`, all representable
decimal powers from `1e-45` through `1e38` and their neighbors, four
deterministic random strata, and retained maximum-error witnesses.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/log10f generate
make -C tools/oracle/log10f verify
```

For an enlarged audit:

```sh
make -C tools/oracle/log10f generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the default corpus afterward.

## Audit record

On 2026-08-13, the default corpus contained 27,188 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native.

Tightening the default corpus to 0 ULP found a one-ULP witness: input
`0x05b504ec`, correctly rounded MPFR result `0xc20b136b`, and library result
`0xc20b136c`. The witness remains in the deterministic standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 141,544 unique inputs. The library stayed within 1 ULP in native
debug and release mode. The audit is not exhaustive or a formal proof, so the
stable contract promises at most 1 ULP and does not claim correct rounding.
