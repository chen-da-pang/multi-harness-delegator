# 质量审查清单

Sub-agent 返回结果后，orchestrator 必须审查质量再交付。

## 代码生成质量清单

### 必需项（不达标 → 重做）
- [ ] **语法正确**：代码能解析，无语法错误
- [ ] **功能完整**：实现了所有要求的功能
- [ ] **可运行**：测试通过或手动验证成功

### 应有项（缺失 → 补充或降级）
- [ ] **类型提示**：Python 有类型标注，TypeScript 有类型声明
- [ ] **错误处理**：网络请求/文件操作/解析有 try/catch 或 Result 类型
- [ ] **文档**：函数有 docstring / JSDoc
- [ ] **输入验证**：对外部输入有基本校验
- [ ] **测试**：至少有示例调用或单元测试

### 风格项（影响可读性）
- [ ] **命名**：变量/函数名清晰（不是 `a`, `foo`, `temp`）
- [ ] **长度**：函数 ≤50 行（超过 → 建议拆分）
- [ ] **注释**：复杂逻辑有解释
- [ ] **一致性**：与项目现有代码风格匹配

### 安全项（敏感场景必查）
- [ ] **无硬编码密钥**：不在代码里写 API key / password
- [ ] **SQL 参数化**：不拼接 SQL 字符串
- [ ] **路径验证**：文件操作限制在允许目录
- [ ] **输入清洗**：用户输入经过 escape / sanitize

---

## Research 质量清单

### 必需项
- [ ] **有来源**：每个关键事实都引用了 URL
- [ ] **来源可信**：官方文档 > 知名媒体 > 个人博客
- [ ] **信息最新**：符合时间范围要求（如 2024-2026）
- [ ] **结构化**：返回了要求的 JSON 格式

### 应有项
- [ ] **多来源验证**：重要结论有 ≥2 个独立来源
- [ ] **引用具体**：不只是域名，给出完整 URL
- [ ] **区分事实和观点**：明确哪些是已证实的，哪些是推测
- [ ] **数据完整**：没有"未找到"/"待补充"的空字段

### 深度项
- [ ] **有反例**：不只列支持观点的证据，也提相反声音
- [ ] **有时间线**：关键事件按时间排序
- [ ] **有量化**：性能/使用率等有具体数字，不是"很快"/"很多"

---

## 图片/视频分析质量清单

### 必需项
- [ ] **识别主体**：图中最重要元素被识别
- [ ] **情绪合理**：情绪判断符合视觉呈现（不是强行解读）
- [ ] **结构化**：返回了要求的 JSON 格式

### 应有项
- [ ] **颜色准确**：主色调描述合理（可目测验证）
- [ ] **文字提取**：图中文字被正确 OCR（如果有）
- [ ] **构图分析**：提到了构图特点（居中/三分/对称等）

### 深度项
- [ ] **细节丰富**：不只是"一个人"，而是"年轻女性，黑发，低头"
- [ ] **关联合理**：情绪推断有视觉依据（表情/姿态/色调）
- [ ] **批量一致**：多张图的分析标准统一

---

## 代码分析质量清单

### 必需项
- [ ] **函数列表完整**：主要函数都被识别
- [ ] **依赖正确**：external imports 列表无遗漏
- [ ] **架构判断**：给出了合理的架构模式标签

### 应有项
- [ ] **函数作用准确**：每个函数的 purpose 描述正确
- [ ] **依赖关系**：internal 调用关系准确
- [ ] **复杂度标注**：指出了长函数/高复杂度热点

### 深度项
- [ ] **模式识别**：识别了缓存/重试/熔断等策略
- [ ] **改进建议**：指出了可优化点
- [ ] **测试覆盖**：提到了哪些部分缺测试

---

## 不达标处理策略

### 必需项缺失 → 重做
```
重新委派同一 harness：
"Previous result missing <X>. Regenerate with:
- <specific requirement>
- <example of expected output>"
```

### 应有项缺失 → 补充
```
委派补充任务：
"Add <X> to the code at <path>:
- <specific addition>
Keep existing logic unchanged."
```

### 深度项缺失 → 降级使用
- 标注"基础版本"
- 告知用户哪些信息不完整
- 建议后续改进方向

---

## 自动化检查（可编程部分）

```python
# 代码检查示例
def check_code_quality(code: str) -> list[str]:
    issues = []
    if 'try' not in code and ('requests.' in code or 'open(' in code):
        issues.append("Missing error handling")
    if len([l for l in code.split('\n') if l.strip()]) > 200:
        issues.append("Code too long (>200 lines)")
    if 'def ' in code and '"""' not in code:
        issues.append("Missing docstrings")
    return issues

# Research 检查示例
def check_research_quality(data: dict) -> list[str]:
    issues = []
    if not data.get('sources'):
        issues.append("No sources cited")
    if len(data.get('sources', [])) < 2:
        issues.append("Only 1 source (need ≥2)")
    for point in data.get('key_points', []):
        if not point.get('source'):
            issues.append(f"Point '{point.get('point')}' has no source")
    return issues
```

---

## 审查耗时预算

- 代码生成（≤100 行）：30-60s 审查
- Research（≤10 来源）：60-90s 审查
- 图片分析（单张）：10-20s 审查
- 代码分析（≤500 行）：30-60s 审查

如果审查发现问题 → 重做耗时 ≈ 原任务耗时

**权衡**：审查时间 vs 错误成本
- 用户要看的交付物 → 严格审查
- 内部中间结果 → 快速检查
