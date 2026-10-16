# Grok Code Generation 模板

用于生成代码（≥50 行或需要多个函数的）。

## 基础模板

```
Generate <description> code.

Requirements:
- Language: <language>
- Must include:
  - Error handling (try/catch or Result types)
  - Type hints / type annotations
  - Docstrings / JSDoc comments
  - Input validation
- Write to: <file path>
- Test with: <command to verify it works>

Constraints:
- Match project style in <reference file path>
- Max <N> lines (split into multiple files if needed)
- No external dependencies unless explicitly approved
- Follow <specific style guide, e.g., PEP 8, Airbnb JS>

Output:
1. The generated code
2. Test output showing it works
3. Brief explanation of design decisions
```

## 变体：带 Schema 验证

```
Generate <description> with JSON schema validation.

Use --json-schema flag to enforce output structure:
{
  "type": "object",
  "properties": {
    "code": {"type": "string"},
    "tests": {"type": "array"},
    "dependencies": {"type": "array"}
  },
  "required": ["code", "tests"]
}

Requirements:
- Language: <language>
- Include type hints, error handling, docstrings
- Generate at least 3 test cases
- Write to: <path>
```

## 变体：重构现有代码

```
Refactor <file path>.

Goals:
1. <goal 1, e.g., Extract duplicate logic into shared function>
2. <goal 2, e.g., Add error handling to network calls>
3. <goal 3, e.g., Add type hints to all functions>

Constraints:
- Keep existing behavior unchanged (tests must still pass)
- Match project style
- Document why each change improves the code

Output:
1. Refactored code
2. Diff summary (what changed and why)
3. Test results showing all pass
```

## 变体：多文件生成

```
Generate <feature> across multiple files.

Structure:
- <file 1>: <purpose>
- <file 2>: <purpose>
- <file 3>: <purpose>

Requirements:
- Each file follows project conventions
- Include integration tests that exercise all files
- Write to: <directory>

Output:
1. All generated files
2. Integration test output
3. Architecture diagram (simple flow chart)
```
