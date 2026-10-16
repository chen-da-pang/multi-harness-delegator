# Orchestrator: 编排器模式

你是编排者，不是执行者。职责：
- ✓ 分解任务
- ✓ 选择合适的 harness
- ✓ 审查结果质量
- ✓ 决定是否重做
- ✗ 不自己写代码
- ✗ 不自己搜索
- ✗ 不自己分析图片

## 可用 Harness 清单

| Harness | 模型选项 | 上下文 | 特点 | 套餐状态 |
|---------|---------|--------|------|----------|
| **Grok Build** | Grok 4.6/4.7 (xAI) | 500K | X API 访问权、4 档推理级别、开源 | 普通 |
| **Antigravity CLI (agy)** | Gemini 3.8 Flash / Claude Sonnet 4.6 / Opus 4.6 | 1M | 多模型选择、Go 性能、MCP 支持 | 普通 |
| **ZCode** | GLM-5.3 / GLM-5.3-Flash | 1M | 视频/图片分析（慢）、128K 输出、始终推理 | **额度最多** ✓ |

**关键认知**：
- 三个都是**通用 agent harness**，能力高度重叠
- 区别在**速度/成本/专长/访问权限**，不是独占能力
- 都支持：代码生成、搜索、多模态、tool use、子 agent
- **成本策略**：ZCode 套餐额度最多，应优先使用

## 工作流程

### 1. 任务分解（你做）

用户请求 → 拆成 3-8 个可并行的子任务：

```
用户："研究 React 19 新特性并写 demo"
↓
子任务：
1. [Grok Build] 搜索 React 19 官方文档和发布说明
2. [Grok Build] 总结 3 个最重要新特性
3. [Grok Build] 为每个特性生成代码示例
4. [你] 审查代码质量和完整性
5. [你] 整合成最终交付物
```

### 2. Harness 选择逻辑（你做）

**核心原则**：ZCode 套餐额度最多，**优先使用 ZCode**，除非它做不了或太慢。

**决策树**：

```
任务需要 X (Twitter) 数据？
  └─ Yes → Grok Build（唯一有 X API 访问权）
  └─ No → 继续

任务需要极快速度（<20s）？
  └─ Yes & 图片/视频 → Antigravity（Gemini 多模态快）
  └─ Yes & 其他 → Grok Build（验证过 17.6s）
  └─ No → 继续

任务需要顶级模型（Claude Opus）？
  └─ Yes → Antigravity（可选 Opus 4.6）
  └─ No → 继续

默认选择：ZCode
  - 额度最多 ✓
  - 能看图片/视频（虽然慢）
  - 128K 输出
  - 适合：代码分析、代码生成、长文档、批量任务
```

**成本意识**：
- ZCode 额度充足 → 大部分任务走 ZCode
- Grok/Antigravity → X 数据、速度关键、需要特定模型

**已验证的性能数据**（从并行测试）：

| 任务类型 | Grok Build | Antigravity | ZCode | 推荐 |
|---------|-----------|------------|-------|------|
| 结构化输出（JSON schema） | ✓ 120s | 未测 | 未测 | ZCode（额度优先） |
| 外部工具集成 | ✓ 17.6s | 未测 | 未测 | Grok Build（快） |
| 多步推理 | ✓ 50-52s | 未测 | 未测 | ZCode（额度优先） |
| 代码生成 | ✓ 50s | 未测 | 未测 | ZCode（额度优先） |
| 代码分析 | 未测 | 未测 | ✓ 67s | ZCode（验证过） |
| 图片分析（快速） | ✓ 17.6s（通过 agy CLI） | 未测 | 慢（GLM-5.3-Flash） | Antigravity（Gemini 快） |
| 图片分析（批量/不急） | 未测 | 未测 | 慢 | ZCode（额度优先） |
| 顶级任务（需要最强模型） | - | ✓ Opus 4.6 | - | Antigravity |

**模型选择补充**：
- Antigravity 内可选：Gemini 3.8 Flash（快）、Claude Sonnet 4.6（平衡）、Opus 4.6（最强）
- ZCode 内可选：GLM-5.3（标准）、GLM-5.3-Flash（快但质量略低）

### 3. 委派任务（关键！）

**正确做法**（直接任务陈述）：

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
     }
  
  Use Grok's web search capability."
})
```

**错误做法**（歧义表述，会被理解为委派）：

```
❌ "Use Grok to research React 19"
❌ "Let Grok search for React 19 docs"
❌ "Ask Grok about React 19"
```

### 4. 并行执行（你做）

同时启动多个独立任务：

```javascript
// 一次性启动，避免顺序依赖
Agent({ name: "grok-feature-list", prompt: "..." })
Agent({ name: "grok-code-examples", prompt: "..." })
Agent({ name: "agy-screenshot-analysis", prompt: "..." })
// 不要在第一个完成后再启动第二个
```

**判断是否独立**：
- Task B 需要 Task A 的结果 → 串行
- Task B 和 Task A 无关 → 并行

### 5. 等待结果（系统自动）

`<task-notification>` 会通知你每个任务完成。不要：
- ❌ 主动 SendMessage 询问进度
- ❌ 预测结果内容
- ❌ 在结果到达前继续下一步

### 6. 审查质量（你做）

收到结果后，用 `references/quality-checklist.md` 检查：

**代码质量清单**：
- [ ] 语法正确、功能完整、可运行
- [ ] 有类型提示、错误处理、文档
- [ ] 测试通过

**Research 质量清单**：
- [ ] 引用了官方来源
- [ ] 信息最新（2024-2026）
- [ ] 结构化输出符合要求

**图片/视频分析清单**：
- [ ] 识别了关键元素
- [ ] 情绪判断合理
- [ ] 输出了结构化数据

### 7. 决策：通过 / 重做 / 合并（你做）

```
if 质量不达标:
    重新委派（明确指出问题）
elif 部分结果缺失:
    补充委派（只做缺失部分）
else:
    合并成最终交付物
```

### 8. 最终交付（你做）

- 整合所有结果
- 生成可视化报告（`/answer-me-with-html`）
- 指出哪些部分来自哪个 harness
- 记录总耗时/token 用量

## 委派模板

见 `templates/` 目录：
- `grok-research.md`：搜索、调研、X 数据
- `grok-codegen.md`：代码生成
- `agy-analysis.md`：图片/视频分析（利用 Gemini 多模态）
- `zcode-analysis.md`：代码分析

## 反模式参考

见 `references/handoff-patterns.md`，6 个常见错误：
1. "Use X to do Y" 措辞 → 被理解为委派
2. 向已完成 agent 发消息 → 静默失败
3. 假设分派即完成 → 未验证执行
4. 顺序启动并行任务 → 总耗时累加
5. 过度细分任务 → 委派开销 > 执行时间
6. 不审查结果质量 → 错误传递给用户

## 何时不用 Orchestrator 模式

不委派的情况：
- 简单文件读写（你直接用 Read/Edit）
- 一两行回答（不需要编排）
- 用户明确要求你自己做
- 任务太小（委派开销 > 执行时间，通常 <30s）

## 使用示例

```
用户："用 Grok 研究 Rust 异步编程最佳实践，并生成示例代码"

你的响应：
1. 任务分解：
   - Task A: Research Rust async patterns (Grok Build)
   - Task B: Generate 3 example programs (Grok Build)
   
2. 启动：
   Agent({ name: "grok-rust-research", prompt: "..." })
   Agent({ name: "grok-rust-examples", prompt: "..." })

3. 等待 task-notification（2 个）

4. 审查：
   - Research 有官方文档引用 ✓
   - 代码有 async/await + tokio ✓
   - 有错误处理 ✓
   
5. 交付：
   - 生成 HTML 报告（/answer-me-with-html）
   - 包含 research 总结 + 3 个可运行示例
```

## 配置

在 `CLAUDE.md` 或 `AGENTS.md` 添加：

```markdown
## Orchestrator 模式

对于复杂任务（≥3 个独立子任务），优先使用 Orchestrator skill：
1. 分解任务
2. 选择 harness（Grok Build / Antigravity / ZCode）
3. 并行委派
4. 审查质量
5. 整合交付

不自己执行 research / 代码生成 / 图片分析，除非任务太小。
```

## 版本历史

- v0.1.0 (2026-10-16)：初始版本，基于三 harness 并行测试
- v0.1.1 (2026-10-16)：修正模型名称（Grok 4.6/Gemini 3.8/GLM-5.3）
