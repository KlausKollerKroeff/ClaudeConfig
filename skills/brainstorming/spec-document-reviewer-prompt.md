# Spec Document Review Checklist

Use this checklist to verify the spec is complete, consistent, and ready for implementation planning.
Apply after the spec document is written to docs/superpowers/specs/.

Run through each item inline — fix any issues before sending to the user for review.

## What to Check

| # | Category | What to Look For | Action if found |
|---|----------|------------------|-----------------|
| 1 | Completeness | TODOs, placeholders, "TBD", incomplete sections | Fill in or remove |
| 2 | Consistency | Internal contradictions, conflicting requirements | Align to one answer |
| 3 | Clarity | Requirements ambiguous enough to cause someone to build the wrong thing | Make explicit |
| 4 | Scope | Covers multiple independent subsystems, unfocused for a single plan | Suggest decomposition |
| 5 | YAGNI | Unrequested features, over-engineering | Remove |

## Calibration

**Only fix issues that would cause real problems during implementation planning.**
A missing section, a contradiction, or a requirement so ambiguous it could be
interpreted two different ways — those are fixes. Minor wording improvements,
stylistic preferences, and "sections less detailed than others" are not.
