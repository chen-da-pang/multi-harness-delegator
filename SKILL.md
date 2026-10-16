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

### 能力边界（重要）

**GLM-5.3**（ZCode 标准）：
- ✓ 高难度编码任务（专长）
- ✗ **没有多模态能力**（看图是通过 GLM-4.7 工具，效果差）
- 使用建议：纯编码任务，或先用别的看完图片，再用文字描述给他

**GLM-5.3-Flash**（ZCode 快速）：
- ✓ 能看图片/视频（**唯一能看视频的模型**）
- ✗ **视频分析听不到音频**
- ✗ **在非多模态任务时智商低**（代码、推理等任务慢且蠢）
- ✗ 速度慢（不如 Gemini 3.8 Flash、Grok 4.7 Fast）

**Grok 4.7 Fast**：
- ✓ 看图快
- ✗ **不能看视频**
- ✓ 额度多

**Gemini 3.8 Flash**：
- ✓ 看图强且快
- ✗ **不能看视频**

**选择原则**：按任务类型选，不是按额度选

## 工作流程（Matt 流程）

### 1. 任务分解（你做）

```
用户请求
  ↓
[你] 分解成 3-8 个可并行子任务
  ↓
[你] 写 spec ticket（如果复杂）
```

### 2. Harness 选择逻辑（你做）

**按任务类型选择，不按额度**：

```
任务需要 X (Twitter) 数据？
  └─ Yes → Grok Build（唯一有 X API 访问权）
  └─ No → 继续

任务需要多模态（看图/视频/听声音）？
  └─ Yes & 需要看**视频**（无论是否有声） → ZCode GLM-5.3-Flash（**唯一能看视频**）
  └─ Yes & 需要听**声音** → Grok Build / Antigravity（但**不支持视频**）
  └─ Yes & 只需要看**图片** → Grok 4.7 Fast / Gemini 3.8 Flash（都快）
  └─ No → 继续

任务是高难度编码？
  └─ Yes → ZCode GLM-5.3（编码专长）
  └─ No → 继续

任务需要顶级模型？
  └─ Yes → Antigravity Opus 4.6（最强）
  └─ No → 继续

默认选择：Grok Build（额度多、能力全面）
```

**禁止做法**：
- ❌ 把多模态任务交给 ZCode GLM-5.3（它没有多模态，调 GLM-4.7 工具效果差）
- ❌ 把需要看**视频**的任务交给 Grok/Antigravity（它们**不支持视频**）
- ❌ 把代码/推理任务交给 ZCode GLM-5.3-Flash（它在非多模态任务时蠢）
- ❌ 因为"ZCode 额度最多"就优先用它（应该按专长选）

**允许的变通**：
- 如果必须用 ZCode 处理有图片的任务 → 先用 Grok/Antigravity 看完图，用文字描述给 ZCode

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
| 视频分析（有声音） | ✗ 不支持视频 | ✗ 不支持视频 | ⚠️ 能看但听不到 | ZCode GLM-5.3-Flash（妥协方案） |
| 视频分析（无声音/可接受无声） | ✗ 不支持视频 | ✗ 不支持视频 | ✓ 能看 | ZCode GLM-5.3-Flash（唯一选项） |
| 顶级任务 | - | ✓ Opus 4.6 | - | Antigravity Opus 4.6 |

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
| 把多模态任务给 ZCode GLM-5.3 | 效果差 | GLM-5.3 无多模态 | 用 Grok/Antigravity 看图 |
| 把视频任务给 Grok/Antigravity | 失败 | 不支持视频 | 用 ZCode GLM-5.3-Flash |
| 把代码任务给 GLM-5.3-Flash | 慢且蠢 | Flash 只擅长多模态 | 用 GLM-5.3 或 Grok |
| 因为额度多就优先用 | 任务不匹配 | 忽略专长 | 按任务类型选 |

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
