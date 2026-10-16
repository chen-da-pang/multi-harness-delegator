# zcode Analysis 模板

用于代码分析和架构理解。

## 代码结构分析模板

```
Analyze code structure in <file path>.

Extract:
- Main functions/classes (name, purpose, signature)
- Architecture pattern (MVC, layered, microkernel, pipe-filter, etc.)
- External dependencies (imports, requires)
- Internal dependencies (which functions call which)
- Caching/optimization strategies
- Error handling approach

Output structured JSON:
{
  "functions": [
    {"name": "...", "purpose": "...", "signature": "...", "lines": "10-30"}
  ],
  "architecture": "...",
  "dependencies": {
    "external": ["lib1", "lib2"],
    "internal": [{"caller": "funcA", "callee": "funcB"}]
  },
  "patterns": ["caching", "retry logic", ...],
  "complexity_hotspots": ["function X is 200 lines", ...]
}

Use zcode ACP bridge at: /Users/wycm/Documents/ChatGPT/zcode-open-bridge-grok/packages/acp-bridge/zcode-acp-local
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
  "integrations": ["PostgreSQL", "Redis", ...]
}
```

## 依赖分析模板

```
Analyze dependencies in <project directory>.

Extract:
- Direct dependencies (from package.json / requirements.txt / Cargo.toml)
- Transitive dependencies (what your deps depend on)
- Outdated packages (current version vs latest)
- Security vulnerabilities (if detectable)
- Dependency graph (who depends on what)

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
  }
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

Output structured JSON:
{
  "issues": [
    {"type": "long_function", "name": "...", "lines": 120, "location": "file:42"},
    {"type": "duplicate", "instances": ["file1:10-20", "file2:30-40"]}
  ],
  "metrics": {
    "avg_function_length": 25,
    "max_complexity": 15,
    "test_coverage": "75%"
  },
  "recommendations": ["Extract funcX into smaller pieces", ...]
}
```
