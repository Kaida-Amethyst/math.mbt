# Moonbit-Math

## 概述

Moonbit 数学库是一个在 Moonbit 编程语言中实现的数学函数库。该库旨在提供与 GNU C 库（glibc）实现相匹配的高精度数学运算。它包含了广泛的函数，如三角函数、指数函数、对数函数和特殊函数，这些函数对于数值计算至关重要。

## 安装

要在您的项目中使用 Moonbit 数学库，您可以通过 Moonbit 包管理器轻松添加它。只需运行以下命令：

```bash
moon add KaidaAmethyst/moonbit-math
```

此命令会将库添加到您的项目依赖项中，使您能够无缝导入和使用数学函数。

## 精度

Moonbit 数学库在计算中力求高精度，旨在匹配 glibc 实现的准确性。下表列出了库中每个函数的 ULP（最后一位的单位）精度差异。

| 函数名          | 描述                         | ulp误差                 |
|---------------|-------------------------------------|-------------------------------------|
| abs           | 计算绝对值                          | TODO                                |
| acos          | 计算反余弦                          | TODO                                |
| acosh         | 计算反双曲余弦                      | TODO                                |
| asin          | 计算反正弦                          | TODO                                |
| asinh         | 计算反双曲正弦                      | TODO                                |
| atan          | 计算反正切                          | TODO                                |
| atan2         | 计算反正切（带两个参数）            | TODO                                |
| atanh         | 计算反双曲正切                      | TODO                                |
| cbrt          | 计算立方根                          | TODO                                |
| ceil          | 向上取整                            | TODO                                |
| clamp         | 限制值在指定范围内                  | TODO                                |
| constants     | 数学常量                            | TODO                                |
| cos           | 计算余弦                            | TODO                                |
| cosh          | 计算双曲余弦                        | TODO                                |
| cospi         | 计算cos(πx)                         | TODO                                |
| digamma       | 计算Digamma函数                     | TODO                                |
| div_euclid    | 计算欧几里得除法                    | TODO                                |
| erf           | 计算误差函数                        | TODO                                |
| erfc          | 计算互补误差函数                    | TODO                                |
| erfcinv       | 计算互补误差函数的逆                | TODO                                |
| erfcx         | 计算缩放互补误差函数                | TODO                                |
| erfinv        | 计算误差函数的逆                    | TODO                                |
| exp           | 计算指数函数                        | TODO                                |
| exp10         | 计算10的幂                          | TODO                                |
| exp2          | 计算2的幂                           | TODO                                |
| expm1         | 计算exp(x) - 1                      | TODO                                |
| fast_rsqrt    | 快速计算平方根的倒数                | TODO                                |
| floor         | 向下取整                            | TODO                                |
| fract         | 计算小数部分                        | TODO                                |
| fdim          | 计算两个数的正差                    | TODO                                |
| gelu          | 计算GELU函数                        | TODO                                |
| gegenbauer    | 计算Gegenbauer多项式                | TODO                                |
| gamma         | 计算Gamma函数                       | TODO                                |
| hermite       | 计算Hermite多项式                   | TODO                                |
| hypot         | 计算欧几里得范数                    | TODO                                |
| ilogb         | 计算以2为底的对数的整数部分         | TODO                                |
| isfinite      | 判断是否为有限数                    | TODO                                |
| isinf         | 判断是否为无穷大                    | TODO                                |
| isnan         | 判断是否为NaN                       | TODO                                |
| isnormal      | 判断是否为正规数                    | TODO                                |
| issubnormal   | 判断是否为次正规数                  | TODO                                |
| jacobi        | 计算Jacobi椭圆函数                  | TODO                                |
| j0            | 计算第一类贝塞尔函数（0阶）         | TODO                                |
| j1            | 计算第一类贝塞尔函数（1阶）         | TODO                                |
| jn            | 计算第一类贝塞尔函数（n阶）         | TODO                                |
| ldexp         | 计算x * 2^exp                       | TODO                                |
| log           | 计算自然对数                        | TODO                                |
| log10         | 计算以10为底的对数                  | TODO                                |
| log1p         | 计算log(1 + x)                      | TODO                                |
| log2          | 计算以2为底的对数                   | TODO                                |
| logaddexp     | 计算log(exp(x) + exp(y))            | TODO                                |
| logb          | 计算以2为底的对数的整数部分         | TODO                                |
| logsumexp     | 计算log(sum(exp(x)))                | TODO                                |
| nearbyint     | 四舍五入到最近的整数                | TODO                                |
| nextafter     | 返回下一个浮点数                    | TODO                                |
| nextdown      | 返回下一个较小的浮点数              | TODO                                |
| nextup        | 返回下一个较大的浮点数              | TODO                                |
| norm          | 计算范数                            | TODO                                |
| normcdf       | 计算正态分布的累积分布函数          | TODO                                |
| normcdfinv    | 计算正态分布的逆累积分布函数        | TODO                                |
| pown          | 计算x的整数次幂                     | TODO                                |
| polygamma     | 计算Polygamma函数                   | TODO                                |
| pow           | 计算x的y次幂                        | TODO                                |
| rcbrt         | 计算立方根的倒数                    | TODO                                |
| rem_euclid    | 计算欧几里得余数                    | TODO                                |
| rhypot        | 计算欧几里得范数的倒数              | TODO                                |
| rint          | 四舍五入到最近的整数                | TODO                                |
| rnorm         | 计算范数的倒数                      | TODO                                |
| round         | 四舍五入到最近的整数                | TODO                                |
| roundeven     | 四舍五入到最近的偶数                | TODO                                |
| rsqrt         | 计算平方根的倒数                    | TODO                                |
| scalbn        | 计算x * 2^n                         | TODO                                |
| sign          | 计算符号函数                        | TODO                                |
| signum        | 计算符号函数                        | TODO                                |
| sin           | 计算正弦                            | TODO                                |
| sinc          | 计算sinc函数                        | TODO                                |
| sincos        | 同时计算正弦和余弦                  | TODO                                |
| sincospi      | 同时计算sin(πx)和cos(πx)            | TODO                                |
| sinh          | 计算双曲正弦                        | TODO                                |
| sinhc         | 计算双曲正弦的归一化形式            | TODO                                |
| sinpi         | 计算sin(πx)                         | TODO                                |
| sqrt          | 计算平方根                          | TODO                                |
| sqrt1pm1      | 计算sqrt(1 + x) - 1                 | TODO                                |
| tan           | 计算正切                            | TODO                                |
| tanh          | 计算双曲正切                        | TODO                                |
| to_degrees    | 将弧度转换为角度                    | TODO                                |
| to_radians    | 将角度转换为弧度                    | TODO                                |
| trunc         | 截断到整数部分                      | TODO                                |
| utils         | 实用工具函数                        | TODO                                |
| y0            | 计算第二类贝塞尔函数（0阶）         | TODO                                |
| y1            | 计算第二类贝塞尔函数（1阶）         | TODO                                |
| yn            | 计算第二类贝塞尔函数（n阶）         | TODO                                |
| zeta          | 计算黎曼ζ函数                       | TODO                                |

### 精度说明

- **ULP（最后一位的单位）**：此指标以浮点表示的最低有效位的单位测量计算结果与真实结果之间的差异。ULP 值越低，表示精度越高。
- **0 ULP**：表示函数与 glibc 实现完全匹配。
- **1 ULP**：表示函数在最后一位的半个单位内，这被认为是极高的精度。
- **2 ULP**：表示函数在最后一位的一个单位内，这对于大多数数值应用来说是可接受的。

## 使用示例

以下是一个简单的示例，演示如何使用 Moonbit 数学库中的 `sin` 函数：

首先你需要在`moon.pkg.json`中添加依赖：

```json
{
    "import" :[
        ...
        "Kaida-Amethyst/math"
    ]
}
```

然后就可以在代码中使用函数：

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

---

感谢您使用 Moonbit 数学库！我们希望它能在您的数值计算工作中为您提供良好的服务。
