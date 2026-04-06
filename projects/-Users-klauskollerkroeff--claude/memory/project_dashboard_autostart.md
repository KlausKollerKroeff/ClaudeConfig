---
name: Agent Office auto-starts on login
description: The Agent Office dashboard at localhost:3100 is always running via launchd
type: project
---

A launchd agent (`~/Library/LaunchAgents/local.agent-office.plist`) runs the Agent Office dashboard server automatically on login with `KeepAlive: true`.

**How to manage:**
- Stop: `launchctl bootout gui/$UID/local.agent-office`
- Start: `launchctl bootstrap gui/$UID ~/Library/LaunchAgents/local.agent-office.plist`
- Logs: `/tmp/agent-office.log` (stdout), `/tmp/agent-office-error.log` (stderr)

The server must be running for any agent spawning to work.