---
name: issue-creation
description: Create clear, actionable GitHub issues with correct labels, priority, acceptance criteria, and assignee hints. Use this whenever the user asks to create an issue from discussion notes, bug reports, feature requests, refactor tasks, or TODO lists, even if they only say "记一下" or "帮我跟进".
---

# Issue Creation

用于把零散需求整理成可执行 issue，减少返工与沟通成本。

## Input Signals

当用户出现以下表达时触发本 skill：

- "帮我建个 issue"
- "把这个 bug 记下来"
- "把这次讨论拆成任务"
- "需要后续跟进"
- "给 reviewer/creator 分配任务"

## Required Output

产出必须包含以下内容：

1. 标题：一句话说明动作和对象。
2. 背景：为什么做，当前影响范围。
3. 验收标准：最少 2 条可验证 checklist。
4. 技术说明：模块范围、数据库变更、依赖关系。
5. 优先级：`P0`/`P1`/`P2`。
6. Labels：至少包含任务类型 + 角色标签。

模板见 `references/issueTemplate.md`，label 选择规则见 `references/labelPolicy.md`。

最终回复时，必须提供一段“可直接粘贴到 GitHub Issue 正文”的完整 markdown，不要只给要点。

## Workflow

### Step 1. 识别任务类型与紧急度

按如下规则分类：

- `bugfix`: 线上故障、功能错误、回归。
- `feature`: 新功能或能力扩展。
- `research`: 调研、方案对比、Spike。

优先级规则：

- `P0`: 阻塞发布/核心流程不可用/高风险数据问题。
- `P1`: 重要功能受影响，但有临时绕过方案。
- `P2`: 优化类、非阻塞事项。

### Step 2. 补全 issue 结构并生成正文

在信息不足时先补问 1-3 个关键问题：

- 影响范围是单模块还是跨模块？
- 验收是否有明确输入输出？
- 是否依赖已有 issue/PR？

然后严格按模板生成正文，避免空段落和模糊表述（如“优化一下”“尽快处理”）。

输出顺序固定为：标题 → 背景 → 验收标准 → 技术说明 → 优先级。

### Step 3. 选择 labels 与协作对象

详细映射见 `references/labelPolicy.md`。

label 组合建议：

- 类型：`feature`/`bugfix`/`research` 三选一。
- 责任：`creator` 或 `reviewer`（必要时两者都加）。
- 优先级：`P0`/`P1`/`P2` 三选一。
- 状态：待审可加 `needs-review`，`approved` 仅由 Owner 在确认后添加。

### Step 4. 通知策略（仅在需要时）

只有在以下场景主动通知：

- `P0` issue 创建完成。
- issue 对当前 reviewer/creator 的进行中工作有阻塞。

立即通知示例：

```bash
tmux send-keys -t SelfLearning-creator "[Issue 通知] 新任务 #123 已创建（P0 bugfix），请优先处理。" Enter
```

若对方忙碌则写入队列：

```bash
echo "[Issue 通知] 新任务 #123 已创建（P1 feature）。" >> /tmp/gh-notify/queue_SelfLearning_creator.txt
```

## Quality Checklist

提交前逐项检查：

- 标题是否可唯一理解（动词 + 对象 + 场景）。
- 验收标准是否可测试、可打勾。
- label 是否覆盖类型、责任、优先级。
- 是否写明依赖 issue/PR。
- 是否避免把实现细节写成需求约束。

## Optional Automation

若需要持续提醒机制，可使用：`scripts/gh-notify-daemon.sh`

建议在 tmux 中后台运行：

```bash
tmux new-session -d -s gh-notify "bash scripts/gh-notify-daemon.sh"
```
