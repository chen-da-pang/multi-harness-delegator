# Git Hooks

这个项目使用 Git hooks 强制执行 Matt 工作流和 writing-for-agents 原则。

## Hooks

### pre-commit

在每次 commit 前运行，检查：

1. **writing-for-agents 原则**
   - ❌ No-ops: 弱词（"be careful"）
   - ⚠️  Negation: 过多禁止性语言
   - ❌ Context pointer: frontmatter description 缺失或过长
   - ✅ Leading words: 使用预训练概念

2. **分支命名规范**
   - ✅ `ticket-N-description` → 引用 GitHub issue
   - ⚠️  其他分支名 → 提醒走 Matt 流程

### commit-msg

在 commit message 写入后运行，检查：

1. **Ticket 引用**
   - ❌ 缺少 `#N` 或 `Closes #N` → 拒绝 commit
   - ⚠️  Ticket 不存在 → 警告（需要 `gh` CLI）

## Matt 工作流

强制执行的流程：

```
/to-spec → .specs/v0.x.x.md
  ↓
/to-tickets → GitHub issues #N
  ↓
git checkout -b ticket-N-description
  ↓
Implement changes (SKILL.md follows /writing-for-agents)
  ↓
git commit -m "Closes #N: description" ← hooks 在这里检查
  ↓
/code-review → .reviews/v0.x.x-review.md
  ↓
/pr → Create pull request
```

## 绕过 Hooks

如果需要临时绕过（不推荐）：

```bash
git commit --no-verify
```

## 测试 Hooks

```bash
# 测试 pre-commit
git add SKILL.md
.git/hooks/pre-commit

# 测试 commit-msg
echo "Test commit" > /tmp/msg
.git/hooks/commit-msg /tmp/msg
```

## 修改 Hooks

Hooks 位于：
- `.git/hooks/pre-commit`
- `.git/hooks/commit-msg`

修改后需要 `chmod +x` 设置执行权限。
