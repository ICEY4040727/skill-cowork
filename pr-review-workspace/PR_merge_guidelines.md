# PR 审查与分支合并步骤方案

> **编写者**: Reviewer
> **版本**: v1.1
> **更新时间**: 2026-04-13
> **目的**: 规范化 PR 审查流程，避免阻塞后续开发，确保 v1.0.0 联调修复文档的已修复项正确标注
> **变更**: 新增 CI 失败处理、历史未合并 PR 清理流程

---

## 📋 审查前准备

### 1. 确认审查上下文

```bash
# 获取 PR 信息
gh pr view $PR_NUMBER --json title,body,headRefName,baseRefName,author,state,mergeable

# 获取关联 Issue
gh pr view $PR_NUMBER --json title,body | jq -r '.body' | grep -oE '#[0-9]+'
```

### 2. 确认分支状态

```bash
# 检查分支是否落后于 main
git fetch origin
git log origin/main..origin/$BRANCH_NAME --oneline

# 检查是否有冲突
git merge-base origin/main origin/$BRANCH_NAME
```

---

## 🚨 Step 1: CI 状态检查（早期阻塞检测）

### 1.1 获取 CI 状态

```bash
# 获取 PR 的 CI 状态
gh pr view $PR_NUMBER --json statusCheckRollup,mergeStateStatus | jq '{
  mergeStateStatus: .mergeStateStatus,
  statusChecks: [.statusCheckRollup[] | {name, conclusion, status}]
}'
```

### 1.2 CI 状态分类处理

| MergeStateStatus | 含义 | 操作 |
|------------------|------|------|
| `BEHIND` | 分支落后于 main | ⚠️ 要求 Creator rebase |
| `BLOCKED` | 受分支保护规则阻塞 | ⚠️ 检查阻塞规则 |
| `DIRTY` | 有合并冲突 | ⚠️ 要求 Creator 解决冲突 |
| `DRAFT` | 草稿状态 | ⏸️ 等待转为正式 PR |
| `HAS_HOOKS` | 等待 hooks 完成 | ⏸️ 等待 CI 完成 |
| `UNSTABLE` | CI 有失败但可合并 | ❌ 检查失败的 check |
| `CLEAN` | 可合并 | ✅ 继续审查 |

### 1.3 StatusCheck 结论处理

| Conclusion | 含义 | 操作 |
|------------|------|------|
| `SUCCESS` | 通过 | ✅ 无需处理 |
| `FAILURE` | 失败 | ❌ **阻塞合并**，要求修复 |
| `TIMED_OUT` | 超时 | ❌ 重试或检查配置 |
| `ACTION_REQUIRED` | 需要人工操作 | ⚠️ 完成所需操作 |
| `CANCELLED` | 已取消 | ⚠️ 重新触发 |
| `(null)` | 进行中 | ⏸️ 等待完成 |
| `SKIPPED` | 跳过 | ℹ️ 确认是否应跳过 |

### 1.4 CI 失败处理流程

参考模板：`docs/pr-203-ci-failure-analysis.md`

```markdown
## CI Status Report

### 失败的 Check

| Check Name | Conclusion | 详情链接 |
|------------|------------|----------|
| lint | FAILURE | [查看](https://github.com/.../actions/runs/...) |
| backend-test | FAILURE | [查看](https://github.com/.../actions/runs/...) |

### 失败原因分析

1. **lint**: ESLint 发现 3 个错误
   - `file.ts:123` - 缺少分号
   - `file.ts:456` - 未使用的变量

2. **backend-test**: 2 个测试失败
   - `test_login()` - 断言失败
   - `test_create_checkpoint()` - 超时

### 修复建议

1. 运行 `npm run lint` 本地检查并修复
2. 运行 `pytest tests/test_auth.py -v` 定位测试问题
```

### 1.4.1 详细 CI 分析模板（实战参考）

当 CI 失败时，创建详细分析文档：

```bash
# 创建分析文档
gh pr view $PR_NUMBER --json statusCheckRollup > /tmp/ci_status.json
# 基于模板创建分析文档
cat <<'EOF' > "docs/pr-$PR_NUMBER-ci-failure-analysis.md"
# PR #$PR_NUMBER CI 失败分析

## 基本信息
- **PR**: #$PR_NUMBER - $(gh pr view $PR_NUMBER --json title -q .title)
- **分支**: $(gh pr view $PR_NUMBER --json headRefName -q .headRefName)
- **状态**: $(gh pr view $PR_NUMBER --json state -q .state)

## CI 状态总览
[从 gh pr view 复制 statusCheckRollup]

## 失败详情
[逐项分析每个失败的 check]

## 修复优先级
### P0 - 阻塞合并
### P1 - 重要但不阻塞
EOF
```

### 1.5 CI 配置缺失处理

**检测**：`statusCheckRollup` 为空数组

**原因**：
1. 分支未配置 CI workflow
2. `.github/workflows/` 文件有语法错误
3. workflow 触发条件不匹配

**处理**：
```markdown
[Critical] CI 未配置或未运行

- **影响**: 无法自动检测代码质量问题，合并风险未知
- **修复建议**:
  1. 检查 `.github/workflows/*.yml` 语法
  2. 确认 workflow 触发条件包含当前分支
  3. 手动触发 CI: `gh workflow run <workflow-name>`
  4. 或在本地运行: `npm run lint && npm test && cd backend && pytest`
```

---

## 🗂️ Step 1.5: 历史未合并 PR 清理

### 1.5.1 定位未合并 PR

```bash
# 查找已关闭但未合并的 PR
gh pr list --state closed --limit 50 --json number,title,headRefName,mergedAt,mergeStateStatus | \
  jq -r '.[] | select(.mergedAt == null) | "\(.number)\t\(.title)\t\(.mergeStateStatus)"'
```

### 1.5.2 未合并原因分类

| MergeStateStatus | 典型原因 | 处理方式 |
|------------------|----------|----------|
| `DIRTY` | 合并冲突未解决 | 重新解决冲突或放弃 |
| `UNSTABLE` | CI 失败未修复 | 修复 CI 后重新提交 |
| `BEHIND` | 分支落后太久 | Rebase 后重新 PR |
| `CLEAN` | CI 通过但未合并 | 确认是否可重新 merge |

### 1.5.3 清理决策树

```
未合并 PR
    │
    ├─ 分支是否仍存在？
    │   ├─ 否 → 记录原因，关闭 issue
    │   └─ 是 → 继续
    │
    ├─ CI 是否通过？
    │   ├─ 否 → 修复 CI 或放弃
    │   └─ 是 → 继续
    │
    ├─ 代码是否仍有价值？
    │   ├─ 否 → 关闭 PR，备注原因
    │   └─ 是 → 继续
    │
    └─ 是否有合并冲突？
        ├─ 是 → 解决冲突，更新 PR
        └─ 否 → 询问 Owner 是否合并
```

### 1.5.4 示例：处理 #170（CLEAN 但未合并）

```bash
# 检查分支是否仍存在
git fetch origin
git rev-parse origin/feat/163-shared-style-base

# 分支存在，检查是否落后
git log origin/main..origin/feat/163-shared-style-base --oneline

# 若落后，建议 rebase
git checkout feat/163-shared-style-base
git rebase origin/main
git push origin feat/163-shared-style-base --force-with-lease

# 通知 Creator 或 Owner 决定是否重新合并
```

---

## 🔍 Step 2: 风险优先级审查

### 1.1 按严重级别检查

| 优先级 | 检查项 | 阻塞合并？ |
|--------|--------|-----------|
| **Critical** | 安全漏洞、数据丢失、线上故障 | ✅ 是 |
| **High** | 逻辑错误、边界问题、兼容性破坏 | ✅ 是 |
| **Medium** | 代码质量、可维护性问题 | ❌ 否 |
| **Low** | 样式、注释、格式 | ❌ 否 |

### 1.2 改动域分类

- **数据库 schema** → 必须 review migration 文件
- **API 接口** → 检查向后兼容性
- **前端 UI** → 要求截图/录屏
- **业务逻辑** → 检查边界条件

---

## 📁 Step 3: **v1.0.0 联调修复文档检查**（每次必做）

### 2.1 浏览所有修复文档

```bash
DOCS_DIR="/home/icey2/Projects/Self_Learning-System/docs/v1.0.0前后端联调修复"

# 列出所有 markdown 文件
find "$DOCS_DIR" -name "*.md" -type f
```

### 2.2 确认"已修复项"标注规范

**规则**：每个文档中的"已修复项"必须：
1. 简化为一句话描述
2. 明确标注 `✅ 已修复` 或 `[已修复]`
3. 包含修复位置（文件名:行号 或文件路径）

**正确示例**：
```markdown
| # | 问题 | 状态 | 说明 |
|---|------|------|------|
| 1 | WorldDetail.vue checkpoint API 路径错误 | ✅ **已修复** | `WorldDetail.vue:178` |
```

**错误示例（需修正）**：
```markdown
- 问题1：WorldDetail.vue 的 checkpoint API 路径写错了，改成了 /save?subject_id=${courseId}，这样就能正确调用了
```

### 2.3 文档清单

| 文件名 | 检查重点 |
|--------|----------|
| `frontend_backend_alignment_status.md` | 已修复项表格式 |
| `frontend_backend_fix_plan.md` | P0 问题状态 |
| `修复方案.md` | P0-1/P0-2/P1-1 状态 |
| `v1.0.0联调home页前后端.md` | 缺失 API 补足状态 |
| `implementation_plan.md` | 实现完成度 |

---

## 🧪 Step 4: 联动验证测试

### 3.1 根据改动选择验证方式

| 改动类型 | 验证方法 |
|----------|----------|
| API 变更 | `curl` 测试或前端 API 调用 |
| UI 变更 | 截图对比或录屏 |
| 数据库 | `alembic current` + 表结构检查 |
| 业务逻辑 | 运行相关 pytest 测试 |

### 3.2 测试证据记录

```markdown
## Test Evidence

| 测试项 | 动作 | 结果 | 置信度 |
|--------|------|------|--------|
| GET /api/user/profile | curl + jq | ✅ 返回正确格式 | 高 |
| UserProfile 页面渲染 | 浏览器访问 /home/profile | ✅ 雷达图显示 | 高 |
```

---

## 📝 Step 5: 输出审查结论

### 4.1 Review 模板

```markdown
## Review Summary

- **Decision**: [Approve / Comment / Request changes]
- **Risk**: [Critical / High / Medium / Low]
- **关联 Issue**: #XXX

## Findings

### [Critical] 问题标题
- **位置**: `file.ts:123`
- **问题**: 描述
- **修复建议**: 可执行的修复方向

### [High] 问题标题
...

## Regression Risks

| 模块 | 风险描述 | 缓解措施 |
|------|----------|----------|
| WorldDetail | checkpoint API 变更可能影响存档加载 | 已测试读档流程 |

## Test Gaps

- [ ] 缺少 XXX 场景的测试

## v1.0.0 联调文档检查

- [ ] 已浏览 `docs/v1.0.0前后端联调修复/` 下所有 markdown
- [ ] 已修复项均为一句话 + `✅ 已修复` 标注
- [ ] 需更新文档: (列出需要更新的文档)

## Final Decision

[结论 + 是否可合并]
```

---

## 🔄 Step 6: 协作通知

### 5.1 需要通知 Creator 的情况

- 结论为 `Request changes`
- 发现 Critical 问题
- 需要架构冲突同步

```bash
# 检查对方是否空闲
tmux capture-pane -t SelfLearning-creator -p | tail -1

# 空闲则直接发送
tmux send-keys -t SelfLearning-creator "[Reviewer 通知] PR #$PR 审查完成：$DECISION，详见 review comments。" Enter

# 忙碌则写入队列
echo "[Reviewer 通知] PR #$PR 审查完成：$DECISION" >> /tmp/gh-notify/queue_SelfLearning_creator.txt
```

---

## ✅ Step 7: Merge 前确认

### 7.1 可合并条件检查

- [ ] 非 Draft 状态
- [ ] **CI 全部通过**（lint / test / build）
- [ ] MergeStateStatus 为 `CLEAN`
- [ ] 无 Critical/High 阻塞项
- [ ] 关联 Issue 已确认

### 6.2 **必须先询问 Owner**

```bash
# 通过 tmux 或直接询问
# "PR #$PR 已达到可合并状态，是否同意 merge？"
```

**仅 Owner 明确同意后，Reviewer 才执行 merge：**

```bash
gh pr merge $PR_NUMBER --squash --delete-branch
```

---

## 🌳 分支合并优先级策略

### 避免阻塞的合并顺序

```
优先级 0: P0 阻塞修复（如 #176 FK 循环依赖）
    ↓
优先级 1: 数据库 schema 变更（依赖基础）
    ↓
优先级 2: 核心业务逻辑（依赖 schema）
    ↓
优先级 3: UI/UX 改进（依赖业务逻辑）
    ↓
优先级 4: 文档/配置更新
```

### 当前分支合并建议

| PR | 分支 | 优先级 | CI 状态 | 阻塞问题 |
|----|------|--------|---------|----------|
| #203 | `feat/ui-polish-world-pages` | P3 | ❌ Lint + E2E 失败 | 必须修复后才能合并 |
| #193 | `feat/193-checkpoint-import-export` | P1 | - | 无 |
| #190 | `feat/190-session-history` | P1 | - | 无 |
| #176 | (未创建) | **P0** | - | 阻塞多个 |

**PR #203 阻塞详情**: 见 `docs/pr-203-ci-failure-analysis.md`

- **Lint**: 48+ 个 Ruff 问题（I001, F401, W293）
- **E2E**: knowledge graph 按钮找不到、移动端 `.character-layer` 缺失

### 历史未合并 PR 清理

| PR | 分支 | MergeState | CI 状态 | 建议操作 |
|----|------|------------|---------|----------|
| #170 | `feat/163-shared-style-base` | CLEAN | ✅ 全部通过 | 考虑恢复 —— Reviewer 已批准，仅因重建截图而关闭 |
| #171 | `feat/login-page-text-update` | DIRTY | ❌ 无 CI | 低优先级，可搁置 |

**详细分析**: 见 `docs/pr-203-ci-failure-analysis.md` 第 7 节

---

## 📊 Reviewer 每次审查 Checklist

```markdown
## 审查前
- [ ] 已获取 PR 完整信息（title, body, branch）
- [ ] 已确认分支状态（mergeStateStatus, CI checks）
- [ ] 已检查历史未合并 PR

## 审查中
- [ ] 按风险优先级检查代码
- [ ] 已浏览 v1.0.0联调修复 目录下所有 markdown
- [ ] 已确认"已修复项"均为一句话 + ✅ 已修复
- [ ] 已执行相关验证测试
- [ ] 已检查 CI 失败原因（如有）

## 审查后
- [ ] 已输出结构化 review 结论
- [ ] 如需修改，已通知 Creator
- [ ] 如可合并，已询问 Owner
```

---

## 🔄 循环改进

每次合并后更新本文档：

- 记录新发现的风险模式
- 补充新的验证方法
- 更新文档检查清单

---

## 附录：常见问题

### Q1: "已修复项"格式不统一怎么办？

**A**: 创建一个格式化任务，让 Creator 统一处理：

```markdown
[Low] 文档格式统一
建议：将 `docs/v1.0.0前后端联调修复/` 下的所有"已修复项"统一为表格格式：
| # | 问题 | 状态 | 说明 |
|---|------|------|------|
| N | 一句话描述 | ✅ 已修复 | `file:line` |
```

### Q2: PR 改动了多个模块，如何确定审查优先级？

**A**: 按以下顺序：

1. 数据库 schema（影响最大）
2. API 接口（向后兼容性）
3. 业务逻辑（正确性）
4. UI（用户体验）

### Q2: PR 改动了多个模块，如何确定审查优先级？

**A**: 按以下顺序：
1. 数据库 schema（影响最大）
2. API 接口（向后兼容性）
3. 业务逻辑（正确性）
4. UI（用户体验）

### Q3: CI 失败但代码看起来没问题怎么办？

**A**:

1. 检查是否是 flaky test（偶发性失败）
2. 本地复现：`cd frontend && npm test` 或 `cd backend && pytest`
3. 确认 CI 环境（node 版本、Python 版本）与本地一致
4. 若确认为 CI 问题，可在 PR 中说明并请求 rerun
5. 重大 CI 失败（lint、测试）必须修复后才能合并

### Q4: 历史未合并 PR 如何处理？

**A**: 按优先级：

1. **P0**: 修复后仍有价值的 → 重新提交 PR
2. **P1**: CI 通过但被遗忘的 → 询问 Owner 决定
3. **P2**: 代码已过时的 → 关闭 PR，记录原因

处理命令：
```bash
# 查看具体 PR 详情
gh pr view $PR_NUMBER --json number,title,headRefName,body

# 检查分支是否仍存在
git rev-parse origin/$BRANCH_NAME

# 若需重新提交，创建新 PR
gh pr create --base main --head $BRANCH_NAME --title "..." --body "..."
```

### Q5: MergeStateStatus 为 DIRTY 怎么办？

**A**: DIRTY 表示有合并冲突，处理方式：

1. 通知 Creator 解决冲突
2. Creator 操作：

   ```bash
   git checkout $BRANCH_NAME
   git fetch origin
   git rebase origin/main
   # 解决冲突
   git add .
   git rebase --continue
   git push origin $BRANCH_NAME --force-with-lease
   ```

3. 若 Creator 不可用，Reviewer 可协助解决（需 Owner 同意）
