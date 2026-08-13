# `hypotf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `hypotf(Float, Float) -> Float` implementation.

The generator evaluates `hypot` with MPFR using downward and upward rounding.
It increases precision until both interval endpoints round to the same IEEE
754 binary32 value under round-to-nearest, ties-to-even. Infinity takes
precedence over NaN, matching the public contract. The generated MoonBit test
contains only fixed input and expected `UInt` bit patterns, so ordinary builds
and tests remain pure MoonBit.

The corpus checks this library within 1 ULP, verifies symmetry, sign invariance,
and the lower bound by either input magnitude, and compares MoonBit Core against
the same independent reference where the reference result is finite.

## Corpus design

The fixed corpus includes:

- Cartesian combinations of zeros, subnormals, finite extrema, infinities, and
  NaN encodings;
- every binary32 exponent boundary and neighboring pairs;
- same-binade pairs and exponent gaps around 11, 12, 22, 23, 24, 74, and 75
  bits, where terms become negligible or intermediate squares become tiny;
- normal/subnormal transitions, the finite/overflow transition, and scaled
  Pythagorean triples;
- deterministic raw-bit, same-binade, exponent-gap, overflow-neighborhood, and
  subnormal random pairs.

## Regenerate or verify

```sh
brew install mpfr pkg-config
make -C tools/oracle/hypotf generate
make -C tools/oracle/hypotf verify
```

For an enlarged audit:

```sh
make -C tools/oracle/hypotf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 36,470 unique input pairs generated
with MPFR 4.2.2. The library agreed exactly with MPFR over that corpus. The
fixed 1 ULP corpus passed in debug and release mode on wasm, wasm-gc,
JavaScript, and native.

The previous Float-only implementation, shared with the inspected MoonBit Core
version, reached 2 ULP for `x=0x04eca996`, `y=0x003f7d1d`: MPFR rounded to
`0x04eca99f`, while the old result was `0x04eca99d`. It also returned maximum
finite `0x7f7fffff` for `x=y=0x7f3504f3`, where MPFR rounds to positive
infinity. Both cases are retained in the corpus. The stable implementation
widens binary32 inputs to binary64 before squaring; the entire binary32 input
range can be squared and summed there without intermediate range loss.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 179,796 unique pairs. It again agreed exactly with MPFR in native
debug mode and passed the 1 ULP contract in native release mode. This is not an
exhaustive enumeration of all binary32 pairs or a formal proof, so the stable
contract conservatively promises 1 ULP rather than correct rounding.
