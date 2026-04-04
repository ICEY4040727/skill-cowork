# Label Policy

本文件定义 pr-creator 的 PR 标签策略。

## 默认标签

- `needs-review`: PR 创建后默认添加。

## 条件标签

- `approved`: 仅由 Owner 在确认可合并后添加。
- `P0` / `P1` / `P2`: 若仓库 PR 流程也使用优先级标签，可按 issue 优先级同步。

## 自检清单

- 是否在未审查前误加 `approved`。
- 是否遗漏 `needs-review`。
- 标签是否与当前状态一致。
- 是否将 Owner 的最终裁决与 Reviewer 的审查意见混淆。
