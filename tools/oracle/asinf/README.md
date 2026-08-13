# `asinf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `asinf(Float) -> Float` implementation.

The generator evaluates `asin` with MPFR using downward and upward rounding.
It increases precision until both interval endpoints round to the same IEEE
754 binary32 value under round-to-nearest, ties-to-even. The generated MoonBit
test contains only fixed input and expected `UInt` bit patterns. Ordinary builds
and tests remain pure MoonBit.

The corpus checks this library and MoonBit Core against the same independent
1 ULP reference, and verifies bit-exact odd symmetry and monotonicity over the
sampled real domain.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, infinities, and
  invalid-domain inputs;
- every signed binary32 exponent boundary and its neighboring inputs;
- the real-domain endpoints `-1` and `1`;
- implementation transitions at `2^-12` and `0.5`;
- deterministic raw-bit, valid-domain, branch-neighborhood, and tiny inputs;
- every maximum-error witness found during enlarged audits.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/asinf generate
make -C tools/oracle/asinf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/asinf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 28,410 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `asinf` stayed within the
same bound.

Tightening the default corpus to 0 ULP found a one-ULP witness: input
`0xbf30c1e8`, correctly rounded MPFR result `0xbf431a7f`, and library result
`0xbf431a80`. The witness remains in the standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 170,960 unique inputs. The library stayed within 1 ULP and retained
sampled monotonicity and bit-exact odd symmetry in native debug and release
mode. The audit is not exhaustive or a formal proof, so the stable contract
does not claim correct rounding or globally proven monotonicity.
