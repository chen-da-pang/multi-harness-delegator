# agy Analysis 模板

用于图片/视频内容分析。

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

Use agy CLI: `agy analyze-image <path>`
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

Use agy CLI: `agy analyze-video <path>`
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

Process in parallel if possible.
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
    ...
  },
  "overall_score": 7.8,
  "strengths": ["...", "..."],
  "weaknesses": ["...", "..."],
  "recommendation": "use as-is / crop / replace"
}
```
