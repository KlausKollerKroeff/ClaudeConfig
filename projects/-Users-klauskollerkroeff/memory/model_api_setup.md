---
name: Model & API setup
description: API provider, model choice, and known authentication issues
type: reference
---

**Model:** qwen/qwen3.6-plus:free via OpenRouter (Alibaba Qwen). This is a non-Anthropic model.

**Why:** User is using OpenRouter's free tier for the Qwen model rather than direct Anthropic API access.

**Known issues:**
- Context management features are unavailable (requires Anthropic provider). Error observed 2026-04-05: "No endpoints available that support Anthropic's context management features."
- Brave search MCP returns 402 (payment required) and 429 (rate limit) errors.
- Earlier session (2026-04-02) showed "bad credentials" authentication error.

**How to apply:** Don't rely on context management for session persistence. Check Brave search status before suggesting web searches.
