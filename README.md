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

To use the moonbit-math package in your project, add the following dependency to your `moon.pkg.json` file:

```json
{
    "import" :[
        "Kaida-Amethyst/math"
    ]
}
```

After that, you can use the mathematical functions in your package, for example:

```moonbit
fn main {
    let angle = 1.0 // in radians
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

**Note:** The above method of adding the package will override the usage of the `math` package in the Core standard library. Moonbit-Math maintains compatibility with the `math` library in Moonbit's Core standard library. This means that using common mathematical functions like `sin`, `cosh`, `cbrt`, etc., in both Core and Moonbit-Math will result in consistent behavior.

If you need to differentiate between using the `math` package from the Core standard library and the Moonbit-Math package, you need to configure your `moon.pkg.json` file as follows:

```json
{
    "import" :[
        {
            "path": "Kaida-Amethyst/math",
            "alias" : "kmath"
        }
    ]
}
```

Then, you can use the mathematical functions in your code with the alias:

```moonbit
fn main {
    let angle = 1.0
    let result1 = @kmath.sin(angle)    // use Moonbit-Math's sin function
    let result2 = @math.sin(angle)      // use Core-Math's sin function
    println("Moonbit-Math: The sine of \{angle} is \{result1}")
    println("Core: The sine of \{angle} is \{result2}")
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
| `atanh`       | Inverse hyperbolic tangent.|
| `cosh`        | Hyperbolic cosine.       |
| `sinh`        | Hyperbolic sine.         |
| `tanh`        | Hyperbolic tangent.      |

### Exponential and Logarithmic Functions

| Function Name | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `exp`         | Exponential function, computes e raised to the power of x.   |
| `exp10`       | Base-10 exponential function.                                |
| `exp2`        | Base-2 exponential function.                                 |
| `expm1`       | Computes exp(x) - 1, offering better precision for small values. |
| `expx2`       | Computes x * 2<sup>n</sup>.                                 |
| `ilogb`       | Returns the integer base-2 exponent of x.                   |
| `inv_digamma` | Inverse of the `digamma` function.                         |
| `lgamma`      | Natural logarithm of the absolute value of the Gamma function. |
| `ln`          | Natural logarithm function (base e).                         |
| `ln_1p`       | Equivalent to `log1p`.                                       |
| `ln_gamma`    | Equivalent to `lgamma`.                                      |
| `log`         | Natural logarithm function (base e).                         |
| `log10`       | Base-10 logarithm function.                                 |
| `log1p`       | Computes the natural logarithm of 1 + x, for better precision with small values. |
| `log1pf`      | Computes `log1p` for `Float` type.                         |
| `log2`        | Base-2 logarithm function.                                  |
| `log_ndtr`    | Logarithm of the standard normal cumulative distribution function. |
| `logaddexp`   | Computes log(exp(x) + exp(y)) avoiding overflow.            |
| `logf`        | Computes the natural logarithm for `Float` type.             |
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
| `ldexp`       | Computes x * 2<sup>exp</sup>.                                             |
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
| `scalbn`      | Computes x * 2<sup>n</sup>.                                             |
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
| `exp2`        | 1       |
| `exp10`       | 1       |
| `expm1`       | 0       |
| `cbrt`        | 0       |
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

要在您的 package 中使用 Moonbit-Math，请在其 `moon.pkg.json` 文件中添加以下依赖：

```json
{
    "import" :[
        "Kaida-Amethyst/math"
    ]
}
```

之后，您就可以在该 package 中使用数学函数了，例如：

```moonbit
fn main {
    let angle = 1.0 // 以弧度为单位
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

**注意：** 上述添加包的方法会覆盖掉 Core 标准库中的 `math` 包。Moonbit-Math 与 Moonbit 语言标准库 Core 中的 `math` 库保持了兼容性。这意味着使用 Core 和 Moonbit-Math 中共同的数学函数（例如 `sin`、`cosh`、`cbrt` 等）将具有一致的行为。

如果您需要区分使用标准库 Core 的 `math` 包和 Moonbit-Math 的 `math` 包，请在 `moon.pkg.json` 中进行如下配置：

```json
{
    "import" :[
        {
            "path": "Kaida-Amethyst/math",
            "alias" : "kmath"
        }
    ]
}
```

然后，您可以在您的代码中通过别名来使用 Moonbit-Math 的函数：

```moonbit
fn main {
    let angle = 1.0
    let result1 = @kmath.sin(angle)    // 使用 Moonbit-Math 的 sin 函数
    let result2 = @math.sin(angle)      // 使用 Core-Math 的 sin 函数
    println("Moonbit-Math: The sine of \{angle} is \{result1}")
    println("Core: The sine of \{angle} is \{result2}")
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
| `atanh`   | 反双曲正切函数。 |
| `cosh`    | 双曲余弦函数。   |
| `sinh`    | 双曲正弦函数。   |
| `tanh`    | 双曲正切函数。   |

### 指数和对数函数

| 函数名      | 描述                               |
| ----------- | ---------------------------------- |
| `exp`       | 指数函数，计算 e 的 x 次方。            |
| `exp10`     | 以 10 为底的指数函数。                 |
| `exp2`      | 以 2 为底的指数函数。                  |
| `expm1`     | 计算 exp(x) - 1，用于提高小数值的精度。 |
| `expx2`     | 计算 x * 2<sup>n</sup>。             |
| `ilogb`     | 返回 x 的以 2 为底的指数部分的整数值。   |
| `inv_digamma` | `digamma` 函数的反函数。             |
| `lgamma`    | 伽马函数的绝对值的自然对数。           |
| `ln`        | 自然对数函数（以 e 为底）。             |
| `ln_1p`     | 等同于 `log1p`。                      |
| `ln_gamma`  | 等同于 `lgamma`。                     |
| `log`       | 自然对数函数（以 e 为底）。             |
| `log10`     | 以 10 为底的对数函数。                 |
| `log1p`     | 计算 1 + x 的自然对数，用于提高小数值的精度。 |
| `log1pf`    | 计算 `Float` 类型的 `log1p`。          |
| `log2`      | 以 2 为底的对数函数。                  |
| `log_ndtr`  | 标准正态分布累积分布函数对数值。       |
| `logaddexp` | 计算 log(exp(x) + exp(y))，避免溢出。   |
| `logf`      | 计算 `Float` 类型的自然对数。           |
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
| `ldexp`       | 计算 x * 2<sup>exp</sup>。                                            |
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
| `scalbn`      | 计算 x * 2<sup>n</sup>。                                            |
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
| `exp2`    | 1        |
| `exp10`   | 1        |
| `expm1`   | 0        |
| `cbrt`    | 0        |
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
