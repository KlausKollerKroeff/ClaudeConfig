#!/bin/bash
# dream-trigger.sh — Stop hook that triggers local-dream every 5 sessions.
# Called automatically when a session ends (Stop hook).

set -euo pipefail

COUNTER_FILE="$HOME/.claude/.local-dream-session-counter"
DREAM_SCRIPT="$HOME/.claude/skills/local-dream/scripts/local-dream.sh"
LOG_FILE="$HOME/.claude/.local-dream-last-run.log"
SESSIONS_THRESHOLD=5

# Initialize counter if missing
if [ ! -f "$COUNTER_FILE" ]; then
  echo "0" > "$COUNTER_FILE"
fi

COUNTER=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNTER=$((COUNTER + 1))
echo "$COUNTER" > "$COUNTER_FILE"

# Run dream when threshold reached
if [ "$COUNTER" -ge "$SESSIONS_THRESHOLD" ]; then
  echo "0" > "$COUNTER_FILE"
  echo "" >> "$LOG_FILE"
  echo "== Dream triggered: $(date '+%Y-%m-%d %H:%M:%S') ==" >> "$LOG_FILE"
  bash "$DREAM_SCRIPT" >> "$LOG_FILE" 2>&1
fi

exit 0
