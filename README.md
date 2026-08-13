# Moonbit-Math Library

[中文版](#moonbit-math-数学库)

## Overview

Moonbit Math Library is a comprehensive collection of mathematical functions implemented in the Moonbit programming language. This library aims to provide high-precision mathematical operations. It includes a wide range of functions, such as trigonometric, exponential, logarithmic, and special functions, which are crucial for numerical computation. Its implementation is derived from various open-source projects, including Glibc-libm, C++-boost-math, Cephes, and Scipy, ensuring reliable accuracy.

## Installation

To use the Moonbit Math Library in your project, you can easily add it via the Moonbit package manager.

First, update the package index (highly recommended):

```bash
moon update
```

Then, run the following command to install:

```bash
moon add Kaida-Amethyst/math
```

## Usage

APIs that pass the stable promotion criteria are exported from
`Kaida-Amethyst/math`; `exp`, `expf`, `expm1f`, `sinhf`, `coshf`, `tanhf`,
`cbrtf`, `sqrtf`, `logf`, `log1pf`, its `ln_1pf` alias, `asinhf`, `atanhf`,
`scalbn`, its `ldexp` alias, and `scalbnf` are currently stable.
Remaining APIs are available from `Kaida-Amethyst/math/experimental` without a
stable behavior or accuracy guarantee.

Because the root package's default alias conflicts with Core's `@math`, import
it with an explicit alias:

```json
{
    "import": [
        {
            "path": "Kaida-Amethyst/math",
            "alias": "kmath"
        }
    ]
}
```

Then use the stable APIs as follows:

```moonbit
fn main {
  let result = @kmath.exp(1.0)
  println("exp(1) = \{result}")
  println("expf(1) = \{@kmath.expf(1.0)}")
  println("expm1f(1) = \{@kmath.expm1f(1.0)}")
  println("tanhf(1) = \{@kmath.tanhf(1.0)}")
  println("sinhf(1) = \{@kmath.sinhf(1.0)}")
  println("coshf(1) = \{@kmath.coshf(1.0)}")
  println("cbrtf(27) = \{@kmath.cbrtf(27.0)}")
  println("sqrtf(4) = \{@kmath.sqrtf(4.0)}")
  println("logf(2) = \{@kmath.logf(2.0)}")
  println("log1pf(1) = \{@kmath.log1pf(1.0)}")
  println("asinhf(1) = \{@kmath.asinhf(1.0)}")
  println("atanhf(0.5) = \{@kmath.atanhf(0.5)}")
  println("scalbn(1.5, 2) = \{@kmath.scalbn(1.5, 2)}")
  println("ldexp(1.5, 2) = \{@kmath.ldexp(1.5, 2)}")
  println("scalbnf(1.5, 2) = \{@kmath.scalbnf(1.5, 2)}")
}
```

Experimental functions require a separate import:

```json
{
    "import": [
        "Kaida-Amethyst/math/experimental"
    ]
}
```

```moonbit
fn main {
    let angle = 1.0
    println(@experimental.sin(angle))
}
```

## Supported Functions

As of version 0.1.17, Moonbit-Math supports the following functions:

### Trigonometric Functions

| Function Name | Description                                              |
| ------------- | -------------------------------------------------------- |
| `acos`        | Inverse cosine function.                                 |
| `asin`        | Inverse sine function.                                   |
| `atan`        | Inverse tangent function.                                |
| `atan2`       | Computes the arctangent of y/x, with the result in radians. |
| `cos`         | Cosine function.                                         |
| `cospi`       | Computes the cosine of `x * pi`.                         |
| `sin`         | Sine function.                                           |
| `sinc`        | Normalized sinc function, defined as sin(πx)/(πx).         |
| `sincos`      | Simultaneously computes the sine and cosine values.       |
| `sincospi`    | Simultaneously computes the sine and cosine of `x * pi`.  |
| `sinpi`       | Computes the sine of `x * pi`.                           |
| `tan`         | Tangent function.                                        |

### Hyperbolic Functions

| Function Name | Description              |
| ------------- | ------------------------ |
| `acosh`       | Inverse hyperbolic cosine. |
| `asinh`       | Inverse hyperbolic sine.   |
| `asinhf`      | **Stable.** Binary32 inverse hyperbolic sine within 1 ULP. |
| `atanh`       | Inverse hyperbolic tangent.|
| `atanhf`      | **Stable.** Binary32 inverse hyperbolic tangent within 1 ULP. |
| `cosh`        | Hyperbolic cosine.       |
| `sinh`        | Hyperbolic sine.         |
| `tanh`        | Hyperbolic tangent.      |

### Exponential and Logarithmic Functions

| Function Name | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `exp`         | **Stable.** Computes e raised to the power of x.             |
| `exp10`       | Base-10 exponential function.                                |
| `exp2`        | Base-2 exponential function.                                 |
| `expm1`       | Computes exp(x) - 1, offering better precision for small values. |
| `expx2`       | Computes x * 2<sup>n</sup>.                                 |
| `ilogb`       | Returns the integer base-2 exponent of x.                   |
| `inv_digamma` | Inverse of the `digamma` function.                         |
| `lgamma`      | Natural logarithm of the absolute value of the Gamma function. |
| `ln`          | Natural logarithm function (base e).                         |
| `ln_1p`       | Equivalent to `log1p`.                                       |
| `ln_1pf`      | **Stable alias of `log1pf`.**                                |
| `ln_gamma`    | Equivalent to `lgamma`.                                      |
| `log`         | Natural logarithm function (base e).                         |
| `log10`       | Base-10 logarithm function.                                 |
| `log1p`       | Computes the natural logarithm of 1 + x, for better precision with small values. |
| `log1pf`      | **Stable.** Computes binary32 `log1p` within 1 ULP.         |
| `log2`        | Base-2 logarithm function.                                  |
| `log_ndtr`    | Logarithm of the standard normal cumulative distribution function. |
| `logaddexp`   | Computes log(exp(x) + exp(y)) avoiding overflow.            |
| `logf`        | **Stable.** Computes binary32 natural logarithm within 1 ULP. |
| `logsumexp`   | Computes the logarithm of the sum of exponentials of an array. |
| `ndtr`        | Standard normal cumulative distribution function.             |
| `ndtri`       | Inverse of the standard normal cumulative distribution function. |
| `pow`         | Computes x raised to the power of y.                        |
| `powi`        | Computes the base as `Double` raised to the power of an `Int` exponent. |
| `pown`        | Computes the base as `Double` raised to the power of an `Int` exponent. |
| `rsqrt`       | Computes 1 / sqrt(x).                                       |
| `sqrt`        | Square root function.                                        |
| `sqrt1pm1`    | Computes sqrt(1 + x) - 1, for better precision with small values. |
| `zeta`        | Zeta function.                                             |

### Special Functions

| Function Name           | Description                                                              |
| ------------------------- | ------------------------------------------------------------------------ |
| `airy_ai`               | Airy function Ai.                                                        |
| `bessel_i0`             | Modified Bessel function of the first kind of order zero, I₀(x).        |
| `bessel_i0e`            | Scaled modified Bessel function of the first kind of order zero, exp(-|x|) * I₀(x). |
| `bessel_i1`             | Modified Bessel function of the first kind of order one, I₁(x).         |
| `bessel_i1e`            | Scaled modified Bessel function of the first kind of order one, exp(-|x|) * I₁(x). |
| `bessel_k0`             | Modified Bessel function of the second kind of order zero, K₀(x).       |
| `bessel_k0e`            | Scaled modified Bessel function of the second kind of order zero, exp(-x) * K₀(x). |
| `bessel_k1`             | Modified Bessel function of the second kind of order one, K₁(x).        |
| `bessel_k1e`            | Scaled modified Bessel function of the second kind of order one, exp(-x) * K₁(x). |
| `bessel_j0`             | Bessel function of the first kind of order zero, J₀(x).               |
| `bessel_j1`             | Bessel function of the first kind of order one, J₁(x).                |
| `bessel_jn`             | Bessel function of the first kind of order n, J<sub>n</sub>(x).          |
| `bessel_y0`             | Bessel function of the second kind of order zero, Y₀(x), also known as Neumann function N₀(x) or Weber function. |
| `bessel_y1`             | Bessel function of the second kind of order one, Y₁(x), also known as Neumann function N₁(x) or Weber function. |
| `bessel_yn`             | Bessel function of the second kind of order n, Y<sub>n</sub>(x), also known as Neumann function N<sub>n</sub>(x). |
| `i0`                      | Equivalent to `bessel_i0`.                                             |
| `i0e`                     | Equivalent to `bessel_i0e`.                                            |
| `i1`                      | Equivalent to `bessel_i1`.                                             |
| `i1e`                     | Equivalent to `bessel_i1e`.                                            |
| `j0`                      | Equivalent to `bessel_j0`.                                             |
| `j1`                      | Equivalent to `bessel_j1`.                                             |
| `jn`                      | Equivalent to `bessel_jn`.                                             |
| `k0`                      | Equivalent to `bessel_k0`.                                             |
| `k0e`                     | Equivalent to `bessel_k0e`.                                            |
| `k1`                      | Equivalent to `bessel_k1`.                                             |
| `k1e`                     | Equivalent to `bessel_k1e`.                                            |
| `y0`                      | Equivalent to `bessel_y0`.                                             |
| `y1`                      | Equivalent to `bessel_y1`.                                             |
| `yn`                      | Equivalent to `bessel_yn`.                                             |
| `erf`                     | Error function.                                                        |
| `erfc`                    | Complementary error function.                                          |
| `erfce`                   | Scaled complementary error function, exp(x²) * erfc(x).                 |
| `erfcinv`                 | Inverse of the complementary error function.                           |
| `erfcx`                   | Scaled complementary error function, exp(x²) * erfc(x).                 |
| `erfinv`                  | Inverse error function.                                                |
| `gamma`                   | Gamma function.                                                        |
| `gdtr`                    | Gamma distribution function.                                           |
| `gdtrc`                   | Complement of the gamma distribution function.                         |
| `polygamma`               | Polygamma function ψ<sup>(n)</sup>(x).                               |
| `trigamma`                | Trigamma function, the second polygamma function.                      |
| `digamma`                 | Digamma function, the first polygamma function.                       |
| `gegenbauer`              | Gegenbauer polynomial C<sup>(α)</sup><sub>n</sub>(x).                 |
| `gegenbauer_derivative`   | Derivative of the Gegenbauer polynomial.                               |
| `gegenbauer_prime`        | Derivative of the Gegenbauer polynomial.                               |
| `hermite`                 | Hermite polynomial H<sub>n</sub>(x).                                  |

### Other Functions

| Function Name | Description                                                               |
| ------------- | ------------------------------------------------------------------------- |
| `cbrt`        | Cube root function.                                                       |
| `cbrtf`       | **Stable.** Computes the binary32 cube root within 1 ULP.                 |
| `sqrtf`       | **Stable.** Delegates binary32 square root to `Float::sqrt`.              |
| `ceil`        | Ceiling function, rounds up to the nearest integer.                         |
| `clamp`       | Clamps a value within a specified range.                                  |
| `div_euclid`  | Computes the result of Euclidean division.                                |
| `entr`        | Computes the binary entropy -p * log2(p).                                  |
| `fdim`        | Computes max(x - y, 0).                                                   |
| `floor`       | Floor function, rounds down to the nearest integer.                         |
| `gelu`        | Gaussian Error Linear Unit activation function.                           |
| `hypot`       | Computes sqrt(x² + y²).                                                   |
| `isinf`       | Checks if a floating-point number is infinite.                            |
| `isnan`       | Checks if a floating-point number is NaN (Not a Number).                  |
| `isninf`      | Checks if a floating-point number is negative infinity.                   |
| `isnormal`    | Checks if a floating-point number is normal (neither zero, subnormal, infinite, nor NaN). |
| `ispinf`      | Checks if a floating-point number is positive infinity.                   |
| `issubnormal` | Checks if a floating-point number is subnormal.                            |
| `ldexp`       | **Stable alias of `scalbn`.** Computes x * 2<sup>exp</sup>.               |
| `lerp`        | Performs linear interpolation between two values.                          |
| `norm`        | Computes the Euclidean norm (L2 norm) of an array.                       |
| `norm3d`      | Computes the Euclidean norm of a 3D vector.                               |
| `norm4d`      | Computes the Euclidean norm of a 4D vector.                               |
| `normcdf`     | Standard normal cumulative distribution function.                           |
| `normcdfinv`  | Inverse of the standard normal cumulative distribution function.         |
| `rcbrt`       | Computes 1 / cbrt(x).                                                     |
| `rem_euclid`  | Computes the remainder of Euclidean division.                             |
| `rhypot`      | Computes 1 / sqrt(x² + y²).                                               |
| `rint`        | Rounds to the nearest integer.                                             |
| `rnorm`       | Computes the reciprocal of the Euclidean norm of an array.               |
| `round`       | Rounds to the nearest integer, away from zero.                             |
| `roundeven`   | Rounds to the nearest even integer.                                       |
| `expf`        | **Stable.** Computes e<sup>x</sup> for binary32 within 1 ULP.             |
| `expm1f`      | **Stable.** Computes e<sup>x</sup> - 1 for binary32 within 1 ULP.         |
| `tanhf`       | **Stable.** Computes the binary32 hyperbolic tangent within 2 ULP.        |
| `sinhf`       | **Stable.** Computes the binary32 hyperbolic sine within 2 ULP.           |
| `coshf`       | **Stable.** Computes the binary32 hyperbolic cosine within 1 ULP.         |
| `scalbn`      | **Stable.** Computes x * 2<sup>n</sup> with correct binary64 rounding.   |
| `scalbnf`     | **Stable.** Computes x * 2<sup>n</sup> with correct binary32 rounding.   |
| `signum`      | Returns the sign of a number: -1, 0, or 1.                                |
| `to_degrees`  | Converts radians to degrees.                                              |
| `to_radians`  | Converts degrees to radians.                                              |
| `trunc`       | Truncates towards zero.                                                   |

## Precision

Moonbit-Math uses ULP (Unit in the Last Place) to quantify precision. For further information on the definition of the Unit in the Last Place (ULP), please see Jean-Michel Muller’s paper "On the definition of ulp(x)", RR-5504, LIP RR-2005-09, INRIA, LIP. 2005, pp.16 at [https://hal.inria.fr/inria-00070503/document](https://hal.inria.fr/inria-00070503/document).

For floating-point functions, Moonbit-Math has currently measured the following maximum ULP values for reference. As the Moonbit-Math library further develops, the ULP precision of more functions will be measured, and algorithms for functions with larger ULP values will be gradually optimized to improve precision.

| Function Name | Max ULP |
| ------------- | ------- |
| `log`         | 0       |
| `log2`        | 1       |
| `log10`       | 0       |
| `log1p`       | 0       |
| `pow`         | 2       |
| `exp`         | 1       |
| `expf`        | 1       |
| `expm1f`      | 1       |
| `tanhf`       | 2       |
| `sinhf`       | 2       |
| `coshf`       | 1       |
| `scalbn`      | 0       |
| `ldexp`       | 0       |
| `scalbnf`     | 0       |
| `exp2`        | 1       |
| `exp10`       | 1       |
| `expm1`       | 0       |
| `cbrt`        | 0       |
| `cbrtf`       | 0       |
| `logf`        | 1       |
| `log1pf`      | 1       |
| `asinhf`      | 1       |
| `atanhf`      | 1       |
| `atan`        | 1       |
| `atan2`       | 1       |
| `asin`        | 1       |
| `acos`        | 1       |
| `acosh`       | 0       |
| `asinh`       | 0       |
| `atanh`       | 0       |
| `cosh`        | 0       |
| `sinh`        | 0       |
| `tanh`        | 0       |
| `cos`         | 0       |
| `sin`         | 0       |
| `tan`         | 0       |
| `cospi`       | 49      |
| `sinpi`       | 3       |
| `sqrt`        | 0       |
| `hypot`       | 1       |
| `erf`         | 1       |
| `erfc`        | 1       |
| `j0`          | 2       |
| `y0`          | 2       |
| `j1`          | 4       |
| `y1`          | 2       |
| `erfinv`      | 2       |
| `gamma`       | 4       |
| `lgamma`      | 23      |
| `trigamma`    | 14      |
| `digamma`     | 1023    |
| `zeta`        | 3       |

## Contributing

We welcome contributions to the Moonbit Math Library! If you find any issues or have suggestions for improvement, please feel free to submit an issue or pull request on our [GitHub repository](https://github.com/Kaida-Amethyst/moonbit-math).

## License

Moonbit Math Library is licensed under the Apache-2.0 License. For more details, see the [LICENSE](LICENSE) file.

---------

# Moonbit-Math 数学库

## 概述

Moonbit 数学库是一个在 Moonbit 编程语言中实现的数学函数集合。该库旨在提供高精度的数学运算，涵盖了三角函数、指数函数、对数函数和特殊函数等，这些函数对于数值计算至关重要。本库的实现参考了多个开源项目，包括 Glibc-libm、C++-boost-math、Cephes 和 Scipy，以确保可靠的精度。

## 安装

您可以通过 Moonbit 包管理器轻松地将 Moonbit 数学库添加到您的项目中。

首先，更新包索引（强烈建议）：

```bash
moon update
```

然后，运行以下命令进行安装：

```bash
moon add Kaida-Amethyst/math
```

## 使用

通过 stable 晋升门槛的 API 由 `Kaida-Amethyst/math` 根包导出；`exp`、`expf`、`expm1f`、
`sinhf`、`coshf`、`tanhf`、`cbrtf`、`sqrtf`、`logf`、`log1pf`、其别名
`ln_1pf`、`asinhf`、`atanhf`、`scalbn`、其别名 `ldexp` 以及 `scalbnf` 是当前 stable API。
其余 API 仍位于
`Kaida-Amethyst/math/experimental`，尚不提供稳定的行为或精度保证。

根包的默认别名会与 Core 的 `@math` 冲突，因此建议显式指定别名：

```json
{
    "import": [
        {
            "path": "Kaida-Amethyst/math",
            "alias": "kmath"
        }
    ]
}
```

然后可以使用 stable API：

```moonbit
fn main {
    let result = @kmath.exp(1.0)
    println("exp(1) = \{result}")
    println("expf(1) = \{@kmath.expf(1.0)}")
    println("expm1f(1) = \{@kmath.expm1f(1.0)}")
    println("tanhf(1) = \{@kmath.tanhf(1.0)}")
    println("sinhf(1) = \{@kmath.sinhf(1.0)}")
    println("coshf(1) = \{@kmath.coshf(1.0)}")
    println("cbrtf(27) = \{@kmath.cbrtf(27.0)}")
    println("sqrtf(4) = \{@kmath.sqrtf(4.0)}")
    println("logf(2) = \{@kmath.logf(2.0)}")
    println("log1pf(1) = \{@kmath.log1pf(1.0)}")
    println("asinhf(1) = \{@kmath.asinhf(1.0)}")
    println("atanhf(0.5) = \{@kmath.atanhf(0.5)}")
    println("scalbn(1.5, 2) = \{@kmath.scalbn(1.5, 2)}")
    println("ldexp(1.5, 2) = \{@kmath.ldexp(1.5, 2)}")
    println("scalbnf(1.5, 2) = \{@kmath.scalbnf(1.5, 2)}")
}
```

experimental 函数需要单独导入：

```json
{
    "import": [
        "Kaida-Amethyst/math/experimental"
    ]
}
```

```moonbit
fn main {
    let angle = 1.0
    println(@experimental.sin(angle))
}
```

## 支持的函数

截至当前 0.1.17 版本，Moonbit-Math 支持以下函数：

### 三角函数

| 函数名    | 描述                                     |
| --------- | ---------------------------------------- |
| `acos`    | 反余弦函数。                               |
| `asin`    | 反正弦函数。                               |
| `atan`    | 反正切函数。                               |
| `atan2`   | 计算给定的 y/x 的反正切（结果以弧度表示）。 |
| `cos`     | 余弦函数。                               |
| `cospi`   | 计算 `x * pi` 的余弦。                     |
| `sin`     | 正弦函数。                               |
| `sinc`    | 归一化 sinc 函数，定义为 sin(πx)/(πx)。      |
| `sincos`  | 同时计算正弦和余弦值。                       |
| `sincospi`| 同时计算 `x * pi` 的正弦和余弦值。          |
| `sinpi`   | 计算 `x * pi` 的正弦。                     |
| `tan`     | 正切函数。                               |

### 双曲函数

| 函数名    | 描述         |
| --------- | ------------ |
| `acosh`   | 反双曲余弦函数。 |
| `asinh`   | 反双曲正弦函数。 |
| `asinhf`  | **Stable。**计算 binary32 反双曲正弦，误差不超过 1 ULP。 |
| `atanh`   | 反双曲正切函数。 |
| `atanhf`  | **Stable。**计算 binary32 反双曲正切，误差不超过 1 ULP。 |
| `cosh`    | 双曲余弦函数。   |
| `sinh`    | 双曲正弦函数。   |
| `tanh`    | 双曲正切函数。   |

### 指数和对数函数

| 函数名      | 描述                               |
| ----------- | ---------------------------------- |
| `exp`       | **Stable。**计算 e 的 x 次方。          |
| `exp10`     | 以 10 为底的指数函数。                 |
| `exp2`      | 以 2 为底的指数函数。                  |
| `expm1`     | 计算 exp(x) - 1，用于提高小数值的精度。 |
| `expx2`     | 计算 x * 2<sup>n</sup>。             |
| `ilogb`     | 返回 x 的以 2 为底的指数部分的整数值。   |
| `inv_digamma` | `digamma` 函数的反函数。             |
| `lgamma`    | 伽马函数的绝对值的自然对数。           |
| `ln`        | 自然对数函数（以 e 为底）。             |
| `ln_1p`     | 等同于 `log1p`。                      |
| `ln_1pf`    | **`log1pf` 的 stable 别名。**         |
| `ln_gamma`  | 等同于 `lgamma`。                     |
| `log`       | 自然对数函数（以 e 为底）。             |
| `log10`     | 以 10 为底的对数函数。                 |
| `log1p`     | 计算 1 + x 的自然对数，用于提高小数值的精度。 |
| `log1pf`    | **Stable。**计算 binary32 的 `log1p`，误差不超过 1 ULP。 |
| `log2`      | 以 2 为底的对数函数。                  |
| `log_ndtr`  | 标准正态分布累积分布函数对数值。       |
| `logaddexp` | 计算 log(exp(x) + exp(y))，避免溢出。   |
| `logf`      | **Stable。**计算 binary32 自然对数，误差不超过 1 ULP。 |
| `logsumexp` | 计算数组中所有值的指数和的对数。         |
| `ndtr`      | 标准正态分布累积分布函数。             |
| `ndtri`     | 标准正态分布累积分布函数的反函数。       |
| `pow`       | 计算 x 的 y 次方。                     |
| `powi`      | 计算底数为 `Double` 类型，指数为 `Int` 类型的幂。 |
| `pown`      | 计算底数为 `Double` 类型，指数为 `Int` 类型的幂。 |
| `rsqrt`     | 计算 1 / sqrt(x)。                   |
| `sqrt`      | 平方根函数。                           |
| `sqrt1pm1`  | 计算 sqrt(1 + x) - 1，用于提高小数值的精度。 |
| `zeta`      | Zeta 函数。                           |

### 特殊函数

| 函数名              | 描述                                                                |
| ------------------- | ------------------------------------------------------------------- |
| `airy_ai`           | Airy 函数 Ai。                                                      |
| `bessel_i0`         | 第一类修正贝塞尔函数 I₀(x)。                                        |
| `bessel_i0e`        | 比例化的第一类修正贝塞尔函数 exp(-|x|) * I₀(x)。                       |
| `bessel_i1`         | 第一类修正贝塞尔函数 I₁(x)。                                        |
| `bessel_i1e`        | 比例化的第一类修正贝塞尔函数 exp(-|x|) * I₁(x)。                       |
| `bessel_k0`         | 第二类修正贝塞尔函数 K₀(x)。                                        |
| `bessel_k0e`        | 比例化的第二类修正贝塞尔函数 exp(-x) * K₀(x)。                        |
| `bessel_k1`         | 第二类修正贝塞尔函数 K₁(x)。                                        |
| `bessel_k1e`        | 比例化的第二类修正贝塞尔函数 exp(-x) * K₁(x)。                        |
| `bessel_j0`         | 第一类贝塞尔函数 J₀(x)。                                            |
| `bessel_j1`         | 第一类贝塞尔函数 J₁(x)。                                            |
| `bessel_jn`         | 第一类贝塞尔函数 J<sub>n</sub>(x)。                               |
| `bessel_y0`         | 第一类贝塞尔函数 y₀(x)。                                            |
| `bessel_y1`         | 第一类贝塞尔函数 y₁(x)。                                            |
| `bessel_yn`         | 第一类贝塞尔函数 y<sub>n</sub>(x)。                               |
| `i0`                | 等同于 `bessel_i0`。                                                 |
| `i0e`               | 等同于 `bessel_i0e`。                                                |
| `i1`                | 等同于 `bessel_i1`。                                                 |
| `i1e`               | 等同于 `bessel_i1e`。                                                |
| `j0`                | 等同于 `bessel_j0`。                                                 |
| `j1`                | 等同于 `bessel_j1`。                                                 |
| `jn`                | 等同于 `bessel_jn`。                                                 |
| `y0`                | 等同于 `bessel_y0`。                                                 |
| `y1`                | 等同于 `bessel_y1`。                                                 |
| `yn`                | 等同于 `bessel_yn`。                                                 |
| `k0`                | 等同于 `bessel_k0`。                                                 |
| `k0e`               | 等同于 `bessel_k0e`。                                                |
| `k1`                | 等同于 `bessel_k1`。                                                 |
| `k1e`               | 等同于 `bessel_k1e`。                                                |
| `y0`                | 第二类贝塞尔函数 Y₀(x)。也称为 Neumann 函数 N₀(x) 或 Weber 函数。 |
| `y1`                | 第二类贝塞尔函数 Y₁(x)。也称为 Neumann 函数 N₁(x) 或 Weber 函数。 |
| `yn`                | 第二类贝塞尔函数 Y<sub>n</sub>(x)。也称为 Neumann 函数 N<sub>n</sub>(x)。 |
| `erf`               | 误差函数。                                                          |
| `erfc`              | 互补误差函数。                                                        |
| `erfce`             | 比例化的互补误差函数 exp(x²) * erfc(x)。                               |
| `erfcinv`           | 互补误差函数的反函数。                                                  |
| `erfcx`             | 比例化的互补误差函数 exp(x²) * erfc(x)。                               |
| `erfinv`            | 误差函数的反函数。                                                    |
| `gamma`             | 伽马函数。                                                          |
| `gdtr`              | 伽马分布函数。                                                        |
| `gdtrc`             | 伽马分布函数的补函数。                                                  |
| `polygamma`         | 多伽马函数 ψ<sup>(n)</sup>(x)。                                   |
| `trigamma`          | 三伽马函数，是 digamma 函数的导数。                                |
| `digamma`           | 双伽马函数，是 lgamma 函数的导数。                                 |
| `gegenbauer`        | Gegenbauer 多项式 C<sup>(α)</sup><sub>n</sub>(x)。                 |
| `gegenbauer_derivative` | Gegenbauer 多项式的导数。                                          |
| `gegenbauer_prime`  | Gegenbauer 多项式的导数。                                          |
| `hermite`           | Hermite 多项式 H<sub>n</sub>(x)。                                |

### 其它函数

| 函数名        | 描述                                                                |
| ------------- | ------------------------------------------------------------------- |
| `cbrt`        | 立方根函数。                                                          |
| `cbrtf`       | **Stable。**计算 binary32 立方根，误差不超过 1 ULP。                  |
| `sqrtf`       | **Stable。**直接使用 `Float::sqrt` 计算 binary32 平方根。             |
| `ceil`        | 向上取整函数。                                                        |
| `clamp`       | 将值限制在给定的范围内。                                                |
| `div_euclid`  | 计算欧几里得除法的结果。                                                  |
| `entr`        | 计算以 2 为底的熵 -p * log2(p)。                                        |
| `fdim`        | 计算 max(x - y, 0)。                                                  |
| `floor`       | 向下取整函数。                                                        |
| `gelu`        | Gaussian Error Linear Unit 激活函数。                                   |
| `hypot`       | 计算 sqrt(x² + y²)。                                                  |
| `isinf`       | 检查浮点数是否为无穷大。                                                |
| `isnan`       | 检查浮点数是否为 NaN（非数值）。                                       |
| `isninf`      | 检查浮点数是否为负无穷大。                                              |
| `isnormal`    | 检查浮点数是否为正规数（既不是零、次正规数、无穷大也不是 NaN）。             |
| `ispinf`      | 检查浮点数是否为正无穷大。                                              |
| `issubnormal` | 检查浮点数是否为次正规数。                                              |
| `ldexp`       | **`scalbn` 的 stable 别名。**计算 x * 2<sup>exp</sup>。               |
| `lerp`        | 在两个值之间进行线性插值。                                                |
| `norm`        | 计算数组的欧几里得范数（L2 范数）。                                       |
| `norm3d`      | 计算三维向量的欧几里得范数。                                              |
| `norm4d`      | 计算四维向量的欧几里得范数。                                              |
| `normcdf`     | 标准正态分布累积分布函数。                                                |
| `normcdfinv`  | 标准正态分布累积分布函数的反函数。                                          |
| `rcbrt`       | 计算 1 / cbrt(x)。                                                    |
| `rem_euclid`  | 计算欧几里得除法的余数。                                                  |
| `rhypot`      | 计算 1 / sqrt(x² + y²)。                                              |
| `rint`        | 四舍五入到最接近的整数。                                                  |
| `rnorm`       | 计算数组的欧几里得范数的倒数。                                            |
| `round`       | 四舍五入到最接近的整数，远离零。                                            |
| `roundeven`   | 四舍五入到最接近的偶数。                                                  |
| `expf`        | **Stable。**计算 binary32 的 e<sup>x</sup>，误差不超过 1 ULP。       |
| `expm1f`      | **Stable。**计算 binary32 的 e<sup>x</sup> - 1，误差不超过 1 ULP。   |
| `tanhf`       | **Stable。**计算 binary32 双曲正切，误差不超过 2 ULP。               |
| `sinhf`       | **Stable。**计算 binary32 双曲正弦，误差不超过 2 ULP。               |
| `coshf`       | **Stable。**计算 binary32 双曲余弦，误差不超过 1 ULP。               |
| `scalbn`      | **Stable。**计算 x * 2<sup>n</sup>，并正确舍入到 binary64。         |
| `scalbnf`     | **Stable。**计算 x * 2<sup>n</sup>，并正确舍入到 binary32。         |
| `signum`      | 返回数字的符号：-1、0 或 1。                                               |
| `to_degrees`  | 将弧度转换为度。                                                        |
| `to_radians`  | 将度转换为弧度。                                                        |
| `trunc`       | 向零取整函数。                                                          |

## 精度说明

Moonbit-Math 使用 ULP（Unit in the Last Place）来衡量精度。有关 ULP 的详细信息，请参阅 Jean-Michel Muller 的论文 "On the definition of ulp(x)"，该论文可在 [https://hal.inria.fr/inria-00070503/document](https://hal.inria.fr/inria-00070503/document) 上找到。

对于浮点函数，Moonbit-Math 已经测量出以下函数的最大 ULP 值，供您参考。随着库的进一步发展，我们将测量更多函数的 ULP 精度，并逐步优化 ULP 值较大的函数。

| 函数名    | 最大 ULP |
| --------- | -------- |
| `log`     | 0        |
| `log2`    | 1        |
| `log10`   | 0        |
| `log1p`   | 0        |
| `pow`     | 2        |
| `exp`     | 1        |
| `expf`    | 1        |
| `expm1f`  | 1        |
| `tanhf`   | 2        |
| `sinhf`   | 2        |
| `coshf`   | 1        |
| `scalbn`  | 0        |
| `ldexp`   | 0        |
| `scalbnf` | 0        |
| `exp2`    | 1        |
| `exp10`   | 1        |
| `expm1`   | 0        |
| `cbrt`    | 0        |
| `cbrtf`   | 0        |
| `logf`    | 1        |
| `log1pf`  | 1        |
| `asinhf`  | 1        |
| `atanhf`  | 1        |
| `atan`    | 1        |
| `atan2`   | 1        |
| `asin`    | 1        |
| `acos`    | 1        |
| `acosh`   | 0        |
| `asinh`   | 0        |
| `atanh`   | 0        |
| `cosh`    | 0        |
| `sinh`    | 0        |
| `tanh`    | 0        |
| `cos`     | 0        |
| `sin`     | 0        |
| `tan`     | 0        |
| `cospi`   | 49       |
| `sinpi`   | 3        |
| `sqrt`    | 0        |
| `hypot`   | 1        |
| `erf`     | 1        |
| `erfc`    | 1        |
| `j0`      | 2        |
| `y0`      | 2        |
| `j1`      | 4        |
| `y1`      | 2        |
| `erfinv`  | 2        |
| `gamma`   | 4        |
| `lgamma`  | 23       |
| `trigamma`| 14       |
| `digamma` | 1023     |
| `zeta`    | 3        |

## 贡献

我们欢迎对 Moonbit 数学库的贡献！如果您发现任何问题或有改进建议，请随时在我们的 [GitHub 仓库](https://github.com/Kaida-Amethyst/moonbit-math) 上提交 issue 或 pull request。

## 许可证

Moonbit 数学库采用 Apache-2.0 许可证。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。
