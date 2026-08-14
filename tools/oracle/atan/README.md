# `atan` MPFR oracle

This development-only generator certifies the binary64 `atan` implementation
against independently rounded MPFR results. It uses adaptive downward/upward
intervals until both endpoints round to the same binary64 value.

The corpus covers IEEE 754 classes, signed exponent boundaries, every fdlibm
range-reduction transition and its bit neighbors, representative integers, and
four deterministic random strata. Generated tests also check monotonicity and
bit-exact odd symmetry. Ordinary builds and tests remain pure MoonBit.

```sh
brew install mpfr pkg-config
make -C tools/oracle/atan generate
make -C tools/oracle/atan verify
```

The checked-in corpus contains 35,875 unique inputs. Its maximum observed error
is 1 ULP; input `0xc06c800000000000` (`-228.0`) is retained as a witness, for
which MPFR rounds to `0xbff9100457530d9d` and `atan` returns the adjacent
`0xbff9100457530d9e`. The same corpus passes in debug and release mode on wasm,
wasm-gc, JavaScript, and native. An enlarged native-debug run with 32,768
samples per random stratum covered 147,109 unique inputs and stayed within the
same bound.

This is sampled testing, not an exhaustive proof over all binary64 inputs.
