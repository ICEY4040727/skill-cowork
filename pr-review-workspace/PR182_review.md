# PR #182 审查报告

**Reviewer**: Reviewer
**Date**: 2026-04-09
**PR**: #182 (fix: 合并 Alembic 双 head 到单一线性链)
**分支**: fix/175-alembic-dual-head
**状态**: ❌ Request Changes

---

## 执行摘要

PR #182 混合了两个不相关的 Issue（#175 和 #183），违反"一 PR 一件事"规矩。需要拆分。

---

## (A) cf458e4 评估：P0 #175 Alembic 修复

### ✅ 合格项

1. **迁移链合并**：创建 `2026_04_06_000_create_base_tables.py` 作为基础迁移，所有表在单一迁移中创建
2. **旧迁移变空**：4 个旧迁移改为 `pass`，不再重复创建表/列
3. **迁移链线性化**：`2026_04_06_000` → `2026_04_06_002` → `2026_04_08_001` → `2026_04_08_002` → `2026_04_06_001`
4. **迁移链顺序正确**：revision 标识符形成正确的依赖链

### ⚠️ 小问题

1. **downgrade 为空**：`downgrade()` 都是 `pass`，无法回滚。但 Alembic 基础迁移的回滚本身就很复杂，可以接受。
2. **PR 描述完整**：包含了测试命令和验收标准

### 📊 结论

**cf458e4 单独合格**，可以合并。

---

## (B) 0e41c21 评估：P1 #183 存储结构重设计

### ⚠️ 严重问题

#### 1. ❌ seed 功能未集成（阻断）

**问题**：`memory_facts.py` 中 `create_seed_memories()` 方法存在，但**从未被调用**。

```bash
# 搜索结果：无任何调用点
$ grep -r "create_seed_memories" backend/
# backend/services/memory_facts.py:    def create_seed_memories(
# backend/services/learning_engine.py:    async def create_seed_memories(
# 无 await self.create_seed_memories 或 memory_facts_service.create_seed_memories 调用
```

**草案要求**：seed 时机是"首次 session 建立时"
**实际实现**：只有方法定义，无调用点

**修复要求**：
- 在 `learning_engine.py` 的 `start_learning` 或类似首次创建 session 的位置调用 `create_seed_memories()`
- 或在 Session 创建 API 路由中添加 seed 逻辑

#### 2. ⚠️ KnowledgeGraph 端点返回空图谱（需跟踪）

**问题**：`/api/archive/knowledge-graph/{world_id}` 端点返回 `{"nodes": [], "edges": [], "links": []}`

**代码位置**：`backend/api/routes/save.py` 第 383 行

**状态**：⭐ 桩代码（stub），不是功能删除

**Owner 需决定**：
- 选项 A：在 Issue #183 中跟踪，后续实现从 memory_facts 重建知识图谱
- 选项 B：直接删除此端点

### ✅ 合格项

1. **表结构正确**：
   - `memory_facts` 表：character_id, world_id(nullable), fact_type, content, concept_tags, source_message_id, salience, created_at, last_recalled_at, recall_count, expires_at
   - `save_snapshots` 表：id, user_id, session_id(nullable), name, payload, created_at

2. **extract_memory 拦截层**：
   - `memory_extractor.py` 实现了 `<memory>` 标签提取
   - `learning_engine.py` 集成了拦截逻辑

3. **knowledge.py 删除清单**：
   - ✅ `services/knowledge.py` 已删除
   - ✅ `services/prompt_builder/modules/knowledge.py` 已删除
   - ✅ `services/prompt_builder/modules/memory_retrieval.py` 已删除

4. **SaveSnapshot 模型**：正确创建，替代 JSON 文件存档

5. **迁移正确**：
   - `2026_04_09_add_memory_facts_and_save_snapshots.py` 创建新表
   - `downgrade()` 重建 knowledge 表（保持可回滚）

---

## (C) 违规事实

### ❌ 违反"一 PR 一件事"

**PR #182 包含两个独立 commit**：
- `cf458e4`: P0 #175 Alembic 双 head 修复
- `0e41c21`: P1 #183 存储结构重设计

**影响**：
- Review 流程混乱（P0 和 P1 优先级不同）
- 合并策略复杂（P0 急，P1 等 #175 修完才能动）
- 难以单独回滚

---

## (D) 要求修改

### 必须修改（阻断）

1. **拆分 PR**：
   - PR #182 只保留 `cf458e4`（P0 #175），关联 #175
   - 新建 PR 包含 `0e41c21`（P1 #183），关联 #183
   - **如果拆分有困难**：至少 `git reset` 后分两次提交

2. **集成 seed 功能**（0e41c21 修复）：
   - 在首次 session 创建时调用 `create_seed_memories()`
   - 参考草案：`seed 时机 = 首次 session 建立时`

3. **明确 KnowledgeGraph 端点处理**：
   - 在 Issue #183 中添加子任务跟踪
   - 或直接删除端点并清理前端引用

---

## (E) Review Checklist

### cf458e4 (P0 #175)

| 检查项 | 状态 |
|--------|------|
| 迁移链线性化 | ✅ |
| alembic upgrade head 成功 | ✅ |
| 旧迁移变空 | ✅ |
| down_revision 正确 | ✅ |
| PR 描述完整 | ✅ |

### 0e41c21 (P1 #183)

| 检查项 | 状态 | 备注 |
|--------|------|------|
| memory_facts 表结构 | ✅ | |
| save_snapshots 表结构 | ✅ | |
| extract_memory 拦截层 | ✅ | |
| knowledge.py 删除 | ✅ | |
| prompt_builder/modules 删除 | ✅ | |
| seed 方法存在 | ✅ | 但未调用 |
| seed 时机集成 | ❌ | 未在首次 session 创建时调用 |
| KnowledgeGraph 端点 | ⚠️ | 桩代码，需决定去留 |

---

## (F) 下一步

1. Creator 执行 PR 拆分
2. 在新 PR 中修复 seed 集成问题
3. Owner 决定 KnowledgeGraph 端点处理策略

---

**Reviewer**: Reviewer
**Date**: 2026-04-09
