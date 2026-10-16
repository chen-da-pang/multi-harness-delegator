# Orchestrator Skill

编排器模式：Claude Code 做决策、规划、审查，Grok Build/Antigravity/ZCode 做执行。

## 职责边界

**你（Claude Code）的职责**：
- ✓ 任务分解（3-8 个可并行子任务）
- ✓ 选择合适的 harness
- ✓ 编写 spec ticket
- ✓ 审查结果质量
- ✓ 生成 PR 和 review
- ✓ 决定是否重做
- ✗ 不自己写代码（除非任务太小）
- ✗ 不自己搜索（除非一两个来源）
- ✗ 不自己分析图片/视频

**Harness 的职责**：
- ✓ 执行具体任务
- ✓ 搜索和调研
- ✓ 代码生成
- ✓ 图片/视频分析
- ✓ 多步推理
- ✗ 不做决策
- ✗ 不审查别人的工作

## 可用 Harness 清单

| Harness | 模型选项 | 上下文 | 专长 | 额度 |
|---------|---------|--------|------|------|
| **Grok Build** | Grok 4.6/4.7/4.7-Fast (xAI) | 500K | X API 访问权、多模态快、4 档推理 | 很多 |
| **Antigravity CLI (agy)** | Gemini 3.8 Flash / Claude Sonnet 4.6 / Opus 4.6 | 1M | 多模型选择、Gemini 多模态强、可选顶级模型 | 普通 |
| **ZCode** | GLM-5.3 / GLM-5.3-Flash | 1M | **高难度编码**、128K 输出、始终推理 | 最多 |

### 能力矩阵（唯一真相源）

| 模型 | 图片 | 视频 | 音频 | 编码 | 速度 | 备注 |
|------|------|------|------|------|------|------|
| **GLM-5.3** (ZCode) | ✗ | ✗ | ✗ | ⭐⭐⭐ | 中 | 高难度编码专长 |
| **GLM-5.3-Flash** (ZCode) | ✓ | ✓ | ✗ | ⚠️ | 慢 | **唯一能看视频**；非多模态任务时蠢 |
| **Grok 4.7 Fast** | ✓ | ✗ | ✓ | ⭐⭐ | 快 | 看图快；额度多 |
| **Gemini 3.8 Flash** (Antigravity) | ✓ | ✗ | ✗ | ⭐⭐ | 快 | 看图强且快 |
| **Opus 4.6** (Antigravity) | ✓ | ✗ | ✗ | ⭐⭐⭐ | 慢 | 顶级模型 |

**关键限制**：
- 🎥 **视频**：只有 GLM-5.3-Flash 支持（但听不到音频）
- 🔊 **音频**：只有 Grok 系列支持
- 💻 **高难度编码**：只有 GLM-5.3 和 Opus 4.6 擅长
- 📸 **看图**：除 GLM-5.3 外都支持

**选择原则**：按任务类型选（参考上表），不是按额度选

## 工作流程（Matt 流程）

### 1. 任务分解（你做）

```
用户请求
  ↓
能分解吗？
  No → 单任务执行
  Yes ↓
子任务是否独立？
  Yes → 并行（Fan-out）
  No → 串行（Pipeline）
  ↓
[你] 分解成 3-8 个子任务
  ↓
[你] 写 spec ticket（如果复杂）
```

**并行 vs 串行判断**：
- **独立任务** → 并行：10 张图片分析、多数据源调研、前后端分层开发
- **依赖关系** → 串行：视频→代码（能力约束）、调研→实现（输出作输入）

### 2. Harness 选择逻辑（你做）

**快速决策卡**（详见能力矩阵）：

🎯 **硬约束优先**
- X 数据 → Grok Build
- 视频 → ZCode GLM-5.3-Flash
- 高难度编码 → ZCode GLM-5.3
- 顶级模型 → Antigravity Opus 4.6

📸 **多模态任务**
- 图片 → Grok 4.7 Fast / Gemini 3.8
- 音频 → Grok Build / Antigravity
- 视频 → ZCode GLM-5.3-Flash

🔧 **通用任务**
- 默认 → Grok Build（额度多、能力全面）

⚠️ **禁止**
- 视频 → Grok/Antigravity ❌
- 多模态 → ZCode GLM-5.3 ❌
- 代码/推理 → GLM-5.3-Flash ❌

**允许的变通**：
- 如果必须用 ZCode GLM-5.3 处理有图片的任务 → 先用 Grok/Antigravity 看完图，用文字描述给 ZCode

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

```typescript
// 一次性启动，避免顺序依赖
Agent({ name: "grok-feature-list", prompt: "..." })
Agent({ name: "grok-code-examples", prompt: "..." })
Agent({ name: "agy-screenshot-analysis", prompt: "..." })
// 不要在第一个完成后再启动第二个
```

### 5. 等待结果（系统自动）

`<task-notification>` 会通知你每个任务完成。不要：
- ❌ 主动 SendMessage 询问进度
- ❌ 预测结果内容
- ❌ 在结果到达前继续下一步

### 6. 审查质量（你做）

收到结果后，检查（用 `references/quality-checklist.md`）。

### 7. 生成 PR 和 Review（你做，Matt 流程）

```
审查通过
  ↓
[你] 整合所有结果
  ↓
[你] 生成 PR description
  ↓
[你] 写 review 报告
  ↓
[你] 生成可视化报告（/answer-me-with-html）
```

**PR 必须包含**：
- 修改了什么
- 为什么这样改
- 测试结果
- 哪些部分来自哪个 harness

**Review 必须包含**：
- 代码质量评估
- 是否符合 spec
- 潜在问题
- 改进建议

### 8. 决策：通过 / 重做 / 合并（你做）

```
if 质量不达标:
    重新委派（明确指出问题）
elif 部分结果缺失:
    补充委派（只做缺失部分）
else:
    生成 PR 和 review
```

## 已验证性能数据

| 任务类型 | Grok Build | Antigravity | ZCode | 推荐 |
|---------|-----------|------------|-------|------|
| 结构化输出（JSON schema） | ✓ 120s | 未测 | 未测 | Grok Build |
| 外部工具集成 | ✓ 17.6s | 未测 | 未测 | Grok Build |
| 多步推理 | ✓ 50-52s | 未测 | 未测 | Grok Build |
| 代码生成（普通） | ✓ 50s | 未测 | 未测 | Grok Build |
| 代码生成（高难度） | 未测 | 未测 | 未测 | ZCode GLM-5.3 |
| 代码分析 | 未测 | 未测 | ✓ 67s | Grok Build / ZCode GLM-5.3 |
| 图片分析（快速） | ✓ 17.6s | 未测 | ✗ 慢 | Grok 4.7 Fast / Gemini 3.8 |
| 视频分析 | ✗ | ✗ | ✓ (GLM-5.3-Flash) | 见能力矩阵 |
| 顶级任务 | - | ✓ Opus 4.6 | - | Antigravity Opus 4.6 |

**注意**：多模态能力详见上方**能力矩阵**。

**模型智商排序**（从高到低）：
1. Claude Opus 4.6（Antigravity）
2. Grok 4.6/4.7（Grok Build）
3. Claude Sonnet 4.6（Antigravity）
4. Gemini 3.8 Flash（Antigravity）
5. GLM-5.3（ZCode，编码强）
6. GLM-5.3-Flash（ZCode，**最蠢**）

## 反模式参考（从本次测试学到的）

| 反模式 | 症状 | 根因 | 修复 |
|--------|------|------|------|
| "Use X to do Y" | Agent 发 SendMessage 而非执行 | 歧义表述 | 直接任务陈述 |
| SendMessage 给已完成 agent | 静默失败，无结果 | 无存活检查 | 只在必要时用 SendMessage |
| 假设分派即完成 | Agent 退出但工作未开始 | 未验证执行 | 等 task-notification |
| 顺序启动任务 | 总耗时 = 所有任务之和 | 串行思维 | 一次性启动所有独立任务 |
| 违反能力矩阵 | 任务失败或效果差 | 未查能力矩阵 | 严格按能力矩阵选择 |

## 使用示例

```
用户："用 Grok 研究 Rust 异步编程最佳实践，并生成示例代码"

你的响应：
1. Spec ticket（如果复杂）：
   - 目标：Rust 异步编程最佳实践总结 + 代码示例
   - 范围：5 个主要模式，每个有示例
   
2. 任务分解：
   - Task A: Research Rust async patterns (Grok Build)
   - Task B: Generate 3 example programs (Grok Build)
   
3. 启动：
   Agent({ name: "grok-rust-research", prompt: "..." })
   Agent({ name: "grok-rust-examples", prompt: "..." })

4. 等待 task-notification（2 个）

5. 审查：
   - Research 有官方文档引用 ✓
   - 代码有 async/await + tokio ✓
   - 有错误处理 ✓
   
6. 生成 PR：
   - 标题："Add Rust async programming guide"
   - 描述：研究来源 + 示例说明
   
7. 生成 review：
   - 代码质量：✓
   - 符合spec：✓
   - 潜在问题：无
   
8. 交付：
   - 生成 HTML 报告（/answer-me-with-html）
   - 包含 research 总结 + 3 个可运行示例
```

## 何时不用 Orchestrator 模式

不委派的情况：
- 简单文件读写（你直接用 Read/Edit）
- 一两行回答（不需要编排）
- 用户明确要求你自己做
- 任务太小（委派开销 > 执行时间）
- 你可以自己决定的简单任务（不需要 grill，但仍需 spec/PR/review）
