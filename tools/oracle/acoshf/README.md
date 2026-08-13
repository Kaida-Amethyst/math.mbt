# `acoshf` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `acoshf(Float) -> Float` implementation.

The generator evaluates `acosh` with MPFR using downward and upward rounding.
It starts at 128 bits and doubles the precision until both interval endpoints
round to the same IEEE 754 binary32 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision or on the
implementation being tested.

The generated MoonBit test contains only fixed input and expected `UInt` bit
patterns. It checks this library against the configured 2 ULP bound and
verifies monotonicity over the real domain. MoonBit Core's `acoshf` is compared
on the unaffected range `[1, 4096)`; the installed Core implementation has
known defects outside that range and is not used as an oracle.
MPFR, GMP, a C compiler, `pkg-config`, and `make` are needed only to regenerate
or verify the corpus; ordinary builds and tests stay pure MoonBit.

## Corpus design

The fixed corpus includes:

- signed zeros, subnormals, normal values, finite extrema, and infinities;
- every signed binary32 exponent boundary and its neighboring inputs;
- the domain boundary at `1` and implementation transitions at `2` and `4096`;
- deterministic raw-bit, exponent-stratified, valid-domain,
  branch-neighborhood, and near-one random inputs;
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
make -C tools/oracle/acoshf generate
make -C tools/oracle/acoshf verify
```

For a larger audit of the candidate 2 ULP bound:

```sh
make -C tools/oracle/acoshf generate SAMPLES_PER_STRATUM=32768 MAX_ULP=2
```

Restore the standard corpus afterward with the default settings.

## Audit record

On 2026-08-13, the default corpus contained 32,391 unique inputs generated with
MPFR 4.2.2. It passed within the 2 ULP contract in debug and release mode on
wasm, wasm-gc, JavaScript, and native. MoonBit Core's `acoshf` stayed within the
same bound on its unaffected range `[1, 4096)`.

Tightening the default corpus to 1 ULP found a two-ULP witness: input
`0x3f803e90`, correctly rounded MPFR result `0x3d7d1184`, and library result
`0x3d7d1182`. The witness remains in the deterministic standard corpus.

An enlarged deterministic audit used 32,768 samples in each random stratum,
producing 203,093 unique inputs. Both the library and MoonBit Core on the
unaffected range stayed within 2 ULP in native debug and release mode. The
audit is not an exhaustive binary32 test or a formal proof, so the stable
contract promises at most 2 ULP and does not claim correct rounding. The
committed corpus was restored to its standard size after the enlarged audit.
