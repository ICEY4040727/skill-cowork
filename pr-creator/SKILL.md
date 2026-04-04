---
name: pr-creator
description: Create clean, review-ready pull requests with clear scope, linked issues, structured PR descriptions, and reviewer-focused checklists. Use this whenever the user asks to open a PR, prepare a PR body, summarize code changes, request review, or decide labels like needs-review.
---

# PR Creator

用于将代码改动整理成可快速审查、可追踪、可合并的 Pull Request。

## Input Signals

当用户出现以下表达时触发本 skill：

- "帮我开 PR"
- "写一份可以直接贴 GitHub 的 PR 描述"
- "把这次改动整理成 review-friendly"
- "这个改动应该怎么拆 PR"

## Required Output

最终输出必须是可直接粘贴到 GitHub 的 PR 描述 markdown，包含：

1. 变更概述（做了什么，为什么做）
2. 改动清单（模块与关键文件）
3. 自查清单（测试、回归、兼容性）
4. Reviewer 关注点（高风险区域）
5. Issue 关联（如 `Closes #N`）

模板见 `references/prTemplate.md`。

## Workflow

### Step 1. 定义 PR 边界与前置条件

- 只覆盖一个核心目标（单一职责）。
- 如果变更跨多个主题，先拆分成多个 PR 草案。

以下改动属于高风险变更，必须先走“方案评审”再开发：

- 数据库 schema 变更
- 架构级改动（中间件、路由重组、基础策略调整）
- 跨 3 个以上文件的结构性重构
- 存在多个技术方案且 trade-off 显著

方案评审最低要求：

- 先创建方案 issue（A/B 方案与 trade-off）
- Reviewer 在 issue 中给出审视意见
- Owner 明确确认后，Creator 才能进入实现与开 PR

### Step 2. 收集变更证据

在 PR 描述中必须基于事实，不使用模糊措辞：

- 改动范围：模块、接口、脚本、配置。
- 影响评估：功能行为、兼容性、性能、安全性。
- 测试结果：执行了什么测试，结果如何。

### Step 3. 生成 PR 描述

严格按模板输出，避免缺段：

- Overview
- Change List
- Self-Check
- Reviewer Focus
- Linked Issues

### Step 4. 设置协作标签

建议规则见 `references/labelPolicy.md`：

- 创建后默认加 `needs-review`
- Reviewer 仅给出审查结论，不直接代 Owner 做最终合并决策
- `approved` 由 Owner 在确认可合并时添加

### Step 5. 通知 Reviewer（可选）

当 PR 为高优先级或阻塞项时，可通知 Reviewer：

```bash
tmux send-keys -t SelfLearn-reviewer "[Creator 通知] PR #<N> 已创建并标记 needs-review，请审查。" Enter
```

## Quality Checklist

提交前确认：

- PR 是否单一职责。
- PR 描述是否可直接粘贴使用。
- 是否包含测试与风险信息。
- 是否正确关联 Issue。
- 是否已设置 `needs-review`。
- 对于高风险变更，是否已完成“方案 issue -> Reviewer 审视 -> Owner 确认”。
