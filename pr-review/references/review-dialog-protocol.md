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
