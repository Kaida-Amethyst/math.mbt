# `acosf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `acosf(Float) -> Float` implementation.

The generator evaluates `acos` with MPFR using downward and upward rounding.
It increases precision until both interval endpoints round to the same IEEE
754 binary32 value under round-to-nearest, ties-to-even. The generated MoonBit
test contains only fixed input and expected `UInt` bit patterns. Ordinary builds
and tests remain pure MoonBit.

The corpus checks this library and MoonBit Core against the same independent
1 ULP reference, and verifies decreasing order and the `[0, pi]` range over the
sampled real domain.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, infinities, and
  invalid-domain inputs;
- every signed binary32 exponent boundary and its neighboring inputs;
- the real-domain endpoints `-1` and `1`;
- implementation transitions at `2^-26` and `0.5`;
- deterministic raw-bit, valid-domain, branch-neighborhood, and tiny inputs;
- every maximum-error witness found during enlarged audits.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/acosf generate
make -C tools/oracle/acosf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/acosf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 28,405 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `acosf` stayed within the
same bound.

Tightening the default corpus to 0 ULP found a one-ULP witness: input
`0xbf7fde0a`, correctly rounded MPFR result `0x40470061`, and library result
`0x40470060`. The witness remains in the standard corpus.

The audit also found that the previous MoonBit translation had discarded the
low part of pi for zero and `-1`, used a cancellation-prone formula on the
negative half of the domain, and omitted the source implementation's truncated
square-root split on the positive half. The stable implementation restores the
pinned OpenLibm formulas; zero and `-1` are retained as migration regressions.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 170,940 unique inputs. The library stayed within 1 ULP and retained
sampled decreasing order and range in native debug and release mode. The audit
is not exhaustive or a formal proof, so the stable contract does not claim
correct rounding or globally proven monotonicity.
