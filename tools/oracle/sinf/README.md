# `sinf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `sinf(Float) -> Float` implementation.

The generator evaluates `sin` with MPFR using downward and upward rounding. It
increases precision until both interval endpoints round to the same IEEE 754
binary32 value under round-to-nearest, ties-to-even. The generated MoonBit test
contains only fixed input and expected `UInt` bit patterns. Ordinary builds and
tests remain pure MoonBit.

The corpus checks this library and MoonBit Core against the same independent
1 ULP reference and verifies bit-exact odd symmetry and the `[-1, 1]` range
over sampled finite inputs.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every signed binary32 exponent boundary and its neighboring inputs;
- neighborhoods of π/4, π/2, π, every musl direct-dispatch boundary
  through 9π/4, and the `0x4dc90fdb` medium/large reduction transition;
- deterministic raw-bit, exponent-stratified, reduction-neighborhood, and
  near-zero inputs;
- every maximum-error witness found during enlarged audits.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/sinf generate
make -C tools/oracle/sinf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/sinf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 30,011 unique inputs generated with
MPFR 4.2.2. It passed within 1 ULP and retained bit-exact odd symmetry and range
in debug and release mode on wasm, wasm-gc, JavaScript, and native. MoonBit Core
stayed within the same bound.

Tightening the standard corpus to 0 ULP found a one-ULP witness: input
`0xfb9177e1`, correctly rounded MPFR result `0x3f537bf4`, and library result
`0x3f537bf5`. The witness remains in the standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 172,993 unique inputs. The library stayed within 1 ULP and retained
bit-exact odd symmetry and range in native debug mode. The audit is not
exhaustive or a formal proof, so the stable contract does not claim correct
rounding.
