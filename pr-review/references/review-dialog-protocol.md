# PR Review 对话协议

本文件定义 Creator 与 Reviewer 在 PR comments 中的协作细节。

## 对话闭环

```text
Creator 提交 PR
  → Reviewer 审查并留言
    → Creator 读取并理解反馈
      → Creator 修复并回复逐项对应说明
        → Reviewer re-review
          → approve / comment / request changes
            → Owner 最终裁决
```

## Creator 回复模板

```markdown
## Creator 修复回复

已修复 Reviewer 提出的 N 项问题：

| # | 问题 | 修复 |
|---|------|------|
| 1 | [问题描述] | [修复说明] |
| 2 | [问题描述] | [修复说明] |

请 re-review。
```

## 强制规则

- 修复后必须在 PR comment 逐项回复。
- 不得只推代码不回复。
- 若不同意建议，必须写明理由。
- PR 若声明关联 issue，必须使用 `Closes/Fixes/Resolves #N`；仅 `Related to #N` 不会自动闭合。

## 合并与中断规则（新增）

- 当 PR 满足可合并条件（非 Draft、必需检查通过、无阻塞问题）时，Reviewer 必须先向 Owner 询问是否同意 merge。
- 仅在 Owner 明确同意后，Reviewer 才可执行 merge。
- 若存在任一阻塞条件（例如 CI 失败、仍为 Draft、存在阻塞缺陷），Reviewer 必须中断合并并立即通知 Owner。
- 中断通知应包含：阻塞项清单、证据链接（如 workflow/job URL）、建议下一步。
