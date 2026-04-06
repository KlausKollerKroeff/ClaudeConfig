#!/bin/bash
# local-dream.sh — Local memory consolidation (Auto Dream replica)
# Performs the 4-phase cycle: Orient, Gather Signal, Consolidate, Prune.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/memory"
ENRICHED_FILE="$CLAUDE_DIR/enriched-history.jsonl"
SUMMARIES_DIR="$CLAUDE_DIR/session-summaries"
HISTORY_FILE="$CLAUDE_DIR/history.jsonl"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# OpenRouter API config
OPENROUTER_URL="https://openrouter.ai/api/v1/chat/completions"
MODEL="qwen/qwen3.6-plus:free"
API_KEY=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // empty' "$SETTINGS_FILE" 2>/dev/null || true)

if [ -z "$API_KEY" ]; then
  echo "ERROR: No ANTHROPIC_AUTH_TOKEN found in settings.json"
  exit 1
fi

echo "=== Local Dream: Memory Consolidation ==="
echo ""

###############################################################################
# CREATE DIRECTORY STRUCTURE IF MISSING
###############################################################################
mkdir -p "$MEMORY_DIR/user" "$MEMORY_DIR/feedback" "$MEMORY_DIR/project" "$MEMORY_DIR/reference"

###############################################################################
# PHASE: ORIENT — Gather current state
###############################################################################
echo "[Orient] Surveying current memory..."

MEMORY_INDEX=""
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  MEMORY_INDEX=$(cat "$MEMORY_DIR/MEMORY.md")
fi

# Read all existing memory topic files
EXISTING_MEMORIES=""
for category_dir in user feedback project reference; do
  if [ -d "$MEMORY_DIR/$category_dir" ]; then
    while IFS= read -r -d '' f; do
      rel_path="${f#$MEMORY_DIR/}"
      EXISTING_MEMORIES="${EXISTING_MEMORIES}
--- FILE: $rel_path ---
$(cat "$f")
"
    done < <(find "$MEMORY_DIR/$category_dir" -name "*.md" -print0 2>/dev/null)
  fi
done

if [ -z "$EXISTING_MEMORIES" ]; then
  EXISTING_MEMORIES="<no existing memory files>"
else
  echo "  Found existing memory files"
fi

###############################################################################
# PHASE: GATHER SIGNAL — Collect enriched history and session data
###############################################################################
echo "[Gather Signal] Collecting recent activity..."

# Calculate cutoff: 7 days ago in milliseconds
CUTOFF_MS=$(date -v-7d +%s 2>/dev/null || date -d '7 days ago' +%s)
CUTOFF_MS=$((CUTOFF_MS * 1000))

# Gather enriched history entries (filter out conversation/continuation noise)
ENRICHED_ENTRIES=""
if [ -f "$ENRICHED_FILE" ] && [ -s "$ENRICHED_FILE" ]; then
  ENRICHED_ENTRIES=$(jq -c "select(.timestamp > $CUTOFF_MS and .category != \"conversation\")" "$ENRICHED_FILE" 2>/dev/null | head -100 || true)
fi

SESSION_COUNT=0
CATEGORY_STATS=""
if [ -f "$ENRICHED_FILE" ] && [ -s "$ENRICHED_FILE" ]; then
  SESSION_COUNT=$(jq -r '.sessionId // empty' "$ENRICHED_FILE" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  CATEGORY_STATS=$(jq -r '.category // empty' "$ENRICHED_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -20 || true)
fi

if [ -z "$ENRICHED_ENTRIES" ]; then
  ENRICHED_ENTRIES="<no enriched entries in past 7 days>"
else
  ENTRY_COUNT=$(echo "$ENRICHED_ENTRIES" | wc -l | tr -d ' ')
  echo "  Found $ENTRY_COUNT enriched entries from $SESSION_COUNT sessions"
fi

# Gather session summaries from past 7 days
SESSION_SUMMARIES=""
if [ -d "$SUMMARIES_DIR" ]; then
  SESSION_SUMMARIES=$(find "$SUMMARIES_DIR" -name "*.md" -mtime -7 -exec cat {} \; 2>/dev/null | head -200 || true)
fi
if [ -z "$SESSION_SUMMARIES" ]; then
  SESSION_SUMMARIES="<no recent session summaries>"
fi

###############################################################################
# BUILD PROMPT
###############################################################################
echo "[Consolidate] Sending to LLM..."

# Read the system prompt from the dedicated file
SYSTEM_PROMPT=""
if [ -f "/Users/klauskollerkroeff/.claude/skills/local-dream/prompts/consolidation.md" ]; then
  SYSTEM_PROMPT=$(cat "/Users/klauskollerkroeff/.claude/skills/local-dream/prompts/consolidation.md")
else
  echo "ERROR: Cannot find consolidation prompt"
  exit 1
fi

# Escape for JSON
SYSTEM_PROMPT_JSON=$(printf '%s' "$SYSTEM_PROMPT" | jq -Rs .)

# Build the user context message
USER_PROMPT="## Context for consolidation

### Current Memory Index (MEMORY.md)
\`\`\`
${MEMORY_INDEX:-<empty or missing>}
\`\`\`

### Existing Memory Topic Files
\`\`\`
${EXISTING_MEMORIES}
\`\`\`

### Enriched History Entries (past 7 days, non-conversation)
\`\`\`
${ENRICHED_ENTRIES}
\`\`\`

### Recent Session Summaries
\`\`\`
${SESSION_SUMMARIES}
\`\`\`

### Session Statistics
- Total unique sessions: ${SESSION_COUNT}
- Category breakdown:
\`\`\`
${CATEGORY_STATS:-<none>}
\`\`\`

---

Execute the 4-phase dream cycle now based on the system instructions. Return only valid JSON matching the schema described in the system prompt."

USER_PROMPT_JSON=$(printf '%s' "$USER_PROMPT" | jq -Rs .)

###############################################################################
# CALL OPENROUTER API
###############################################################################
RESPONSE=$(curl -s --max-time 90 \
  -H "Authorization: Bearer $API_KEY" \
  -H "HTTP-Referer: https://claude.ai" \
  -H "X-Title: local-dream" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"temperature\": 0.1,
    \"messages\": [
      {\"role\": \"system\", \"content\": $SYSTEM_PROMPT_JSON},
      {\"role\": \"user\", \"content\": $USER_PROMPT_JSON}
    ]
  }" "$OPENROUTER_URL")

# Check for API errors
API_ERROR=$(echo "$RESPONSE" | jq -r '.error?.message // empty' 2>/dev/null || true)
if [ -n "$API_ERROR" ]; then
  echo "ERROR: API returned: $API_ERROR"
  exit 1
fi

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null || true)

if [ -z "$CONTENT" ]; then
  echo "ERROR: No content in LLM response"
  exit 1
fi

# Strip markdown code fences if present
CONTENT=$(echo "$CONTENT" | grep -v '^```' || true)

# Validate JSON
echo "$CONTENT" | jq -e '.' >/dev/null 2>&1 || {
  echo "ERROR: LLM returned invalid JSON. First 200 chars:"
  echo "$CONTENT" | head -c 200
  exit 1
}

echo ""
echo "[Prune] Executing operations..."

# Print summary
SUMMARY=$(echo "$CONTENT" | jq -r '.summary // "No summary provided"' 2>/dev/null)
echo ""
echo "$SUMMARY"
echo ""

# CREATE operations
OP_COUNT=$(echo "$CONTENT" | jq -r '(.operations.create // []) | length' 2>/dev/null)
if [ "$OP_COUNT" -gt 0 ]; then
  for i in $(seq 0 $((OP_COUNT - 1))); do
    FILE_PATH=$(echo "$CONTENT" | jq -r ".operations.create[$i].path" 2>/dev/null)
    FILE_CONTENT=$(echo "$CONTENT" | jq -r ".operations.create[$i].content" 2>/dev/null)
    if [ -n "$FILE_PATH" ] && [ -n "$FILE_CONTENT" ]; then
      TARGET="$MEMORY_DIR/$FILE_PATH"
      mkdir -p "$(dirname "$TARGET")"
      printf '%s\n' "$FILE_CONTENT" > "$TARGET"
      echo "  CREATED: $FILE_PATH"
    fi
  done
fi

# UPDATE operations
OP_COUNT=$(echo "$CONTENT" | jq -r '(.operations.update // []) | length' 2>/dev/null)
if [ "$OP_COUNT" -gt 0 ]; then
  for i in $(seq 0 $((OP_COUNT - 1))); do
    FILE_PATH=$(echo "$CONTENT" | jq -r ".operations.update[$i].path" 2>/dev/null)
    FILE_CONTENT=$(echo "$CONTENT" | jq -r ".operations.update[$i].content" 2>/dev/null)
    if [ -n "$FILE_PATH" ] && [ -n "$FILE_CONTENT" ]; then
      TARGET="$MEMORY_DIR/$FILE_PATH"
      mkdir -p "$(dirname "$TARGET")"
      printf '%s\n' "$FILE_CONTENT" > "$TARGET"
      echo "  UPDATED: $FILE_PATH"
    fi
  done
fi

# DELETE operations
OP_COUNT=$(echo "$CONTENT" | jq -r '(.operations.delete // []) | length' 2>/dev/null)
if [ "$OP_COUNT" -gt 0 ]; then
  for i in $(seq 0 $((OP_COUNT - 1))); do
    FILE_PATH=$(echo "$CONTENT" | jq -r ".operations.delete[$i]" 2>/dev/null)
    if [ -n "$FILE_PATH" ]; then
      TARGET="$MEMORY_DIR/$FILE_PATH"
      if [ -f "$TARGET" ]; then
        rm "$TARGET"
        echo "  DELETED: $FILE_PATH"
      fi
    fi
  done
fi

# MEMORY.md
MEMORY_INDEX_CONTENT=$(echo "$CONTENT" | jq -r '.memory_index // empty' 2>/dev/null || true)
if [ -n "$MEMORY_INDEX_CONTENT" ]; then
  printf '%s\n' "$MEMORY_INDEX_CONTENT" > "$MEMORY_DIR/MEMORY.md"
  echo "  UPDATED: MEMORY.md"

  # Check line count
  LINE_COUNT=$(wc -l < "$MEMORY_DIR/MEMORY.md" | tr -d ' ')
  echo "  MEMORY.md lines: $LINE_COUNT (limit: 200)"
fi

echo ""
echo "=== Dream complete ==="
