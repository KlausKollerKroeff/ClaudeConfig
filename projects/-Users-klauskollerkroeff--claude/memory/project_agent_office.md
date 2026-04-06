---
name: agent-office dashboard
description: Local web dashboard for managing Claude Code agent teams, built in session 9756f4d4
type: project
---

User built a local Express.js dashboard at `/Users/klauskollerkroeff/Documents/agent-office` to visualize and manage Claude Code agent teams. Server runs on port 3100.

**Features:** REST API for agents/teams, spawn agents via Terminal.app, walkable office map (WIP), agent description management.

**Manager Agent (Trevor):** Lives at `~/.claude/agents/trevor.md`. When spawned from dashboard with role="manager" or name="Trevor", launches with `claude --agent=trevor`. Trevor is extroverted, funny, respectful, sportish. He orchestrates teams — receives tasks, creates teams, assigns work, reports back.

**Worker Agents:** Can be hired from dashboard, spawn as regular `claude` sessions that read `~/.claude/CLAUDE.md` for context.

**Why:** User wanted a visual, walkable office interface where they can see all active agents, spawn new workers, and manage teams without CLI commands.

**How to apply:** When user mentions "agent office", "dashboard", "local application", or "walkable map", reference this project.

**Tech stack:** Express.js, vanilla JS frontend, `.command` files for process spawning, agent descriptions in `~/Documents/agent-office/agents.json`.