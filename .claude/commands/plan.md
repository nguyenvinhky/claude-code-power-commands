# /plan — Deep Planning Mode

## Mission
Analyze the request and produce a detailed implementation plan. **Absolutely NO writing or modifying any line of code.**

## Input
$ARGUMENTS

---

## Process

### Step 0 — Check for upstream spec (if present)
If `SPEC.md` exists at project root (or user passes `--spec=<path>` — note: this is a `/plan` flag, NOT a `/spec` flag) → read it FIRST and treat these sections as authoritative:
- **Goal** + **Reformulated Requirements** + **Business Rules** → load as primary input; skip duplicate clarification in Step 2 for items already answered
- **Acceptance Criteria** → use to define tasks' "done"
- **Ambiguities (Critical)** → if any remain unresolved, surface as **❓ Questions to Confirm** in plan output and STOP before designing phases — re-run `/spec` after BA clarifies
- **Codebase Alignment ❌ items** → these become Phase 0 / scaffolding tasks in the plan

Output PLAN.md MUST include a `## 📌 Source Spec` line linking to SPEC.md for traceability.

If no SPEC.md → proceed normally to Step 1.

### Step 1 — Read & understand current context
Auto-read the important files to understand the codebase:
- Read `README.md`, `package.json` / `pyproject.toml` / `go.mod` (if present)
- List directory structure at a high level (max 2-3 levels)
- Read main config files (`.env.example`, `tsconfig.json`, etc.)
- Identify the tech stack and patterns in use

### Step 2 — Requirements analysis
- Clarify the final GOAL
- Identify **constraints**: performance, security, compatibility
- List **assumptions** that need user confirmation
- Surface potential **risks**
- For non-trivial scope (>200 LOC or new module boundaries), consider invoking the `architect` subagent to sanity-check the proposed shape before finalizing the plan

### Step 3 — Output the plan

Present the plan in this format:

```
## 🎯 Goal
[One-line description]

## 📊 Current State Analysis
- Tech stack: ...
- Patterns in use: ...
- Related files: ...

## ⚠️ Risks & Assumptions
- [Risk 1]: ...
- [Assumption]: ...

## 📋 Execution Plan

### Phase 1: [Name]
- [ ] Task 1.1 — [Description] | File: `path/to/file`
- [ ] Task 1.2 — [Description] | File: `path/to/file`

### Phase 2: [Name]
- [ ] Task 2.1 — [Description]
...

## 🔀 Priority & Dependencies
[Which tasks must come first, which can run in parallel]

## ✅ Definition of Done
- [ ] ...
- [ ] ...

## ❓ Questions to Confirm
1. ...
```

### Step 4 — Save the plan
Create a `PLAN.md` file at the project root with the content above.

---

## Important Notes
- If the request is vague → ask for clarification BEFORE planning
- The plan must be concrete enough to hand off to `/code` directly
- After planning, suggest the user run `/code` to start implementing
