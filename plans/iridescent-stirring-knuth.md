# Brainstorming Skill Improvement Plan

**Goal:** Fix issues in the brainstorming skill and its related files for accuracy and usability.

---

### Task 1: Reconcile Spec Review Flow

**Files to modify:**
- `skills/brainstorming/SKILL.md` (checklist + After the Design section)
- `skills/brainstorming/spec-document-reviewer-prompt.md`

**Changes:**
1. Decide: use the subagent dispatch OR inline review. Given the user already reviews manually, **use inline review + user review only** (simpler, fewer moving parts).
2. Replace step 7 in the checklist: remove mention of the subagent.
3. Update the "After the Design" section in SKILL.md to remove references to spec-document-reviewer-prompt.md as a dispatch target.
4. Keep `spec-document-reviewer-prompt.md` but add a deprecation note, or repurpose it as a manual review checklist the user can consult.

### Task 2: Remove/Replace Nonexistent Skill References

**Files to modify:**
- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`

**Changes:**
1. In brainstorming: remove the line referencing `elements-of-style:writing-clearly-and-concisely`.
2. In writing-plans: replace `superpowers:subagent-driven-development` and `superpowers:executing-plans` with actual available alternatives (offer inline execution or general-purpose agent dispatch).

### Task 3: Clarify Visual Companion Dependencies

**Files to modify:**
- `skills/brainstorming/SKILL.md`
- `skills/brainstorming/visual-companion.md`

**Changes:**
1. Add a clear note in SKILL.md that the Visual Companion requires external scripts (`start-server.sh`, `stop-server.sh`, `frame-template.html`, `helper.js`) to be available — currently these paths are ambiguous.
2. In visual-companion.md, make clear that users need to install/provide the visual companion server separately, or suggest using an alternative (e.g., browser-based mockup delivery via file://).

## Verification

1. Read each modified file and confirm no broken references remain
2. Confirm the checklist steps flow logically from start to finish
3. Confirm all referenced skills/commands actually exist or are clearly marked as optional
