---
name: pr-review
description: Review pull requests with risk-based checks, skill-assisted testing, clear severity levels, and merge decisions. Use this whenever the user asks to review a PR, check code quality, assess regression risk, validate behavior with related skills/tests, decide approve/request-changes, or summarize review comments.
---

# PR Review

用于在协作流程中给出高质量、可执行、可追踪的 PR 审查结论。

## Input Signals

当用户出现以下表达时触发本 skill：

- "帮我 review 这个 PR"
- "看看这次改动有没有风险"
- "给我一个能直接贴到 GitHub 的 review"
- "这次该 approve 还是 request changes"

## Required Output

审查输出模板见 `references/reviewTemplate.md`，审查相关 labels 规则见 `references/labelPolicy.md`，示例池见 `references/examples/reviewCommentExamples.md`，对话协作规则见 `references/review-dialog-protocol.md`。

最终回复时，必须提供一段“可直接粘贴到 GitHub PR review comment”的完整 markdown，不要只给结论摘要。

审查输出必须包含：

1. 结论：`Approve` / `Comment` / `Request changes`。
2. 发现项：按严重级别归类（Critical/High/Medium/Low）。
3. 证据：每条问题附文件路径、关键代码位置或复现条件。
4. 建议：给出可执行修复方向，而不是只指出问题。
5. 回归风险：列出可能受影响模块。
6. 测试证据：说明调用了哪些相关 skill/测试、结果如何、结论置信度。

**当改动涉及前端 UI 时，必须评估用户体验影响，并要求提供相应截图或录屏。**

### UI 改动 PR 的特殊审查要点

当 PR 修改了页面布局、CSS 类名或组件结构时：

1. **E2E 测试影响评估**
   - 检查是否有测试选择器失效
   - 在 Findings 中列出需要更新的测试文件
   - 不要因此阻塞合并（测试可后续更新）

2. **文档截图影响评估**
   - 检查 `docs/evidence/` 中是否有相关页面截图
   - 在 Findings 中列出需要重新生成的截图
   - 标记为 `[Low]` 优先级，让 Creator 在合并后补充

3. **后续任务清单**
   - 明确哪些任务由 Creator 在合并后完成
   - 包括：更新 E2E 测试、重新生成截图、更新 Release Notes
   - 不要由 Reviewer 创建 Issue，直接在 review comment 中指明

**原则**：Reviewer 指出问题，Creator 补充完成。Reviewer 不应包揽 Creator 的责任。

## Workflow

### Step 1. 建立审查上下文

先确认：

- PR 类型：`feat`/`fix`/`docs`/`refactor`/`test`/`chore`
- 影响范围：单模块还是跨模块
- 是否涉及数据结构、权限、并发、外部接口
- 是否有对应 issue 与验收标准

### Step 2. 风险优先级审查

按照下面顺序审查，优先找会导致线上故障的问题：

1. 正确性：逻辑错误、边界条件、空值处理、错误路径。
2. 安全性：鉴权、输入校验、敏感信息泄露。
3. 兼容性：接口变更、配置变更、向后兼容。
4. 可维护性：重复代码、命名可读性、过度耦合。
5. 测试覆盖：是否覆盖关键路径和异常路径。

### Step 3. 联动相关验证测试

- 根据改动域选择 1-2 个相关测试路径或验证方法。
- 对关键行为做验证，不只停留在静态代码阅读。
- 记录测试动作、结果、失败证据和置信度。

若无法执行验证测试，必须在 review 中明确阻塞原因，不得直接 `Approve`。

### Step 4. 形成审查结论

可直接复用的评论结构见 `references/reviewTemplate.md`。

输出顺序固定为：Review Summary → Findings → Regression Risks → Test Gaps → Final Decision。

决策规则：

- `Approve`: 无 High 及以上问题，且改动目标清晰、测试充分。
- `Comment`: 仅 Low/Medium 建议，不阻塞合并。
- `Request changes`: 存在 Critical/High 问题，或缺少必要测试导致高回归风险。

补充规则：若改动仅限文档/注释且未涉及可执行逻辑，风险默认不高于 `Medium`，优先使用 `Comment` 或 `Approve`，除非有明确阻塞证据。

建议使用以下结构输出 review：

```markdown
## Review Summary
- Decision: Request changes
- Risk: High

## Findings
1. [High] 空指针风险：xxx
2. [Medium] 测试遗漏：xxx

## Suggested Fixes
1. 在 xxx 增加空值分支
2. 补充 xxx 场景单测
```

### Step 5. 协作通知策略

仅在以下情况主动通知 Creator：

- 结论为 `Request changes`
- 发现 Critical 问题
- 需要同步较大架构冲突

立即通知示例：

```bash
tmux send-keys -t SelfLearning-creator "[Reviewer 通知] PR #45 需修改：1 个 High 风险问题，详见 review comments。" Enter
```

对方忙碌时写入队列：

```bash
echo "[Reviewer 通知] PR #45 审查完成，需修改后再提审。" >> /tmp/gh-notify/queue_SelfLearning_creator.txt
```

若目标会话不存在：

- 自动扫描当前 tmux 会话并匹配潜在目标（如 `creator` / `reviewer` 命名会话）。
- 匹配成功后继续执行空闲检测与发送。
- 仍未匹配时写入原目标队列文件，等待后续补发。

### Step 6. Merge 前确认 Owner

- 当 PR 达到可合并状态（非 Draft、检查通过、无阻塞项）时，Reviewer 不得直接 merge。
- Reviewer 必须先询问 Owner 是否同意 merge。
- 仅在 Owner 明确同意后，Reviewer 才执行 merge。

## Quality Checklist

提交审查意见前确认：

- 是否优先报告了会阻塞上线的问题。
- 每条发现是否有证据和影响描述。
- 修复建议是否可执行。
- 审查结论是否与问题严重度一致。
- 是否避免“只给结论不给依据”。

## Optional Automation

tmux 通知细则见 `references/tmux-notification-guide.md`。

如需自动接收 `needs-review` 与 PR 更新提醒，可运行：`scripts/gh-notify-daemon.sh`

```bash
tmux new-session -d -s gh-notify "bash scripts/gh-notify-daemon.sh"
```
