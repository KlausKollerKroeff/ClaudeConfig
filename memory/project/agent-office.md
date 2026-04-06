# Agent Office Dashboard

- **Project Path:** `/Users/klauskollerkroeff/Documents/agent-office`
- **Purpose:** Visual dashboard for Claude Code Agent Teams, displaying hired agents in a walkable office environment.
- **Implemented Features:**
  - Walkable office view with agent visualization
  - Agent velocity control (user preference: 5x slower)
  - Hiring flow integration
  - Agent list displayed below the map
  - Wake-up button for active agents (opens session, verifies if asleep/terminated)
  - Preference for running spawned agents in macOS background without visible terminal windows
- **Known Issues:**
  - Dashboard server frequently exits with code 143 (SIGTERM) on start/restart
  - Loading page experiences significant delays
  - Description input field for new agents is not clickable/interactive
- **Context:** Tied to `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` configuration. Manager agent "Trevor" created to coordinate sub-agents.
