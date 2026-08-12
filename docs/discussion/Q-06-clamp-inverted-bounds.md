# Q-06. clamp 对倒置边界的处理 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

当前 `clamp` 文档和实现会在 `min > max` 时自动交换两个边界。该行为不一定与其他语言或标准库的 clamp 契约一致，需要决定是否把这种容错行为固定为稳定契约。

## 问题引发模型

### 最小例子

对于 `clamp(5.0, 10.0, 0.0)`，当前库先把边界交换成 `[0.0, 10.0]`，因此返回 `5.0`。这一结果等同于推断并修正调用者的参数顺序，而不是按调用者给出的有序区间执行。

### 与其他库的比较

- MoonBit Core 的 [`Double::clamp`](https://github.com/moonbitlang/core/blob/ace5c884/builtin/double.mbt#L111-L120) 和 [`Float::clamp`](https://github.com/moonbitlang/core/blob/ace5c884/float/methods.mbt#L264-L273) 都先以 `guard min <= max` 检查边界；对应测试把倒置边界明确列为 panic。
- Rust `f64::clamp` 在 `min > max` 时 [panic](https://doc.rust-lang.org/stable/std/primitive.f64.html#method.clamp)。
- Java `Math.clamp` 在 `min > max` 时抛出 [`IllegalArgumentException`](https://docs.oracle.com/en/java/javase/26/docs/api/java.base/java/lang/Math.html#clamp(double,double,double))。
- C++ `std::clamp` 把“`hi` 不小于 `lo`”列为[前置条件](https://eel.is/c++draft/alg.clamp)，没有定义自动交换。
- NumPy `clip` 是一个值得注意的不同方向：它[不检查边界顺序](https://numpy.org/doc/stable/reference/generated/numpy.clip.html)，但 `a_min > a_max` 时结果全部为 `a_max`，同样不会自动交换。

这些 API 对“违约后是 panic、异常、前置条件还是继续计算”并不完全一致，但共同点很清楚：边界参数是有方向的，未发现上述主流实现把倒置边界解释为“请替我交换”。IEEE 754/C23 的语义底线没有直接规定通用 `clamp` 的这项策略，因此这里应主要依据 MoonBit Core 兼容目标和生产错误可观测性来选择。

### 问题分析

自动交换适合把两个无序端点规范化为区间的工具函数，却不一定适合参数已命名为 `min`、`max` 的 `clamp`。后者一旦传反，通常意味着上游区间计算出现错误。静默纠正会让程序继续产生看似合理的值，使错误更晚、更难定位。

Q-05 已决定任一参数为 NaN 时返回 NaN。因此若本问题采用拒绝倒置边界，实现顺序应是：先传播 NaN；仅在三个参数均非 NaN 且 `min > max` 时拒绝调用。这会在 NaN 规则上有意不同于当前 MoonBit Core，但不会影响倒置有限边界与 Core 对齐。

## 关联问题

1. [Q-01. 稳定 API 的语义裁判顺序](Q-01-semantic-precedence.md)（依赖：需核对 C23 和 MoonBit Core 是否已有对应约定）
2. [Q-05. clamp 对 NaN 参数的处理](Q-05-clamp-nan.md)（一般关系：两个规则共同组成 clamp 的边界契约，但可独立决定）

## 建议的解决方案

### A1. 保留自动交换倒置边界的现有行为

#### 方案描述

当 `min > max` 时先交换两者，再执行 clamp，并为该行为添加黑盒测试。

#### 优点

- 保持当前文档和正常有限值实现的兼容性。
- 对调用者较宽容。

#### 缺点

- 可能掩盖调用者传参错误。
- 若生态常用契约要求 `min <= max`，会形成行为差异。

### A2. 把有序边界作为前置条件，倒置时 panic 【已采纳】

#### 方案描述

把 `min <= max` 写入公共契约。先按 Q-05 处理 NaN；其余情况下若 `min > max`，立即 panic，并添加黑盒回归测试。

#### 优点

- 与 MoonBit Core 的有限边界行为直接一致，也符合 Rust、Java 和 C++ 将倒置边界视为调用错误的共同方向。
- 让上游区间计算错误在发生点暴露，不会静默生成一个看似有效的数值。
- 保持现有 `Double` 返回类型，无需为错误路径引入新的返回表示。

#### 缺点

- 改变当前已经写入文档的自动交换行为；依赖该容错特性的调用会在升级后失败。
- panic 不适合调用者确实需要动态处理无序端点的场景；这类调用者需先自行排序边界。

### A3. 保持参数顺序但不检查，按嵌套 min/max 计算

#### 方案描述

不交换也不拒绝边界，采用类似 NumPy `minimum(max, maximum(x, min))` 的固定计算顺序；倒置时通常返回 `max`。

#### 优点

- 没有 panic 路径。
- 与 NumPy `clip` 的计算模型接近。

#### 缺点

- 对标量数学库而言语义反直觉，也与 MoonBit Core 不兼容。
- 仍会掩盖调用错误，而且结果比自动交换更难从区间直觉解释。

## 最终采用方案

A2. 把有序边界作为前置条件，倒置时 panic
