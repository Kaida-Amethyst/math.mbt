# `coshf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `coshf(Float) -> Float` implementation.

The generator evaluates `cosh` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core against the same independent reference, and verifies the lower
range bound and bit-exact even symmetry over the corpus.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every branch threshold in the FreeBSD-msun-derived implementation and its
  neighboring binary32 inputs;
- the analytic transitions where results for both signs overflow;
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
make -C tools/oracle/coshf generate
make -C tools/oracle/coshf verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/coshf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 12,832 unique inputs generated with
MPFR 4.2.2. It passed within 1 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core also stayed within 1 ULP on the same
corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 98,828 unique inputs. It passed in native debug and release mode. A
stricter zero-ULP run found this witness:

```text
input bits    = 0xc2b2d4fc
MPFR result   = 0x7f7fffec
actual result = 0x7f7fffed
error         = 1 ULP
```

This disproves a correctly-rounded or zero-ULP claim for the current
implementation. The stable contract therefore promises at most 1 ULP. The
committed corpus was restored to its default size after the audit.
