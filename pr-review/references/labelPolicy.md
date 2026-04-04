# Label Policy

本文件定义 pr-review skill 在 PR/Issue 协作中的标签使用约定。

## PR Labels

- `needs-review`: PR 创建后待 Reviewer 审查。
- `approved`: 仅由 Owner 在最终确认可合并后添加。

## Review 结果与标签建议

- 结论 `Approve`:
  - Reviewer 给出通过意见
  - Owner 添加 `approved`
  - 移除 `needs-review`

- 结论 `Comment`:
  - 保留 `needs-review`
  - 不添加 `approved`
  - 由 Creator 在 PR comment 中确认是否处理建议项

- 结论 `Request changes`:
  - 保留 `needs-review`
  - 不添加 `approved`

## 与 Issue 的联动

- PR 请求修改且涉及需求变更时：
  - 在关联 issue 增加/保留 `needs-review`
- PR 合并后：
  - 对应 issue 按流程转入下一状态（例如关闭或标记完成）

## 自检清单

- 是否在“尚未通过审查”时误加 `approved`。
- 是否在审查通过后移除 `needs-review`。
- 是否确保标签状态与审查结论一致。
- 是否在 `Comment` 路径下遗漏了 Creator 的后续响应。
