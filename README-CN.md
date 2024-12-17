# Moonbit 数学库

## 概述

Moonbit 数学库是一个在 Moonbit 编程语言中实现的数学函数综合集合。该库旨在提供高精度的数学运算，与 GNU C 库（glibc）中的实现紧密对齐。它包含了广泛的函数，如三角函数、指数函数、对数函数和特殊函数，这些函数对于数值计算至关重要。

## 安装

要在您的项目中使用 Moonbit 数学库，您可以通过 Moonbit 包管理器轻松添加它。只需运行以下命令：

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
| acos          | 计算反余弦                    | ✓       |  0       |
| acosh         | 计算反双曲余弦                | ✓       |  0       |
| asin          | 计算反正弦                    | ✓       |  0       |
| asinh         | 计算反双曲正弦                | ✓       |  0       |
| atan          | 计算反正切                    | ✓       |  0       |
| atan2         | 计算带有两个参数的反正切      | ✓       |  0       |
| atanh         | 计算反双曲正切                | ✓       |  0       |
| cbrt          | 计算立方根                    | ✓       |  0       |
| ceil          | 向上取整到最近的整数          | ✓       |  0       |
| clamp         | 将值限制在指定范围内          | ✓       |  0       |
| cos           | 计算余弦                      | ✓       |  0       |
| cosh          | 计算双曲余弦                  | ✓       |  0       |
| cospi         | 计算 cos(πx)                  | ✓       |  0       |
| cyl_bessel_i0 | 柱贝塞尔函数（0阶）           | (TODO)  |  (TODO)  |
| cyl_bessel_i1 | 柱贝塞尔函数（1阶）           | (TODO)  |  (TODO)  |
| digamma       | 计算 Digamma 函数             | ✓       |  4       |
| div_euclid    | 计算欧几里得除法              | ✓       |  0       |
| erf           | 计算误差函数                  | ✓       |  1       |
| erfc          | 计算互补误差函数              | ✓       |  1       |
| erfcinv       | 计算反互补误差函数            | ✓       |  4       |
| erfcx         | 计算缩放互补误差函数          | ✓       |  1       |
| erfinv        | 计算反误差函数                | ✓       |  2       |
| exp           | 计算指数函数                  | ✓       |  0       |
| exp10         | 计算 10 的 x 次方             | ✓       |  0       |
| exp2          | 计算 2 的 x 次方              | ✓       |  0       |
| expm1         | 计算 exp(x) - 1               | ✓       |  0       |
| fast_rsqrt    | 计算快速倒数平方根            | ✓       |  (TODO)  |
| floor         | 向下取整到最近的整数          | ✓       |  0       |
| fract         | 计算小数部分                  | ✓       |  0       |
| fdim          | 计算两个数的正差              | ✓       |  0       |
| gelu          | 计算 GELU 函数                | ✓       |  (TODO)  |
| gegenbauer    | 计算 Gegenbauer 多项式        | ✓       |  (TODO)  |
| gamma         | 计算 Gamma 函数               | (TODO)  |  (TODO)  |
| hermite       | 计算 Hermite 多项式           | ✓       |  3       |
| hypot         | 计算欧几里得范数              | ✓       |  0       |
| ilogb         | 计算 log2(x) 的整数部分       | ✓       |  0       |
| isfinite      | 检查值是否有限                | ✓       |  0       |
| isinf         | 检查值是否无限                | ✓       |  0       |
| isnan         | 检查值是否为 NaN              | ✓       |  0       |
| isnormal      | 检查值是否正常                | ✓       |  0       |
| issubnormal   | 检查值是否为次正常            | ✓       |  0       |
| jacobi        | 计算 Jacobi 椭圆函数          | ✓       |  0       |
| j0            | 计算第一类贝塞尔函数（0阶）   | ✓       |  1       |
| j1            | 计算第一类贝塞尔函数（1阶）   | ✓       |  1       |
| jn            | 计算第一类贝塞尔函数（n阶）   | ✓       |  1       |
| ldexp         | 计算 x * 2^exp                | ✓       |  0       |
| log           | 计算自然对数                  | ✓       |  0       |
| log10         | 计算以 10 为底的对数          | ✓       |  0       |
| log1p         | 计算 log(1 + x)               | ✓       |  0       |
| log2          | 计算以 2 为底的对数           | ✓       |  0       |
| logaddexp     | 计算 log(exp(x) + exp(y))     | ✓       |  0       |
| logb          | 计算 log2(x) 的整数部分       | ✓       |  0       |
| logsumexp     | 计算 log(sum(exp(x)))         | ✓       |  0       |
| nearbyint     | 四舍五入到最近的整数          | ✓       |  0       |
| nextafter     | 返回下一个浮点数              | ✓       |  0       |
| nextdown      | 返回下一个较小的浮点数        | (TODO)  |  (TODO)  |
| nextup        | 返回下一个较大的浮点数        | (TODO)  |  (TODO)  |
| norm          | 计算范数                      | ✓       |  0       |
| norm3d        | 计算 norm3d                   | ✓       |  0       |
| norm4d        | 计算 norm4d                   | ✓       |  0       |
| normcdf       | 计算正态分布的累积分布函数    | ✓       |  0       |
| normcdfinv    | 计算正态分布的反累积分布函数  | ✓       |  0       |
| pown          | 计算 x 的整数次幂             | ✓       |  0       |
| polygamma     | 计算 Polygamma 函数           | (TODO)  |  (TODO)  |
| pow           | 计算 x 的 y 次方              | ✓       |  0       |
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
| sin           | 计算正弦                      | ✓       |  0       |
| sinc          | 计算 sinc 函数                | (TODO)  |  (TODO)  |
| sincos        | 同时计算正弦和余弦            | ✓       |  0       |
| sincospi      | 同时计算 sin(πx) 和 cos(πx)   | ✓       |  0       |
| sinh          | 计算双曲正弦                  | ✓       |  0       |
| sinhc         | 计算归一化双曲正弦            | (TODO)  |  (TODO)  |
| sinpi         | 计算 sin(πx)                  | ✓       |  0       |
| sqrt          | 计算平方根                    | ✓       |  0       |
| sqrt1pm1      | 计算 sqrt(1 + x) - 1          | ✓       |  0       |
| tan           | 计算正切                      | ✓       |  0       |
| tanh          | 计算双曲正切                  | ✓       |  0       |
| to_degrees    | 将弧度转换为度                | ✓       |  0       |
| to_radians    | 将度转换为弧度                | ✓       |  0       |
| trunc         | 截断到整数部分                | ✓       |  0       |
| y0            | 计算第二类贝塞尔函数（0阶）   | ✓       |  2       |
| y1            | 计算第二类贝塞尔函数（1阶）   | ✓       |  2       |
| yn            | 计算第二类贝塞尔函数（n阶）   | ✓       |  2       |
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
fn main() {
    let angle = 1.0 // 以弧度为单位
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

## 贡献

我们欢迎对 Moonbit 数学库的贡献！如果您发现任何问题或有改进建议，请随时在我们的 [GitHub 仓库](https://github.com/Kaida-Amethyst/moonbit-math) 上提交问题或拉取请求。

## 许可证

Moonbit 数学库采用 Apache-2.0 许可证。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。
