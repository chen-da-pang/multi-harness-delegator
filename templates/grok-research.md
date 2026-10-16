# Grok Build Research 模板

用于搜索、调研、X (Twitter) 数据采集。

**模型**：Grok 4.6/4.7 (xAI)，500K 上下文，4 档推理级别

## 通用 Research 模板

```
Research <topic>.

Requirements:
1. Search <specific sources>
2. Focus on <specific aspects>
3. Output structured JSON:
   {
     "summary": "...",
     "key_points": [
       {"point": "...", "source": "URL", "date": "2026-XX-XX"}
     ],
     "sources": [
       {"url": "...", "title": "...", "credibility": "official/media/blog"}
     ]
   }

Constraints:
- Only use information from 2024-2026
- Cite specific URLs (not just domains)
- Ignore speculation or unverified claims
- Prefer official docs > known media > personal blogs
```

## X (Twitter) 数据采集模板

```
Search X (formerly Twitter) for <query>.

Requirements:
1. Use your X API access (xAI product advantage)
2. Time range: <date range>
3. Filter: <verified accounts / all / by engagement>
4. Extract:
   - Tweet text
   - Author info (username, verified, followers)
   - Engagement (likes, retweets, views)
   - Timestamp
   - Media attachments (URLs)

Output structured JSON:
{
  "query": "...",
  "time_range": "...",
  "results": [
    {
      "id": "...",
      "author": {"username": "...", "verified": true, "followers": 123456},
      "text": "...",
      "engagement": {"likes": 100, "retweets": 50, "views": 10000},
      "timestamp": "2026-10-16T10:00:00Z",
      "media": ["https://..."]
    }
  ],
  "summary": {
    "total_results": 50,
    "sentiment_distribution": {"positive": 20, "neutral": 15, "negative": 15}
  }
}

Do NOT fabricate tweets. Only return real data from X API.
```

## 对比研究模板

```
Compare <option A> vs <option B>.

Research dimensions:
1. Performance (benchmarks, real-world data)
2. Ease of use (learning curve, API design)
3. Community (adoption, ecosystem, support)
4. Cost (licensing, hosting, operational)
5. Maturity (release history, stability, breaking changes)

For each dimension:
- Find concrete data (not opinions)
- Cite sources
- Note recency (2024-2026 preferred)

Output structured JSON:
{
  "comparison": [
    {
      "dimension": "Performance",
      "option_a": {"score": "...", "evidence": "...", "source": "URL"},
      "option_b": {"score": "...", "evidence": "...", "source": "URL"},
      "winner": "A/B/tie"
    }
  ],
  "overall_recommendation": "..."
}
```

## 技术栈调研模板

```
Research <technology/framework> for <use case>.

Questions to answer:
1. What is it? (purpose, category, alternatives)
2. Who uses it? (notable adopters, case studies)
3. How mature is it? (first release, latest version, breaking changes)
4. What are its strengths? (unique features, benchmarks)
5. What are its weaknesses? (known issues, limitations)
6. How active is development? (commit frequency, issue response time)
7. What's the learning curve? (docs quality, tutorial availability)

Output structured JSON:
{
  "overview": {"name": "...", "category": "...", "first_release": "..."},
  "adopters": [{"company": "...", "source": "URL"}],
  "maturity": {"latest_version": "...", "stability": "production/beta/alpha"},
  "strengths": ["...", "..."],
  "weaknesses": ["...", "..."],
  "activity": {"commits_last_month": 50, "avg_issue_response": "2 days"},
  "learning_curve": "easy/medium/steep"
}
```

## 最佳实践汇总模板

```
Compile best practices for <topic>.

Sources to check:
- Official docs (language/framework guides)
- Well-known engineering blogs (Google, Meta, Netflix, etc.)
- Popular GitHub repos (>10K stars) with good practices
- Recent conference talks (2024-2026)

For each practice:
- Name it concisely
- Explain why it's recommended
- Give a code example (if applicable)
- Cite source

Output structured JSON:
{
  "best_practices": [
    {
      "name": "...",
      "rationale": "...",
      "example": "code snippet or description",
      "source": "URL",
      "adoption": "widely adopted / emerging / controversial"
    }
  ]
}
```

## 漏洞/安全研究模板

```
Research security vulnerabilities in <software/library>.

Requirements:
1. Search CVE databases, security advisories, GitHub security alerts
2. Time range: <date range>
3. For each vulnerability:
   - CVE ID (if assigned)
   - Severity (critical/high/medium/low)
   - Affected versions
   - Fixed version
   - Exploit availability (proof-of-concept exists?)
   - Mitigation steps

Output structured JSON:
{
  "vulnerabilities": [
    {
      "cve_id": "CVE-2026-XXXXX",
      "severity": "high",
      "affected_versions": "< 3.2.1",
      "fixed_version": "3.2.1",
      "description": "...",
      "exploit_available": true,
      "source": "URL"
    }
  ],
  "summary": {
    "total": 5,
    "critical": 1,
    "high": 2,
    "recommendation": "Upgrade to X.X.X immediately"
  }
}
```

## 已验证能力（从并行测试）

| 任务 | 结果 | 耗时 | 备注 |
|------|------|------|------|
| 结构化输出（JSON schema） | ✓ | 120s | 使用 `--json-schema` 强制验证 |
| 外部工具调用（agy CLI） | ✓ | 17.6s | 子进程集成成功 |
| 多步推理（文档对比） | ✓ | 50-52s | 4 次工具调用 |
| 扩展推理 | ✓ | - | 11K+ 推理 tokens |

## 使用建议

- **优先用于**：X 数据、深度推理、JSON schema 验证
- **推理级别**：默认 / high / xhigh / max（选择 xhigh 用于复杂问题）
- **上下文限制**：500K tokens（比 Antigravity/ZCode 的 1M 小）
- **无头模式**：使用 `--always-approve` 和管道输入
