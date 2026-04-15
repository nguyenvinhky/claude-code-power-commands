# CLAUDE.md

Auto-loaded context for Claude Code. Project-wide conventions and operating rules.

## Project Overview

**Claude Code Power Commands** — reusable drop-in setup (`.claude/` + `CLAUDE.md`) that turns any repo into a Claude Code power environment: 9 slash commands, 5 subagents, safety/observability hooks, output styles, MCP template, expanded permissions.

See [README.md](README.md) for directory layout, installation, and workflows.

## Conventions

- **Commands in Vietnamese** (project audience); **agents + output styles in English** for international reusability
- **Subagents use `sonnet`** — balance of capability and cost
- **Hooks prefer `ask` over `deny`** — user stays in control
- **No secrets in `.claude/settings.json`** — use `.claude/settings.local.json` (gitignored)

## Safety Hooks

`PreToolUse` prompts for confirmation on: `rm -rf /`, wildcard root deletes, `git push --force` to main/master, `git reset --hard` on dirty tree, `DROP TABLE`/`DROP DATABASE`.

`PostToolUse` appends every `Write`/`Edit` to `.claude/edit-log.txt` (gitignored). `SessionStart` injects git branch + last commit.

## Skills

Reusable file-based capabilities live in `.claude/skills/<name>/SKILL.md`. Each has a `name` + `description` frontmatter that tells Claude when to trigger it. Current templates: `pr-review`, `changelog-gen`.

## MCP Servers

Copy `.mcp.json.example` → `.mcp.json` and set env vars. Templates: filesystem, github, postgres, puppeteer, sentry. Uncomment only what's needed.

## For Claude: Operating Notes

- **Always check `PLAN.md` first** — if present, follow it and tick checkboxes as you go
- **Prefer slash commands over ad-hoc reasoning** — they encode the user's preferred workflow
- **Delegate to subagents** for code review, running tests, root-cause analysis, security checks, doc generation
- **Do not edit `.claude/settings.json`** without explicit user request — shared config
- **Never commit** `.claude/settings.local.json`, `.mcp.json`, or `.claude/edit-log.txt`
