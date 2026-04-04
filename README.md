# skill-cowork

A collaborative skill suite for GitHub issue creation, PR creation, and PR review.

## Included Skills

- `issue-creation`: Turn discussion notes and requests into actionable GitHub issues.
- `pr-creator`: Convert code changes into review-ready PR descriptions.
- `pr-review`: Perform risk-based PR review with structured findings and decisions.

## Repository Layout

```text
skill-cowork/
  CONTRIBUTING.md
  pr-review-workspace/
    README.md
  research/
    pr-review-example-ablation/
      README.md
      experiments/
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

Use the skill-creator validator:

```bash
python ../skill-creator/scripts/quick_validate.py issue-creation
python ../skill-creator/scripts/quick_validate.py pr-creator
python ../skill-creator/scripts/quick_validate.py pr-review
```

## Evaluation

Each skill ships with starter eval prompts in `evals/evals.json`.
You can extend them with project-specific files and expectations.

Runtime evaluation artifacts should be stored in `pr-review-workspace/`.
Skill-authoring methodology experiments are stored in `research/pr-review-example-ablation/`.

## Release Cleanup

Before publishing externally, remove authoring artifacts and workspace outputs:

```bash
bash scripts/prepare_release.sh
```

## Usage Notes

- Team governance and decision boundaries are defined in `CONTRIBUTING.md`.
- PR dialog protocol and notification guides are colocated under `pr-review/references/` for better retrieval during review tasks.
- Legacy redirect docs are intentionally removed to keep the structure explicit and unambiguous.

## Release Status

Current status: Beta (internally validated, recommended for team use before broad external distribution).
