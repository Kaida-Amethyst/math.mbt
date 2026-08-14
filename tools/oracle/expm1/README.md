# `expm1` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `expm1(Double) -> Double` implementation.

The generator evaluates `expm1` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary64 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core against the same independent reference, and verifies the lower
range bound and monotonicity over the ordered corpus. MPFR, GMP, a C compiler,
`pkg-config`, and `make` are needed only to regenerate or verify the corpus;
ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every branch threshold in the FreeBSD-msun-derived implementation and its
  neighboring binary64 inputs;
- every argument-reduction cell boundary used before negative saturation or
  positive overflow;
- analytic transitions where negative results round to `-1.0` and positive
  results overflow to infinity;
- deterministic value-uniform, exponent-stratified, and reduction-cell random
  inputs;
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
make -C tools/oracle/expm1 generate
make -C tools/oracle/expm1 verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/expm1 generate SAMPLES_PER_STRATUM=32768 MAX_ULP=0
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 31,384 unique inputs generated with
MPFR 4.2.2. It passed within 1 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core also stayed within 1 ULP on the same
corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 117,400 unique inputs. It passed in native debug and release mode.
The following fixed input demonstrates the observed one-ULP error:

```text
input bits    = 0xc01205966f2b4f0f
MPFR result   = 0xbfefa57d86660311
actual result = 0xbfefa57d86660310
error         = 1 ULP
```

This disproves a correctly-rounded or zero-ULP claim for the current
implementation. The stable contract therefore promises at most 1 ULP. The
committed corpus was restored to its default size after the audit.
