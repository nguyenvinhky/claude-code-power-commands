# GEMINI.md

Auto-loaded context for Gemini CLI. Project-wide conventions and operating rules.

## Project Overview

**Claude Code Power Commands** (now supporting Gemini CLI) — reusable drop-in setup (`.claude/` + `CLAUDE.md` + `GEMINI.md`) that turns any repo into a power environment with 12 slash commands (simulated via instructions), 5 subagents, safety hooks, and expanded capabilities.

See [README.md](README.md) for directory layout, installation, and workflows.

## Conventions

- **Commands in Vietnamese** (project audience); **agents + output styles in English** for international reusability.
- **Subagents use `invoke_agent`** — Gemini CLI's native way to delegate tasks.
- **Hooks prefer `ask` over `deny`** — user stays in control.
- **No secrets in `.claude/settings.json`** — use `.claude/settings.local.json` (gitignored).

## How to use Slash Commands with Gemini CLI

Gemini CLI doesn't natively have "slash commands" in the same way as Claude Code, but it can simulate them by reading the definitions in `.claude/commands/`.

**When the user types a command (e.g., `/plan` or "hãy /plan"), you MUST:**
1. Read the corresponding file in `.claude/commands/<command_name>.md`.
2. Follow the **Mission** and **Process** defined in that file strictly.
3. Use the Vietnamese language for responses if the command is in Vietnamese.

Available simulated commands: `/plan`, `/ask`, `/brainstorm`, `/code`, `/review`, `/debug`, `/test`, `/refactor`, `/design`, `/sync`, `/ship`, `/usage`.

## Subagents & Agents

Gemini CLI should use its `invoke_agent` tool to delegate specialized tasks. The agent definitions are in `.claude/agents/`.

**Tool Mapping for Agents:**
The agent definitions use Claude Code tool names. When invoking an agent, map them to Gemini CLI tools as follows:
- `Read` → `read_file`
- `Grep` → `grep_search`
- `Glob` → `glob`
- `Bash` → `run_shell_command`

Available Agents:
- **code-reviewer**: Audit bugs/security/perf/style.
- **test-runner**: Run test suite, analyze failures.
- **debugger**: Systematic root cause analysis.
- **security-auditor**: OWASP Top 10, secret scan.
- **doc-writer**: Write README, API docs, ADR, comments.

## Safety & Security

- **Strictly follow the `deny` rules** in `.claude/settings.json` regarding sensitive files (`.env`, `*.pem`, etc.).
- Before executing potentially destructive commands (`rm -rf`, `git push --force`, etc.), always ask for user confirmation.

## Design artifacts

`/design` writes UI/UX previews to `design/<slug>/v<N>/`. Follow the structure in `design/_example/`.

## For Gemini CLI: Operating Notes

- **Always follow `PLAN.md` first** if present.
- **Simulate slash commands** by reading `.claude/commands/*.md`.
- **Use `invoke_agent`** for specialized tasks defined in `.claude/agents/`.
- **Maintain consistency** with the project's Vietnamese/English language split.
- **Do not edit shared config** like `.claude/settings.json` without explicit request.
