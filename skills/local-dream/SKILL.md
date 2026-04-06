---
name: local-dream
description: >
  Run a local memory consolidation cycle (Auto Dream replica). Performs a 4-phase reflective pass over memory files: Orient, Gather Signal, Consolidate, Prune. Uses enriched-history.jsonl and session summaries as signal source, OpenRouter API for reasoning. Triggers on /dream. Also triggers automatically when the user asks about sleeping, dreaming, memory cleanup, consolidating memories, or cleaning up memory files. Runs automatically every 5 sessions via Stop hook.
---

# Local Dream

A local replica of Claude Code's Auto Dream feature — memory consolidation that runs during downtime, mirroring how biological brains consolidate memories during REM sleep.

## What it does

Performs a 4-phase reflective pass over your memory files:

| Phase | Description |
|-------|-------------|
| **1. Orient** | Reads MEMORY.md and surveys the memory directory to understand what already exists |
| **2. Gather Signal** | Reads enriched-history.jsonl (pre-classified entries from past 7 days), recent session summaries, current state of all memory files |
| **3. Consolidate** | Merges new learnings into existing topic files, converts relative dates to absolute, deletes contradicted facts, merges duplicates |
| **4. Prune & Index** | Rebuilds MEMORY.md index (kept under 200 lines), aggressively removes superseded knowledge |

## Memory Architecture

```
~/.claude/
├── memory/                          # Persistent memory (consolidation output)
│   ├── MEMORY.md                    # Index file, < 200 lines
│   ├── user/                        # User preferences, working style
│   ├── feedback/                    # Corrections, output preferences
│   ├── project/                     # Project-specific knowledge
│   └── reference/                   # External references, patterns
├── .local-dream-session-counter     # Auto-trigger counter
└── .local-dream-last-run.log        # Consolidation log
```

## How to use

- **Manual:** Type `/dream` to trigger a consolidation cycle now
- **Automatic:** Runs every 5 sessions via the Stop hook configured in settings.json

## How it works

1. **Shell script** gathers context: enriched history, session summaries, existing memory files
2. **Context** is sent to OpenRouter API with 4-phase consolidation instructions
3. **LLM** analyzes signal, decides create/update/delete operations, returns JSON
4. **Shell script** executes the file operations and reports results
