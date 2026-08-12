# Q-15. logsumexp 中 NaN 与正无穷的优先级 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

非空数组同时包含 NaN 和正无穷时，`logsumexp` 可以选择传播 NaN，也可以让确定会支配总和的正无穷优先。这个判断独立于全负无穷和空数组行为，需要单独形成契约。

## 问题引发模型

### 问题复现

当前最大值平移算法对 `[NaN, +∞]` 和 `[+∞, NaN]` 都会在中间步骤产生 NaN，最终返回 NaN。该结果尚未写入契约，也缺少输入顺序互换的回归测试。

### 外部契约比较

- [SciPy 将 `logsumexp` 定义为稳定计算 `log(sum(exp(a)))`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.logsumexp.html)。其实现对非有限结果[退回直接的 `exp`、求和和 `log` 路径](https://github.com/scipy/scipy/blob/v1.18.0/scipy/special/_logsumexp.py#L1263-L1295)；因此 `+∞` 与 NaN 同时出现时，求和传播 NaN，最终结果也是 NaN。
- [JAX 的实现](https://github.com/jax-ml/jax/blob/main/jax/_src/ops/special.py#L533-L552)在归约最大值不是有限数时把平移量改为零，但仍对全部输入求指数并归约；混合的 `+∞` 与 NaN 因此同样传播为 NaN。
- `hypot` 中“无穷优先于 NaN”的规则不能直接移植到这里。那是 C23 对 `hypot` 明文规定的特殊例外，而上述直接实现 `logsumexp` 的库没有采用这一例外。

因此，依照 Q-01 的裁判顺序，应优先跟随直接提供同层函数的 SciPy/JAX，而不是根据 `hypot` 的不同函数语义自主类推。

## 关联问题

1. [Q-01. 稳定 API 的语义裁判顺序](Q-01-semantic-precedence.md)（依赖：特殊值契约需与已采用的裁判顺序一致）
2. [Q-09. logsumexp 对全负无穷输入的处理](Q-09-logsumexp-special-values.md)（一般关系：同属 logsumexp 特殊值契约）

## 建议的解决方案

### A1. 对齐 SciPy/JAX：任一 NaN 都传播 【已采纳】

#### 方案描述

只要输入包含 NaN，`logsumexp` 就返回 NaN，即使同一输入还包含 `+∞`；没有 NaN 但存在 `+∞` 时返回 `+∞`。结果不得依赖 NaN 与无穷的输入顺序。

若调用者希望忽略缺失或无效元素，应先显式过滤，或将来另设名称明确的忽略 NaN 接口，而不改变 `logsumexp` 的默认语义。

#### 优点

- 与 SciPy 和 JAX 的直接实现一致。
- 保留 IEEE 浮点运算对 NaN 的诊断传播，不会因另一个无穷元素而静默掩盖无效输入。
- 当前实现的可观察结果无需反转，只需补齐契约和回归测试。

#### 缺点

- 若把 NaN 理解为“未知但可忽略”的缺失值，即使存在确定支配总和的 `+∞`，结果仍无法返回 `+∞`。

### A2. 让正无穷优先于 NaN

#### 方案描述

只要输入包含 `+∞` 就返回 `+∞`；仅在没有 `+∞` 时传播 NaN。

#### 优点

- 从扩展实数总和的支配关系看，`+∞` 可以被视为已经确定结果。
- 与 Q-07 采用的 `norm` 特殊值优先级表面一致。

#### 缺点

- 与 SciPy/JAX 的 `logsumexp` 行为不一致。
- 把 C23 专门赋予 `hypot` 的例外扩展到另一个函数，缺少直接的外部契约依据。
- 会吞掉 NaN，可能掩盖无效输入。

## 最终采用方案

A1. 对齐 SciPy/JAX：任一 NaN 都传播
