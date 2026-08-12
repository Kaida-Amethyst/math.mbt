# Q-10. logsumexp 对空数组的处理 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

`logsumexp` 当前通过访问第一个元素寻找最大值，空数组会越界。R0 需要决定空输入返回 `-∞`、返回其他值，还是显式拒绝。该问题可以独立于非空数组的 NaN 与无穷规则决定。

## 问题引发模型

### 问题复现

当前 `max_element([])` 无法产生有效的最大元素和索引，因此空输入在进入稳定求和公式前就失败。这个实现限制本身不能决定公共契约。

### 外部契约比较

- SciPy 的[正式测试](https://github.com/scipy/scipy/blob/v1.18.0/scipy/special/tests/test_logsumexp.py#L38-L43)明确要求 `logsumexp([]) == -∞`；当前实现也为零尺寸输入[直接构造 `-∞`](https://github.com/scipy/scipy/blob/v1.18.0/scipy/special/_logsumexp.py#L1259-L1305)。
- JAX 将该函数定义为 [SciPy 兼容实现](https://docs.jax.dev/en/latest/_autosummary/jax.scipy.special.logsumexp.html)，并在[源码](https://github.com/jax-ml/jax/blob/main/jax/_src/ops/special.py#L77-L96)中以 `-∞` 作为最大值归约初值；空归约的指数和为零，最终同样得到 `log(0) = -∞`。
- 这一行为也保持 log-sum-exp 作为 log 域加法归约的单位元：把空输入与任意输入连接，不应改变后者的结果。

因此，`-∞` 不只是从公式临时推导出的建议，而是 SciPy 明确测试并由 JAX 跟随的外部契约。

## 关联问题

1. [Q-09. logsumexp 对全负无穷输入的处理](Q-09-logsumexp-special-values.md)（一般关系：都涉及扩展实数上的边界行为）
2. [Q-15. logsumexp 中 NaN 与正无穷的优先级](Q-15-logsumexp-nan-infinity.md)（一般关系：同属 logsumexp 边界契约，但可独立决定）

## 建议的解决方案

### A1. 对齐 SciPy/JAX：空数组返回负无穷 【已采纳】

#### 方案描述

定义 `logsumexp([]) -> -∞`，并在访问最大元素之前处理空数组。

#### 优点

- 直接对齐 SciPy 的明确回归测试以及 JAX 的兼容实现。
- 保留 log 域加法归约的单位元，方便分块、过滤和增量组合。
- 不需要改变现有返回类型。

#### 缺点

- 业务上意外产生空数组时不会自动失败；调用者若要求非空，需要自行验证输入。

### A2. 把空数组视为非法输入并 panic

#### 方案描述

把非空作为函数前置条件，对空数组给出明确 panic，而不是保留当前偶然的越界失败。

#### 优点

- 能立即暴露调用方意外产生空集合的问题。

#### 缺点

- 与 SciPy/JAX 的归约契约不兼容。
- 失去 `-∞` 作为 log 域加法单位元带来的组合性。

## 最终采用方案

A1. 对齐 SciPy/JAX：空数组返回负无穷
