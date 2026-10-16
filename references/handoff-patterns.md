# 任务交接反模式参考

从三 harness 并行测试中学到的教训。

## 反模式 1："Use X to do Y" 措辞

### 症状
Agent 发送 `SendMessage` 给另一个 agent，而不是自己执行任务。

### 根因
**Prompt 歧义**：
```
❌ "Use Grok to research React 19"
```

Agent 理解为：
- "找一个叫 Grok 的 agent"
- "给它发消息让它做 research"

而不是：
- "你（作为有 Grok 能力的 agent）去 research"

### 真实案例
```
Prompt: "Use Grok ACP to generate a Python script"
↓
Agent 行为:
1. 调用 SendMessage(to="grok-agy", message="Generate Python merge script")
2. grok-agy 已完成，收不到消息
3. 主 agent 认为"任务已分派"，标记自己完成
4. 没有生成脚本

修复:
Prompt: "Generate a Python script that merges test results..."
↓
Agent 行为:
1. 直接生成脚本
2. 写入文件
3. 测试验证
4. 成功 ✓
```

### 修复方案
**直接任务陈述**，不提工具名：
```
✓ "Research React 19 new features."
✓ "Generate a Python script that..."
✓ "Analyze the image at <path>."
```

如果必须提工具（比如指定用 X API），放在后面作为补充说明：
```
✓ "Search for tweets about React 19.
   Use your X API access (as xAI product)."
```

---

## 反模式 2：向已完成 agent 发消息

### 症状
`SendMessage` 调用成功，但目标 agent 永远不回复。

### 根因
**无存活检查**：
- Agent A 完成并退出
- Agent B 尝试 `SendMessage(to="A", ...)`
- 消息无法送达，静默失败

### 真实案例
```
grok-codegen (v1):
  SendMessage(to="grok-agy", message="...")
  ↓
grok-agy: 已完成 17 分钟前，收不到消息
  ↓
grok-codegen: 认为消息已发送，标记完成
  ↓
结果: 没有生成代码
```

### 修复方案
**避免跨 agent 通信**：
- 在 Orchestrator 模式下，只有主 orchestrator 发消息给 sub-agents
- Sub-agents 不互相通信
- 结果通过 `<task-notification>` 回到 orchestrator

如果必须通信，先检查目标是否活着：
```
ListAgents() → 查找目标 agent 是否在列表中
如果不在 → 重新启动或换策略
```

---

## 反模式 3：假设分派即完成

### 症状
Agent 发完 `SendMessage` 或启动子任务后立即退出，不等结果。

### 根因
**未验证执行**：
- Agent 认为"我已经告诉别人做了" = "任务完成"
- 没有等待 `<task-notification>`
- 没有验证工作真正开始

### 真实案例
```
grok-codegen (v1):
1. SendMessage(to="grok-agy", ...)
2. 认为完成，退出
3. 没有等通知，没有验证结果
```

### 修复方案
**等待 task-notification**：
```
Agent() 调用返回 → 等待 <task-notification>
收到通知 → 检查 status (completed / killed / failed)
如果 completed → 读取 result
如果 killed / failed → 决定重试或换方案
```

**不要假设**：
- ❌ "我发了消息，肯定在执行"
- ❌ "我启动了 agent，应该在跑"
- ✓ "我收到了 notification，看到了结果"

---

## 反模式 4：顺序启动并行任务

### 症状
总耗时 = 所有任务耗时之和。

### 根因
**串行思维**：
```
❌ 
Agent({ name: "task-1", ... })
等 task-1 完成
Agent({ name: "task-2", ... })
等 task-2 完成
Agent({ name: "task-3", ... })

总耗时: 60s + 50s + 45s = 155s
```

### 修复方案
**一次性启动所有独立任务**：
```
✓
Agent({ name: "task-1", ... })
Agent({ name: "task-2", ... })
Agent({ name: "task-3", ... })
等所有 3 个 task-notification

总耗时: max(60s, 50s, 45s) = 60s
```

**判断是否独立**：
- Task B 需要 Task A 的结果 → 串行
- Task B 和 Task A 无关 → 并行

---

## 反模式 5：过度细分任务

### 症状
任务太碎，委派开销 > 执行时间。

### 根因
**不必要的分派**：
```
❌ "Read file X" → 委派给 agent
❌ "回答一句话" → 委派给 agent
```

### 修复方案
**只委派有价值的任务**：

| 任务 | 是否委派 | 原因 |
|------|---------|------|
| 搜索 ≥3 个来源 | ✓ | 需要 research 能力 |
| 生成 ≥50 行代码 | ✓ | 需要代码生成能力 |
| 分析图片/视频 | ✓ | 需要多模态能力 |
| 读一个文件 | ✗ | 直接用 Read |
| 回答 1-2 句话 | ✗ | 直接回答 |
| < 30s 的任务 | ✗ | 委派开销不值得 |

---

## 反模式 6：不审查结果质量

### 症状
Sub-agent 返回的结果有错误/缺失，orchestrator 直接交付给用户。

### 根因
**盲目信任**：
- 认为 agent 一定做对了
- 不检查结果完整性
- 不验证引用来源

### 修复方案
**质量清单审查**（见 `quality-checklist.md`）：
- 代码：类型提示？错误处理？测试通过？
- Research：官方来源？最新信息？结构化输出？
- 分析：关键元素？合理判断？数据格式正确？

如果不达标 → 重新委派，明确指出问题。

---

## 总结：6 条黄金规则

1. **直接任务陈述**，不用"Use X to..."
2. **避免跨 agent 通信**，结果回到 orchestrator
3. **等待 task-notification**，不假设完成
4. **一次性启动并行任务**，不串行
5. **只委派有价值的任务**（≥30s 或需要专门能力）
6. **审查结果质量**，不盲目交付
