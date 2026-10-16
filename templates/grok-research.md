# Grok Build 调研任务模板

**专长：X (Twitter) API 访问权、多模态快、额度充足**，默认选择。

**模型选项**：
- **Grok 4.6** (xAI)：标准质量
- **Grok 4.7** (xAI)：最新版本
- **Grok 4.7 Fast** (xAI)：快速模式

**能力**：
- ✓ **X (Twitter) API 访问权**（唯一）
- ✓ 多模态快（图片 17.6s 验证）
- ✓ 500K 上下文
- ✓ 4 档推理级别（包括 xhigh）
- ✓ Extended thinking（11K+ tokens）
- ✓ JSON schema 强制验证
- ✓ 子进程集成（可调用外部 CLI）
- ✓ 额度充足

**何时使用 Grok Build**：
- 需要 X (Twitter) 数据（唯一有 API）
- 快速图片/视频分析（验证过 17.6s）
- 需要 extended thinking（11K+）
- 需要 JSON schema 验证
- 默认选择（能力全面、额度充足）

## Research 模板

```
Research <topic>.

Requirements:
1. Search <specific sources>
2. Focus on <specific aspects>
3. Output structured JSON:
   {
     "summary": "...",
     "key_points": [...],
     "sources": [{"url": "...", "title": "...", "date": "..."}]
   }

Constraints:
- Only use information from 2024-2026
- Cite specific URLs
- Ignore speculation
- Verify facts from multiple sources

Use Grok's web search capability and extended thinking.
```

## X (Twitter) 数据采集模板

```
Collect X (Twitter) data about <topic>.

Requirements:
1. Search X posts from <date range>
2. Filter by <criteria>
3. Extract: username, post text, timestamp, likes, retweets, comments
4. Output structured JSON array

Constraints:
- Only verified information
- Respect rate limits
- No personal data beyond public posts

Use Grok's X API access (xAI is X's product).
```

## Extended Thinking 模板

```
<Complex reasoning task requiring deep analysis>

Requirements:
<detailed requirements>

Constraints:
- Use extended thinking (11K+ reasoning tokens)
- Show reasoning steps
- Verify conclusions

Use Grok's extended thinking capability for deep reasoning.
```

## 已验证能力

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| 结构化输出（JSON schema） | ✓ | 120s | 从 300 条评论提取情绪 |
| 外部工具集成 | ✓ | 17.6s | 调用 agy CLI 分析图片 |
| 多步推理 | ✓ | 50-52s | 对比文档、找差异 |
| 代码生成 | ✓ | 50s | 生产级代码带测试 |
| 图片分析 | ✓ | 17.6s | 通过 agy CLI |

## 与其他 Harness 对比

| 能力 | Grok Build | Antigravity | ZCode |
|-----|-----------|------------|-------|
| X API | ✓ 唯一 | - | - |
| 多模态 | ✓ 快 | ✓ Gemini 强 | ✗ GLM-5.3 无，GLM-5.3-Flash 蠢 |
| Extended thinking | ✓ 11K+ | - | ✓ 始终推理 |
| 编码 | ✓ 不错 | ✓ Opus 最强 | ✓ 高难度专长 |
| JSON schema | ✓ 有 | 未知 | 未知 |
| 额度 | 很多 | 普通 | 最多 |

**选择建议**：
- X 数据 → Grok Build（唯一）
- 图片/视频快速分析 → Grok 4.7 Fast 或 Antigravity Gemini
- 需要 extended thinking → Grok Build
- 默认选择 → Grok Build（能力全面、额度充足）
