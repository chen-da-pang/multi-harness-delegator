# Orchestrator Skill

编排器模式：Claude Code 做决策和审查，Grok/agy/zcode 做执行。

## 结构

```
orchestrator/
├── SKILL.md                    # 主 skill 说明
├── templates/                   # 委派模板
│   ├── grok-research.md        # 搜索/调研
│   ├── grok-codegen.md         # 代码生成
│   ├── agy-analysis.md         # 图片/视频分析
│   └── zcode-analysis.md       # 代码分析
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
[你] 选择 harness（Grok / agy / zcode）
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
1. [Grok] 搜索 Rust 官方文档和社区最佳实践
2. [Grok] 总结 5 个最重要的模式
3. [Grok] 为每个模式生成代码示例
4. [你] 审查代码质量
5. [你] 整合成 HTML 报告

并行启动 1+2+3，等 3 个 task-notification，审查，交付。
```

## Harness 选择逻辑

| 任务需求 | 首选 | 备选 | 原因 |
|---------|------|------|------|
| X (Twitter) 数据 | Grok 3 | - | 唯一有 X API 访问权（xAI 产品） |
| 视频分析 | agy | Grok 3 | 速度更快（17.6s 验证） |
| 图片分析 | agy / Grok 3 | - | 质量相近，看余额 |
| 代码生成 | Grok 3 | zcode | 质量验证过（类型/文档/错误处理） |
| 代码分析 | zcode / Grok 3 | - | 都准确，zcode 有 ACP 桥延迟 |
| Extended thinking | Grok 3 | - | 11K+ 推理 tokens |
| 网页搜索 | 任意 | - | 都能联网，选余额充足的 |

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
- **templates/**：4 种常见任务的 prompt 模板
- **handoff-patterns.md**：6 个反模式和修复方案
- **quality-checklist.md**：代码/research/分析的审查标准

## 下一步

- [ ] 在 `CLAUDE.md` 中配置触发规则
- [ ] 运行第一个编排任务，测试流程
- [ ] 根据实际使用调整模板
- [ ] 记录新的反模式到 handoff-patterns.md

## 版本

- v0.1.0 (2026-10-16)：初始版本，基于三 harness 并行测试经验
