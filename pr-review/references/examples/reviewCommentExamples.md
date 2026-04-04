# Review Comment Examples (Selected, v5 Verified)

用于存放 A/B v5 评测后筛选出的高质量案例。

## 使用规则

- 先完成无示例基线测试，再从真实输出中挑选案例放入本文件。
- 只保留通过评测且结构完整、证据充分的案例。
- 案例必须匿名化，不要包含真实密钥、账号或敏感信息。

## Example 1: Context Missing (Block Merge)

```markdown
## Review Summary
- Decision: Request changes
- Risk: High
- Scope: 目标服务改动（上下文缺失）

## Findings
1. [Critical] 无法定位 PR 变更内容
   - Evidence: 工作目录仅包含 skill 包文件，未找到目标服务源码或 PR diff。
   - Impact: 无法对正确性、安全性、兼容性做有效审查。
   - Suggestion: 提供 PR URL、git diff/patch 或正确仓库路径后再审。

## Regression Risks
- 无法评估：缺少变更文件与差异信息。

## Test Gaps
- 无法确认测试覆盖：未提供相关测试结果。

## Skill-Assisted Validation
- Selected Skills:
  - pr-review: 风险分级与结构化审查
- Test Actions:
  - 定位源码、差异与测试结果
- Results:
  - 失败：无可审查输入
- Confidence:
  - Low：上下文缺失

## Final Decision
- Request changes。当前输入不足，不应合并。
```

## Example 2: Refactor PR (Risk and Test Focus)

```markdown
## Review Summary
- Decision: Request changes
- Risk: High
- Scope: 重构类跨模块改动

## Findings
1. [High] 回归风险未被测试覆盖
   - Evidence: 缺少关键路径与异常路径回归测试结果。
   - Impact: 上线后可能出现功能行为偏移。
   - Suggestion: 补充核心流程与异常流程集成测试。

2. [Medium] 错误处理一致性不足
   - Evidence: 异常分支未统一错误码映射策略。
   - Impact: 增加排障成本。
   - Suggestion: 统一错误映射并补充断言。

## Regression Risks
- 状态机行为偏移。
- 跨模块接口契约不一致。

## Test Gaps
- 缺少跨模块集成测试。

## Skill-Assisted Validation
- Selected Skills:
  - pr-review: 风险优先级审查
- Test Actions:
  - 检查回归风险与测试覆盖完整性
- Results:
  - 部分失败：覆盖不足
- Confidence:
  - Medium：需补测确认

## Final Decision
- Request changes。需补齐测试后再提审。
```

## Example 3: Docs-Only PR (Low Risk)

```markdown
## Review Summary
- Decision: Comment
- Risk: Low
- Scope: 文档与注释

## Findings
1. [Low] 术语不一致
   - Evidence: 文档中同一概念出现多种写法。
   - Impact: 阅读理解成本增加，但不影响运行时行为。
   - Suggestion: 统一术语并补充术语说明。

## Regression Risks
- 运行时回归风险低（无可执行逻辑变更）。

## Test Gaps
- 无阻塞测试缺口；建议做文档链接可用性检查。

## Skill-Assisted Validation
- Selected Skills:
  - pr-review: 结构化审查
- Test Actions:
  - 核对变更是否仅文档/注释
- Results:
  - 通过：未发现可执行逻辑变更
- Confidence:
  - High：范围明确

## Final Decision
- Comment。可合并，建议后续统一术语。
```
