# Antigravity (agy) 任务模板

**专长：多模型选择**，可选 Gemini、Claude Sonnet、Claude Opus。

**模型选项**：
- **Gemini 3.8 Flash** (Google)：快速多模态，图片/视频分析强
- **Claude Sonnet 4.6** (Anthropic)：平衡性能
- **Claude Opus 4.6** (Anthropic)：顶级模型，最强智商

**能力**：
- ✓ 1M 上下文
- ✓ Gemini 多模态强且快
- ✓ 可选顶级 Opus 4.6
- ✓ MCP 支持
- ✓ Go 性能

**模型智商排序**：
1. Claude Opus 4.6 ← 最强
2. Claude Sonnet 4.6
3. Gemini 3.8 Flash

## 何时使用 Antigravity

**推荐场景**：
- 快速图片分析（Gemini 3.8 Flash）
- 快速视频分析（Gemini 3.8 Flash）
- 需要顶级模型的任务（Opus 4.6）
- 多模态任务（Gemini 专长）

**模型选择建议**：
- 图片/视频分析 → Gemini 3.8 Flash（17.6s 验证过）
- 顶级任务 → Opus 4.6
- 平衡任务 → Sonnet 4.6

## 图片分析模板

```
Analyze image at <file path>.

Extract:
- Visual theme
- Dominant emotions (from closed set: joy, sadness, anger, fear, surprise, neutral, despair, vulnerable, isolated, pain)
- Key visual elements
- Color palette (specific hex codes or descriptive names)
- Text content (if any)

Output structured JSON:
{
  "theme": "...",
  "emotions": [...],
  "elements": [...],
  "colors": [...],
  "text": "..."
}

Use Antigravity's Gemini 3.8 Flash for fast multimodal analysis.
```

## 视频分析模板

```
Analyze video at <file path>.

Extract:
- Main subjects/actions
- Scene changes (timestamps)
- Mood progression
- Audio content (if any)
- Key frames (timestamps + descriptions)

Output structured JSON:
{
  "subjects": [...],
  "scenes": [...],
  "mood_progression": [...],
  "audio_summary": "...",
  "key_frames": [...]
}

Use Antigravity's Gemini 3.8 Flash for multimodal video analysis.
```

## 顶级任务模板

```
<Complex task requiring highest intelligence>

Requirements:
<detailed requirements>

Use Antigravity's Claude Opus 4.6 for maximum capability.
```

## 已验证能力

| 任务 | 模型 | 结果 | 耗时 | 备注 |
|------|------|------|------|------|
| 图片分析 | Gemini（通过 agy CLI） | ✓ | 17.6s | 识别主题、情绪、颜色、文字 |
| 视频分析 | 未测 | - | - | 应该也快 |
| 顶级任务 | Opus 4.6 | 未测 | - | 理论上最强 |

## CLI 集成

Antigravity 可以通过 `agy` CLI 调用：

```bash
# 图片分析示例（通过 Grok 子进程调用）
agy analyze <image_path> --output-json

# 返回结构化 JSON
```

## 与其他 Harness 对比

| 能力 | Antigravity | Grok Build | ZCode |
|-----|------------|-----------|-------|
| 图片分析 | ✓ 快（17.6s） | ✓ 快 | ✗ 慢且蠢 |
| 视频分析（有声） | ✓ 有 | ✓ 有 | ✗ 听不到 |
| 视频分析（无声） | ✓ 快 | ✓ 快 | ✗ 蠢 |
| 顶级模型 | ✓ Opus 4.6 | - | - |
| 编码 | ✓ Sonnet/Opus | ✓ 不错 | ✓ 高难度专长 |
| X API | - | ✓ 有 | - |

**选择建议**：
- 图片/视频分析 → Antigravity Gemini 3.8 或 Grok 4.7 Fast
- 顶级任务 → Antigravity Opus 4.6
- 普通任务 → Grok Build（默认）
- 高难度编码 → ZCode GLM-5.3 或 Antigravity Opus 4.6
