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

| 函数名        | ULP                  |
|---------------|----------------------|
| acos          |1                     |
| acosh         |1                     |
| asin          |(TODO)                |
| asinh         |1                     |
| atan          |(TODO)                |
| atanh         |1                     |
| cbrt          |1                     |
| ceil          |0                     |
| cos           |2                     |
| cosh          |1                     |
| cospi         |1                     |
| digamma       |7                     |
| erf           |(TODO)                |
| erfc          |(TODO)                |
| erfcx         |2                     |
| erfinv        |2                     |
| erfcinv       |(TODO)                |
| exp           |1                     |
| exp10         |1                     |
| exp2          |1                     |
| expm1         |2                     |
| floor         |0                     |
| hypot         |2                     |
| isinf         |0                     |
| isnan         |0                     |
| isfinite      |0                     |
| j0            |(TODO)                |
| j1            |(TODO)                |
| jn            |(TODO)                |
| log           |1                     |
| log10         |1                     |
| log1p         |1                     |
| log2          |1                     |
| logb          |(TODO)                |
| lgamma        |(TODO)                |
| ldexp         |2                     |
| normcdf       |(TODO)                |
| normcdfinv    |(TODO)                |
| pow           |2                     |
| pown          |0                     |
| rsqrt         |(TODO)                |
| rcbrt         |(TODO)                |
| rint          |(TODO)                |
| round         |0                     |
| scalbn        |2                     |
| sin           |2                     |
| sinc          |(TODO)                |
| sinh          |1                     |
| sinhc         |(TODO)                |
| sinpi         |1                     |
| sincos        |(TODO)                |
| sincospi      |(TODO)                |
| sqrt          |1                     |
| tan           |2                     |
| tanh          |1                     |
| trunc         |0                     |
| tgamma        |(TODO)                |
| y0            |(TODO)                |
| y1            |(TODO)                |
| yn            |(TODO)                |
| zeta          |(TODO)                |

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
