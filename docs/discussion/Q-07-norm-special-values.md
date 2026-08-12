# Q-07. norm 中 NaN 与无穷的优先级 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

当前 `norm` 文档分别声明存在无穷分量时结果为无穷、存在 NaN 分量时结果为 NaN，但没有说明二者同时存在时谁优先。当前缩放算法还会让普通的无穷向量得到 NaN。R0 需要确定完整的特殊值优先级。

## 问题引发模型

### 问题复现

`norm([1.0, +∞])` 当前在归一化时计算 `∞ / ∞`，最终得到 NaN，而文档要求无穷。

### 问题分析

仅修复单个反例仍不足以形成契约；还要决定 `[NaN, +∞]` 应返回 NaN 还是无穷，并据此安排扫描顺序和测试。

### 外部契约比较

- C23 的 `hypot` 是最直接的标准参照。其一般定义要求避免不必要的上溢和下溢；Annex F 进一步规定 [`hypot(±∞, y)` 返回 `+∞`，即使 `y` 是 NaN](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3096.pdf#page=544)，而没有无穷时 NaN 才传播。
- [ECMAScript `Math.hypot`](https://tc39.es/ecma262/2025/multipage/numbers-and-dates.html#sec-math.hypot) 接受任意数量的坐标，明确先扫描所有无穷，再扫描 NaN。
- CPython 对任意维 `math.hypot` 的[正式测试](https://github.com/python/cpython/blob/v3.14.0/Lib/test/test_math.py#L800-L866)规定“任一无穷则 `+∞`；没有无穷时，任一 NaN 才返回 NaN”。
- NumPy 的 `linalg.vector_norm` 代表另一种真实约定：默认二范数最终使用[平方和归约](https://github.com/numpy/numpy/blob/v2.5.0/numpy/linalg/_linalg.py#L2746-L2803)，因此 `[NaN, +∞]` 会得到 NaN。
- MoonBit Core 当前也不是单一参照：Double 的[非 JS 实现](https://github.com/moonbitlang/core/blob/ace5c884/math/algebraic_double_nonjs.mbt#L109-L116)先检查 NaN，而 [JS 实现](https://github.com/moonbitlang/core/blob/ace5c884/math/algebraic_double_js.mbt#L73)委托给 `Math.hypot`，混合输入会得到 `+∞`。这同时暴露了跨后端差异。

因此这里不是根据现有文档自行补写规则，而是在两个外部家族之间选择。依照 Q-01 已采用的裁判顺序，C23/IEC 60559 的 `hypot` 规则优先于 NumPy 的一般数组归约行为，也优先于 MoonBit Core 当前不一致的实现。

## 关联问题

1. [Q-01. 稳定 API 的语义裁判顺序](Q-01-semantic-precedence.md)（依赖：优先参考成熟 hypot/norm 语义）
2. [Q-08. norm 对空向量的处理](Q-08-norm-empty-vector.md)（一般关系：同属 norm 边界契约，但可独立决定）
3. [Q-11. 稳定 API 的跨后端一致性标准](Q-11-cross-backend-consistency.md)（一般关系：MoonBit Core 的 hypot 现状本身存在后端差异）

## 建议的解决方案

### A1. 对齐 C23、ECMAScript 与 Python hypot：无穷优先 【已采纳】

#### 方案描述

只要向量中存在任一正无穷或负无穷，`norm` 就返回 `+∞`；若不存在无穷但存在 NaN，则返回 NaN；否则计算有限值范数。该规则与输入顺序无关。

#### 优点

- 直接扩展 C23 `hypot` 的特殊值规则，并与任意维的 ECMAScript、Python 实现一致。
- 符合 Q-01 已采用的标准优先顺序。
- 可以消除 MoonBit Core 当前 JS 与非 JS 路径在混合特殊值上的差异，而不是任选其中一个后端作为真值。

#### 缺点

- 与 NumPy `linalg.vector_norm([NaN, +∞]) -> NaN` 的数组归约习惯不同。
- 也不同于 MoonBit Core 当前 Double 非 JS 实现，需要在兼容性说明中明确这是标准优先于当前 Core 行为的结果。

### A2. 对齐 NumPy 向量范数：NaN 优先

#### 方案描述

只要存在 NaN 就返回 NaN；仅在没有 NaN 且存在无穷时返回 `+∞`。

#### 优点

- 与 NumPy 默认二范数的可观察结果一致。
- 与 MoonBit Core 当前 Double 非 JS 路径一致。

#### 缺点

- 与 C23 Annex F 的 `hypot`、ECMAScript `Math.hypot` 和 CPython 任意维 `math.hypot` 不一致。
- 按 Q-01 的裁判顺序，不能仅因 NumPy 的函数也名为 norm 就让这一惯例覆盖更直接的标准语义。

## 最终采用方案

A1. 对齐 C23、ECMAScript 与 Python hypot：无穷优先
