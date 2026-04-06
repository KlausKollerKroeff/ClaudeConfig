#!/bin/bash
# classify-message.sh — takes a JSON user message on stdin, returns enriched JSON
# Usage: echo '{"display":"fix the bug","project":"/path"}' | ./classify-message.sh
# This is a simple heuristic classifier (no LLM — too slow for a hook)

input=$(cat)

display=$(echo "$input" | jq -r '.display // empty' 2>/dev/null)
project=$(echo "$input" | jq -r '.project // "/Users/klauskollerkroeff"'  2>/dev/null)
sessionId=$(echo "$input" | jq -r '.sessionId // "unknown"' 2>/dev/null)
timestamp=$(echo "$input" | jq -r '.timestamp // (now * 1000 | floor)' 2>/dev/null)

# Default if display is empty
: "${display:=no display}"
: "${project:=/Users/klauskollerkroeff}"
: "${sessionId:=unknown}"

lower=$(echo "$display" | tr '[:upper:]' '[:lower:]')

category="conversation"
summary="$display"
topic=""
is_continuation="false"

# Check for short/continuation messages
msg_len=${#display}
if [ "$msg_len" -lt 5 ]; then
  is_continuation="true"
  case "$lower" in
    *"exit"*|*"/exit"*)
      category="command"
      ;;
    ok|yes|yeah|sure|sure!|go|go!)
      category="conversation"
      topic="acknowledgment"
      ;;
  esac
# Check for slash commands
elif [[ "$lower" == /* ]]; then
  category="command"
  case "$lower" in
    *plugin*|*marketplace*) topic="plugin management" ;;
    *memory*) topic="memory management" ;;
    *model*) topic="model configuration" ;;
    *login*|*logout*) topic="authentication" ;;
    *config*) topic="configuration" ;;
    *skill*) topic="skill management" ;;
    *security*) topic="security" ;;
    *buddy*|*sticker*|*effort*) topic="misc" ;;
    *) topic="slash command" ;;
  esac
# Skill-related (before question — "skill" keyword trumps "can you")
elif [[ "$lower" =~ (skill) ]]; then
  category="skill"
  topic="working with skills"
# Info-lookup (before question — "weather", "latest", "version" are specific lookups)
elif [[ "$lower" =~ (search|find|look up|news|weather|latest|version|docs|doc|package|restaurant) ]]; then
  category="info-lookup"
  topic="searching for information"
# Code-related
elif [[ "$lower" =~ (create|make|build|add|write|implement|code|function|class|component|hook|script) ]]; then
  if [[ "$lower" =~ (fix|bug|error|issue|broke|wrong|broken|debug|troubleshoot) ]]; then
    category="bug-fix"
    topic="bug fix"
  else
    category="code-write"
    topic="implementing feature"
  fi
elif [[ "$lower" =~ (fix|bug|error|patch) ]]; then
  category="bug-fix"
  topic="fixing issue"
elif [[ "$lower" =~ (clean|refactor|simplify|organize|improve|better|cleanup|optimiz) ]]; then
  category="refactor"
  topic="code improvement"
elif [[ "$lower" =~ (explain.*code|understand.*code|can you read|how does|read.*code) ]]; then
  category="code-read"
  topic="understanding code"
elif [[ "$lower" =~ (config|setting|hook|plugin|install|mcp|api key|link|connect) ]]; then
  category="config"
  topic="configuration"
elif [[ "$lower" =~ (test|run|try|check|see if|execute|launch|start) ]]; then
  category="exploration"
  topic="testing/trying"
elif [[ "$lower" =~ (question|what|how|why|can you|tell me|please) ]]; then
  category="question"
  topic="asking question"
fi

# Build summary
if [[ -z "$topic" ]]; then
  topic="$summary"
  if [ "${#topic}" -gt 40 ]; then
    topic="${topic:0:40}..."
  fi
fi

# Output as JSON
jq -cn \
  --arg display "$display" \
  --arg category "$category" \
  --arg summary "$summary" \
  --arg project "$project" \
  --arg sessionId "$sessionId" \
  --arg timestamp "$timestamp" \
  --arg topic "$topic" \
  --arg isContinuation "$is_continuation" \
  '{
    display: $display,
    category: $category,
    summary: $summary,
    project: $project,
    sessionId: $sessionId,
    timestamp: ($timestamp | tonumber),
    context: {
      topic: $topic,
      isContinuation: ($isContinuation == "true")
    },
    enrichmentLevel: "partial"
  }' 2>/dev/null
