# `logf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `logf(Float) -> Float` implementation.

The generator evaluates `log` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core's `lnf` against the same independent reference, and verifies
monotonicity over the positive domain.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every positive binary32 exponent boundary and its neighboring inputs;
- the exact-zero result at `x = 1` and every argument-reduction boundary;
- deterministic raw-bit, exponent-stratified, positive-domain, and near-one
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
make -C tools/oracle/logf generate
make -C tools/oracle/logf verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/logf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=0
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 25,794 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `lnf` stayed within the
same bound.

Tightening the default corpus to 0 ULP found a one-ULP witness: input
`0x00d110ba`, correctly rounded MPFR result `0xc2adb11d`, and library result
`0xc2adb11e`. The witness remains in the deterministic standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 140,162 unique inputs. Both the library and MoonBit Core stayed within
1 ULP in native debug and release mode. The audit is not an exhaustive binary32
test or a formal proof, so the stable contract promises at most 1 ULP and does
not claim correct rounding. The committed corpus was restored to its standard
size after the enlarged audit.
