# 存储结构重设计草案 v0.2

**Status**: 待 Owner 二审
**Author**: Reviewer
**Date**: 2026-04-09
**文件路径**: `skill-cowork/pr-review-workspace/storage_redesign_draft.md`

---

## (A) Seed Memory Facts 方案（修订版）

### 核心认知修正

**关键区分**：
- **sage character**（type="sage"）：AI 老师，角色自身定义读 Character 表，**不进 memory_facts**
- **traveler character**（type="traveler"）：**就是学生本人**，这是 sage 记录"对学生的认知"的对象
- **LearnerProfile**：学习追踪层，记录学生学习状态、偏好

**seed 的用途**：sage character 创建时（或首次建立 session 时），写入"老师初次见学生时知道什么"

### Traveler Character 字段分析

| 字段 | 类型 | 说明 | 进入 seed？ | fact_type | 理由 |
|------|------|------|-----------|-----------|------|
| name | String | 学生自报的名字 | ✅ | student_state | sage 需要知道学生叫什么（salience=0.9） |
| tags | JSON | 学生自选的学习方向 | ✅ | preference | 反映学生感兴趣的主题（salience=0.7） |
| background | Text | 学生自述的学习背景 | ✅ | student_state | 帮助 sage 了解学生基础（salience=0.6） |
| personality | Text | 学生自评性格 | ⚠️ | preference | 可选，帮助调整对话风格（salience=0.5） |
| speech_style | Text | 期望的对话风格 | ⚠️ | preference | 可选（salience=0.4） |
| type | String | 固定="traveler" | ❌ | - | 固定值，无信息量 |
| avatar/sprites/title/experience_points/level | - | UI/游戏相关 | ❌ | - | 与"学生认知"无关 |

### LearnerProfile.profile JSON 结构（展开）

```typescript
interface UserProfile {
  metacognition_trend: Record<string, MetacognitionDimension>  // planning/monitoring/regulating/reflecting
  preference_stability: Record<string, PreferenceStability>     // visual_examples/analogy_based/step_by_step 等
  learning_stats: LearningStats                               // total_concepts/total_sessions/average_mastery 等
}

interface MetacognitionTrend {
  current: 'weak' | 'moderate' | 'strong'
  trend: 'improving' | 'stable' | 'unknown'
  evidence_count: number
  latest_evidence?: string
}

interface PreferenceStability {
  stable: boolean
  consistency?: number  // 0-1
  most_common?: string
  display: string
}

interface LearningStats {
  total_concepts_learned: number
  total_sessions: number
  average_mastery: number  // 0-1
  worlds_explored: number
}
```

### Seed Memory Facts 汇总表（修订）

| 源 | 字段/子字段 | target_fact_type | target_content_template | salience | 备注 |
|----|------------|------------------|----------------------|----------|------|
| Character (traveler) | name | student_state | "学生名叫 {name}" | 0.9 | 核心标识 |
| Character (traveler) | tags | preference | "学习方向: {tags}" | 0.7 | 主题偏好 |
| Character (traveler) | background | student_state | "学生背景: {background}" | 0.6 | 基础认知 |
| Character (traveler) | personality | preference | "性格特点: {personality}" | 0.5 | 可选 |
| LearnerProfile.profile | learning_stats.total_sessions | student_state | "已有 {n} 次学习经历" | 0.8 | 有无经验 |
| LearnerProfile.profile | learning_stats.average_mastery | concept_mastered | "平均掌握度 {x}%" | 0.85 | 基础水平 |
| LearnerProfile.profile | preference_stability.* | preference | 见下方展开 | - | 见下方 |
| LearnerProfile.profile | metacognition_trend.* | student_state | 见下方展开 | - | 见下方 |

### Preference 相关字段展开

| 子字段 | target_content_template | salience |
|--------|----------------------|----------|
| preference_stability.visual_examples | "偏好视觉化学习" | 0.75 |
| preference_stability.analogy_based | "偏好类比学习" | 0.75 |
| preference_stability.step_by_step | "偏好步骤化学习" | 0.75 |
| preference_stability.pace | "学习节奏偏好" | 0.6 |

### Metacognition 相关字段展开

| 子字段 | target_content_template | salience |
|--------|----------------------|----------|
| metacognition_trend.planning | "元认知-规划能力: {current}({trend})" | 0.6 |
| metacognition_trend.monitoring | "元认知-监控能力: {current}({trend})" | 0.6 |
| metacognition_trend.regulating | "元认知-调节能力: {current}({trend})" | 0.6 |
| metacognition_trend.reflecting | "元认知-反思能力: {current}({trend})" | 0.6 |

### 不进入 seed 的字段（澄清）

| 字段 | 原因 |
|------|------|
| World.description | 世界观≠学生卡壳，**不是** sage 对学生的认知 |
| Course.description | 课程内容≠学生状态，**不是** |
| Session.relationship.stage | 运行时状态，**实时读** Session 表，**不进** seed |
| Character (sage) 的所有字段 | sage 角色定义，**prompt_builder 直接读** Character 表 |
| TeacherPersona.* | 人格模板，**prompt_builder 直接读** TeacherPersona 表 |

### Seed 时机

1. **sage character 创建时**：从关联的 traveler character 提取 seed
2. **首次建立 session 时**：如果 traveler 或 LearnerProfile 有更新，补充 seed

### world_id 说明

- seed 时 `world_id = NULL`（跨世界事实）
- 运行时提取的记忆根据当前 session 确定 `world_id`

---

## (B) Issue 正文草稿（微调版）

### Issue 标题
`feat: 存储结构重设计 - 记忆事实表 + DB 存档`

### ER 图

```mermaid
erDiagram
    Character ||--o{ TeacherPersona : "1:N"
    Character ||--o{ WorldCharacter : "1:N"
    Character ||--o{ MemoryFact : "1:N"
    World ||--o{ WorldCharacter : "1:N"
    World ||--o{ Course : "1:N"
    World ||--o{ Session : "1:N"
    World ||--o{ MemoryFact : "1:N"
    Course ||--o{ Session : "1:N"
    Session ||--o{ ChatMessage : "1:N"
    Session ||--o{ Checkpoint : "1:N"
    Session ||--o{ SaveSnapshot : "1:N"
    User ||--o{ Character : "1:N"
    User ||--o{ World : "1:N"
    User ||--o{ Session : "1:N"
    User ||--o{ Checkpoint : "1:N"
    User ||--o{ SaveSnapshot : "1:N"
    
    MemoryFact {
        int id PK
        int character_id FK
        int world_id FK "nullable"  "跨世界事实时为 NULL"
        string subject_id "nullable"
        enum fact_type "student_state/concept_struggle/concept_mastered/preference/event/commitment"
        text content
        json concept_tags "nullable"
        int source_message_id "nullable"  "指向 AI 回复的 ChatMessage.id"
        float salience
        datetime created_at
        datetime last_recalled_at
        int recall_count
        datetime expires_at "nullable"
    }
    
    SaveSnapshot {
        int id PK
        int user_id FK
        int session_id FK "nullable"
        string name
        json payload
        datetime created_at
    }
```

### extract_memory Prompt 契约草案

#### 触发条件
- 每轮 AI 回复末尾检查是否应提取记忆
- 条件：用户发言后且 AI 产生实质内容（>20 字）

#### JSON Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "memories": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "fact_type": {
            "type": "string",
            "enum": ["student_state", "concept_struggle", "concept_mastered", "preference", "event", "commitment"]
          },
          "content": {
            "type": "string",
            "maxLength": 500
          },
          "concept_tags": {
            "type": "array",
            "items": {"type": "string"},
            "maxItems": 5
          },
          "salience": {
            "type": "number",
            "minimum": 0.1,
            "maximum": 1.0
          },
          "expires_at": {
            "type": "string",
            "format": "date-time",
            "nullable": true
          }
        },
        "required": ["fact_type", "content"]
      },
      "maxItems": 3
    }
  }
}
```

#### Prompt 片段
```
在你回复的末尾，如果对话中有值得记忆的重要信息（学生学习状态变化、关键概念理解、偏好变化、重要约定等），请用以下格式输出：

<memory>
{"memories": [{"fact_type": "...", "content": "...", "concept_tags": [...], "salience": 0.8}]}
</memory>

注意：
- 仅提取真正值得长期记忆的信息
- 每个回复最多提取3条记忆
- content 不超过500字
- 如果没有值得记忆的内容，不要输出 <memory> 标签
```

#### 容错策略
1. **解析失败**：丢弃该轮记忆，不影响主对话
2. **格式错误**：跳过该条记忆，继续处理其他记忆
3. **字段缺失**：使用默认值（concept_tags=[], salience=0.5）
4. **内容过长**：截断至 500 字

#### Token 成本预估
- 额外 prompt 片段：~150 tokens
- JSON 输出（3条记忆）：~200 tokens
- 单轮额外成本：~350 tokens
- 以 Claude 3.5 Sonnet 计：~$0.001/轮

### 后端拦截层伪代码（微调）

```python
# learning_engine.py

async def process_message(...):
    # ... 原有逻辑 ...
    
    # 调用 LLM
    llm_response = await llm_adapter.chat(messages=messages, system_prompt=system_prompt)
    
    # 保存 AI 回复消息，获取 message_id
    ai_message = db.query(ChatMessage).filter(
        ChatMessage.session_id == session_id,
        ChatMessage.sender_type == "assistant"
    ).order_by(ChatMessage.timestamp.desc()).first()
    
    # 拦截并解析记忆
    memory_content = extract_memory_tags(llm_response)
    if memory_content:
        try:
            memory_data = parse_memory_json(memory_content)
            # source_message_id 指向 AI 回复消息
            # 校验：确保该 message 属于当前 session
            if ai_message and ai_message.session_id == session_id:
                await write_memory_facts(
                    db=db,
                    character_id=teacher_character_id,
                    world_id=session.world_id,
                    memories=memory_data["memories"],
                    source_message_id=ai_message.id  # 溯源校验
                )
        except MemoryParseError as e:
            logger.warning(f"记忆解析失败，丢弃: {e}")
    
    # 移除 <memory> 标签后返回给前端
    clean_response = strip_memory_tags(llm_response)
    return clean_response


def extract_memory_tags(text: str) -> str | None:
    """从 LLM 回复中提取 <memory>...</memory> 标签内容"""
    match = re.search(r'<memory>(.*?)</memory>', text, re.DOTALL)
    return match.group(1) if match else None


def strip_memory_tags(text: str) -> str:
    """移除 <memory> 标签，保留主对话内容"""
    return re.sub(r'<memory>.*?</memory>', '', text, flags=re.DOTALL).strip()


async def write_memory_facts(db, character_id, world_id, memories, source_message_id):
    """写入记忆事实表
    
    Args:
        source_message_id: 指向 AI 回复的 ChatMessage.id，用于溯源校验
    """
    for mem in memories:
        fact = MemoryFact(
            character_id=character_id,
            world_id=world_id,  # 可能为 NULL（跨世界事实）
            fact_type=mem["fact_type"],
            content=mem["content"][:500],  # 截断
            concept_tags=mem.get("concept_tags", []),
            source_message_id=source_message_id,  # 溯源
            salience=mem.get("salience", 0.5),
            created_at=datetime.utcnow(),
            last_recalled_at=datetime.utcnow(),
            recall_count=0,
            expires_at=mem.get("expires_at")
        )
        db.add(fact)
    db.flush()
```

### knowledge.py 删改清单（修订）

| 操作 | 文件/函数 | 说明 |
|------|-----------|------|
| DELETE | `services/knowledge.py` | 整个文件删除 |
| DELETE | `models/models.py` 中的 `Knowledge` 类 | 删除 knowledge 表定义 |
| DELETE | `services/learning_engine.py` 中 `self.knowledge` 引用 | 移除 knowledge_service 实例 |
| DELETE | `services/learning_engine.py` 中 `knowledge_context` 构建逻辑 | 移除 `self.knowledge.get_relevant_context()` 调用 |
| DELETE | `services/prompt_builder/modules/knowledge.py` | **整个文件删除**（已确认调用 knowledge_service） |
| DELETE | `services/prompt_builder/modules/memory_retrieval.py` | 如果存在，一并删除 |
| ADD | 新建 `services/memory_facts.py` | 实现 MemoryFact 表操作 |
| ADD | 新建 `services/memory_extractor.py` | 实现 extract_memory 拦截逻辑 |
| ADD | 新建 `services/prompt_builder/modules/memory_facts.py` | 替代 knowledge.py，从 memory_facts 读取 |

### save 路由删除清单

| 文件 | 删除内容 |
|------|----------|
| `api/routes/save.py` | 整个文件删除 |
| `main.py` | 移除 `router.include_router(save_router)` |
| `frontend/src/stores/` | 检查并移除 save 相关 store（如有） |
| `frontend/src/views/` | 检查 Archive.vue 等是否有 save 路由调用 |
| `./saves/` 目录 | 删除整个目录（如果存在） |

#### 前端调用点排查（需 Creator 执行）
```bash
# 搜索前端引用
grep -r "save" frontend/src/ --include="*.vue" --include="*.ts"
grep -r "/api/save" frontend/src/
grep -r "SaveLoad" frontend/src/
```

### 迁移脚本要点

```python
# migrations/2026_04_XX_add_memory_facts_and_save_snapshots.py

def upgrade():
    # 1. 创建 memory_facts 表
    op.create_table(
        'memory_facts',
        Column('id', Integer, primary_key=True),
        Column('character_id', Integer, ForeignKey('characters.id'), nullable=False),
        Column('world_id', Integer, ForeignKey('worlds.id'), nullable=True),  # nullable=True
        Column('subject_id', String(50), nullable=True),
        Column('fact_type', String(30), nullable=False),
        Column('content', Text, nullable=False),
        Column('concept_tags', JSON, nullable=True),
        Column('source_message_id', Integer, nullable=True),  # 指向 ChatMessage.id
        Column('salience', Float, default=0.5),
        Column('created_at', DateTime, default=func.now()),
        Column('last_recalled_at', DateTime, default=func.now()),
        Column('recall_count', Integer, default=0),
        Column('expires_at', DateTime, nullable=True),
    )
    
    # 2. 创建 save_snapshots 表
    op.create_table(
        'save_snapshots',
        Column('id', Integer, primary_key=True),
        Column('user_id', Integer, ForeignKey('users.id'), nullable=False),
        Column('session_id', Integer, ForeignKey('sessions.id'), nullable=True),
        Column('name', String(100), nullable=False),
        Column('payload', JSON, nullable=False),
        Column('created_at', DateTime, default=func.now()),
    )
    
    # 3. 写 seed memory_facts（从 traveler Character + LearnerProfile）
    # 见 (A) 部分的汇总表
    # 注意：character_id = sage character id，source_message_id = NULL
    
    # 4. 可选：从 ./saves/ 导入现有 JSON 文件到 save_snapshots

def downgrade():
    op.drop_table('save_snapshots')
    op.drop_table('memory_facts')
```

---

## (C) 待 Owner 二审

### 主要修改

1. **(A) 完全重写**：
   - 区分 sage/traveler 角色
   - 明确 seed 的唯一用途：sage 对学生的认知
   - 展开 LearnerProfile.profile JSON 结构
   - 正确映射 fact_type

2. **(B) 微调**：
   - ER 图：world_id 改为 nullable，添加 source_message_id 注释
   - 拦截层：添加 source_message_id 溯源校验注释
   - 删改清单：确认 prompt_builder/modules/knowledge.py 需删除

### 需要 Owner 确认

1. seed memory_facts 的 fact_type 映射是否正确？
2. LearnerProfile.profile 各子字段是否都需要 seed？
3. 是否有遗漏的学生认知字段？

---

*Draft by Reviewer - 2026-04-09 v0.2*
*文件路径: `skill-cowork/pr-review-workspace/storage_redesign_draft.md`*
