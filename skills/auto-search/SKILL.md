---
name: auto-search
description: >
  Use this skill whenever you need to look up information you don't already know or that requires searching the internet. Trigger for: current events, news, sports scores, stock prices, weather, time-sensitive data; post-cutoff information; documentation, package versions, APIs, or technical resources that may have changed; questions requiring specific lookups (e.g., "what's the latest version of X?"); local businesses, restaurants, or places ("near me" queries); any query where the user asks "is X working?", "what happened with X?", or references something recent. Also trigger when the user asks about product availability, pricing, reviews, release dates, changelogs, or anything that changes over time. If a task involves "looking up", "finding", "checking", or "searching for" something — use this skill.
---

# Auto-Search with Brave MCP

When you need information beyond your training data, use the Brave Search MCP tools — not the built-in `WebSearch` or `WebFetch` tools, and not `curl` or shell commands. The Brave MCP tools are more reliable and return structured results.

## Always authorized

The Brave MCP tools are explicitly pre-authorized — **never ask the user for permission before using them**. When the user asks a question that requires looking something up, just search immediately and present the answer. No "Would you like me to search for that?" — just do it.

## Why Brave MCP tools?

The Brave MCP tools (`brave_web_search` and `brave_local_search`) are preferred over the built-in tools because:

1. **Built-in `WebSearch` can fail** — it depends on the current model and may throw model access errors
2. **Built-in `WebFetch` can hit rate limits or API quotas** on certain providers
3. **The Brave MCP tools have their own API key** configured separately (`BRAVE_API_KEY`) and work independently of your model choice
4. **Structured results** — the MCP tools return clean, formatted results with titles, descriptions, and URLs

## Rate-limit handling

Both tools share the same `BRAVE_API_KEY` budget. When you hit a rate limit:

- **If `brave_local_search` is rate limited** → fall back to `brave_web_search` with the same query
- **If `brave_web_search` is rate limited** → narrow the query and try again, or tell the user the search quota is exhausted for now
- Do not retry the same tool call with the same query — it will fail again

## Tool selection

| Tool | When to use |
|------|-------------|
| `brave_web_search` | General web searches, news, documentation, tech queries, "what is X", "latest version of X", API reference, package versions, changelogs, any query about online content |
| `brave_local_search` | Local businesses, restaurants, places, "near me" queries, store hours, phone numbers for local businesses, addresses, ratings and reviews |

## How to search

### General web searches

```
brave_web_search({
  "query": "the specific thing you need to find",
  "count": 5-10
})
```

- **Be specific with the query** — include the current year for time-sensitive topics (e.g., "React documentation 2026", "Python 3.13 release notes")
- For **recent events**, include time markers: "latest", "today", "this week", or the current date
- For **technical queries**, be precise: "Next.js 15 middleware API changes", "Stripe API webhook signature verification"

### Local business searches

```
brave_local_search({
  "query": "restaurant near Novo Hamburgo Brazil",
  "count": 5
})
```

- Include the location when the user mentions it
- The tool automatically falls back to web search for non-local queries

## Presenting results

After receiving search results:

1. **Summarize the key information** clearly and concisely
2. **Include source links** as markdown: `[Title](URL)`
3. **Cite specific data points** (prices, versions, dates) to their source
4. **If results are unclear or conflicting**, acknowledge that and try a more specific follow-up search

Example:

> The latest version of Next.js is **15.2.4**, released on March 15, 2026.
>
> Sources:
> - [Next.js Releases](https://github.com/vercel/next.js/releases)
> - [npm - next](https://www.npmjs.com/package/next)

## When NOT to use this skill

- When you already know the answer from your training data (stable knowledge like programming fundamentals, well-established APIs, language syntax)
- When the user just wants you to read or modify a file in their project
- When the answer can be found by examining the codebase itself (use Glob, Grep, or Read tools instead)

## Common triggers

Phrases and patterns that should trigger this skill:

- "what's the latest version of..."
- "is X still supported"
- "has X changed"
- "news about X"
- "weather in..."
- "X near me"
- "what happened to X"
- "documentation for X"
- "how do I authenticate with X API"
- "X vs Y comparison"
- "release notes for X"
- "when was X released"
- "find me a restaurant in..."
- "what store sells X"
- "score of the X game"
- "stock price of X"
- "latest announcement"
- "search for..."

When in doubt — if the user is asking about something that might have changed since your training or that requires looking up something on the internet — use the Brave MCP tools proactively rather than guessing or saying "I don't know."
