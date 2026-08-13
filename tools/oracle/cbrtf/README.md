# `cbrtf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `cbrtf(Float) -> Float` implementation.

The generator evaluates `cbrt` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core against the same independent reference, and verifies monotonicity
and bit-exact odd symmetry over the corpus.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every binary32 exponent boundary and its neighboring inputs;
- exactly representable integer cubes and their neighboring inputs;
- deterministic raw-bit, exponent-stratified, and cube-derived random inputs;
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
make -C tools/oracle/cbrtf generate
make -C tools/oracle/cbrtf verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/cbrtf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=0
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 20,525 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core stayed within the same bound.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 105,705 unique inputs. Both implementations again agreed exactly
with MPFR in native debug and release mode.

The upstream algorithm states that its final conversion is correctly rounded
in round-to-nearest mode, and no contrary input was found. The audit is not an
exhaustive binary32 test or a formal proof, however, so the stable contract
conservatively promises at most 1 ULP rather than correct rounding. The
committed corpus was restored to its standard size after the enlarged audit.
