# Q-09. logsumexp 对全负无穷输入的处理 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

当前 `logsumexp` 通过减去最大值避免普通溢出，但在全部元素为负无穷时会计算 `-∞ - -∞` 并返回 NaN。本问题只决定非空数组全部为负无穷时的结果；NaN 与正无穷混合输入另行讨论。

## 问题引发模型

### 问题复现

`logsumexp([-∞, -∞])` 当前返回 NaN；按 `log(sum(exp(x)))` 的数学延拓，结果应为 `-∞`。

### 问题分析

该输入不能直接进入普通的“减去最大值”路径，需要显式处理或采用不会产生 `-∞ - -∞` 的等价算法。

### 外部契约比较

- SciPy 将 `logsumexp` 定义为稳定计算 `log(sum(exp(a)))`，其[正式测试](https://github.com/scipy/scipy/blob/v1.18.0/scipy/special/tests/test_logsumexp.py#L38-L74)明确要求单个 `-∞` 和 `[-∞, -∞]` 都返回 `-∞`。
- JAX 明确把自己的实现定义为 [SciPy `logsumexp` 的对应实现](https://docs.jax.dev/en/latest/_autosummary/jax.scipy.special.logsumexp.html)，其[源码](https://github.com/jax-ml/jax/blob/main/jax/_src/ops/special.py#L77-L96)以 `-∞` 作为最大值归约初值，并将全负无穷输入归结为零的指数和，从而返回 `log(0) = -∞`。
- PyTorch 同样将 [`torch.logsumexp`](https://docs.pytorch.org/docs/stable/generated/torch.logsumexp.html) 定义为稳定计算同一表达式。

这些直接提供 log-sum-exp 的权威库在函数定义上没有为全负无穷引入 NaN 语义；SciPy 还把期望结果固定在回归测试中。

## 关联问题

1. [Q-01. 稳定 API 的语义裁判顺序](Q-01-semantic-precedence.md)（依赖：特殊值契约需与基础语义一致）
2. [Q-10. logsumexp 对空数组的处理](Q-10-logsumexp-empty-array.md)（一般关系：都涉及扩展实数上的单位元行为）
3. [Q-15. logsumexp 中 NaN 与正无穷的优先级](Q-15-logsumexp-nan-infinity.md)（一般关系：同属特殊值契约，但可独立决定）

## 建议的解决方案

### A1. 对齐 SciPy/JAX：全负无穷输入返回负无穷 【已采纳】

#### 方案描述

将非空数组 `logsumexp([-∞, ..., -∞])` 定义为 `-∞`，与 `log(0)` 的扩展实数结果一致。

#### 优点

- 符合该运算的数学含义和常见数值计算用法。
- 修复已经确认的反例。

#### 缺点

- NaN、正无穷和空数组的契约由 Q-10 与 Q-15 分别补齐，需要合并落实为完整测试矩阵。

### A2. 保留当前 NaN 结果 【不建议】

#### 方案描述

把全负无穷输入产生的 NaN 固定为公共契约。

#### 优点

- 无需修改当前实现路径。

#### 缺点

- 与 SciPy 的明确测试和 JAX 的兼容目标不一致。
- NaN 来自稳定化公式中的未定义中间量 `-∞ - -∞`，不是原始 `log(sum(exp(x)))` 的结果。

## 最终采用方案

A1. 对齐 SciPy/JAX：全负无穷输入返回负无穷
