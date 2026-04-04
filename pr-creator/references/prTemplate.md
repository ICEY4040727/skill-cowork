# PR Template

用于生成可直接粘贴到 GitHub 的 PR 描述。

## 直接粘贴版

```markdown
## Overview
[本 PR 的目的、背景与核心收益]

## Change List
- [模块/文件 1]：[改动说明]
- [模块/文件 2]：[改动说明]

## Self-Check
- [ ] 已运行相关测试（单测/集成/手测）
- [ ] 已评估回归风险
- [ ] 已检查兼容性（接口/配置/数据）
- [ ] 无无关改动混入

## Reviewer Focus
- [高风险点 1]
- [高风险点 2]

## Linked Issues
Closes #N
```

## 最小填写要求

- Change List 至少 2 条，且包含具体模块或文件。
- Self-Check 必须全部可核对，不能空置。
- Reviewer Focus 至少 1 条。
- Linked Issues 必须填写真实 issue（`Closes #N`），不得留空。

## 高风险变更附加要求

若涉及 schema/架构/跨 3 文件以上重构，应在 Overview 中补充：

- 方案评审 issue 链接
- Owner 确认信息（如 comment 链接）
