# Antigravity CLI (agy) Analysis 模板

用于图片/视频内容分析，利用 Gemini 多模态能力。

**模型**：Gemini 3.8 Flash (Google)，1M 上下文，高推理级别

## 图片分析模板

```
Analyze image at <file path>.

Extract:
- Visual theme (e.g., dark/light, minimalist/complex, professional/casual)
- Dominant emotions (from closed set: <list emotions>)
- Key visual elements (people, objects, text, symbols)
- Color palette (top 3-5 dominant colors with hex codes)
- Text content (OCR if text is present)
- Composition style (centered, rule-of-thirds, symmetry, etc.)

Output structured JSON:
{
  "theme": "...",
  "emotions": ["emotion1", "emotion2"],
  "elements": [
    {"type": "person/object/text", "description": "...", "location": "..."}
  ],
  "colors": [
    {"name": "...", "hex": "#...", "percentage": 30}
  ],
  "text": "...",
  "composition": "..."
}

Use Gemini's native multimodal capabilities.
```

## 视频分析模板

```
Analyze video at <file path>.

Extract:
- Visual theme across the video
- Emotional arc (how emotions change over time)
- Key scenes (with timestamps)
- Dominant colors per scene
- Audio characteristics (if audio track exists)
- Pacing (fast/slow cuts, transitions)

Output structured JSON:
{
  "theme": "...",
  "emotional_arc": [
    {"timestamp": "00:00", "emotions": ["..."]},
    {"timestamp": "00:30", "emotions": ["..."]}
  ],
  "key_scenes": [
    {"timestamp": "00:15", "description": "...", "significance": "..."}
  ],
  "colors": [...],
  "pacing": "..."
}

Use Gemini's video understanding capabilities.
```

## 批量图片分析模板

```
Analyze all images in <directory>.

For each image:
- Theme
- Top 2 emotions
- Presence of faces (yes/no)
- Text content (if any)

Output structured JSON array:
{
  "images": [
    {"path": "...", "theme": "...", "emotions": [...], "has_faces": true, "text": "..."},
    ...
  ],
  "summary": {
    "total": 50,
    "dominant_theme": "...",
    "emotional_distribution": {"happy": 20, "sad": 15, ...}
  }
}

Process in parallel if possible. Use Gemini's batch processing if available.
```

## 封面图质量评估模板

```
Evaluate <file path> as a video/article cover.

Criteria:
- Visual appeal (1-10)
- Emotional impact (1-10)
- Clarity (is the subject clear?) (1-10)
- Composition quality (rule-of-thirds, balance) (1-10)
- Text legibility (if text present) (1-10)

Output structured JSON:
{
  "scores": {
    "appeal": 8,
    "impact": 7,
    "clarity": 9,
    "composition": 7,
    "text_legibility": 6
  },
  "overall_score": 7.4,
  "strengths": ["Strong emotional impact", "Clear subject"],
  "weaknesses": ["Text too small", "Composition slightly off-center"],
  "recommendation": "use as-is / crop / replace"
}
```

## 截图内容提取模板

```
Extract structured information from screenshot at <file path>.

Expected content type: <UI/dashboard/document/chart/etc>

Extract:
- All visible text (with bounding boxes if important)
- UI elements (buttons, forms, menus)
- Data visualization (if present: chart type, trends)
- Errors or alerts (if any)

Output structured JSON:
{
  "content_type": "...",
  "text": [
    {"text": "...", "location": "top-left/center/etc", "type": "heading/body/button"}
  ],
  "ui_elements": [
    {"type": "button", "label": "Submit", "state": "enabled/disabled"}
  ],
  "visualizations": [
    {"type": "line chart", "trend": "increasing", "data_points": 12}
  ],
  "alerts": ["Error: Connection failed"]
}
```

## 已验证能力（从并行测试）

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| 图片分析（视频封面） | ✓ | 17.6s | 识别视觉主题、情绪、颜色、确认无文字 |

**测试案例**：
- 文件：`7674506336575903461_cover.jpg`
- 识别：黑暗/电影感、绝望/脆弱/悲伤/孤立/痛苦、近黑色/石板蓝灰/淡米色
- 质量：细致、细腻、准确

## 使用建议

- **优先用于**：图片/视频分析（Gemini 3.8 多模态能力强）
- **上下文优势**：1M tokens（可处理大批量图片）
- **速度**：17.6s（已验证，快速）
- **命令行调用**：可作为 CLI 子进程集成到 Grok Build 任务中

## 与 Grok Build 集成

Grok Build 可以调用 Antigravity CLI 作为外部工具：

```python
# 在 Grok Build agent 中
import subprocess
import json

result = subprocess.run(
    ["agy", "analyze-image", "/path/to/image.jpg", "--output-json"],
    capture_output=True,
    text=True
)

analysis = json.loads(result.stdout)
# 使用 analysis 结果继续任务
```

这种集成模式已在并行测试中验证成功（17.6s）。
