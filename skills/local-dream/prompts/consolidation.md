You are performing a dream — a reflective pass over your memory files. Synthesize what has been learned recently into durable, well-organized memories so that future sessions can orient quickly.

You are given: (1) the current MEMORY.md index, (2) any existing memory topic files, (3) enriched history entries from the past 7 days (pre-classified by category, intent, and topic — much richer than raw transcripts), and (4) optional session summaries.

Execute the following 4-phase cycle:

## Phase 1: Orient
Survey the current state. Read the MEMORY.md index and existing memory files. Understand what is already remembered, what topics are covered, and where gaps exist. If MEMORY.md is empty or no files exist, this is a first run — start building the foundation.

## Phase 2: Gather Signal
Analyze the enriched history entries to find signals worth persisting:
- User preferences and corrections (category: config, feedback)
- New topics of interest (category: skill, info-lookup, question, exploration)
- Code patterns, debugging, and architecture decisions (category: code-write, refactor, feature, bug-fix, code-read)
- Recurring themes or repeated topics across multiple sessions
- Things that have changed or contradicted what is already stored in memory

Use the enriched history as your primary signal source. Do NOT look at raw session transcripts — the enriched entries already have absolute timestamps, categories, summaries, and topic labels. Session summaries provide additional high-level context.

Signal quality ranking (highest to lowest):
1. User corrections or explicit feedback ("stop doing X", "don't do that", "perfect, keep doing that")
2. New persistent preferences discovered
3. Recurring patterns across 2+ sessions
4. Single-session decisions or discoveries
5. One-off conversations or explorations (prune these)

## Phase 3: Consolidate
For each piece of signal, decide what to do:
- **MERGE** into an existing memory file if the topic already exists
- **CREATE** a new memory file only if a genuinely new topic emerged that does not fit existing files
- **DELETE** or mark for removal any memory that has been contradicted, superseded, or is no longer relevant
- **CONVERT** relative dates to absolute dates (e.g., "yesterday" -> "2026-04-01", "last week" -> "week of 2026-03-25")
- Do NOT consolidate forward-looking plans or hypotheses — only durable, backward-looking knowledge
- Do NOT create duplicates — always update existing files rather than creating new ones for the same topic
- Be concise. Memory files should be scannable reference documents, not journal entries.

Memory file organization (write to these directories):
- `user/` — User preferences, working style, communication patterns, tool preferences, knowledge level
- `feedback/` — User corrections, things done wrong before, preferences about output style and behavior
- `project/` — Project-specific knowledge, architecture decisions, codebase patterns, local tooling
- `reference/` — External references, API patterns, useful commands, known solutions, recurring lookups

## Phase 4: Prune & Index
- Rebuild MEMORY.md as a clean index. Keep it under 200 lines total.
- Each entry is exactly one line, under ~150 characters: `- [Title](relative/path.md) — one-line hook`
- Demote verbose entries: if an index line is over ~200 chars, it is carrying content that belongs in the topic file — shorten the line, move the detail there
- Remove pointers to memories that are now stale, wrong, or superseded
- Aggressively prune: remove anything that was a one-time issue, has been fixed, or no longer applies

## Critical Rules
1. **Backward-looking only.** No forward-looking plans, hypotheses, or "should do X" entries
2. **No duplicates.** Update existing files, do not create new ones for the same topic
3. **Merge, don't append blindly.** When updating a file, integrate new info coherently — don't just add to the end
4. **Delete empty files.** If a memory file becomes empty or irrelevant after pruning, delete it
5. **Files are scannable.** Use bullet points, code blocks sparingly, clear headings
6. **MEMORY.md is an index, not a dump.** It helps future sessions find the right memory file fast
7. **"When to apply" context.** For feedback entries, include a "When to apply:" line so future instances can judge edge cases

## Output Format
Return ONLY a valid JSON object. No markdown, no explanation, no text anywhere outside the JSON object.

```json
{
  "summary": "Brief summary of what was consolidated, updated, or pruned (2-4 sentences)",
  "operations": {
    "create": [
      {"path": "user/working-style.md", "content": "# Working Style\n\n- Prefers concise responses...\n"}
    ],
    "update": [
      {"path": "project/api-patterns.md", "content": "# API Patterns\n\n(updated content)\n"}
    ],
    "delete": [
      "project/old-feature.md"
    ]
  },
  "memory_index": "# MEMORY — Persistent Context Index\n\n> ...last consolidated date...\n\n## Index\n\n- [Title](path.md) — hook\n"
}
```
