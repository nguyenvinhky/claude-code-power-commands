# GEMINI.md

Auto-loaded context for Gemini CLI. Project-wide conventions and operating rules.

## Project Overview

**Gemini Power Commands** — reusable drop-in setup (`.gemini-commands/` + `GEMINI.md`) that turns any repo into a power environment with 12 slash commands (simulated via instructions), 5 subagents, and expanded capabilities optimized for Gemini CLI.

See [README.md](README.md) for directory layout, installation, and workflows.

## Conventions

- **Commands in Vietnamese** (project audience); **agents + output styles in English** for international reusability.
- **Subagents use `invoke_agent`** — Gemini CLI's native way to delegate tasks.
- **Tools Alignment**: Always prefer native Gemini tools:
  - `read_file`, `grep_search`, `glob`, `replace`, `write_file`, `run_shell_command`.
- **Vietnamese Language**: Use Vietnamese for all command responses and user interactions unless specified otherwise.

## How to use Slash Commands with Gemini CLI

Gemini CLI simulates slash commands by reading the definitions in `.gemini-commands/commands/`.

**When the user types a command (e.g., `/plan` or "hãy /plan"), you MUST:**
1. Read the corresponding file in `.gemini-commands/commands/<command_name>.md`.
2. Follow the **Mission** and **Process** defined in that file strictly.
3. Use the Vietnamese language for responses.

Available simulated commands: `/plan`, `/ask`, `/brainstorm`, `/code`, `/review`, `/debug`, `/test`, `/refactor`, `/design`, `/sync`, `/ship`, `/usage`.

## Subagents & Agents

Use the `invoke_agent` tool to delegate specialized tasks. Agent definitions are in `.gemini-commands/agents/`.

**Agent Execution:**
When invoking an agent, provide the instructions from its corresponding file and ensure it uses Gemini's toolset:
- `read_file`, `grep_search`, `glob`, `run_shell_command`, `replace`.

Available Agents:
- **code-reviewer**: Audit bugs/security/perf/style.
- **test-runner**: Run test suite, analyze failures.
- **debugger**: Systematic root cause analysis.
- **security-auditor**: OWASP Top 10, secret scan.
- **doc-writer**: Write README, API docs, ADR, comments.

## Safety & Security

- **Sensitive Files**: Never read or log `.env`, `*.pem`, `*.key`, or anything matching "credentials".
- **Destructive Commands**: Always explain and wait for confirmation before running `rm -rf`, `git push --force`, or database deletions.

## Design artifacts

`/design` writes UI/UX previews to `design/<slug>/v<N>/`. Follow the structure in `design/_example/`.

## Gemini CLI Best Practices

- **Context Efficiency**: Use `grep_search` to find code rather than reading large files.
- **Surgical Edits**: Use `replace` with minimal, precise context to avoid token bloat.
- **Verification**: Always run tests or linting after `/code` or `/refactor` tasks.
