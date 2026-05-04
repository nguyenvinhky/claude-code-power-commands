# /code — Implementation Mode

## Mission
Write, edit, and complete code as requested. Auto-sync context before and after coding.

## Input
$ARGUMENTS

---

## Process

### Step 1 — Sync context (REQUIRED before coding)
Read in this order — don't skip:
1. **`PLAN.md`** if present → follow it; identify which task IDs (e.g. `P1.1`, `R5.2`) belong to this run
2. **Files that will change** + their direct imports — use `Glob` for the directory, `Read` for each
3. **Matching test files** (`*.test.*`, `*_test.*`) — understand existing expected behavior
4. **`git diff HEAD`** + `git status --short` — see what's already modified vs clean
5. **Adjacent code** following the same pattern — match naming/structure conventions in step 3

If scope is unclear after this pass → ask user before writing any code.

### Step 2 — Pre-code analysis
Before writing a single line, determine:
- [ ] Which files will be created / modified / deleted?
- [ ] Any breaking changes?
- [ ] Do tests need to be updated?
- [ ] Do docs/comments need to be updated?

If there's a **breaking change** or **large change** → report and confirm with the user first.

### Step 3 — Implement

Coding rules:
- **Consistency**: Use the same patterns and naming conventions as the existing codebase
- **Minimalism**: Don't add new dependencies unless truly needed
- **Defensive**: Handle edge cases and error paths
- **Clarity**: Comment only complex logic — the WHY, not the WHAT

### Step 4 — Self-check after coding

After implementing, self-review the diff:
```
✅ Does the code follow project conventions?
✅ Are error cases handled?
✅ Do imports/exports need updating?
✅ Are there related files that need matching updates?
✅ Any obvious type errors or syntax issues?
```

**Then verify it actually compiles / type-checks** — don't claim "done" until this passes:
- TypeScript: `npx tsc --noEmit` (or detect from `package.json` scripts)
- Python: `mypy <file>` if mypy in deps; else `python -m compileall <file>`
- Go: `go build ./...`
- Rust: `cargo check`
- Other: detect lint/check command from project (look in scripts / Makefile / README), run it

If verification fails → report the failure honestly + iterate. Do **NOT** mark task done in `PLAN.md` and do **NOT** call this step complete. Saying "done" on broken code is the worst failure mode.

### Step 5 — Update PLAN.md (if present)
If the project has `PLAN.md`, auto-check completed tasks:
```markdown
- [x] Task done ✓
- [ ] Task pending
```

### Step 6 — Report results

```
## ✅ Done
- Created/modified `file1.ts`: [what changed]
- Created/modified `file2.ts`: [what changed]

## ⚠️ Notes
[What to watch out for with the new code]

## 🔜 Next Step (if any)
[Suggested next step]
```

### Step 7 — Suggest delegations (if applicable)

Based on what was changed:
- **Tests exist for affected files** → "use `test-runner` agent to run tests on changed files"
- **Scope crossed >2 modules / introduced a new boundary** → "use `architect` agent to review shape before merge"
- **Touched auth / payment / crypto / secret-handling** → "use `security-auditor` agent before commit"
- **Single-file fix, no test changes** → no delegation needed; suggest `/commit` directly

---

## Hard Rules
- **Do NOT refactor** beyond the scope of the request
- **Do NOT delete code** without a clear reason
- **Do NOT change** existing logic when only adding a new feature
- If you spot a bug while coding → **report it**, don't fix it unless directly related
