# `sinh` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `sinh(Double) -> Double` implementation.

The generator evaluates `sinh` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary64 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. It checks this library against the configured 2 ULP bound, checks
MoonBit Core against a separately stated 2 ULP comparison bound, and verifies
bit-exact odd symmetry and monotonicity over the ordered corpus. MPFR, GMP, a C
compiler, `pkg-config`, and `make` are needed only to regenerate or verify the
corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every branch threshold in the FreeBSD-msun-derived implementation and its
  neighboring binary64 inputs;
- the analytic transitions where positive and negative results overflow;
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
make -C tools/oracle/sinh generate
make -C tools/oracle/sinh verify
```

For a larger audit:

```sh
make -C tools/oracle/sinh generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-14, the default corpus contained 14,151 unique inputs generated with
MPFR 4.2.2. It passed within 2 ULP in debug and release mode on wasm, wasm-gc,
JavaScript, and native. MoonBit Core also stayed within 2 ULP on the same
corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 100,162 unique inputs. It passed in native debug and release mode.
The following fixed input demonstrates the observed two-ULP error:

```text
input bits    = 0xbfeabc3c7931e986
MPFR result   = 0xbfedf4bb646aaa74
actual result = 0xbfedf4bb646aaa72
error         = 2 ULP
```

The pinned OpenLibm implementation produces the same output bits for this
input. The evidence therefore distinguishes an inherited upstream accuracy
limit from a MoonBit porting error. The stable contract promises at most 2 ULP;
correct rounding is not claimed. The committed corpus is the default-sized
one.
