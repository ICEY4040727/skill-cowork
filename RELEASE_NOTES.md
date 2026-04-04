# Release Notes

## v0.1.0 (2026-04-04)

### 中文

首个 Beta 版本发布，提供一套面向 GitHub 协作流程的技能包。

包含技能：
- issue-creation
- pr-creator
- pr-review

本版本重点：
- 统一技能目录命名与结构，全部使用 SKILL.md
- 强化三方协作边界（Owner / Creator / Reviewer）与标签策略
- 提供可直接粘贴到 GitHub 的 issue / PR / review 输出模板
- 为三个技能补充 starter evals（evals/evals.json）
- 将 PR 对话协议与通知指南收敛到 pr-review/references
- 增加发布清理脚本 scripts/prepare_release.sh，发布时自动清理 authoring 实验产物

已知范围：
- 当前版本定位为 Beta，建议先在团队协作场景验证后再扩展到更广泛分发

### English

Initial beta release of a collaborative skill suite for GitHub workflows.

Included skills:
- issue-creation
- pr-creator
- pr-review

Highlights:
- Unified structure and naming across skills, standardized on SKILL.md
- Clear collaboration boundaries (Owner / Creator / Reviewer) and label policy
- Paste-ready GitHub output templates for issue / PR / review workflows
- Starter eval sets added for all three skills (evals/evals.json)
- PR dialog protocol and notification guide colocated under pr-review/references
- Added release cleanup script at scripts/prepare_release.sh to remove authoring artifacts before publishing

Known scope:
- This release is beta-grade and recommended for team validation before broader public distribution
