# `atanf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `atanf(Float) -> Float` implementation.

The generator evaluates `atan` with MPFR using downward and upward rounding.
It increases precision until both interval endpoints round to the same IEEE
754 binary32 value under round-to-nearest, ties-to-even. The generated MoonBit
test contains only fixed input and expected `UInt` bit patterns. Ordinary builds
and tests remain pure MoonBit.

The corpus checks this library against the configured 1 ULP bound, compares
MoonBit Core's `atanf` with the same independent reference, and verifies
bit-exact odd symmetry and monotonicity over the sampled extended real line.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every signed binary32 exponent boundary and its neighboring inputs;
- implementation transitions at `2^-12`, `7/16`, `11/16`, `19/16`, `39/16`,
  and `2^26`;
- deterministic raw-bit, exponent-stratified, branch-neighborhood, and tiny
  random inputs;
- every maximum-error and migration-regression witness found during audits.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/atanf generate
make -C tools/oracle/atanf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/atanf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 29,197 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `atanf` stayed within the
same accuracy bound.

The audit found a translation defect at the large-input transition. OpenLibm
adds both stored parts of π/2, `atanhi[3] + atanlo[3]`; the previous MoonBit
implementation replaced the low part with `2^-120`, losing one ULP and causing
a local monotonicity inversion at `±2^26`. The stable implementation restores
the upstream expression. Inputs `0x4c7fffff`, `0x4c800000`, `0xcc800000`, and
`0xcc7fffff` remain as exact regression cases.

Tightening the corrected implementation to 0 ULP found a one-ULP witness:
input `0xc3878000`, correctly rounded MPFR result `0xbfc896f1`, and library
result `0xbfc896f0`. The witness remains in the standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 171,771 unique inputs. The library stayed within 1 ULP and retained
sampled monotonicity and bit-exact odd symmetry in native debug and release
mode. This is not exhaustive or a formal proof, so the stable contract does not
claim correct rounding or globally proven monotonicity.
