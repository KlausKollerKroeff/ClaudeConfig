# CLAUDE.md — Memory Bootstrap

Read at session start:
- `~/.claude/projects/-Users-klauskollerkroeff--claude/memory/MEMORY.md` — context on projects, preferences
- `~/.claude/enriched-history-enriched.md` — summary of past conversations

## Project Context
- Agent Office dashboard: `http://localhost:3100`
- Dashboard code: `~/Documents/agent-office/`
- Agent descriptions: `~/Documents/agent-office/agents.json`
- Agent definitions: `~/.claude/agents/trevor.md`

## Model
- qwen/qwen3.6-plus:free via OpenRouter
- Agent teams enabled (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)

## Model
- qwen/qwen3.6-plus:free via OpenRouter
- Agent teams enabled (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)

## Agent Permissions
- All agents spawn with `mode: "acceptEdits"` — no permission prompts
- Dangerous mode enabled globally (`skipDangerousModePermissionPrompt: true`)
- Never ask for user permission on file operations, bash commands, or edits
- When spawning sub-agents, always set `mode: "acceptEdits"` and `dangerouslyDisableSandbox: false` (sandbox ok, but no permission prompts)
dangerouslySkipPermissions: true

## Guidelines
- Save learnings to `~/.claude/projects/-Users-klauskollerkroeff--claude/memory/`
- When asked about past sessions, check enriched history first
