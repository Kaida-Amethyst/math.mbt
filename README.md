# Moonbit Math Library

[中文版](#Moonbit-数学库)

## Overview

The Moonbit Math Library is a comprehensive collection of mathematical functions implemented in the Moonbit programming language. This library is designed to provide high-precision mathematical operations that align closely with the implementations found in the GNU C Library (glibc). It includes a wide range of functions such as trigonometric, exponential, logarithmic, and special functions, all of which are essential for numerical computations.

## Installation

To use the Moonbit Math Library in your project, you can easily add it via the Moonbit package manager. First, update moonbit package index:

```bash
moon update
```

Then run the following command:

```bash
moon add Kaida-Amethyst/moonbit-math
```

Or:

```bash
moon add Kaida-Amethyst/math
```

This command will add the library to your project dependencies, allowing you to import and use the mathematical functions seamlessly.

## Precision

The Moonbit Math Library strives for high precision in its calculations, aiming to match the accuracy of glibc implementations. Below is a table that outlines the ULP (Units in the Last Place) precision differences for each function in the library.

| func          | description                          | Support | ulp (for result is float or double) |
|---------------|--------------------------------------|---------|-------------------------------------|
| abs           | Compute absolute value               | ✓       |  0                                  |
| acos          | Compute arccosine                    | ✓       |  1                                  |
| acosh         | Compute inverse hyperbolic cosine    | ✓       |  1                                  |
| asin          | Compute arcsine                      | ✓       |  1                                  |
| asinh         | Compute inverse hyperbolic sine      | ✓       |  1                                  |
| atan          | Compute arctangent                   | ✓       |  1                                  |
| atan2         | Compute arctangent with two arguments| ✓       |  1                                  |
| atanh         | Compute inverse hyperbolic tangent   | ✓       |  1                                  |
| cbrt          | Compute cubic root                   | ✓       |  1                                  |
| ceil          | Round up to the nearest integer      | ✓       |  0                                  |
| clamp         | Clamp value within a specified range | ✓       |  0                                  |
| cos           | Compute cosine                       | ✓       |  1                                  |
| cosh          | Compute hyperbolic cosine            | ✓       |  1                                  |
| cospi         | Compute cos(πx)                      | ✓       |  3                                  |
| bessel_i0     | Cylindrical Bessel function of order 0| (TODO) |  (TODO)                             |
| bessel_i1     | Cylindrical Bessel function of order 1| (TODO) |  (TODO)                             |
| bessel_j0     | Compute Bessel function of the first kind (0th order) | ✓       |  2                 |
| bessel_j1     | Compute Bessel function of the first kind (1st order) | ✓       |  4                 |
| bessel_jn     | Compute Bessel function of the first kind (nth order) | ✓       |  1                 |
| bessel_k0     | Modified Bessel function of the second kind of order 0 | (TODO) | (TODO)             |
| bessel_k1     | Modified Bessel function of the second kind of order 1 | (TODO) | (TODO)             |
| bessel_kn     | Modified Bessel function of the second kind of order n | (TODO) | (TODO)             |
| bessel_y0     | Compute Bessel function of the second kind (0th order) | ✓       |  2                |
| bessel_y1     | Compute Bessel function of the second kind (1st order) | ✓       |  2                |
| bessel_yn     | Compute Bessel function of the second kind (nth order) | ✓       |  2                |
| digamma       | Compute Digamma function             | ✓       |  1023                               |
| div_euclid    | Compute Euclidean division           | ✓       |  0                                  |
| erf           | Compute error function               | ✓       |  1                                  |
| erfc          | Compute complementary error function | ✓       |  (TODO)                             |
| erfcinv       | Compute inverse complementary error function | ✓      |  (TODO)                      |
| erfcx         | Compute scaled complementary error function | ✓       |  1                           |
| erfinv        | Compute inverse error function       | ✓       |  2                                  |
| exp           | Compute exponential function         | ✓       |  0                                  |
| exp10         | Compute 10 raised to the power of x  | ✓       |  1                                  |
| exp2          | Compute 2 raised to the power of x   | ✓       |  1                                  |
| expm1         | Compute exp(x) - 1                   | ✓       |  1                                  |
| fast_rsqrt    | Compute fast reciprocal square root  | ✓       |  (TODO)                             |
| floor         | Round down to the nearest integer    | ✓       |  0                                  |
| fract         | Compute fractional part              | ✓       |  0                                  |
| fdim          | Compute positive difference of two numbers | ✓       |  0                            |
| gelu          | Compute GELU function                | ✓       |  (TODO)                             |
| gegenbauer    | Compute Gegenbauer polynomial        | ✓       |  (TODO)                             |
| gamma         | Compute Gamma function               | ✓       |  4                                  |
| hermite       | Compute Hermite polynomial           | ✓       |  3                                  |
| hypot         | Compute Euclidean norm               | ✓       |  4                                  |
| ilogb         | Compute integer part of log2(x)      | ✓       |  0                                  |
| isfinite      | Check if value is finite             | ✓       |  0                                  |
| isinf         | Check if value is infinite           | ✓       |  0                                  |
| isnan         | Check if value is NaN                | ✓       |  0                                  |
| isnormal      | Check if value is normal             | ✓       |  0                                  |
| issubnormal   | Check if value is subnormal          | ✓       |  0                                  |
| jacobi        | Compute Jacobi elliptic function     | ✓       |  0                                  |
| ldexp         | Compute x * 2^exp                    | ✓       |  0                                  |
| lgamma        | Compute log gamma                    | ✓       |  23                                  |
| log           | Compute natural logarithm            | ✓       |  0                                  |
| log10         | Compute logarithm base 10            | ✓       |  0                                  |
| log1p         | Compute log(1 + x)                   | ✓       |  0                                  |
| log2          | Compute logarithm base 2             | ✓       |  1                                  |
| logaddexp     | Compute log(exp(x) + exp(y))         | ✓       |  0                                  |
| logb          | Compute integer part of log2(x)      | ✓       |  0                                  |
| logsumexp     | Compute log(sum(exp(x)))             | ✓       |  0                                  |
| nearbyint     | Round to nearest integer             | ✓       |  0                                  |
| nextafter     | Return next floating-point number    | ✓       |  0                                  |
| nextdown      | Return next smaller floating-point number | (TODO)       |  (TODO)                   |
| nextup        | Return next larger floating-point number | (TODO)    |  (TODO)                       |
| norm          | Compute norm                         | ✓       |  0                                  |
| norm3d        | Compute norm3d                       | ✓       |  0                                  |
| norm4d        | Compute norm4d                       | ✓       |  0                                  |
| normcdf       | Compute cumulative distribution function of normal distribution | ✓       |  (TODO)  |
| normcdfinv    | Compute inverse cumulative distribution function of normal distribution | ✓       |  (TODO) |
| pown          | Compute integer power of x           | ✓       |  0                                  |
| polygamma     | Compute Polygamma function           | ✓       |  (TODO)                             |
| pow           | Compute x raised to the power of y   | ✓       |  3                                  |
| rcbrt         | Compute reciprocal of cubic root     | ✓       |  1                                  |
| rem_euclid    | Compute Euclidean remainder          | ✓       |  0                                  |
| rhypot        | Compute reciprocal of Euclidean norm | ✓       |  1                                  |
| rint          | Round to nearest integer             | ✓       |  0                                  |
| rnorm         | Compute reciprocal of norm           | ✓       |  1                                  |
| rnorm3d       | Compute reciprocal of norm3d         | ✓       |  1                                  |
| rnorm4d       | Compute reciprocal of norm4d         | ✓       |  1                                  |
| round         | Round to nearest integer             | ✓       |  0                                  |
| roundeven     | Round to nearest even integer        | ✓       |  0                                  |
| rsqrt         | Compute reciprocal of square root    | ✓       |  1                                  |
| scalbn        | Compute x * 2^n                      | ✓       |  0                                  |
| sign          | Compute sign function                | ✓       |  0                                  |
| signum        | Compute sign function                | ✓       |  0                                  |
| sin           | Compute sine                         | ✓       |  1                                  |
| sinc          | Compute sinc function                | (TODO)  |  (TODO)                             |
| sincos        | Compute sine and cosine simultaneously | ✓       |  1                                |
| sincospi      | Compute sin(πx) and cos(πx) simultaneously | ✓       |  1                            |
| sinh          | Compute hyperbolic sine              | ✓       |  0                                  |
| sinhc         | Compute normalized hyperbolic sine   | (TODO)  |  (TODO)                             |
| sinpi         | Compute sin(πx)                      | ✓       |  3                                  |
| sqrt          | Compute square root                  | ✓       |  1                                  |
| sqrt1pm1      | Compute sqrt(1 + x) - 1              | ✓       |  1                                  |
| tan           | Compute tangent                      | ✓       |  1                                  |
| tanh          | Compute hyperbolic tangent           | ✓       |  1                                  |
| to_degrees    | Convert radians to degrees           | ✓       |  0                                  |
| to_radians    | Convert degrees to radians           | ✓       |  0                                  |
| trunc         | Truncate to integer part             | ✓       |  0                                  |
| zeta          | Compute Riemann zeta function        | ✓       |  3                                  |

### Notes on Precision

- **ULP (Units in the Last Place)**: This metric measures the difference between the computed result and the true result in terms of the least significant bit of the floating-point representation. A lower ULP value indicates higher precision.
- **0 ULP**: Indicates that the function matches the glibc implementation exactly.
- **1 ULP**: Indicates that the function is within half a unit of the last place, which is considered very high precision.
- **2 ULP**: Indicates that the function is within one unit of the last place, which is still considered acceptable for most numerical applications.

## Usage Example

Here is a simple example demonstrating how to use the `sin` function from the Moonbit Math Library:

First add dependencies in `moon.pkg.json`:

```json
{
    "import" :[
        {
            "path":"Kaida-Amethyst/moonbit-math",
            "alias": "math"
        }
    ]
}
```

Or use `Kaida-Amethyst/math` if what you added is `Kaida-Amethyst/math`.

```json
{
    "import" :[
        "Kaida-Amethyst/math"
    ]
}
```

Then you can use math functions, for example:

```moonbit
fn main {
    let angle = 1.0 // in radians
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

## Contributing

We welcome contributions to the Moonbit Math Library! If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on our [GitHub repository](https://github.com/Kaida-Amethyst/moonbit-math).

## License

The Moonbit Math Library is licensed under the Apache-2.0 License. See the [LICENSE](LICENSE) file for more details.

---

Thank you for using the Moonbit Math Library! We hope it serves you well in your numerical computing endeavors.

------

# Moonbit 数学库

## 概述

Moonbit 数学库是一个在 Moonbit 编程语言中实现的数学函数综合集合。该库旨在提供高精度的数学运算，与 GNU C 库（glibc）中的实现紧密对齐。它包含了广泛的函数，如三角函数、指数函数、对数函数和特殊函数，这些函数对于数值计算至关重要。

## 安装

要在您的项目中使用 Moonbit 数学库，您可以通过 Moonbit 包管理器轻松添加它。

首先更新包索引（强烈建议）：

```bash
moon update
```

接着运行以下命令：

```bash
moon add Kaida-Amethyst/moonbit-math
```

或者：

```bash
moon add Kaida-Amethyst/math
```

此命令将把库添加到您的项目依赖项中，使您能够无缝导入和使用数学函数。

## 精度

Moonbit 数学库在计算中力求高精度，旨在匹配 glibc 实现的准确性。下表概述了库中每个函数的 ULP（最后一位的单位）精度差异。

| 函数          | 描述                          | 支持情况| ulp      |
|---------------|-------------------------------|---------|----------|
| abs           | 计算绝对值                    | ✓       |  0       |
| acos          | 计算反余弦                    | ✓       |  1       |
| acosh         | 计算反双曲余弦                | ✓       |  1       |
| asin          | 计算反正弦                    | ✓       |  1       |
| asinh         | 计算反双曲正弦                | ✓       |  1       |
| atan          | 计算反正切                    | ✓       |  1       |
| atan2         | 计算带有两个参数的反正切      | ✓       |  1       |
| atanh         | 计算反双曲正切                | ✓       |  1       |
| cbrt          | 计算立方根                    | ✓       |  0       |
| ceil          | 向上取整到最近的整数          | ✓       |  0       |
| clamp         | 将值限制在指定范围内          | ✓       |  0       |
| cos           | 计算余弦                      | ✓       |  1       |
| cosh          | 计算双曲余弦                  | ✓       |  1       |
| cospi         | 计算 cos(πx)                  | ✓       |  1       |
| bessel_i0     | 柱贝塞尔函数（0阶）           | (TODO)  |  (TODO)  |
| bessel_i1     | 柱贝塞尔函数（1阶）           | (TODO)  |  (TODO)  |
| bessel_j0     | 计算第一类贝塞尔函数（0阶）   | ✓       |  1       |
| bessel_j1     | 计算第一类贝塞尔函数（1阶）   | ✓       |  1       |
| bessel_jn     | 计算第一类贝塞尔函数（n阶）   | ✓       |  1       |
| bessel_y0     | 计算第二类贝塞尔函数（0阶）   | ✓       |  2       |
| bessel_y1     | 计算第二类贝塞尔函数（1阶）   | ✓       |  2       |
| bessel_yn     | 计算第二类贝塞尔函数（n阶）   | ✓       |  2       |
| digamma       | 计算 Digamma 函数             | ✓       |  1023    |
| div_euclid    | 计算欧几里得除法              | ✓       |  0       |
| erf           | 计算误差函数                  | ✓       |  1       |
| erfc          | 计算互补误差函数              | ✓       |  1       |
| erfcinv       | 计算反互补误差函数            | ✓       |  4       |
| erfcx         | 计算缩放互补误差函数          | ✓       |  1       |
| erfinv        | 计算反误差函数                | ✓       |  2       |
| exp           | 计算指数函数                  | ✓       |  1       |
| exp10         | 计算 10 的 x 次方             | ✓       |  1       |
| exp2          | 计算 2 的 x 次方              | ✓       |  1       |
| expm1         | 计算 exp(x) - 1               | ✓       |  1       |
| fast_rsqrt    | 计算快速倒数平方根            | ✓       |  (TODO)  |
| floor         | 向下取整到最近的整数          | ✓       |  0       |
| fract         | 计算小数部分                  | ✓       |  0       |
| fdim          | 计算两个数的正差              | ✓       |  0       |
| gelu          | 计算 GELU 函数                | ✓       |  (TODO)  |
| gegenbauer    | 计算 Gegenbauer 多项式        | ✓       |  (TODO)  |
| gamma         | 计算 Gamma 函数               | ✓       |  4       |
| hermite       | 计算 Hermite 多项式           | ✓       |  3       |
| hypot         | 计算欧几里得范数              | ✓       |  0       |
| ilogb         | 计算 log2(x) 的整数部分       | ✓       |  0       |
| isfinite      | 检查值是否有限                | ✓       |  0       |
| isinf         | 检查值是否无限                | ✓       |  0       |
| isnan         | 检查值是否为 NaN              | ✓       |  0       |
| isnormal      | 检查值是否正常                | ✓       |  0       |
| issubnormal   | 检查值是否为次正常            | ✓       |  0       |
| jacobi        | 计算 Jacobi 椭圆函数          | ✓       |  0       |
| ldexp         | 计算 x * 2^exp                | ✓       |  1       |
| log           | 计算自然对数                  | ✓       |  0       |
| log10         | 计算以 10 为底的对数          | ✓       |  0       |
| log1p         | 计算 log(1 + x)               | ✓       |  0       |
| log2          | 计算以 2 为底的对数           | ✓       |  1       |
| logaddexp     | 计算 log(exp(x) + exp(y))     | ✓       |  1       |
| logb          | 计算 log2(x) 的整数部分       | ✓       |  1       |
| logsumexp     | 计算 log(sum(exp(x)))         | ✓       |  0       |
| nearbyint     | 四舍五入到最近的整数          | ✓       |  0       |
| nextafter     | 返回下一个浮点数              | ✓       |  0       |
| nextdown      | 返回下一个较小的浮点数        | (TODO)  |  (TODO)  |
| nextup        | 返回下一个较大的浮点数        | (TODO)  |  (TODO)  |
| norm          | 计算范数                      | ✓       |  0       |
| norm3d        | 计算 norm3d                   | ✓       |  1       |
| norm4d        | 计算 norm4d                   | ✓       |  1       |
| normcdf       | 计算正态分布的累积分布函数    | ✓       |  1       |
| normcdfinv    | 计算正态分布的反累积分布函数  | ✓       |  1       |
| pown          | 计算 x 的整数次幂             | ✓       |  1       |
| polygamma     | 计算 Polygamma 函数           | ✓       |  (TODO)  |
| pow           | 计算 x 的 y 次方              | ✓       |  3       |
| rcbrt         | 计算立方根的倒数              | ✓       |  0       |
| rem_euclid    | 计算欧几里得余数              | ✓       |  0       |
| rhypot        | 计算欧几里得范数的倒数        | ✓       |  0       |
| rint          | 四舍五入到最近的整数          | ✓       |  0       |
| rnorm         | 计算范数的倒数                | ✓       |  0       |
| rnorm3d       | 计算 norm3d 的倒数            | ✓       |  0       |
| rnorm4d       | 计算 norm4d 的倒数            | ✓       |  0       |
| round         | 四舍五入到最近的整数          | ✓       |  0       |
| roundeven     | 四舍五入到最近的偶数整数      | ✓       |  0       |
| rsqrt         | 计算平方根的倒数              | ✓       |  0       |
| scalbn        | 计算 x * 2^n                  | ✓       |  0       |
| sign          | 计算符号函数                  | ✓       |  0       |
| signum        | 计算符号函数                  | ✓       |  0       |
| sin           | 计算正弦                      | ✓       |  1       |
| sinc          | 计算 sinc 函数                | (TODO)  |  (TODO)  |
| sincos        | 同时计算正弦和余弦            | ✓       |  1       |
| sincospi      | 同时计算 sin(πx) 和 cos(πx)   | ✓       |  1       |
| sinh          | 计算双曲正弦                  | ✓       |  1       |
| sinhc         | 计算归一化双曲正弦            | (TODO)  |  (TODO)  |
| sinpi         | 计算 sin(πx)                  | ✓       |  1       |
| sqrt          | 计算平方根                    | ✓       |  1       |
| sqrt1pm1      | 计算 sqrt(1 + x) - 1          | ✓       |  1       |
| tan           | 计算正切                      | ✓       |  1       |
| tanh          | 计算双曲正切                  | ✓       |  1       |
| to_degrees    | 将弧度转换为度                | ✓       |  0       |
| to_radians    | 将度转换为弧度                | ✓       |  0       |
| trunc         | 截断到整数部分                | ✓       |  0       |
| zeta          | 计算黎曼 zeta 函数            | (TODO)  |  (TODO)  |

### 精度说明

- **ULP（最后一位的单位）**：该指标以浮点表示的最小有效位的单位来衡量计算结果与真实结果之间的差异。ULP 值越低，精度越高。
- **0 ULP**：表示函数与 glibc 实现完全匹配。
- **1 ULP**：表示函数在最后一位的半单位内，被认为是极高精度。
- **2 ULP**：表示函数在最后一位的一个单位内，对于大多数数值应用仍然是可以接受的。

## 使用示例

以下是一个简单的示例，演示如何使用 Moonbit 数学库中的 `sin` 函数：

首先在 `moon.pkg.json` 中添加依赖：

```json
{
    "import" :[
        {
            "path":"Kaida-Amethyst/moonbit-math",
            "alias": "math"
        }
    ]
}
```

或者如果您添加的是 `Kaida-Amethyst/math`，则使用：

```json
{
    "import" :[
        "Kaida-Amethyst/math"
    ]
}
```

然后您可以使用数学函数，例如：

```moonbit
fn main {
    let angle = 1.0 // 以弧度为单位
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

## 贡献

我们欢迎对 Moonbit 数学库的贡献！如果您发现任何问题或有改进建议，请随时在我们的 [GitHub 仓库](https://github.com/Kaida-Amethyst/moonbit-math) 上提交问题或拉取请求。

## 许可证

Moonbit 数学库采用 Apache-2.0 许可证。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。
