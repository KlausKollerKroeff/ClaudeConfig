---
name: API issues
description: Brave search API returning 402 (payment required) and 429 (rate limit) errors
type: feedback
---

**Issue:** Brave search MCP tool is returning 402 errors ("payment required") and 429 rate limit errors. The auto-search skill was created to wrap Brave search but the underlying API key needs billing setup.

**Why:** User tried to test weather in Novo Hamburgo, Brazil and got API errors. Multiple failed attempts observed in session 51079045.

**How to apply:** Before using Brave search or suggesting web searches, check if the API key has been paid for. The `mcp__brave-search__brave_web_search` tool will fail with 402 until billing is resolved.
