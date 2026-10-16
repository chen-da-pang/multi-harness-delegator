# Orchestrator Skill

编排器模式：Claude Code 做决策和审查，Grok Build/Antigravity/ZCode 做执行。

## 结构

```
orchestrator/
├── SKILL.md                    # 主 skill 说明
├── templates/                   # 委派模板
│   ├── grok-research.md        # Grok 4.6: 搜索/调研/X数据
│   ├── grok-codegen.md         # Grok 4.6: 代码生成
│   ├── agy-analysis.md         # Gemini 3.8: 图片/视频分析
│   └── zcode-analysis.md       # GLM-5.3: 代码分析
├── references/                  # 参考文档
│   ├── handoff-patterns.md     # 任务交接反模式
│   └── quality-checklist.md    # 结果质量审查清单
└── README.md                    # 本文件
```

## 快速开始

### 1. 触发 Skill

在用户的 `CLAUDE.md` 或 `AGENTS.md` 中添加：

```markdown
## Orchestrator 模式

对于复杂任务（≥3 个独立子任务），使用 `/orchestrator` skill。

触发条件：
- 用户说"研究"/"调研"（需要 ≥3 个来源）
- 需要生成 ≥50 行代码
- 需要分析图片/视频
- 明确说"orchestrator" 或 "编排"
```

### 2. 工作流程

```
用户请求
  ↓
[你] 任务分解（3-8 个子任务）
  ↓
[你] 选择 harness（Grok Build / Antigravity / ZCode）
  ↓
[你] 并行委派（一次性启动所有独立任务）
  ↓
[系统] task-notification（等待所有完成）
  ↓
[你] 审查质量（用 quality-checklist.md）
  ↓
[你] 决策：通过 / 重做 / 补充
  ↓
[你] 整合交付（用 /answer-me-with-html 生成报告）
```

### 3. 示例

```
用户："研究 Rust 异步编程最佳实践，并生成示例代码"

分解：
1. [Grok Build] 搜索 Rust 官方文档和社区最佳实践
2. [Grok Build] 总结 5 个最重要的模式
3. [Grok Build] 为每个模式生成代码示例
4. [你] 审查代码质量
5. [你] 整合成 HTML 报告

并行启动 1+2+3，等 3 个 task-notification，审查，交付。
```

## 可用 Harness 清单

| Harness | 实际名称 | 模型 | 上下文 | 独特能力 |
|---------|---------|------|--------|---------|
| Grok Build | Grok Build (CLI) | Grok 4.6/4.7 (xAI) | 500K | X API 访问权、4 档推理、开源 |
| Antigravity | agy (Antigravity CLI) | Gemini 3.8 Flash (Google) | 1M | Go 性能、MCP 支持 |
| ZCode | ZCode Desktop | GLM-5.3/GLM-5.3-Flash (Z.ai) | 1M | 128K 输出、始终推理 |

**关键认知**：
- 三个都是**通用 agent harness**，能力高度重叠
- 区别在**速度/成本/专长/访问权限**，不是独占能力
- 都支持：代码生成、搜索、多模态、tool use、子 agent

## Harness 选择逻辑

**决策树**：

```
任务需要 X (Twitter) 数据？
  └─ Yes → Grok Build（唯一有 X API 访问权）
  └─ No → 继续

任务需要 ≥500K 上下文？
  └─ Yes → Antigravity / ZCode（1M 上下文）
  └─ No → 继续

任务需要大量输出（≥50K tokens）？
  └─ Yes → ZCode（128K 输出上限）
  └─ No → 继续

任务是长时间开发任务（多步骤代码修改）？
  └─ Yes → ZCode（长任务优化）
  └─ No → 继续

默认选择：
  - Grok Build：推理任务、X 相关、JSON schema 验证
  - Antigravity：图片/视频分析（Gemini 多模态）、速度优先
  - ZCode：代码分析、长上下文需求
```

## 已验证性能数据

| 任务类型 | Grok Build | Antigravity | ZCode | 选择建议 |
|---------|-----------|------------|-------|---------|
| 结构化输出（JSON schema） | ✓ 120s | 未测 | 未测 | Grok Build |
| 外部工具集成 | ✓ 17.6s | - | - | Grok Build |
| 多步推理 | ✓ 50-52s | 未测 | 未测 | Grok Build |
| 代码生成 | ✓ 50s | 未测 | 未测 | Grok Build |
| 代码分析 | 未测 | 未测 | ✓ 67s | ZCode |
| 图片分析 | ✓ 17.6s（通过 agy CLI） | 未测 | 未测 | Antigravity |

## 关键规则

### ✓ 正确做法
- 直接任务陈述："Research X. Output JSON: {...}"
- 一次性并行启动：`Agent(...) Agent(...) Agent(...)`
- 等待 task-notification，不假设完成
- 审查质量，用 quality-checklist.md

### ✗ 错误做法
- ❌ "Use Grok to research X"（歧义 → 被理解为委派）
- ❌ 顺序启动任务（总耗时累加）
- ❌ SendMessage 给已完成 agent（静默失败）
- ❌ 不审查直接交付（错误/缺失传递给用户）

## 文件说明

- **SKILL.md**：主文档，定义职责边界和工作流程
- **templates/**：4 种常见任务的 prompt 模板（含真实模型名称）
- **handoff-patterns.md**：6 个反模式和修复方案
- **quality-checklist.md**：代码/research/分析的审查标准

## 下一步

- [ ] 在 `CLAUDE.md` 中配置触发规则
- [ ] 运行第一个编排任务，测试流程
- [ ] 根据实际使用调整模板
- [ ] 记录新的反模式到 handoff-patterns.md

## 版本历史

- v0.1.0 (2026-10-16)：初始版本，基于三 harness 并行测试
- v0.1.1 (2026-10-16)：修正模型名称（Grok 4.6/Gemini 3.8/GLM-5.3）
