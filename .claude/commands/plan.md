# /plan — Deep Planning Mode

## Mission
Analyze the request and produce a detailed implementation plan. **Absolutely NO writing or modifying any line of code.**

## Input
$ARGUMENTS

---

## Process

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
