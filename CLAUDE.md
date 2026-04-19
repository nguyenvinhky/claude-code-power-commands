# CLAUDE.md

Auto-loaded context for Claude Code. Project-wide conventions and operating rules.

## Project Overview

**Claude Code Power Commands** — reusable drop-in setup (`.claude/` + `CLAUDE.md`) that turns any repo into a Claude Code power environment: 12 slash commands, 5 subagents, safety/observability hooks, output styles, MCP template, expanded permissions.

See [README.md](README.md) for directory layout, installation, and workflows.

## Conventions

- **Commands in Vietnamese** (project audience); **agents + output styles in English** for international reusability
- **Subagents use `sonnet`** — balance of capability and cost
- **Hooks prefer `ask` over `deny`** — user stays in control
- **No secrets in `.claude/settings.json`** — use `.claude/settings.local.json` (gitignored)

## Safety Hooks

`PreToolUse` prompts for confirmation on: `rm -rf /`, wildcard root deletes, `git push --force` to main/master, `git reset --hard` on dirty tree, `DROP TABLE`/`DROP DATABASE`.

`PostToolUse` appends every `Write`/`Edit` to `.claude/edit-log.txt` (gitignored). `SessionStart` injects git branch + last commit.

## Observability

`Stop` hook appends cost/session metadata to `.claude/usage.jsonl` (gitignored) after every assistant turn. Records are cumulative per session — `/usage` deduplicates by `session_id`. Set `CLAUDE_SESSION_BUDGET_USD` in `.claude/settings.local.json` to tag over-budget sessions with `"warn":"over_budget"` (non-blocking).

## Skills

Reusable file-based capabilities live in `.claude/skills/<name>/SKILL.md`. Each has a `name` + `description` frontmatter that tells Claude when to trigger it. Current templates: `pr-review`, `changelog-gen`.

## MCP Servers

Copy `.mcp.json.example` → `.mcp.json` and set env vars. Templates: filesystem, github, postgres, mssql, mssql-dab, postman, puppeteer, sentry, slack. Uncomment only what's needed.

## Design artifacts

`/design` writes UI/UX previews to `design/<slug>/v<N>/` with a `preview.html` (self-contained Tailwind CDN) + `DESIGN.md` (spec). Cross-platform pointers: `latest.html` (meta-refresh), `LATEST.txt`, `LATEST.md`. Iterate by bumping `v<N>`; never overwrite. `design/_example/` is the canonical reference. Generated `*.png` screenshots are gitignored by default; `DESIGN.md` + `preview.html` + pointers are tracked.

## Brainstorms

`/brainstorm` is the only divergent-mode command — it generates 6–12 option cards (Pros/Cons/Effort/Reversibility) plus a wild card and clustering. It never recommends a winner. Default is ephemeral (chat only); `--save=<slug>` persists to `brainstorms/<slug>.md`. The `brainstorms/` folder is gitignored — `git add -f brainstorms/foo.md` per file if you want to commit a specific list.

## For Claude: Operating Notes

- **Always check `PLAN.md` first** — if present, follow it and tick checkboxes as you go
- **Prefer slash commands over ad-hoc reasoning** — they encode the user's preferred workflow
- **Delegate to subagents** for code review, running tests, root-cause analysis, security checks, doc generation
- **Do not edit `.claude/settings.json`** without explicit user request — shared config
- **Never commit** `.claude/settings.local.json`, `.mcp.json`, `.claude/edit-log.txt`, or `.claude/usage.jsonl`
