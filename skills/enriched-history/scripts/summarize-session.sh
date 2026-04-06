#!/bin/bash
# summarize-session.sh — runs on Stop hook after session ends.
# Writes a markdown summary to ~/.claude/session-summaries/{sessionId}.md
# and upgrades enriched-history entries from partial to full.
#
# Hook input on stdin: {"session_id": "abc", "stopReason": "user_exit" | "finished" | ...}

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENRICHED_FILE="$HOME/.claude/enriched-history.jsonl"
SUMMARIES_DIR="$HOME/.claude/session-summaries"

mkdir -p "$SUMMARIES_DIR"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // empty' 2>/dev/null || true)

[ -z "$session_id" ] && exit 0

# Filter entries for this session
entries=$(grep "\"sessionId\":\"$session_id\"\|\"sessionId\": \"$session_id\"" "$ENRICHED_FILE" 2>/dev/null || true)

if [ -z "$entries" ]; then
  # Create a minimal entry if no enriched entries exist
  echo '{"sessionId":"'"$session_id"'","category":"command","display":"(no enriched data available)"}' >> "$ENRICHED_FILE"
  entries=$(tail -1 "$ENRICHED_FILE")
fi

# Count messages
msg_count=$(echo "$entries" | wc -l | tr -d ' ')

# Category breakdown
categories=$(echo "$entries" | jq -r '.category' 2>/dev/null | sort | uniq -c | sort -rn || true)

# Time range
first_ts=$(echo "$entries" | head -1 | jq -r '.timestamp' 2>/dev/null || echo "0")
last_ts=$(echo "$entries" | tail -1 | jq -r '.timestamp' 2>/dev/null || echo "0")

# Project
project=$(echo "$entries" | head -1 | jq -r '.project' 2>/dev/null || echo "unknown")

# Unique topics
topics=$(echo "$entries" | jq -r '.context.topic // empty' 2>/dev/null | sort -u || true)

# Top topic (most messages)
top_topic=$(echo "$entries" | jq -r '.context.topic // empty' 2>/dev/null | sort | uniq -c | sort -rn | head -1 | sed 's/^ *//;s/ .*//' || echo "unknown")

# Build markdown summary
summary_md="# Session Summary — $session_id

## Overview
- **Time range:** $(date -r $((first_ts / 1000)) '+%Y-%m-%d %H:%M' 2>/dev/null || echo "N/A") — $(date -r $((last_ts / 1000)) '+%Y-%m-%d %H:%M' 2>/dev/null || echo "N/A")
- **Duration:** $(( (last_ts - first_ts) / 60000 )) minutes
- **Messages:** $msg_count
- **Project:** $project
- **Main topic:** $top_topic

## Categories
\`\`\`
$categories
\`\`\`

## Topics Covered
\`\`\`
$topics
\`\`\`

## Conversation Flow
$(echo "$entries" | jq -r '"- [\(.category)] \(.display)"' 2>/dev/null | head -20)
$(if [ "$msg_count" -gt 20 ]; then echo "...and $((msg_count - 20)) more messages"; fi)
"

# Write summary
echo "$summary_md" > "$SUMMARIES_DIR/${session_id}.md"

# Output as JSON for hook
jq -nc --arg summary "$summary_md" '{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": ""
  }
}' 2>/dev/null

exit 0
