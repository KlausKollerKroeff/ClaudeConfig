# Agent Office Dashboard

## Context
The user wants a local web app that shows all running Claude Code agents as people in an office workspace, with the ability to create and delete agents. Each agent is a "person" with a name and description.

## Architecture

**Backend**: Node.js + Express server
- Polls `~/.claude/teams/` directory for active teams
- Reads `~/.claude/teams/{team-name}/config.json` for member info
- Executes Claude CLI commands to create/destroy agents
- Serves static frontend files or uses a simple template engine

**Frontend**: HTML/CSS/JS (no framework needed for this scope)
- Office-themed layout with agent cards as "desks"
- Each card shows: name, role, status (working/idle/planning), description
- "Hire" button to create new agents
- "Fire" button to shut down agents
- Auto-refresh every 5 seconds

## Implementation Steps

### 1. Enable agent teams feature
- Add `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` to `settings.json` env section
- File: `~/.claude/settings.json`

### 2. Create backend server
- File: `~/.claude/office-dashboard/server.js`
- Endpoints:
  - `GET /api/agents` — returns list of all active agents across all teams
  - `POST /api/agents` — creates a new agent/team via Claude CLI
  - `DELETE /api/agents/:id` — shuts down a specific agent
  - `GET /api/teams` — returns list of active teams
  - `POST /api/teams` — creates a new team with specified structure

### 3. Create frontend
- File: `~/.claude/office-dashboard/public/index.html`
- Office-themed CSS with agent cards as desks/cubicles
- Status indicators (green=working, yellow=idle, blue=planning)
- Modal/dialog for creating new agents (form for name, role, description, team)
- JavaScript for API calls and auto-refresh

## Critical Files

- **Read**: `/Users/klauskollerkroeff/.claude/settings.json` — add env var
- **Create**: `~/.claude/office-dashboard/server.js` — backend server
- **Create**: `~/.claude/office-dashboard/public/index.html` — frontend UI
- **Create**: `~/.claude/office-dashboard/public/office.css` — styling
- **Create**: `~/.claude/office-dashboard/public/app.js` — frontend logic
- **Read dynamically**: `~/.claude/teams/{team}/config.json` — team state and members

## Data Flow

```
Filesystem (~/.claude/teams/) → server.js reads config.json → API → browser UI
Browser "Create Agent" button → app.js → POST /api/agents → server runs claude CLI → new team created
Browser "Delete Agent" button → app.js → DELETE /api/agents/:id → server sends cleanup command
```

## Agent Info Mapping
- Agent name → from config.json `members[].name`
- Status → inferred from team config state and task list status
- Role → from spawn prompt or subagent type if available
- Description → allow user to add/edit custom descriptions (stored in local JSON file)

## Verification

1. Run `node server.js` to start the dashboard
2. Open `http://localhost:3100` in browser
3. Create an agent team via CLI: `claude "explore this codebase"`
4. Verify agent appears on dashboard
5. Create new agent via dashboard UI
6. Delete agent via dashboard UI
