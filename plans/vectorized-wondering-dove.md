# Complete the Local Dream Implementation

## Remaining Steps

### 1. Make scripts executable
- `chmod +x` on `scripts/local-dream.sh` and `scripts/dream-trigger.sh`

### 2. Update settings.json Stop hook
- Add the `dream-trigger.sh` command to the existing Stop hooks array (merge alongside the existing Stop hook for session summaries)

### 3. Validate JSON and test
- Run a manual `/dream` to verify the full 4-phase cycle works

## Files Created (already done)
- `~/.claude/skills/local-dream/SKILL.md` - Skill definition
- `~/.claude/skills/local-dream/scripts/local-dream.sh` - Main orchestrator
- `~/.claude/skills/local-dream/prompts/consolidation.md` - 4-phase AI consolidation prompt
- `~/.claude/skills/local-dream/scripts/dream-trigger.sh` - Auto-trigger on every 5th session end

## Files to Modify
- `~/.claude/settings.json` - Add Stop hook for dream-trigger.sh

## Verification
- Run `bash ~/.claude/skills/local-dream/scripts/local-dream.sh` manually
- Confirm MEMORY.md is created, memory files are populated
- Open with /hooks to verify hook is active, or restart session to trigger automatically
