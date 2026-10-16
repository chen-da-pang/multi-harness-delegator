# ZCode 任务模板

**优先使用 ZCode**（套餐额度最多），适合批量、长任务。

**模型选项**：
- **GLM-5.3** (Z.ai)：标准质量
- **GLM-5.3-Flash** (Z.ai)：更快但质量略低

**能力**：
- 1M 上下文、128K 输出
- 始终推理（3 档级别，无法关闭）
- 代码分析/生成、长文档处理
- **能看图片/视频**（但比 Antigravity 慢）

**套餐状态**：✓ 额度最多，应优先使用

## 代码结构分析模板

```
Analyze code structure in <file path>.

Extract:
- Main functions/classes (name, purpose, signature, line range)
- Architecture pattern (MVC, layered, microkernel, pipe-filter, event-driven, etc.)
- External dependencies (imports, requires)
- Internal dependencies (which functions call which)
- Caching/optimization strategies
- Error handling approach
- Concurrency patterns (if any)

Output structured JSON:
{
  "functions": [
    {"name": "...", "purpose": "...", "signature": "...", "lines": "10-30"}
  ],
  "classes": [
    {"name": "...", "purpose": "...", "methods": [...], "lines": "50-100"}
  ],
  "architecture": "...",
  "dependencies": {
    "external": ["lib1", "lib2"],
    "internal": [{"caller": "funcA", "callee": "funcB"}]
  },
  "patterns": ["caching", "retry logic", "connection pooling"],
  "complexity_hotspots": ["function X is 200 lines", "nested loops in Y"]
}

Use ZCode's code understanding capabilities via ACP bridge at:
/Users/wycm/Documents/ChatGPT/zcode-open-bridge-grok/packages/acp-bridge/zcode-acp-local
```

## 代码库地图模板

```
Build architecture map of <directory>.

Extract:
- Directory structure (modules/packages)
- Entry points (main, index, etc.)
- Key abstractions (core classes/interfaces)
- Data flow (how data moves through the system)
- External integrations (APIs, databases, file I/O)
- Configuration files

Output structured JSON:
{
  "structure": {
    "src/": {
      "utils/": ["file1.py", "file2.py"],
      "core/": [...]
    }
  },
  "entry_points": ["src/main.py"],
  "key_abstractions": [
    {"name": "Parser", "file": "...", "role": "..."}
  ],
  "data_flow": "linear / branching / circular",
  "integrations": [
    {"type": "database", "name": "PostgreSQL", "connection": "..."}
  ],
  "config_files": ["config.yml", ".env.example"]
}
```

## 依赖分析模板

```
Analyze dependencies in <project directory>.

Extract:
- Direct dependencies (from package.json / requirements.txt / Cargo.toml / go.mod)
- Transitive dependencies (what your deps depend on)
- Outdated packages (current version vs latest)
- Security vulnerabilities (if detectable)
- Dependency graph (who depends on what)
- License issues (GPL mixed with proprietary, etc.)

Output structured JSON:
{
  "direct": [
    {"name": "lodash", "version": "4.17.21", "latest": "4.17.21", "outdated": false}
  ],
  "transitive": [...],
  "vulnerabilities": [
    {"package": "...", "severity": "high", "fix": "upgrade to X"}
  ],
  "graph": {
    "lodash": ["internal-util", "api-handler"]
  },
  "license_issues": []
}
```

## 代码质量审查模板

```
Review code quality in <file path>.

Check:
- Function length (flag functions > 50 lines)
- Cyclomatic complexity (flag > 10)
- Duplicate code (similar blocks)
- Naming consistency
- Error handling coverage
- Test coverage (if tests exist)
- Documentation completeness

Output structured JSON:
{
  "issues": [
    {"type": "long_function", "name": "...", "lines": 120, "location": "file:42"},
    {"type": "duplicate", "instances": ["file1:10-20", "file2:30-40"]},
    {"type": "high_complexity", "name": "...", "complexity": 15}
  ],
  "metrics": {
    "avg_function_length": 25,
    "max_complexity": 15,
    "test_coverage": "75%",
    "documented_functions": "60%"
  },
  "recommendations": [
    "Extract funcX into smaller pieces",
    "Add error handling to Y",
    "Write tests for Z"
  ]
}
```

## 迁移影响分析模板

```
Analyze impact of migrating from <old tech> to <new tech> in <project>.

Identify:
- Files that directly use <old tech>
- Files that indirectly depend on it
- API surface that would change
- Tests that would need updates
- Configuration changes
- Estimated effort (file count, line count)

Output structured JSON:
{
  "direct_usage": [
    {"file": "...", "lines": [...], "usage_type": "import/call/extend"}
  ],
  "indirect_dependencies": [...],
  "api_changes": [
    {"old": "funcA()", "new": "funcB()", "affected_callers": 12}
  ],
  "test_updates": ["test/integration/..."],
  "config_changes": ["package.json", "tsconfig.json"],
  "effort_estimate": {
    "files": 45,
    "lines": 3200,
    "risk": "medium"
  }
}
```

## 性能瓶颈分析模板

```
Identify performance bottlenecks in <file path or directory>.

Look for:
- Nested loops (O(n²) or worse)
- Repeated database queries (N+1 problem)
- Large data loaded into memory
- Synchronous I/O in hot paths
- Missing indices (if DB schema visible)
- Inefficient algorithms

Output structured JSON:
{
  "hotspots": [
    {
      "location": "file:line",
      "issue": "nested loop",
      "complexity": "O(n²)",
      "impact": "high",
      "suggestion": "use hash map lookup"
    }
  ],
  "io_issues": [
    {"location": "...", "issue": "blocking file read in loop"}
  ],
  "db_issues": [
    {"query": "...", "issue": "missing index on user_id"}
  ]
}
```

## 已验证能力（从并行测试）

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| 代码分析（199行并发爬虫） | ✓ | 67s | 识别 7 个函数、两阶段架构、外部依赖、缓存策略 |

**测试案例**：
- 文件：`full_collect_tikhub.py`
- 识别：7 个函数、两阶段架构、`tikhub_transport` 依赖、缓存策略
- 桥接：通过 stdio 连接 ACP 桥
- 输出：结构化 JSON

## 图片/视频分析模板（ZCode 也能做）

```
Analyze image/video at <file path>.

Extract:
- Visual theme
- Dominant emotions
- Key elements
- Color palette

Output structured JSON.

Note: ZCode's GLM-5.3-Flash can handle images/videos but is slower than Antigravity's Gemini 3.8.
Use ZCode for batch analysis (cost-effective) or when not time-sensitive.
```

## 使用建议

- **优先用于**：大部分任务（额度最多 ✓）
  - 代码分析/生成
  - 长文档处理
  - 批量图片/视频分析（不急的）
  - 需要大输出的任务（128K 上限）
- **上下文优势**：1M tokens
- **输出优势**：128K tokens（可生成详细架构报告）
- **推理模式**：始终推理，3 档级别
- **多模态**：能看图片/视频，但比 Antigravity 慢

## 何时不用 ZCode

- X (Twitter) 数据 → 用 Grok Build（X API 访问权）
- 图片/视频需要快速结果（<20s）→ 用 Antigravity（Gemini 快）
- 关键任务需要最强模型 → 用 Antigravity Opus 4.6

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

| 能力 | ZCode | Grok Build | Antigravity |
|-----|-------|-----------|-------------|
| 代码分析 | ✓ 67s（验证） | 未测 | 未测 |
| 代码生成 | 未测 | ✓ 50s（验证） | 未测 |
| 长上下文 | 1M | 500K | 1M |
| 大输出 | 128K | 未知 | 未知 |
| 推理模式 | 始终开启 | 4 档可选 | 高级别可选 |

建议：
- 代码分析 → ZCode 或 Grok Build（都准确）
- 代码生成 → Grok Build（验证过质量）
- 长任务 → ZCode（长任务优化）
