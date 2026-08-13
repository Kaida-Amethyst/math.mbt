# `tanf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `tanf(Float) -> Float` implementation.

The generator evaluates `tan` with MPFR using downward and upward rounding. It
increases precision until both interval endpoints round to the same IEEE 754
binary32 value under round-to-nearest, ties-to-even. The generated MoonBit test
contains only fixed input and expected `UInt` bit patterns. Ordinary builds and
tests remain pure MoonBit.

The corpus checks this library and MoonBit Core against the same independent
2 ULP reference and verifies bit-exact odd symmetry over sampled finite inputs.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every signed binary32 exponent boundary and its neighboring inputs;
- neighborhoods of π/4, π/2, π, including inputs close to tangent's poles, and
  the implementation's `142.90625` fast/large range-reduction transition;
- deterministic raw-bit, exponent-stratified, reduction-neighborhood, and
  near-zero inputs;
- every maximum-error witness found during enlarged audits.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/tanf generate
make -C tools/oracle/tanf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/tanf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 28,972 unique inputs generated with
MPFR 4.2.2. It passed within 2 ULP and retained bit-exact odd symmetry in debug
and release mode on wasm, wasm-gc, JavaScript, and native. MoonBit Core stayed
within the same bound.

Tightening the standard corpus to 1 ULP found a two-ULP witness: input
`0xfd000002`, correctly rounded MPFR result `0xbfe6c2cf`, and library result
`0xbfe6c2d1`. The witness remains in the standard corpus. This confirms the
existing 2 ULP expectation for the fdlibm-derived reduced-interval polynomial;
the audit found no evidence of a migration regression requiring a replacement
implementation.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 171,784 unique inputs. The library stayed within 2 ULP and retained
bit-exact odd symmetry in native debug and release mode. The audit is not
exhaustive or a formal proof, so the stable contract does not claim correct
rounding.
