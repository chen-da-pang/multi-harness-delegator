# Grok Build 代码生成模板

**专长：代码生成质量高、额度充足**，默认选择。

**模型选项**：
- **Grok 4.6** (xAI)：标准质量
- **Grok 4.7** (xAI)：最新版本

**能力**：
- ✓ 代码生成质量高（验证过）
- ✓ 类型提示、文档字符串、错误处理
- ✓ JSON schema 强制验证
- ✓ 500K 上下文
- ✓ Extended thinking（11K+）
- ✓ 额度充足

**何时使用 Grok Build**：
- 普通代码生成（验证过 50s）
- 需要 JSON schema 验证输出
- 需要 extended thinking
- 默认选择

**何时不用**：
- 高难度编码 → ZCode GLM-5.3 或 Antigravity Opus 4.6

## 代码生成模板

```
Generate <description> code.

Requirements:
- Language: <lang>
- Must include: error handling, type hints, docstrings
- Write to: <path>
- Test with: <test command>

Constraints:
- Match project style in <reference file>
- Max <N> lines
- No external dependencies unless: <list>

Output:
1. Write code to <path>
2. Run tests
3. Report results

Use Grok's code generation capability.
```

## 测试生成模板

```
Generate tests for <function/class> in <file>.

Requirements:
- Framework: <test framework>
- Coverage: edge cases, happy path, error cases
- Mock: <dependencies to mock>

Constraints:
- Match existing test style
- Each test: one assertion focus
- Clear test names

Use Grok for test generation.
```

## 已验证能力

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| Python 合并脚本 | ✓ | 50s | 类型提示、错误处理、测试 |
| 生产级代码 | ✓ | 50s | 质量高 |

## 与其他 Harness 对比

| 能力 | Grok Build | Antigravity | ZCode |
|-----|-----------|------------|-------|
| 普通编码 | ✓ 推荐 | ✓ Sonnet/Opus | ✓ 可以 |
| 高难度编码 | ✓ 不错 | ✓ Opus 最强 | ✓ 专长 |
| 代码质量 | ✓ 高 | ✓ Opus 最高 | ✓ 高（深度推理） |
| 速度 | 50s | 未测 | 未测 |
| 额度 | 很多 | 普通 | 最多 |

**选择建议**：
- 普通编码 → Grok Build（默认）
- 高难度编码 → ZCode GLM-5.3 或 Antigravity Opus 4.6
- 代码生成 → Grok Build（验证过）
