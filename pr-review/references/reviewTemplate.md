# Review Template

用于在 GitHub PR 评论中输出结构化审查结果。

## 直接粘贴版

```markdown
## Review Summary
- Decision: Approve | Comment | Request changes
- Risk: Critical | High | Medium | Low
- Scope: [受影响模块]

## Findings
1. [Severity] [标题]
   - Evidence: [文件路径 + 关键位置/复现步骤]
   - Impact: [对功能、稳定性、安全性的影响]
   - Suggestion: [可执行修复建议]

## Regression Risks
- [风险项 1]
- [风险项 2]

## Test Gaps
- [缺失用例或验证步骤]

## Skill-Assisted Validation
- Selected Skills:
   - [skill-name]: [选择理由]
- Example Source:
   - [none | references/examples/reviewCommentExamples.md#Example-X]
- Test Actions:
   - [执行了什么测试]
- Results:
   - [通过/失败 + 关键证据]
- Confidence:
   - [High/Medium/Low + 原因]

## Final Decision
- [一句话给出是否可合并]
```

## 最小填写要求

- 至少 1 条 Findings（如果无问题，写“未发现阻塞问题”并给出抽样范围）。
- 每条 Findings 必须包含 Evidence 和 Suggestion。
- Decision 必须与严重级别一致。
- Skill-Assisted Validation 必须说明测试动作和结果；若未执行测试需给出阻塞原因。
- Final Decision 必须可直接作为 PR review 总结。

## Severity Guide

- Critical: 可导致线上故障、数据错误、严重安全风险。
- High: 高概率引发功能异常或明显回归。
- Medium: 不阻塞合并，但应尽快处理。
- Low: 风格或可维护性建议。

## Decision Guide

- Approve: 无 High/Critical 问题，且测试充分。
- Comment: 仅 Medium/Low 建议。
- Request changes: 任一 Critical/High，或测试缺失导致高风险。
