# Plan: Manager Agent that Orchestrates Teams

## Context

The user wants a **manager agent** that acts as their primary interface whenever they run `claude`. When the user gives a task, the manager distributes it to other agents/teams, organizing the work. This replaces the current flow where the user directly interacts with agents — now they talk to the manager, who coordinates everything.

## Architecture

The manager lives at `~/.claude/agents/manager.md` and is the default agent loaded when running `claude`. It operates by coordinating Claude Code **Teams** — each team is a separate session with workers that get assigned tasks.

## Files to Create

### 1. `~/.claude/agents/manager.md`
Agent definition file with YAML frontmatter and system prompt:
- **description**: "Orchestrates and manages agent teams. The default interface for all work."
- **tools**: Full tool access (can spawn agents, create teams, manage work)
- **Model**: Uses current settings (Qwen 3.6 via OpenRouter)

The system prompt defines the manager behavior:
- Always receive user tasks as the primary point of contact
- Break down tasks and create Teams for parallel work
- Monitor team progress via the task system
- Report back to user when work is complete
- Load enriched history and memory at session start for context

### 2. `~/.claude/CLAUDE.md`
Root CLAUDE.md that always loads when starting `claude` from home directory. Instructs:
- This session IS the manager agent
- On every task request, distribute to teams, don't do the work yourself
- Read memory from `~/.claude/memory/MEMORY.md` for context

## How It Works

```
User → `claude "build me a new feature"`
  → Manager receives the request
  → Manager creates a Team (e.g., "feature-implementation")
  → Manager spawns sub-agents (researcher, implementer, reviewer)
  → Manager assigns tasks and monitors progress
  → Manager reports completion to user
```

## Implementation Steps

1. Create `~/.claude/agents/manager.md` with agent definition and full system prompt
2. Create `~/.claude/CLAUDE.md` with manager boot instructions (loads enriched history + memory)
3. The CLAUDE.md includes a directive to use the enriched history and memory system on every session
4. Verify by running `claude` — the manager should load and be ready to receive commands

## Verification

1. Run `claude` with a test task like "tell me about my project"
2. Manager should greet, show available teams from memory, and ask what to work on
3. Run `claude "do X"` — manager should respond with a plan and offer to create teams
