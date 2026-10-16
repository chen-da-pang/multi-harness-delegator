# Orchestrator Skill

编排器模式：Claude Code 做编排、策划、规划、审查，将执行任务委派给专门的 harness。

## 版本

- v0.1.3 (2026-10-16)

## 概述

基于三 harness（Grok Build、Antigravity、ZCode）并行测试的经验，提炼出的编排模式。

**核心价值**：
- 留痕迹：spec → PR → review，方便复盘
- 专业分工：Claude Code 做决策，harness 做执行
- 并行加速：6 个任务并行，总耗时 = 最慢的一个

## 能力清单

| Harness | 模型 | 专长 | 额度 |
|---------|------|------|------|
| **Grok Build** | Grok 4.6/4.7/4.7-Fast | X API、多模态快、全面 | 很多 |
| **Antigravity** | Gemini 3.8 / Sonnet 4.6 / Opus 4.6 | 多模型、Gemini 多模态强、可选顶级 | 普通 |
| **ZCode** | GLM-5.3 / GLM-5.3-Flash | 高难度编码 | 最多 |

**关键认知**：
- 按任务类型选，不按额度选
- ZCode GLM-5.3 没有多模态（调 GLM-4.7 工具效果差）
- ZCode GLM-5.3-Flash 听不到声音、智商最蠢

## 快速开始

### 安装 Git Hooks

**首次 clone 后必须运行**：

```bash
./scripts/install-hooks.sh
```

这会安装 pre-commit hooks 来强制执行：
- ✅ Matt 工作流（ticket 引用）
- ✅ writing-for-agents 原则（no-ops、negation、context pointers）

详见 [docs/GIT-HOOKS.md](docs/GIT-HOOKS.md)

### 示例工作流

```
用户："研究 React 19 新特性并生成示例"

你的响应：
1. [你] 写 spec ticket（.specs/react19-research.md）
2. [你] 启动 2 个并行任务：
   - Grok: Research React 19
   - Grok: Generate examples
3. [系统] 等 task-notification
4. [你] 审查质量（quality-checklist.md）
5. [你] 生成 PR description
6. [你] 写 review 报告
7. [你] 交付 HTML 报告（/answer-me-with-html）
```

## 选择逻辑

```
X 数据? → Grok Build（唯一）
多模态（听声音）? → Grok / Antigravity
多模态（快）? → Grok 4.7 Fast / Gemini 3.8
高难度编码? → ZCode GLM-5.3
顶级任务? → Antigravity Opus 4.6
默认 → Grok Build（全面、额度充足）
```

## 已验证性能数据

| 任务类型 | Grok Build | Antigravity | ZCode | 推荐 |
|---------|-----------|------------|-------|------|
| 结构化输出（JSON schema） | ✓ 120s | 未测 | 未测 | Grok Build |
| 外部工具集成 | ✓ 17.6s | 未测 | 未测 | Grok Build |
| 多步推理 | ✓ 50-52s | 未测 | 未测 | Grok Build |
| 代码生成（普通） | ✓ 50s | 未测 | 未测 | Grok Build |
| 代码生成（高难度） | 未测 | 未测 | 未测 | ZCode GLM-5.3 |
| 代码分析 | 未测 | 未测 | ✓ 67s | Grok Build / ZCode |
| 图片分析（快速） | ✓ 17.6s（通过 agy CLI） | 未测 | ✗ 慢且蠢 | Grok 4.7 Fast / Gemini 3.8 |
| 视频分析（有声音） | 未测 | 未测 | ✗ 听不到 | Grok Build / Antigravity |
| 视频分析（无声） | 未测 | 未测 | ✗ 蠢 | Grok 4.7 Fast / Gemini 3.8 |
| 顶级任务 | - | ✓ Opus 4.6 | - | Antigravity Opus 4.6 |

## 文件结构

```
orchestrator/
├── SKILL.md                    # 主 skill（职责/流程/选择逻辑）
├── README.md                   # 使用说明
├── .specs/                     # Spec tickets（留痕）
│   └── v0.1.3-fix-harness-capabilities.md
├── templates/                  # 4 个委派模板
│   ├── grok-research.md
│   ├── grok-codegen.md
│   ├── agy-analysis.md
│   └── zcode-analysis.md
└── references/                 # 参考文档
    ├── handoff-patterns.md     # 6个反模式+修复
    └── quality-checklist.md    # 结果质量审查清单
```

## Matt 流程

**目的：留痕迹，方便复盘**，不是规范开发。

每次修改：
1. 写 spec ticket（`.specs/<name>.md`）
2. 实现修改
3. 生成 PR description
4. 写 review 报告
5. Git commit（描述性 message）

**可选**：
- Grill（自己能决定的任务可以不用）

**必须**：
- Spec ticket
- PR description
- Review 报告

## 版本历史

- v0.1.0 (2026-10-16)：初始版本，基于三 harness 并行测试
- v0.1.1 (2026-10-16)：修正模型名称（Grok 4.6/Gemini 3.8/GLM-5.3）
- v0.1.2 (2026-10-16)：成本策略调整（补充完整模型列表）
- v0.1.3 (2026-10-16)：**能力边界修正**
  - ZCode GLM-5.3 没有多模态（调 GLM-4.7 工具效果差）
  - ZCode GLM-5.3-Flash 听不到声音、智商最蠢
  - 按任务类型选，不按额度选
  - 补充 Matt 流程说明（留痕迹目的）

## 参考

- [SKILL.md](SKILL.md)：完整流程
- [templates/](templates/)：4 个委派模板
- [references/](references/)：反模式和质量清单
