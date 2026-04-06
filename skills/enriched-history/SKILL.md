---
name: enriched-history
description: >
  Use this skill whenever the user wants to improve, enrich, or better organize their Claude Code session history, conversation log, or message tracking. Also triggers when the user asks about their past interactions, session summaries, "what did I do in session X?", or Auto Dream memory consolidation. This skill manages the enriched-history.jsonl file and session summaries that serve as the structured data source for Claude Code's Auto Dream consolidation engine.
---

# Enriched History

This skill manages structured history files that provide rich, categorized context far beyond Claude Code's default `history.jsonl`. These files are designed to work both as a queryable history and as the primary data source for Auto Dream's "Gather Signal" phase.

## Auto Dream Integration

Auto Dream is Claude Code's background memory consolidation system inspired by biological REM sleep. When enabled via `autoDreamEnabled: true` in settings.json, it spawns a background agent that runs a 4-phase consolidation cycle:

| Phase | What it does | How enriched history helps |
|-------|-------------|---------------------------|
| **1. Orient** | Reads MEMORY.md and memory directory, takes inventory | MEMORY.md can include stats and trends from enriched-history categories |
| **2. Gather Signal** | Grep-scans session transcripts for corrections, preferences, patterns | Enriched history entries are pre-classified — Auto Dream can grep for specific categories (`skill`, `config`, `code-write`) instead of parsing raw messages |
| **3. Consolidate** | Merges duplicates, converts relative dates, deletes contradicted facts | Enriched entries already have absolute timestamps and topic tags, reducing consolidation overhead |
| **4. Prune & Index** | Rebuilds MEMORY.md, keeps it under 200 lines | Category distribution data helps decide what memory topics deserve space vs. pruning |

**The key insight:** Raw `history.jsonl` only has `{display, timestamp, project, sessionId}` — no intent, no category, no topic. Auto Dream has to read full session transcripts to figure out what happened. With `enriched-history.jsonl`, every message is pre-tagged with category and topic, making the Gather Signal phase dramatically faster and more accurate.

## File Architecture

```
~/.claude/
├── history.jsonl                    # Default Claude Code history (thin)
├── enriched-history.jsonl           # Every message with category, topic, summary
├── session-summaries/               # One markdown per session
│   ├── {sessionId}.md
│   └── ...
└── memory/
    ├── MEMORY.md                    # Auto Dream rebuilds this index
    └── user/                        # Topic-specific memory files
        └── ...
```

## Enriched History Entry Schema

Each line in `enriched-history.jsonl` (compact JSON, one per line):

```json
{"display":"original message","category":"intent_category","summary":"A sum up you are going to do based on what the user asked.","project":"/path","sessionId":"uuid","timestamp":1775349518457,"context":{"topic":"high-level topic","isContinuation":false},"enrichmentLevel":"full"}
```

| Field | Type | Source |
|-------|------|--------|
| `display` | string | Original user message exactly as typed |
| `category` | string | Heuristic classification (12 categories) |
| `summary` | string | Same as display (upgraded to "full" when AI-enhanced) |
| `project` | string | Working directory from hook input |
| `sessionId` | string | UUID from Claude Code session |
| `timestamp` | number | Milliseconds epoch, from hook input |
| `context.topic` | string | Short topic label for topic clustering |
| `context.isContinuation` | boolean | True if message is <5 chars (ok, yes, etc.) |
| `enrichmentLevel` | string | `partial` (hook-only) or `full` (post-session AI enhancement) |

### Categories

| Category | When to use | Auto Dream memory type |
|----------|-------------|----------------------|
| `code-write` | Writing new code or adding functions | Project memory |
| `code-read` | Reading/understanding existing code | Codebase familiarity |
| `bug-fix` | Fixing errors, debugging, troubleshooting | Known issues/patterns |
| `refactor` | Improving code organization/clarity | Architecture decisions |
| `feature` | Adding new features or capabilities | Feature requirements |
| `question` | Asking for explanation, clarification | Knowledge gaps |
| `config` | Changing settings, plugins, hooks, MCP | User configuration preferences |
| `skill` | Creating, editing, or testing skills | Tool usage patterns |
| `info-lookup` | Searching external info (weather, news, docs, packages) | Research topics of interest |
| `exploration` | Browsing, testing, proving a concept | Experiment tracking |
| `command` | Slash commands (`/exit`, `/plugin`, `/memory`) | Session lifecycle |
| `conversation` | Casual chat, acknowledgments, "ok", "thanks" | Pruned aggressively by Auto Dream |

## How to Use

### When asked about past sessions

1. Read `history.jsonl` for raw message sequence
2. Read matching `{sessionId}.md` in `~/.claude/session-summaries/` if exists
3. Read `enriched-history.jsonl` entries for that sessionId
4. Present summary organized by category

### When asked to browse history

Filter `enriched-history.jsonl` by Session ID, project path, date range, category, or topic keyword.

### Enriching a backfill

```bash
# View recent entries by project
tail -n 50 ~/.claude/enriched-history.jsonl | jq -r '"\(.timestamp) | \(.category) | \(.display)"'

# Count entries by category
jq -r '.category' ~/.claude/enriched-history.jsonl | sort | uniq -c | sort -rn

# View entries for a specific session
jq -r 'select(.sessionId == "abc-123") | "\(.category): \(.display)"' ~/.claude/enriched-history.jsonl
```

### Backfilling old history

To enrich existing `history.jsonl` entries that predate the hooks (which have no enriched entries):

```bash
# Process each raw history entry through the classifier
while IFS= read -r line; do
  echo "$line" | bash /path/to/skills/enriched-history/scripts/enrich-history.sh 2>/dev/null
done < /path/to/old-session-history.jsonl
```

## Hook Architecture

Two hooks in `settings.json` automatically populate these files:

### UserPromptSubmit Hook (per-message enrichment)

Runs a shell classifier on every user message via `scripts/enrich-history.sh`:
- Receives hook input: `{session_id, prompt, pasted_contents}` from Claude Code
- Passes to `classify-message.sh` which categorizes by intent
- Appends single-line JSON to `~/.claude/enriched-history.jsonl`
- Runs in <50ms, never blocks the session

### Stop Hook (end-of-session summary)

Runs when session ends (`/exit`, ctrl+C, disconnect):
- Writes a markdown summary to `~/.claude/session-summaries/{sessionId}.md`
- Includes: time span, message count, category breakdown, files touched, key topics
- Upgrades all enriched-history entries for this session from `partial` to `full` level

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/classify-message.sh` | Heuristic message classifier (no LLM, <10ms) | Piped JSON in, enriched JSON out |
| `scripts/enrich-history.sh` | Hook wrapper — extracts prompt, classifies, appends | Called by UserPromptSubmit hook |
| `scripts/summarize-session.sh` | Writes session markdown summary | Called by Stop hook |
