---
name: multi-harness-delegator
description: Orchestrate tasks across Grok Build, Antigravity, and ZCode. Delegate execution (coding, research, multimodal) to specialized harnesses while Claude Code handles planning, quality review, and Matt workflow.
---

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

## 编排模式实战

三种最常见的并行场景，提供分解策略和 harness 选择指南。

### Market Research（多数据源并行）

**任务特征**：
- 用户要求调研某个主题
- 需要综合多个来源（官方文档、博客、GitHub、社区）
- 各来源独立，可并行检索

**分解策略**：按数据源并行
- ✓ 独立性：各数据源可独立检索，无顺序要求
- ✓ 可合并：最后汇总对比，生成综合报告
- ✗ 依赖：无（不需要等某个来源完成才能查下一个）

**Harness 选择**（参考快速决策卡 § 2）：
- 默认 → **Grok Build**（额度多、Web 访问强）
- X/Twitter 数据 → **必须 Grok Build**（X API 专属）
- 学术论文/长文 → **Antigravity**（1M 上下文）

**实例**：

用户请求：
```
"研究 React Server Components 的采用情况：
1. 技术博客观点
2. GitHub 仓库趋势
3. Reddit 社区讨论"
```

你的分解：
```typescript
// 3 个独立数据源，一次性启动
Agent({
  name: "grok-tech-blogs",
  prompt: "Search React Server Components adoption in major tech blogs.
  
  Sources: Vercel blog, Kent C. Dodds, Dan Abramov, CSS-Tricks.
  Output: 5 key points with quotes and URLs."
})

Agent({
  name: "grok-github-trends", 
  prompt: "Analyze React Server Components adoption on GitHub.
  
  Tasks:
  1. Search repos using RSC (sort by stars)
  2. Count RSC mentions in Next.js discussions
  3. List 5 major projects using it
  
  Output: Structured JSON with repo names, stars, adoption dates."
})

Agent({
  name: "grok-reddit-community",
  prompt: "Summarize React Server Components discussions on r/reactjs.
  
  Focus:
  - Top 10 threads (last 3 months)
  - Main concerns and praises
  - Common use cases
  
  Output: Sentiment analysis + 3 representative quotes."
})
```

**避免**（串行等待）：
```typescript
❌ Agent({ name: "grok-1", prompt: "Search blogs first..." })
   // 等 grok-1 完成
   Agent({ name: "grok-2", prompt: "Now search GitHub..." })
   // 总耗时 = grok-1 + grok-2 + grok-3
```

**审查清单**（参考 `references/quality-checklist.md`）：
- [ ] 每个来源有具体数据（不是泛泛而谈）
- [ ] 有原始 URL 引用（可验证）
- [ ] 结论互相印证（不矛盾）

---

### Full-stack App（架构分层并行）

**任务特征**：
- 用户要求构建完整应用（前端 + 后端 + 数据库）
- 各层有明确分界（API 接口作为契约）
- 可以先定义接口，然后并行开发

**分解策略**：按架构层并行
- ✓ 独立性：前端/后端基于约定的 API schema 独立开发
- ✓ 可合并：最后集成测试
- ✗ 依赖：需要先定义 API 接口（串行前置步骤）

**Harness 选择**（参考能力矩阵 § 2）：
- 前端（React/Vue） → **Grok Build**（快、额度多）或 **Gemini 3.8**（多模态强）
- 后端（复杂逻辑） → **ZCode GLM-5.3**（编码专长）
- 数据库设计 → **Grok Build**（快速生成 schema）

**实例**：

用户请求：
```
"做一个任务管理 SPA：
- 前端：React + TailwindCSS
- 后端：Node.js + Express
- 数据库：PostgreSQL"
```

你的分解：

**步骤 1**（串行前置）：定义 API 契约
```typescript
Agent({
  name: "grok-api-design",
  prompt: "Design REST API for task management app.
  
  Endpoints:
  - GET /tasks (list)
  - POST /tasks (create)
  - PATCH /tasks/:id (update)
  - DELETE /tasks/:id (delete)
  
  Output: OpenAPI 3.0 spec with schemas."
})
```

**步骤 2**（并行）：等 API spec 完成后，并行开发
```typescript
Agent({
  name: "grok-frontend",
  prompt: "Build React task management frontend.
  
  Based on API spec: [粘贴 grok-api-design 的输出]
  
  Requirements:
  - TaskList component (fetch /tasks)
  - TaskForm component (POST /tasks)
  - Use React Query for data fetching
  - TailwindCSS for styling
  
  Deliverable: Complete src/ directory with components."
})

Agent({
  name: "zcode-backend",
  prompt: "Build Node.js + Express backend for task management.
  
  API spec: [粘贴 grok-api-design 的输出]
  
  Requirements:
  - Express routes matching spec
  - PostgreSQL integration (pg library)
  - Input validation (Zod)
  - Error handling middleware
  
  Deliverable: server.js + routes/ + models/"
})

Agent({
  name: "grok-database",
  prompt: "Create PostgreSQL schema for task management.
  
  Based on API spec: [粘贴 grok-api-design 的输出]
  
  Tables:
  - tasks (id, title, description, status, created_at, updated_at)
  - Indexes on status and created_at
  
  Deliverable: schema.sql with CREATE TABLE and indexes."
})
```

**避免**（无 API 契约直接并行）：
```typescript
❌ Agent({ name: "frontend", prompt: "Make a task app UI..." })
   Agent({ name: "backend", prompt: "Make a task API..." })
   // 前端期待 /api/tasks，后端实现 /tasks → 接口不匹配
```

**审查清单**：
- [ ] API spec 明确（请求/响应结构清晰）
- [ ] 前端调用与后端实现匹配（端点、方法、数据结构）
- [ ] 数据库 schema 支持 API 所需字段
- [ ] 有错误处理（404、500、validation errors）

---

### Multi-image Analysis（批量并行）

**任务特征**：
- 用户提供多张图片（截图、设计稿、数据图表）
- 需要分析每张图片，然后汇总
- 各图片独立，分析过程无依赖

**分解策略**：按图片数量并行
- ✓ 独立性：每张图片独立分析（无需知道其他图片内容）
- ✓ 可合并：最后汇总共性/差异
- ✗ 依赖：无（不需要先看图 A 才能看图 B）

**Harness 选择**（参考能力矩阵 § 2）：
- 快速分析 → **Grok 4.7 Fast**（17.6s，额度多）
- 高质量分析 → **Gemini 3.8 Flash**（Antigravity，多模态强）
- ❌ **不用 ZCode GLM-5.3**（无多模态能力）

**实例**：

用户请求：
```
"分析这 5 张移动端 UI 截图，找出设计不一致的地方：
- screenshot-1.png
- screenshot-2.png
- screenshot-3.png
- screenshot-4.png
- screenshot-5.png"
```

你的分解：
```typescript
// 5 张图片，一次性启动 5 个并行分析
const screenshots = [1, 2, 3, 4, 5];

screenshots.forEach(i => {
  Agent({
    name: `grok-analyze-screenshot-${i}`,
    prompt: `Analyze UI screenshot-${i}.png for design consistency.
    
    Check:
    - Color palette (primary, secondary, text colors)
    - Typography (font families, sizes, weights)
    - Spacing (margins, paddings, gaps)
    - Component styles (buttons, inputs, cards)
    
    Output structured JSON:
    {
      "colors": {"primary": "#...", "text": "#..."},
      "fonts": ["Font Name", ...],
      "spacing": {"margin": "...", "padding": "..."},
      "issues": ["Issue 1", "Issue 2"]
    }
    
    Image: @screenshot-${i}.png`
  });
});

// 等所有 5 个任务完成后，汇总分析
Agent({
  name: "grok-summarize-consistency",
  prompt: "Compare 5 UI analysis results and find inconsistencies.
  
  Results: [粘贴 5 个 grok-analyze-screenshot-N 的输出]
  
  Find:
  1. Color inconsistencies (different blues across screens)
  2. Font inconsistencies (mixed fonts)
  3. Spacing inconsistencies (varying margins)
  
  Output: Summary with specific examples (e.g., 'Screenshot 2 uses #3B82F6 but Screenshot 4 uses #2563EB')."
})
```

**变体**（视频 + 图片混合）：
```typescript
// 如果有视频，先用 ZCode GLM-5.3-Flash 提取关键帧
Agent({
  name: "zcode-extract-frames",
  prompt: "Extract 5 key frames from demo-video.mp4.
  
  Output: 5 PNG files (frame-1.png to frame-5.png).
  
  Video: @demo-video.mp4"
})

// 等视频处理完成后，用 Grok 分析提取的图片
Agent({
  name: "grok-analyze-frames",
  prompt: "Analyze 5 key frames from video.
  
  Images: @frame-1.png, @frame-2.png, ..., @frame-5.png
  
  Describe the workflow shown in the video."
})
```

**避免**（串行分析）：
```typescript
❌ Agent({ name: "analyze-1", prompt: "Analyze screenshot-1..." })
   // 等 analyze-1 完成
   Agent({ name: "analyze-2", prompt: "Analyze screenshot-2..." })
   // 总耗时 = 5 * 单张耗时（可能 5 * 20s = 100s）
```

**避免**（违反能力矩阵）：
```typescript
❌ Agent({
     name: "zcode-analyze-image",  // ZCode GLM-5.3 无多模态！
     prompt: "Analyze @screenshot.png..."
   })
   // 结果：任务失败或调用 GLM-4.7 工具（效果差）
```

**审查清单**：
- [ ] 每张图片都有具体分析（不是"都差不多"）
- [ ] 汇总报告有对比数据（具体颜色值、字体名称）
- [ ] 识别出的问题可操作（可以直接去改设计）

---

### 模式选择决策树

```
用户请求
  ↓
需要多个来源？
  Yes → Market Research 模式
    ↓
    按数据源并行（Grok Build）
  No ↓
  
需要前后端？
  Yes → Full-stack App 模式
    ↓
    先定义 API，再分层并行（前端 Grok/Gemini，后端 ZCode）
  No ↓
  
多张图片/视频？
  Yes → Multi-image Analysis 模式
    ↓
    按图片数量并行（Grok 4.7 Fast / Gemini 3.8）
    或视频先提取帧（ZCode GLM-5.3-Flash）
  No ↓
  
单一任务 → 不用编排，直接执行
```

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
