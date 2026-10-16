# Grok Research 模板

用于搜索、调研、文献综述等任务。

## 基础模板

```
Research <topic>.

Requirements:
1. Search <specific sources> (e.g., official docs, academic papers, GitHub)
2. Focus on <specific aspects> (e.g., performance benchmarks, API changes, use cases)
3. Collect evidence from at least <N> independent sources
4. Output structured JSON:
   {
     "summary": "one-paragraph overview",
     "key_points": [
       {"point": "...", "source": "URL", "quote": "..."}
     ],
     "sources": ["URL1", "URL2", ...],
     "date_range": "YYYY-MM to YYYY-MM"
   }

Constraints:
- Only use information from <date range, e.g., 2024-2026>
- Cite specific URLs for every claim
- Ignore speculation and rumors
- Mark confidence level: high / medium / low
```

## 变体：X (Twitter) 数据搜索

```
Search X (Twitter) for <topic/hashtag/user>.

Requirements:
1. Collect tweets from <date range>
2. Filter by: <criteria, e.g., engagement > 1K, verified users only>
3. Extract:
   - Tweet text
   - Author
   - Engagement metrics (likes, retweets, replies)
   - Timestamp
4. Output structured JSON array

Use your X API access (as xAI product).
```

## 变体：对比调研

```
Compare <A> vs <B> across <dimensions>.

Requirements:
1. Research both <A> and <B> from official sources
2. Compare on:
   - <dimension 1>
   - <dimension 2>
   - <dimension 3>
3. Output structured JSON:
   {
     "comparison": [
       {"dimension": "...", "A": "...", "B": "...", "verdict": "..."}
     ],
     "recommendation": "which one for what use case"
   }

Cite sources for each comparison point.
```

## 变体：时间线调研

```
Build timeline of <event/technology evolution>.

Requirements:
1. Search historical records from <start year> to <end year>
2. Identify key milestones (releases, decisions, controversies)
3. Output structured JSON:
   {
     "timeline": [
       {"date": "YYYY-MM-DD", "event": "...", "impact": "...", "source": "URL"}
     ]
   }

Sort chronologically.
```
