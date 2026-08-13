# `scalbn` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `scalbn(Double, Int) -> Double` implementation.

For every finite nonzero input, the generator loads the binary64 value exactly
into MPFR, applies `mpfr_mul_2si`, and converts the exact scaled value to
binary64 with round-to-nearest, ties-to-even. Results are compared by their
complete `UInt64` representation: the admitted error is zero ULP. Zero and
infinity are handled directly so their sign is explicit; NaN payloads are not
part of the public contract and are tested only by classification.

The generated MoonBit test contains fixed `(input_bits, exponent,
expected_bits)` tuples. It checks both `@math.scalbn` and MoonBit Core's
`@core_math.scalbn`. MPFR, GMP, a C compiler, `pkg-config`, and `make` are
needed only to regenerate or verify the corpus; ordinary builds and tests stay
pure MoonBit.

## Corpus design

The fixed corpus combines:

- positive and negative zero, subnormals, normal values, finite extrema, and
  infinities;
- exponent values around every staged-scaling branch in the musl-derived
  implementation, plus the minimum and maximum MoonBit `Int`;
- input-specific neighborhoods where the result crosses zero/subnormal,
  subnormal/normal, and finite/infinity boundaries;
- deterministic random bit patterns with uniform, exponent-stratified, and
  full-`Int` exponent strata.

The seed, stratum size, MPFR version, and final case count are embedded in the
generated MoonBit file.

## Prerequisites on macOS

```sh
brew install mpfr pkg-config
```

## Regenerate or verify

From the repository root:

```sh
make -C tools/oracle/scalbn generate
make -C tools/oracle/scalbn verify
```

To increase each deterministic random stratum during an audit:

```sh
make -C tools/oracle/scalbn generate SAMPLES_PER_STRATUM=32768
```

The standard committed corpus should be restored with the default stratum
size after an enlarged audit.

## Audit record

On 2026-08-13, the default corpus contained 15,646 unique `(input, exponent)`
pairs generated with MPFR 4.2.2. It matched exactly in debug and release mode
on wasm, wasm-gc, JavaScript, and native, and every case also matched MoonBit
Core. The maximum observed error was zero ULP.

The three random strata were then enlarged from 4,096 to 32,768 samples each.
All 101,662 resulting unique cases matched MPFR exactly in native debug and
release mode. The committed corpus was restored to the default size after this
audit.
