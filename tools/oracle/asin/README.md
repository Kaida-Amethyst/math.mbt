# `asin` MPFR oracle

This development-only generator certifies the binary64 `asin` implementation
against independently rounded MPFR results. It uses adaptive downward/upward
intervals until both endpoints round to the same binary64 value.

The corpus covers IEEE 754 classes, signed exponent boundaries, the real-domain
endpoints, implementation transitions at `2^-26`, `0.5`, and the high-word
split near `0.975`, representative integers, and four deterministic random
strata. Generated tests also check monotonicity and bit-exact odd symmetry over
`[-1, 1]`. Ordinary builds and tests remain pure MoonBit.

```sh
brew install mpfr pkg-config
make -C tools/oracle/asin generate
make -C tools/oracle/asin verify
```

The checked-in corpus contains 35,303 unique inputs. Its maximum observed error
is 1 ULP; input `0xbfef3333000fcd4d` is retained as a witness, for which MPFR
rounds to `0xbff58c2ae9ced889` and `asin` returns the adjacent
`0xbff58c2ae9ced888`. The same corpus passes in debug and release mode on wasm,
wasm-gc, JavaScript, and native. An enlarged native-debug run with 32,768
samples per random stratum covered 146,463 unique inputs and stayed within the
same bound.

This is sampled testing, not an exhaustive proof over all binary64 inputs.
