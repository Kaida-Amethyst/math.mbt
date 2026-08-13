# `log1pf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `log1pf(Float) -> Float` implementation.

The generator evaluates `log1p` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core's `ln_1pf` against the same independent reference, and verifies
monotonicity over the real domain `[-1, +infinity]`.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- the domain boundary at `-1`, signed zero, and all implementation branches;
- positive binade boundaries and negative binades within the real domain;
- inputs for which `1+x` crosses an argument-reduction boundary;
- deterministic raw-bit, positive-domain, negative-domain, near-zero, and
  near-`-1` random inputs;
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
make -C tools/oracle/log1pf generate
make -C tools/oracle/log1pf verify
```

For a larger audit that searches for incorrectly rounded results:

```sh
make -C tools/oracle/log1pf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=0
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 33,225 unique inputs generated with
MPFR 4.2.2. It passed within the 1 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `ln_1pf` stayed within the
same bound.

Tightening the default corpus to 0 ULP found a one-ULP witness: input
`0xbf7fe95d`, correctly rounded MPFR result `0xc0ff10a5`, and library result
`0xc0ff10a4`. The witness remains in the deterministic standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 204,658 unique inputs. Both the library and MoonBit Core stayed within
1 ULP in native debug and release mode. The audit is not an exhaustive binary32
test or a formal proof, so the stable contract promises at most 1 ULP and does
not claim correct rounding. The committed corpus was restored to its standard
size after the enlarged audit.
