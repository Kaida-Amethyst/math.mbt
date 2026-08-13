# `exp` MPFR oracle

This directory contains the development-only oracle used to certify the
MoonBit `Double -> Double` implementation of `exp`.

The generator evaluates `exp` with MPFR using both downward and upward
rounding. It starts at 128 bits and doubles the precision until both interval
endpoints round to the same IEEE 754 binary64 value under round-to-nearest,
ties-to-even. This avoids relying on an arbitrary fixed precision and avoids a
possible double-rounding error.

The generated MoonBit test contains only fixed input and expected `UInt64` bit
patterns. MPFR, GMP, a C compiler, `pkg-config`, and `make` are required only to
regenerate or verify the corpus; they are not build, test, or runtime
dependencies of the published MoonBit library.

## Prerequisites on macOS

```sh
brew install mpfr pkg-config
```

## Regenerate the committed corpus

From this directory:

```sh
make generate
```

To use a larger random stratum during an audit:

```sh
make generate SAMPLES_PER_STRATUM=32768
```

The generator can also consume an additional text corpus containing one
decimal or hexadecimal floating-point input per line. Blank lines and lines
beginning with `#` are ignored:

```sh
build/generate --input-file /path/to/exp-inputs.txt > exp_oracle_test.mbt
```

For an audit that searches specifically for any incorrectly rounded result,
set the admitted error to zero:

```sh
build/generate --max-ulp 0 --input-file /path/to/exp-inputs.txt \
  > exp_oracle_test.mbt
```

The default corpus includes:

- IEEE 754 zeros, subnormals, normals, finite extrema, and infinities;
- the implementation's high-word branch transitions and their neighbors;
- analytic underflow, subnormal, normal, and overflow rounding transitions;
- every argument-reduction cell boundary in the usable `exp` range;
- fixed-seed samples that are uniform by value, stratified by binary exponent,
  and distributed through argument-reduction cells.

The fixed cases also retain every worst-case witness found during an external
audit. The current corpus includes a one-ULP witness found with the
[CORE-MATH binary64 `exp` hard-case inputs](https://gitlab.inria.fr/core-math/core-math/-/blob/07cf01e12a42b82cc478341982936cad7f3f9bdc/src/binary64/exp/exp.wc).

## Certification record

On 2026-08-12, the CORE-MATH corpus at commit
`07cf01e12a42b82cc478341982936cad7f3f9bdc` was split into ten batches and all
1,129,371 non-NaN inputs were checked against MPFR 4.2.2. No result exceeded
one ULP. The maximum-error witness retained by the default corpus is input bits
`0xc086f6872b5f94e6`: the correctly rounded result is `0x0000000000003b15`,
while this implementation returns `0x0000000000003b14` on wasm, wasm-gc,
JavaScript, and native.

The default 24,697-case corpus passed in debug and release mode on all four
backends with MoonBit 0.1.20260803. The ordinary test run remained pure
MoonBit; MPFR and CORE-MATH were used only for offline generation and audit.

Run `make verify` to regenerate into a temporary file and compare it byte for
byte with `src/test/exp_oracle_test.mbt`.
