# /code — Implementation Mode

## Mission
Write, edit, and complete code as requested. Auto-sync context before and after coding.

## Input
$ARGUMENTS

---

## Process

### Step 1 — Sync context (REQUIRED before coding)
Auto-read to grab the latest context:
- Check `PLAN.md` if it exists → follow the plan
- Read the files that will change + related files (imports, dependencies)
- Review matching test files to understand expected behavior
- Check existing patterns in the codebase (naming, structure, style)

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

After implementing, self-review:
```
✅ Does the code follow project conventions?
✅ Are error cases handled?
✅ Do imports/exports need updating?
✅ Are there related files that need matching updates?
✅ Any obvious type errors or syntax issues?
```

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

---

## Hard Rules
- **Do NOT refactor** beyond the scope of the request
- **Do NOT delete code** without a clear reason
- **Do NOT change** existing logic when only adding a new feature
- If you spot a bug while coding → **report it**, don't fix it unless directly related
