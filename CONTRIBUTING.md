# 协作规范

## 快速原则（10 行版）

1. Owner 负责最终裁决与合并。
2. Creator 负责实现代码并创建 PR。
3. Reviewer 负责审查与技术风险识别，不直接写实现代码。
4. 所有改动必须走 Issue -> PR 流程，不得直推 main。
5. PR 必须关联 Issue（`Closes #N`）并标记 `needs-review`。
6. `approved` 仅由 Owner 在最终确认后添加。
7. 高风险改动先方案评审，再实现开发。
8. Creator 修复后必须在 PR comments 逐项回复。
9. Reviewer 给出 `approve/comment/request changes`，Owner 做最终决定。
10. 通过 tmux 通知减少等待，但不要打断对方正在输出。

## 角色分工

| 角色 | 负责人 | 职责 |
|------|--------|------|
| **Owner** | 项目负责人（人类） | 最终决策、合并 PR、确定优先级 |
| **Creator** | Claude Code | 在现有框架内实现功能，产出代码（分支、提交、PR） |
| **Reviewer** | Claude Code | 审查代码、识别风险、提出修复建议 |

## 状态流转

```text
Issue 创建 -> Owner 标记 approved
  -> Creator 接手开发
    -> 提交 PR（关联 Issue，标记 needs-review）
      -> Reviewer 审查（approve/comment/request changes）
        -> Owner 最终裁决并合并
```

## 协作边界

### Creator 可直接执行

- 现有模块内新增/修改功能
- Bug 修复
- UI 样式和交互微调

### Creator 必须先方案评审

- 数据库 schema 变更
- 架构级改动（中间件、路由重组、基础策略调整）
- 跨 3 个以上文件的结构性重构
- 多方案 trade-off 显著的技术选型

高风险前置门槛：方案 issue -> Reviewer 审视 -> Owner 确认 -> 实现与开 PR。

## Git 与 PR 规范

- 分支：`feat/#N-描述`、`fix/#N-描述`、`docs/描述`、`refactor/描述`
- Commit：Conventional Commits（`feat:`, `fix:`, `docs:`, `refactor:`, `test:`）
- PR 要求：单一职责、尽量 300 行内、必须关联 Issue
- PR 描述最少包含：变更概述、改动清单、自查清单、Reviewer 关注点

## 标签规范

- `needs-review`：PR 创建后默认添加
- `approved`：仅 Owner 最终确认后添加
- 任务类标签：`feature` / `bugfix` / `research`
- 优先级标签：`P0` / `P1` / `P2`

## 详细文档

- PR 对话协议：`pr-review/references/review-dialog-protocol.md`
- tmux 通知指南：`pr-review/references/tmux-notification-guide.md`
- 各 skill 细则：
  - `issue-creation/SKILL.md`
  - `pr-creator/SKILL.md`
  - `pr-review/SKILL.md`

## 发布前清理

- 对外发布前必须执行：`bash scripts/prepare_release.sh`
- `research/` 下 authoring 实验产物不进入发布包
- `pr-review-workspace/` 仅保留 `README.md` 作为目录占位说明
