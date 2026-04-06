#!/bin/bash
# enrich-history.sh — runs on each UserPromptSubmit hook.
# Takes hook input JSON on stdin, classifies the message, and appends to enriched-history.jsonl
#
# Hook input: {"session_id": "abc", "prompt": "..."}

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENRICHED_FILE="$HOME/.claude/enriched-history.jsonl"

input=$(cat)

# Extract fields from hook input
prompt=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null || true)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null || true)

# Build JSON to feed the classifier — include timestamp and project from this process
classifier_input=$(jq -nc \
  --arg display "${prompt:-}" \
  --arg sessionId "${session_id:-unknown}" \
  --arg project "$(pwd)" \
  --arg timestamp "$(date +%s000)" \
  '{
    display: $display,
    sessionId: $sessionId,
    project: $project,
    timestamp: ($timestamp | tonumber)
  }' 2>/dev/null)

# Classify the message
if [ -n "$classifier_input" ]; then
  enriched=$(echo "$classifier_input" | bash "$SCRIPT_DIR/classify-message.sh" 2>/dev/null)
  # Enrich further based on what we know
  if [ -n "$enriched" ] && echo "$enriched" | jq -e '.' >/dev/null 2>&1; then
    echo "$enriched" >> "$ENRICHED_FILE"
    # Return JSON to provide additionalContext to the model
    echo "$enriched" | jq -c '{
      "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": ""
      }
    }' 2>/dev/null
  fi
fi

exit 0
