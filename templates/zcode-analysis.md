# ZCode 任务模板

**专长：高难度编码任务**，不适合多模态。

**模型选项**：
- **GLM-5.3** (Z.ai)：标准质量，**高难度编码专长**
- **GLM-5.3-Flash** (Z.ai)：更快但**智商最蠢**

**能力边界（重要）**：

**GLM-5.3**：
- ✓ 高难度编码任务（这是它的专长）
- ✓ 1M 上下文、128K 输出
- ✓ 始终推理（3 档级别，无法关闭）
- ✗ **没有多模态能力**
  - 看图是通过调用 GLM-4.7 工具实现，**效果非常差**
  - 不要把需要看图/视频的任务交给它
  - 如果必须用它处理有图片的任务 → 先用 Grok/Antigravity 看完，用文字描述给它

**GLM-5.3-Flash**：
- ✓ 能看图片/视频
- ✗ **听不到声音**
- ✗ **智商最蠢**（在所有模型中最蠢）
- ✗ 速度不快（不如 Gemini 3.8 Flash、Grok 4.7 Fast）
- 建议：不要用，除非没有其他选择

**套餐状态**：额度最多，但不意味着优先使用

## 何时使用 ZCode

**唯一推荐场景**：高难度编码任务
- 复杂算法实现
- 性能优化
- 架构重构
- 需要深度推理的代码生成

**不要用于**：
- 图片/视频分析 → 用 Grok/Antigravity
- 需要听声音的任务 → 用 Grok/Antigravity
- 普通编码任务 → 用 Grok Build（也不错）
- 多模态任务 → GLM-5.3 没有多模态，GLM-5.3-Flash 太蠢

## 代码分析模板

```
Analyze code structure in <file path>.

Extract:
- Main functions/classes (name, purpose, signature, line range)
- Architecture pattern
- External dependencies
- Caching/optimization strategies
- Error handling approach
- Complexity hotspots

Output structured JSON:
{
  "functions": [...],
  "architecture": "...",
  "dependencies": {...},
  "patterns": [...],
  "complexity_hotspots": [...]
}

Use ZCode's GLM-5.3 for deep code understanding.
```

## 高难度代码生成模板

```
Generate <description> code.

Requirements:
- Language: <lang>
- Complexity: high (algorithms/optimization/architecture)
- Must include: error handling, type hints, docstrings, tests
- Performance constraints: <if any>

Constraints:
- Match project style in <reference file>
- Optimize for <metric>

Use ZCode's GLM-5.3 for complex code generation with deep reasoning.
```

## 变通方案（有图片时）

```
[Step 1: 先用 Grok/Antigravity 看图]
Agent({ name: "grok-analyze-image", prompt: "Analyze <image>. Describe what you see in text." })

[Step 2: 等结果]

[Step 3: 用文字描述给 ZCode]
Agent({ 
  name: "zcode-implement", 
  prompt: "Implement <complex algorithm> based on this diagram:
  
  [Paste text description from step 1]
  
  <complex requirements>"
})
```

## 已验证能力

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| 代码分析（199行并发爬虫） | ✓ | 67s | 识别 7 个函数、两阶段架构、外部依赖、缓存策略 |
| 高难度编码 | 未测 | - | 用户反馈：这是它的专长 |

## ACP 桥集成

ZCode 通过 ACP 桥集成：

```bash
# ACP 桥路径
/Users/wycm/Documents/ChatGPT/zcode-open-bridge-grok/packages/acp-bridge/zcode-acp-local

# 使用方式
# 在 agent prompt 中指定使用 ZCode，系统会自动通过 ACP 桥调用
```

**注意事项**：
- 需要 ZCode 账户余额
- ACP 桥比直接 CLI 增加延迟
- stdio 通信，返回结构化 JSON

## 与其他 Harness 对比

| 能力 | ZCode GLM-5.3 | Grok Build | Antigravity |
|-----|--------------|-----------|-------------|
| 高难度编码 | ✓ 专长 | ✓ 也不错 | ✓ Opus 4.6 最强 |
| 普通编码 | ✓ 可以 | ✓ 推荐 | ✓ Sonnet 4.6 |
| 多模态 | ✗ 无（调 GLM-4.7 效果差） | ✓ 有 | ✓ Gemini 强 |
| 长上下文 | 1M | 500K | 1M |
| 大输出 | 128K | 未知 | 未知 |

**选择建议**：
- 高难度编码 → ZCode GLM-5.3 或 Antigravity Opus 4.6
- 普通编码 → Grok Build（默认）
- 代码分析 → Grok Build / ZCode GLM-5.3
- 有图片/视频 → Grok Build / Antigravity（不要用 ZCode）
