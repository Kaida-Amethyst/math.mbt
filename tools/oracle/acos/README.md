# `acos` MPFR oracle

This development-only generator certifies the binary64 `acos` implementation
against independently rounded MPFR results. It uses adaptive downward/upward
intervals until both endpoints round to the same binary64 value.

The corpus covers IEEE 754 classes, signed exponent boundaries, the real-domain
endpoints, the high-word tiny shortcut near `2^-57`, the `0.5` range-reduction
boundary, representative integers, and four deterministic random strata.
Generated tests also check decreasing order and the `[0, π]` range over
`[-1, 1]`. Ordinary builds and tests remain pure MoonBit.

```sh
brew install mpfr pkg-config
make -C tools/oracle/acos generate
make -C tools/oracle/acos verify
```

The checked-in corpus contains 35,319 unique inputs. Its maximum observed error
is 1 ULP; input `0xbfe0b994d4cde728` is retained as a witness, for which MPFR
rounds to `0x4000f74f9d6a0bf3` and `acos` returns the adjacent
`0x4000f74f9d6a0bf2`. The same corpus passes in debug and release mode on wasm,
wasm-gc, JavaScript, and native. An enlarged native-debug run with 32,768
samples per random stratum covered 146,612 unique inputs and stayed within the
same bound.

Promotion also restored the source algorithm's positive-half square-root
split: the high part has its low 32 bits cleared and the discarded part is
recovered through a correction term. The previous translation used the full
root as its own high part, which made that correction identically zero.

This is sampled testing, not an exhaustive proof over all binary64 inputs.
