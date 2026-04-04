# tmux 通知指南

用于 Creator/Reviewer 跨 session 实时通知。

## 手动通知示例

```bash
# 示例环境变量（按你的项目修改）
export CREATOR_SESSION="your-creator-session"
export REVIEWER_SESSION="your-reviewer-session"

# Creator -> Reviewer
tmux send-keys -t "$REVIEWER_SESSION" "[Creator 通知] PR #9 已修复，请 re-review。" Enter

# Reviewer -> Creator
tmux send-keys -t "$CREATOR_SESSION" "[Reviewer 通知] PR #9 有必须修复项，请查看 comments。" Enter
```

## 发送前空闲检查

```bash
tmux capture-pane -t <session-name> -p | grep -v '^$' | tail -1
```

## 自动守护脚本

```bash
# 示例环境变量（按你的项目修改）
export REPO="owner/repo"
export CREATOR_SESSION="your-creator-session"
export REVIEWER_SESSION="your-reviewer-session"
export POLL_INTERVAL="60"

# 启动
tmux new-session -d -s gh-notify "bash issue-creation/scripts/gh-notify-daemon.sh"

# 查看
tmux attach -t gh-notify

# 停止
tmux kill-session -t gh-notify
```

## 环境变量

- `REPO`：目标仓库，格式 `owner/repo`
- `CREATOR_SESSION`：Creator 所在 tmux session
- `REVIEWER_SESSION`：Reviewer 所在 tmux session
- `POLL_INTERVAL`：轮询秒数（建议 30-120）
