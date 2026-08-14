# `atan2` MPFR oracle

This directory contains the development-only oracle used to certify
`atan2(Double, Double) -> Double`. The generator evaluates `atan2(y, x)` with
adaptive MPFR downward and upward rounding until both interval endpoints round
to the same IEEE 754 binary64 result. Generated tests contain only fixed bit
patterns, so ordinary builds and tests remain pure MoonBit.

The corpus covers Cartesian combinations of IEEE 754 classes, all four
quadrants, the signed-zero branch cut, representative mantissas across every
binary64 exponent, exponent gaps around 59, 60, and 61 bits, the two ratio
shortcuts, and five deterministic random-pair strata. It also checks the result
range and bit-exact reflection across the x-axis.

```sh
brew install mpfr pkg-config
make -C tools/oracle/atan2 generate
make -C tools/oracle/atan2 verify
```

The checked-in corpus contains 156,560 unique input pairs. Its maximum observed
error is 1 ULP. The witness `y=0x0005555555555555`,
`x=0x003aaaaaaaaaaaaa` rounds to `0x3fa9942597929f25` in MPFR while `atan2`
returns the adjacent `0x3fa9942597929f26`; it is retained independently of the
analytic generator. The same corpus passes in debug and release mode on wasm,
wasm-gc, JavaScript, and native. An enlarged native-debug run with 32,768
samples per random stratum covered 299,912 unique pairs and stayed within the
same bound.

This is sampled testing, not an exhaustive proof over all binary64 input pairs.
