# tmux 通知指南

用于 Creator/Reviewer 跨 session 实时通知。

## 当前项目配置

```bash
# Session 组名（推荐使用，更稳定）
export CREATOR_SESSION="creator"
export REVIEWER_SESSION="reviewer"

# 具体_session 名称（会动态变化）
# 当前: creator-1, reviewer-0
```

> **重要**: Session 名称可能动态变化 (如 creator-1, creator-2)，但组名固定。**优先使用组名**。

## 手动通知示例

```bash
# Creator -> Reviewer（推荐：使用组名）
tmux send-keys -t reviewer "[Creator 通知] PR #9 已修复，请 re-review。" Enter

# Reviewer -> Creator（推荐：使用组名）
tmux send-keys -t creator "[Reviewer 通知] PR #9 有必须修复项，请查看 comments。" Enter
```

## 发送前空闲检查

```bash
# 检查 Creator（使用组名）
tmux capture-pane -t creator -p | grep -v '^$' | tail -1

# 检查 Reviewer（使用组名）
tmux capture-pane -t reviewer -p | grep -v '^$' | tail -1

# 空闲标志：最后一行包含 ❯
```

## 会话不存在时的回退策略

- 若配置的 `CREATOR_SESSION` / `REVIEWER_SESSION` 不存在，不应直接放弃通知。
- 应自动扫描当前 tmux 会话并按角色匹配候选对象（如 `creator`、`reviewer`、`*creator*`、`*reviewer*`）。
- 找到候选后继续执行空闲检测并发送；若目标忙碌则写入对应队列文件。
- 若仍无法匹配目标，则将消息写入原配置会话名对应队列，等待会话恢复后补发。

## 自动守护脚本

```bash
# 环境变量
export REPO="ICEY4040727/Self_Learning-System"
export CREATOR_SESSION="creator"
export REVIEWER_SESSION="reviewer"
export POLL_INTERVAL="60"

# 启动
tmux new-session -d -s gh-notify "bash scripts/gh-notify-daemon.sh"

# 查看
tmux attach -t gh-notify

# 停止
tmux kill-session -t gh-notify
```

## 环境变量

| 变量 | 说明 | 推荐值 |
|------|------|--------|
| `REPO` | 目标仓库 | `owner/repo` |
| `CREATOR_SESSION` | Creator tmux 组名 | `creator` |
| `REVIEWER_SESSION` | Reviewer tmux 组名 | `reviewer` |
| `POLL_INTERVAL` | 轮询秒数 | `60` |
