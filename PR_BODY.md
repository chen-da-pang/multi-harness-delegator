## Summary

修正 orchestrator skill 对视频分析能力的错误描述：

```diff
 任务需要多模态（看图/视频/听声音）？
-  └─ Yes & 需要听声音 → Grok Build / Antigravity
-  └─ Yes & 不需要听声音 → Grok 4.7 Fast / Gemini 3.8 Flash
+  └─ Yes & 需要看**视频** → ZCode GLM-5.3-Flash（唯一能看视频）
+  └─ Yes & 需要听**声音** → Grok Build / Antigravity（不支持视频）
+  └─ Yes & 只需要看**图片** → Grok 4.7 Fast / Gemini 3.8 Flash
   └─ No → 继续
```

**修正的错误**：
1. ❌ Grok/Antigravity **不支持视频**（之前说推荐它们做视频分析）
2. ✅ GLM-5.3-Flash 是**唯一能看视频的模型**（但听不到音频）
3. ⚠️ GLM-5.3-Flash 的"蠢"是指**非多模态任务**（代码/推理），不是多模态任务本身

**附加文件**（应独立提交）：
- Matt Pocock skills 配置（CLAUDE.md、docs/agents/*）
- v0.1.3 review 报告

---

## Evidence

**Before:**
```markdown
视频分析（有声音） | 未测 | 未测 | ✗ 听不到 | Grok Build / Antigravity
视频分析（无声）   | 未测 | 未测 | ✗ 蠢 | Grok 4.7 Fast / Gemini 3.8
```
❌ 推荐 Grok/Antigravity/Gemini 做视频任务（它们不支持视频）

**After:**
```markdown
视频分析（有声音）               | ✗ 不支持视频 | ✗ 不支持视频 | ⚠️ 能看但听不到 | ZCode GLM-5.3-Flash
视频分析（无声音/可接受无声）    | ✗ 不支持视频 | ✗ 不支持视频 | ✓ 能看 | ZCode GLM-5.3-Flash
```
✅ 正确指向唯一支持视频的模型

**新增反模式**：
```markdown
| 把视频任务给 Grok/Antigravity | 失败 | 不支持视频 | 用 ZCode GLM-5.3-Flash |
| 把代码任务给 GLM-5.3-Flash | 慢且蠢 | Flash 只擅长多模态 | 用 GLM-5.3 或 Grok |
```

---

## Merge Danger

**Door:** Two-way（文档修正，无破坏性）

**Blast Radius:** Documentation-only

影响范围仅限 orchestrator skill 的决策逻辑说明，不影响代码实现。如有错误可直接回滚或热修复。

**待改进**：
- ⚠️ Shotgun Surgery：视频能力信息重复在 4+ 处（能力描述、决策树、反模式表、测试表），建议提取单一能力矩阵表格作为唯一真相源
- 🔴 Scope Creep：215+ 行 Matt Pocock 配置应独立提交
