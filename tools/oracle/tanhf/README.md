# `tanhf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `tanhf(Float) -> Float` implementation.

The generator evaluates `tanh` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 2 ULP bound, checks
MoonBit Core against the same independent reference, and verifies the
`[-1.0, 1.0]` range, monotonicity, and bit-exact odd symmetry over the corpus.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every branch threshold in the FreeBSD-msun-derived implementation and its
  neighboring binary32 inputs;
- the analytic transitions where results round to positive or negative one;
- deterministic value-uniform, exponent-stratified, and branch-stratified
  random inputs;
- every maximum-error witness found during enlarged audits.

The seed, sample count, MPFR version, precision range, admitted error, and final
case count are embedded in the generated file.

## Prerequisites on macOS

```sh
brew install mpfr pkg-config
```

## Regenerate or verify

From the repository root:

```sh
make -C tools/oracle/tanhf generate
make -C tools/oracle/tanhf verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/tanhf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 12,727 unique inputs generated with
MPFR 4.2.2. It passed within 2 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core also stayed within 2 ULP on the same
corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 98,712 unique inputs. It passed in native debug and release mode. A
stricter 1 ULP run found this branch-boundary witness:

```text
input bits    = 0xbe82c576
MPFR result   = 0xbe7ffffd
actual result = 0xbe7ffffb
error         = 2 ULP
```

This disproves a correctly-rounded or 1 ULP claim for the current
implementation. The stable contract therefore promises at most 2 ULP. The
committed corpus was restored to its default size after the audit.
