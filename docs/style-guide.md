# 文档注释与可信证据风格指南

本文规定公开 MoonBit 接口的文档注释，重点适用于 `src/` 中已经晋升为 stable
的数值函数。目标不是让注释变长，而是让读者能够区分：库承诺什么、现有证据支持什么，
以及证据尚未覆盖什么。

## 1. 基本原则

公开接口使用 `///|` 文档块。开头用一到两句话直接说明数学含义和核心语义，不添加
“简介”标题，也不机械复述函数名和类型。

文档中的三类陈述必须分开：

- **契约**说明所有调用者可以依赖的行为，例如“有限输入的误差不超过 1 ULP”；
- **证据**说明实际执行过的验证，例如“24,697 个固定输入上的最大观测误差为 1 ULP”；
- **边界**说明现有证据不能推出什么，例如“这不是正确舍入承诺，也不是形式化证明”。

测试结果不能倒写成数学定理。除非确实完成了对应证明或穷举，不使用“完全正确”、
“全部输入均已验证”、“无误差”或“已证明”等措辞。`Moon prove`、oracle 对照、性质测试和
代码覆盖率是不同种类的证据，不能互相替代。

函数注释是面向使用者的摘要，不承载会持续增长的全部日志。stable 数值函数必须链接到
`docs/reliability/` 下的认证记录；工具版本、语料构成、内容哈希、完整命令、失败见证和
证据限制写在认证记录中。

## 2. 语言、标题与示例

- 公开 API 文档注释使用英文，与现有生成接口和生态文档保持一致；维护文档和认证记录
  可以使用中文。
- 章节统一使用二级标题，例如 `## Accuracy`，并按本文给出的顺序排列。
- 只添加对当前接口有意义的章节，不留下空章节，也不重复类型签名已经表达的信息。
- 示例默认使用 `moonbit check`，使其能被工具链检查。只有确实依赖测试环境无法提供的
  外部条件时才使用 `moonbit nocheck`，并应由普通测试另行覆盖。
- 示例只断言稳定契约，不固定契约未承诺的末位结果、NaN payload 或后端实现细节。

## 3. stable 数值函数的章节

章节采用以下顺序。标为“按需”的章节可以省略；其余章节对适用的 stable 数值函数是
必需的。

1. **开头语义**：必需。说明函数计算什么，以及结果类型所代表的浮点格式。
2. **`## Parameters`**：按需。说明定义域、单位、规范化、sentinel 或其他非显然参数语义。
3. **`## Returns`**：按需。返回值存在分段含义或非显然编码时使用。
4. **`## Domain and special values`**：浮点函数必需。明确 NaN、无穷、正负零、定义域边界、
   上溢、下溢和次正规数中适用的行为。
5. **`## Accuracy`**：近似数值函数必需。明确误差尺度、上界、参考真值和舍入方式；如果
   不承诺正确舍入，应直接说明。
6. **`## Properties`**：按需。只写入准备长期承诺的单调性、奇偶性、值域或不变量。仅在
   样本上观察到的性质属于验证证据，不应写成全局性质。
7. **`## Errors`**：按需。说明显式错误、异常或不可恢复状态；IEEE 754 的 NaN 或无穷结果
   通常应在特殊值章节说明，而不是描述成 MoonBit 异常。
8. **`## Notes`**：按需。记录用户需要知道的性能、平台或可移植性限制。
9. **`## Verification`**：stable 数值函数必需。摘要说明独立 oracle、固定语料、跨后端
   范围、最大观测误差、证明状态，并链接完整认证记录。
10. **`## References`**：采用外部规范、算法或实现时必需。分别说明语义依据、算法来源和
    oracle；引用应尽量固定到具体版本或提交。
11. **`## DevNotes`**：按需。记录维护者需要知道的内部不变量和实现原因；用户正确使用
    接口所需的信息不能只写在这里。
12. **`## Example`**：建议。展示最小正常用法或关键边界，优先选择契约保证精确的断言。

## 4. 文档注释模板

模板中的花括号是写作提示，实际注释不得保留。省略不适用的章节后，仍保持章节顺序。

````moonbit
///|
/// {用一到两句话说明数学含义和核心语义。}
///
/// ## Parameters
///
/// - `{name}`: {只说明类型签名无法表达的定义域、单位或边界。}
///
/// ## Returns
///
/// {说明非显然的返回值分段或编码。}
///
/// ## Domain and special values
///
/// - `{special input}` produces `{specified result}`.
/// - {说明 NaN、无穷、signed zero、上溢、下溢和次正规数中适用的行为。}
/// - {明确不承诺的 payload、状态标志或其他环境副作用。}
///
/// ## Accuracy
///
/// {写明误差上界、ULP/绝对/相对误差尺度、参考真值和舍入模式。}
/// {说明是否承诺 correctly rounded；若不承诺，应明确否定。}
///
/// ## Properties
///
/// {只列入稳定契约中的全局性质。}
///
/// ## Errors
///
/// {说明错误触发条件及其状态影响。}
///
/// ## Notes
///
/// {说明用户可见的平台、性能或可移植性限制。}
///
/// ## Verification
///
/// {说明独立 oracle 和固定语料的种类。} The maximum observed error was
/// {结果}; the committed corpus passed on {后端和模式}. {说明是否存在形式化
/// 证明。} See the [reliability record]({相对路径}) for the corpus, tool versions,
/// reproducible commands, witnesses, and evidence limits.
///
/// ## References
///
/// - {语义规范或数学定义，尽量链接固定版本。}
/// - {算法或实现来源，链接具体提交。}
/// - {独立 oracle 的规范或实现。}
///
/// ## DevNotes
///
/// {记录实现不变量、偏离上游的原因或维护约束。}
///
/// ## Example
///
/// ```moonbit check
/// test {
///   ...
/// }
/// ```
pub fn example(...) -> ... {
  ...
}
````

## 5. `Verification` 的最低信息量

`Verification` 不是一句“有测试”就结束。对于近似数值函数，至少应让读者知道：

- 参考值是否来自独立高精度 oracle，而不是当前实现或同源移植；
- 固定语料是否覆盖 IEEE 特殊值、实现分支、数学边界、固定种子随机输入和已知困难输入；
- 语料规模和最大**观测**误差；
- 哪些 MoonBit 后端和 debug/release 模式执行了固定语料；
- 是否执行过更大的外部攻击语料，以及它只覆盖了哪些后端；
- 当前结论是测试证据、穷举结果还是针对明确命题的形式化证明；
- 完整认证记录的位置。

具体版本、内容哈希和长命令留在认证记录中。函数注释中的数字若发生变化，必须与认证记录
同步更新；不能只更新其中一处。

## 6. `exp` 的目标注释示例

下面只展示应用模板后的目标形态，供后续修改 `src/exp.mbt` 时审阅；本文档本身不改变
当前源码。

````moonbit
///|
/// Returns the base-e exponential of `input` as an IEEE 754 binary64 value.
///
/// ## Domain and special values
///
/// - `exp(NaN)` is NaN; no NaN payload is promised.
/// - `exp(+infinity)` is positive infinity.
/// - `exp(-infinity)` is positive zero.
/// - `exp(+0.0)` and `exp(-0.0)` are exactly `1.0`.
/// - Overflow produces positive infinity; underflow may produce a positive
///   subnormal value or positive zero.
///
/// ## Accuracy
///
/// For every finite input, the result is within 1 ULP of the exact exponential
/// rounded to binary64 with round-to-nearest, ties-to-even. Correct rounding is
/// not promised.
///
/// ## Verification
///
/// A 24,697-case fixed corpus was generated with an independent MPFR oracle.
/// Its maximum observed error is 1 ULP, and it passes in debug and release mode
/// on wasm, wasm-gc, JavaScript, and native. A pinned CORE-MATH hard-case audit
/// checked 1,129,371 non-NaN inputs on native with the same bound. This is testing
/// evidence, not a formal proof. See the [reliability record](../docs/reliability/exp.md)
/// for the complete method, witnesses, reproducible commands, and limitations.
///
/// ## References
///
/// - The range reduction and polynomial approximation are derived from
///   [fdlibm `e_exp.c`](https://android.googlesource.com/platform/bionic/+/4032c1e/libm/src/e_exp.c).
/// - Reference results are generated with
///   [GNU MPFR](https://www.mpfr.org/mpfr-current/mpfr.html).
///
/// ## Example
///
/// ```moonbit check
/// test {
///   assert_eq(exp(0.0), 1.0)
///   assert_eq(exp(@double.neg_infinity), 0.0)
/// }
/// ```
pub fn exp(input : Double) -> Double {
  ...
}
````

## 7. experimental 接口

`src/experimental/` 中的公开函数仍需写清目标语义和已知边界，但不得使用 stable 的口吻
暗示已经完成认证。尚未通过的准确度目标应写成“target”或记录在开发文档中，不能写成
既成保证。

当接口晋升时，必须同时完成三项工作：把目标语义改成明确契约，补齐 `Verification` 摘要，
并在 `docs/reliability/` 建立绑定到具体实现和语料的认证记录。具体流程见
[API 晋升规则](api-promotion.md)。
