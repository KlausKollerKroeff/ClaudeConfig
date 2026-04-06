---
name: office-improver
description: Iteratively improve the Agent Office dashboard through repeated review-fix-validate cycles. Use when the user wants to automatically polish and enhance the dashboard without manual intervention.
compatibility_mode: false
---

# Office Improver

Autonomous improvement cycle for the Agent Office dashboard at `localhost:3100`.

## Workflow

1. **Scout**: Read all dashboard files
   - `public/app.js` — frontend logic and canvas rendering
   - `public/office.css` — styling
   - `public/index.html` — structure
   - `server.js` — backend
   - `agents.json` — agent definitions

2. **Identify**: Find 1-2 concrete improvements per cycle
   - Visual polish (colors, spacing, animations)
   - UX improvements (buttons, hover states, transitions)
   - Performance (render loop optimization, debouncing)
   - Bug fixes (console errors, missing handlers)
   - Feature polish (tooltips, better labels, status badges)

3. **Pick the most impactful one** — small, testable, high-visibility changes.

4. **Apply**: Make ONLY that change. Don't fix everything at once.

5. **Validate**: Run `node -c public/app.js` to check syntax. Verify no regressions.

6. **Log**: Append what was changed to `improvements.log`.

7. **Repeat**: If more improvements are found, start the next cycle.

## Priority Order

1. Fix broken/invisible elements (player sprite, agent sprites, buttons)
2. Fix rendering performance (slow canvas, memory leaks)
3. Visual polish (colors, labels, overlays, animations)
4. UX additions (tooltips, hover effects, responsive layouts)
5. Nice-to-haves (more decorations, sound effects, confetti)

## Rules

- ALWAYS validate before moving to the next change
- NEVER break existing functionality
- Keep changes atomic — one issue per iteration
- If a change causes a regression, revert immediately
- Log every change for audit trail
