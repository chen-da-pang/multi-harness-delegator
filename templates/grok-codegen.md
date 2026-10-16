# Grok Build Code Generation 模板

用于代码生成任务。

**模型**：Grok 4.6/4.7 (xAI)，500K 上下文，4 档推理级别

## 通用代码生成模板

```
Generate <description> code.

Requirements:
- Language: <lang>
- Must include: error handling, type hints, docstrings
- Write to: <path>
- Test with: <test command>

Constraints:
- Match project style in <reference file>
- Max 200 lines (split into modules if needed)
- No external dependencies unless approved

Output:
1. Write code to file
2. Run tests
3. Report: file path, test result, any issues
```

## 带测试的代码生成模板

```
Generate <description> code with tests.

Requirements:
- Implementation file: <path>
- Test file: <test_path>
- Test framework: <pytest/jest/cargo test/etc>

Implementation must include:
- Type hints / type declarations
- Error handling (try/catch, Result types, etc.)
- Docstrings / JSDoc
- Input validation

Tests must include:
- Happy path (normal inputs)
- Edge cases (empty, null, boundary values)
- Error cases (invalid inputs)

Workflow:
1. Write implementation
2. Write tests
3. Run tests
4. If tests fail: fix and re-run
5. Report: both file paths, test coverage, final status
```

## 脚本生成模板

```
Generate a <language> script that <task>.

Requirements:
- Shebang (if applicable)
- Usage help (--help flag)
- Input validation
- Error messages to stderr
- Exit codes (0 = success, 1 = error)

Example usage:
<show how the script will be invoked>

Constraints:
- Single file
- Standard library only (no external deps)
- Must handle missing files/network errors gracefully

Output:
1. Write script to <path>
2. Make executable (chmod +x)
3. Test with example inputs
4. Report: file path, test result
```

## 重构模板

```
Refactor <file path> to <goal>.

Current issues:
- <issue 1>
- <issue 2>

Refactoring goals:
- <goal 1>
- <goal 2>

Constraints:
- Keep existing functionality (no behavior changes)
- Preserve public API
- Add tests if missing

Workflow:
1. Read current code
2. Write tests (if missing)
3. Refactor
4. Run tests
5. Report: diff summary, test status
```

## API 客户端生成模板

```
Generate an API client for <API name>.

Endpoints to cover:
- <endpoint 1>: <method> <path>
- <endpoint 2>: <method> <path>

Client requirements:
- Base URL configuration
- Authentication (API key / OAuth / Bearer token)
- Timeout handling
- Retry logic (exponential backoff)
- Type-safe request/response (TypeScript interfaces / Python dataclasses)
- Error handling (network errors, rate limits, validation errors)

Output structured code:
1. Client class
2. Type definitions
3. Example usage
4. Tests for at least 2 endpoints
```

## 数据处理管道模板

```
Generate a data processing pipeline: <input> → <output>.

Pipeline stages:
1. <stage 1>: <description>
2. <stage 2>: <description>

Requirements:
- Handle missing data gracefully
- Log progress (at least at stage boundaries)
- Error handling (retry transient errors, fail fast on permanent errors)
- Resumability (can continue from last successful stage)

Output:
1. Main pipeline file
2. Tests with sample data
3. Example run
```

## 已验证能力（从并行测试）

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| Python 合并脚本生成 | ✓ | 50s | 生产级代码带测试、类型提示、错误处理 |

## 生成质量标准

**必须包含**：
- [ ] 类型提示 / 类型声明
- [ ] 错误处理
- [ ] 文档字符串
- [ ] 可运行（测试通过）

**应该包含**：
- [ ] 输入验证
- [ ] 单元测试
- [ ] 示例用法

## 使用建议

- **优先用于**：需要深思熟虑的代码（算法、复杂逻辑）
- **推理级别**：默认或 high（代码生成通常不需要 xhigh）
- **验证方式**：生成后立即运行测试
- **失败处理**：如果测试失败，明确指出错误信息重新生成
