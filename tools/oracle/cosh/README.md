# `cosh` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `cosh(Double) -> Double` implementation.

The generator evaluates `cosh` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary64 value under round-to-nearest,
ties-to-even.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. It checks this library against the configured 1 ULP bound, checks
MoonBit Core against a separately stated 2 ULP comparison bound, and verifies
bit-exact even symmetry and the lower range bound. MPFR, GMP, a C compiler,
`pkg-config`, and `make` are needed only to regenerate or verify the corpus;
ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every implementation branch threshold and neighboring binary64 inputs;
- the analytic positive and negative overflow transitions;
- deterministic value-uniform, exponent-stratified, and branch-stratified
  random inputs;
- every maximum-error witness found during enlarged audits.

The seed, sample count, MPFR version, precision range, admitted error, and final
case count are embedded in the generated file.

## Prerequisites and reproduction

```sh
brew install mpfr pkg-config
make -C tools/oracle/cosh generate
make -C tools/oracle/cosh verify
```

For a larger audit:

```sh
make -C tools/oracle/cosh generate SAMPLES_PER_STRATUM=32768 MAX_ULP=1
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 14,156 unique inputs generated with
MPFR 4.2.2. It passed within 1 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core stayed within 2 ULP on the same corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 100,172 unique inputs. It passed in native debug and release mode.
The following fixed input demonstrates the observed one-ULP error:

```text
input bits    = 0xc08633ce8fb9f87d
MPFR result   = 0x7feffffffffffd3b
actual result = 0x7feffffffffffd3c
error         = 1 ULP
```

This disproves a correctly-rounded claim. The stable contract promises at most
1 ULP, and the committed corpus is the default-sized one.
