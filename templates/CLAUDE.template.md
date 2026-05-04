# CLAUDE.md

Auto-loaded context for Claude Code in **{{PROJECT_NAME}}**. Project-wide conventions and operating rules.

> 📝 This file was bootstrapped from a template. Replace every `{{PLACEHOLDER}}` below with project-specific content. Markers are intentionally loud so they're easy to grep.

## Project Overview

**{{PROJECT_NAME}}** — {{ONE_LINE_DESCRIPTION}}

Tech stack: {{TECH_STACK}}

## Quick reference

| What | Command |
|------|---------|
| Run tests | `{{TEST_CMD}}` |
| Lint | `{{LINT_CMD}}` |
| Format | `{{FORMAT_CMD}}` |
| Build | `{{BUILD_CMD}}` |
| Dev server | `{{DEV_CMD}}` |
| Entry point | `{{ENTRY_POINT}}` |

## Conventions

- {{CONVENTION_1 — e.g. "All public APIs documented with TSDoc"}}
- {{CONVENTION_2 — e.g. "Errors propagate up, never swallowed silently"}}
- {{CONVENTION_3 — e.g. "Database access only through repository layer"}}

## Architecture

{{ARCHITECTURE_NOTES — high-level layering, key boundaries, where state lives.

For example:
- `src/api/` — HTTP layer, no business logic
- `src/domain/` — pure business logic, no I/O
- `src/infra/` — DB, external APIs, side-effecting code
- Dependency direction: api → domain → infra (never reverse)
}}

## Workflow notes for Claude

- {{WORKFLOW_NOTE_1 — e.g. "Run tests after every change in src/"}}
- {{WORKFLOW_NOTE_2 — e.g. "Use /commit then /pr for changes; /ship before merge"}}
- {{WORKFLOW_NOTE_3 — e.g. "Schema migrations go through dedicated review"}}

## For Claude: Operating Notes

- **Always check `PLAN.md` first** — if present, follow it and tick checkboxes as you go
- **Prefer slash commands over ad-hoc reasoning** — they encode the team's preferred workflow
- **Delegate to subagents** for code review, running tests, root-cause analysis, security checks, doc generation
- **Do not edit `.claude/settings.json`** without explicit user request — shared config
- **Never commit** `.claude/settings.local.json`, `.mcp.json`, `.claude/edit-log.txt`, `.claude/usage.jsonl`, or anything in `.claude/.checkpoints/`
- **Architectural decisions** go in `decisions/NNNN-slug.md` via `/adr` — not buried in commit messages
