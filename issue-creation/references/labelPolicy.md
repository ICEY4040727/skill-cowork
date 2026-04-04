# Label Policy

本文件定义 issue-creation skill 的 labels 选择规则。

## 必选 Labels

每个 issue 至少包含以下 3 类 label：

1. 类型标签（必选其一）
- `feature`
- `bugfix`
- `research`

2. 责任标签（至少一个）
- `creator`
- `reviewer`

3. 优先级标签（必选其一）
- `P0`
- `P1`
- `P2`

## 条件 Labels

- `approved`: 仅当 Owner 明确批准后添加。
- `needs-review`: issue 需要 Reviewer 先审阅方案或验收口径时添加。

## 决策规则

- Bug 且阻塞核心流程：`bugfix + P0 + creator`。
- 新功能且已有明确方案：`feature + P1 + creator`。
- 调研任务或方案提案：`research + P1/P2 + reviewer`。
- 涉及跨模块方案评审：在以上基础上加 `needs-review`。

## 自检清单

- 是否只选择了一个类型标签。
- 是否只选择了一个优先级标签。
- 是否至少有一个责任标签。
- 是否错误地提前添加了 `approved`。
