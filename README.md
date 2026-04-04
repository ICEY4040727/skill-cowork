# skill-cowork

面向 GitHub 协作流程的技能包，覆盖 Issue 创建、PR 创建与 PR 审查。

A collaborative skill suite for GitHub issue creation, PR creation, and PR review.

## Included Skills

包含技能：

- `issue-creation`：将讨论记录和需求整理为可执行的 GitHub Issue。
- `pr-creator`：将代码改动整理为可审查的 PR 描述。
- `pr-review`：执行风险优先的 PR 审查并给出结构化结论。

Included skills:

- `issue-creation`: Turn discussion notes and requests into actionable GitHub issues.
- `pr-creator`: Convert code changes into review-ready PR descriptions.
- `pr-review`: Perform risk-based PR review with structured findings and decisions.

## Repository Layout

```text
skill-cowork/
  CONTRIBUTING.md
  RELEASE_NOTES.md
  pr-review-workspace/
    README.md
  scripts/
    prepare_release.sh
  issue-creation/
    SKILL.md
    references/
    scripts/
    evals/
  pr-creator/
    SKILL.md
    references/
    evals/
  pr-review/
    SKILL.md
    references/
    scripts/
    evals/
```

## Validation

校验命令：

Use the skill-creator validator:

```bash
python ../skill-creator/scripts/quick_validate.py issue-creation
python ../skill-creator/scripts/quick_validate.py pr-creator
python ../skill-creator/scripts/quick_validate.py pr-review
```

## Evaluation

评测说明：

- 每个技能都提供了起步用例，位于 `evals/evals.json`。
- 你可以按项目场景扩展输入文件和 expectations。
- 运行产物应放在 `pr-review-workspace/`。

Evaluation notes:

Each skill ships with starter eval prompts in `evals/evals.json`.
You can extend them with project-specific files and expectations.

Runtime evaluation artifacts should be stored in `pr-review-workspace/`.

## Release Cleanup

发布前清理：

- 对外发布前执行 `bash scripts/prepare_release.sh`。
- 该脚本会清理不应进入发布包的工作区与实验产物。

Release cleanup:

Before publishing externally, remove authoring artifacts and workspace outputs:

```bash
bash scripts/prepare_release.sh
```

## Usage Notes

使用说明：

- 协作规范与职责边界见 `CONTRIBUTING.md`。
- PR 对话协议与通知指南集中在 `pr-review/references/`。
- 不保留历史重定向文档，保持结构直接清晰。

Usage notes:

- Team governance and decision boundaries are defined in `CONTRIBUTING.md`.
- PR dialog protocol and notification guides are colocated under `pr-review/references/` for better retrieval during review tasks.
- Legacy redirect docs are intentionally removed to keep the structure explicit and unambiguous.

## Release Status

发布状态：Beta（已完成内部验证，建议先在团队场景使用，再扩展到更广泛分发）。

Current status: Beta (internally validated, recommended for team use before broad external distribution).

## Release Notes

版本日志见 `RELEASE_NOTES.md`。

See `RELEASE_NOTES.md` for versioned changelogs.
