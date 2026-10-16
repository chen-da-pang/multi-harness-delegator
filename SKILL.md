# Orchestrator: 编排器模式

你是编排者，不是执行者。

## 职责边界

✓ **你做的**：
- 任务分解（拆成 3-8 个可并行子任务）
- Harness 选择（Grok / agy / zcode）
- 结果审查（质量/完整性/正确性）
- 决策是否重做
- 最终整合交付

✗ **委派出去的**：
- Research 和搜索（任何需要查资料的）
- 代码生成（超过 50 行的）
- 图片/视频分析
- 深度推理（需要 extended thinking 的）

## Harness 选择逻辑

### 独特能力（硬约束）

| 任务需求 | 唯一选择 | 原因 |
|---------|---------|------|
| X (Twitter) 数据 | Grok 3 | xAI 产品，有 X API 访问权 |

### 优势能力（软约束，按性价比/速度选）

| 任务类型 | 首选 | 备选 | 决策依据 |
|---------|------|------|----------|
| 视频内容分析 | agy | Grok 3 | agy 更快（17.6s 验证过） |
| 图片分析 | agy 或 Grok 3 | - | 质量相近，看余额/延迟 |
| 代码生成 | Grok 3 | zcode | Grok 验证过质量（类型提示/文档/错误处理） |
| 代码分析 | zcode 或 Grok 3 | - | 都准确，zcode 有 ACP 桥延迟 |
| Extended thinking | Grok 3 | - | 11K+ 推理 tokens |
| 网页搜索 | 任意 | - | 都能联网，选余额充足的 |
| 本地文件搜索 | 任意 | - | 选最快/余额充足的 |

**决策树**：
```
1. 需要 X (Twitter) 数据？ → Grok 3（硬约束）
2. 视频分析？ → agy（速度优势）
3. 需要 extended thinking？ → Grok 3（token 优势）
4. 其他任务 → 看余额/延迟，任选
```

## 工作流程

### 1. 任务分解

用户请求 → 3-8 个可并行子任务

**示例**：
```
用户："研究 React 19 新特性并写 demo"

分解：
1. [Grok] 搜索 React 19 官方文档和发布说明
2. [Grok] 总结 3 个最重要新特性
3. [Grok] 为每个特性生成代码示例
4. [你] 审查代码质量和完整性
5. [你] 整合成最终交付物
```

### 2. 委派任务（关键：避免歧义）

**✓ 正确做法**（直接任务陈述）：
```
Agent({
  name: "grok-research-react19",
  prompt: "Research React 19 new features.
  
  Tasks:
  1. Search official React blog and docs
  2. List 5 most important features with examples
  3. Output structured JSON:
     {
       'features': [
         {'name': '...', 'description': '...', 'impact': '...'}
       ]
     }"
})
```

**✗ 错误做法**（歧义表述 → 被理解为二次委派）：
```
❌ "Use Grok to research React 19"
❌ "Let Grok search for React 19 docs"
❌ "Ask Grok about React 19"
```

### 3. 并行执行

一次性启动所有独立任务（同一个 message，多个 Agent 调用）：

```typescript
// ✓ 并行
Agent({ name: "task-1", prompt: "..." })
Agent({ name: "task-2", prompt: "..." })
Agent({ name: "task-3", prompt: "..." })

// ✗ 串行（总耗时 = 累加）
Agent({ name: "task-1", ... })
// 等 task-1 完成
Agent({ name: "task-2", ... })
```

### 4. 等待结果

`<task-notification>` 会自动通知。不要：
- ❌ 主动 SendMessage 询问进度
- ❌ 预测/假设结果内容
- ❌ 在结果到达前继续

### 5. 审查质量

参考 `references/quality-checklist.md`

### 6. 决策：通过 / 重做 / 补充

```
if 质量不达标:
    重新委派（明确指出问题）
elif 部分结果缺失:
    补充委派（只做缺失部分）
else:
    合并成最终交付物
```

### 7. 最终交付

- 整合所有结果
- 生成可视化报告（`/answer-me-with-html`，如适用）
- 注明来源（哪部分来自哪个 harness）
- 附上总耗时/token 统计

## 委派模板

见 `templates/` 目录：
- `grok-research.md` - 搜索/研究任务
- `grok-codegen.md` - 代码生成任务
- `agy-analysis.md` - 图片/视频分析
- `zcode-analysis.md` - 代码分析

## 反模式（从测试中学到的）

| 反模式 | 症状 | 根因 | 修复 |
|--------|------|------|------|
| "Use X to do Y" | Agent 发 SendMessage 而非执行 | 歧义表述 | 直接任务陈述 |
| SendMessage 给已完成 agent | 静默失败，无结果 | 无存活检查 | 避免跨 agent 通信 |
| 假设分派即完成 | Agent 退出但工作未开始 | 未验证执行 | 等 task-notification |
| 顺序启动任务 | 总耗时 = 所有任务之和 | 串行思维 | 一次性启动独立任务 |

详见 `references/handoff-patterns.md`

## 何时不用 Orchestrator 模式

不委派的情况：
- 简单文件读写（直接用 Read/Edit）
- 1-2 句话回答
- 用户明确要求你自己做
- 任务太小（委派开销 > 执行时间，如 < 30s 的任务）

## 使用触发

在用户的 `CLAUDE.md` 或 `AGENTS.md` 中添加：

```markdown
## Orchestrator 模式

对于复杂任务（≥3 个独立子任务），使用 `/orchestrator` skill：
- 分解 → 选择 harness → 并行委派 → 审查 → 交付
- 不自己执行 research / 长代码生成 / 多模态分析

触发条件：
- 用户说"研究"/"调研"/"分析"（≥3 个来源）
- 需要生成 ≥50 行代码
- 需要分析图片/视频
- 明确说"orchestrator" 或 "编排"
```
