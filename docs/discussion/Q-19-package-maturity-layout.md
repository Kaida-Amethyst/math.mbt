# Q-19. stable、experimental 与 internal 的包分层 〔已解决〕

> 最后更新日期：2026-08-12
> 仓库：Kaida-Amethyst/math.mbt
> 记录者：Codex

## 问题描述

后续讨论提出不再把独立成熟度清单作为主要约束，而是让代码所在的包直接表示成熟度：stable 接口位于 `src/` 根包，experimental 接口位于 `src/experimental/`，需要被多个包复用但不应对外承诺的实现位于 `src/internal/`。初始时所有尚未认证的公共能力进入 experimental，通过晋升测试后再移动到 stable。

这一方向不以兼容现有导入路径为前提。本问题同时确定四个细节：internal 按职责而不是宽泛的 `utils` 拆包；所有公共符号一起纳入成熟度分层；stable、experimental 与 internal 采用单向依赖；晋升以能保持依赖方向成立的最小依赖闭包为单位。

## 关联问题

1. [Q-04. ULP 测量函数是否保留为公共 API](Q-04-ulp-api-visibility.md)（落实：internal 包需要实际限制 ULP 工具的外部可见性）
2. [Q-13. R0 是否清点全部公共 API 的成熟度](Q-13-public-api-inventory.md)（替代：包路径成为成熟度事实源，Q-13 的独立全量清单不再实施）
3. [Q-17. experimental 状态在 R0 中如何呈现](Q-17-experimental-surface.md)（替代：本问题以包结构取代已经作废的清单优先方案）
4. [Q-18. ULP 内部尺子的实施方案](Q-18-ulp-internal-ruler-implementation.md)（后续：ULP 文件已经内部化，但采用本方案后还需迁入职责化 internal 包）
5. [Q-20. stable API 的晋升测试门槛](Q-20-stable-promotion-testing.md)（依赖：从 experimental 移入 stable 的条件由该问题决定）

## 建议的解决方案

### A1. 以包路径作为成熟度边界，internal 按职责拆包 【已采纳】

#### 方案描述

采用以下物理边界：

- `src/` 根包只放已经通过晋升门槛的 stable 公共符号。
- `src/experimental/` 作为独立包，容纳尚未认证的公共符号。初次迁移应覆盖函数、常量、类型和枚举等全部公共符号，不能只移动函数；私有辅助实现默认留在所属包内。
- `src/internal/ulp/` 容纳 ULP 距离和相关测试辅助，不建立含义宽泛的 `src/internal/utils/`。将来只有出现新的明确职责时，才增加 `internal/fpbits` 等同样按用途命名的包。

MoonBit 的目录对应包；官方的 [internal 包规则](https://docs.moonbitlang.com/en/stable/language/packages.html) 会把 `a/b/c/internal/...` 限制给 `a/b/c` 及其子包使用。因此 internal 包中需要跨包调用的符号可以声明为 `pub`，其可达范围仍受 internal 路径限制；这和把它作为库的稳定公共 API 是两件不同的事。

依赖方向固定为：stable 可以依赖 internal，experimental 可以依赖 stable 和 internal，stable 不得依赖 experimental，experimental 不重新导出 stable。ULP 目前只承担测试测量，不应成为 stable 或 experimental 的普通运行时依赖；相应测试应迁入 `*_test.mbt` 或 `*_wbtest.mbt`，并使用 MoonBit 的 [test/wbtest 专用导入](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html#test-import)。

晋升单位不是机械的“一个函数文件”，而是能保持依赖方向成立的最小依赖闭包。例如互相依赖或共同构成契约的函数族应一起评估；候选代码依赖的公共能力必须已经 stable，其他共享实现只能位于职责明确的 internal 包。晋升时实现、公共测试和文档一起移动。

#### 优点

- 包路径就是可由编译器检查的成熟度边界，不需要另外维护一份容易漂移的状态清单。
- 用户从导入路径即可知道是否依赖 experimental 能力。
- internal 的访问范围由语言规则约束，同时允许 stable 与 experimental 复用实现。
- 按职责拆分 internal 可以避免 `utils` 演变为无边界的依赖汇集点。

#### 缺点

- 初始迁移会改变大部分公共 API 的导入路径，并要求同步移动测试和文档。
- internal 子包的跨包符号需要使用 `pub`，代码审查时必须区分“包间可见”和“对外稳定承诺”。
- 函数族存在依赖时，晋升工作量可能大于单个函数表面上的改动量。

## 最终采用方案

A1. 以包路径作为成熟度边界，internal 按职责拆包
