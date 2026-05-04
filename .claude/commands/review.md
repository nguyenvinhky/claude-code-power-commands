# /review — Code Review Mode

## Mission
Review code thoroughly — find bugs, security issues, performance problems, and suggest improvements.

## When to use /review vs `code-reviewer` agent

Both audit the same 5 dimensions (correctness, security, performance, maintainability, conventions). Pick by **context cost**:

| Use `/review` (this command) when... | Use `code-reviewer` agent when... |
|---|---|
| Quick review, small diff (<200 LOC) | Large diff (>500 LOC) — agent's isolated context window keeps main clean |
| You want to discuss findings inline + iterate | You want a one-shot report and move on |
| Reviewing your OWN in-progress work | Reviewing a teammate's PR or branch you didn't write |
| One review at a time | Multiple parallel reviews (different files / branches) |

Rule of thumb: **default to `/review` for everyday work; reach for the agent when context budget matters or you need parallelism**.

For PRs already open on GitHub → use the `pr-review` skill (fetches via `gh`, audits, reports).

## Input
$ARGUMENTS
(If no arguments → review the latest changes or the specified file)

---

## Process

### Step 1 — Determine review scope
- If a specific file/folder is named → review that
- If there's git → run `git diff HEAD` or `git diff main` to see changes
- If unclear → ask the user what to review

### Step 2 — Read full context
- Read the file being reviewed (in full, no skimming)
- Read related test files
- Read interfaces/types the code depends on
- Understand business context (from comments, README, function names)

### Step 3 — Review checklist

#### 🐛 Correctness
- [ ] Is the logic correct? (especially edge cases: null, empty, overflow)
- [ ] Async/await handled correctly?
- [ ] Is error handling complete?
- [ ] Are return values consistent?

#### 🔒 Security
- [ ] SQL injection / XSS / path traversal risks?
- [ ] Is input validation sufficient?
- [ ] Any hardcoded secrets/credentials?
- [ ] Are auth/permission checks in the right places?

#### ⚡ Performance
- [ ] N+1 queries or unnecessary loops?
- [ ] Large data paginated or streamed?
- [ ] Cache used appropriately?

#### 🏗️ Design & Maintainability
- [ ] Single Responsibility Principle respected?
- [ ] Code too complex? (needs refactor)
- [ ] Naming clear and consistent?
- [ ] Magic numbers/strings promoted to constants?

#### 🧪 Testability
- [ ] Is the code easy to test?
- [ ] Do current tests cover the new logic?
- [ ] Any test cases worth adding?

### Step 4 — Output review results

```
## 📋 Review Summary
- Files reviewed: ...
- Verdict: 🟢 Good / 🟡 Needs Work / 🔴 Critical Issues

## 🔴 Critical (must fix)
### [Issue name]
**File**: `path/to/file.ts:42`
**Problem**: [Clear description]
**Suggestion**:
```[language]
// Suggested code
```

## 🟡 Warning (should fix)
...

## 🟢 Suggestion (nice to have)
...

## ✅ Good Practices
[Call out what was done well]
```

---

## Notes
- Clearly separate **Critical** (security/correctness) from **Style** (preference)
- Give **concrete code examples**, not just descriptions
- Tone: constructive, not judgmental
- After review, suggest `/code` to fix the issues
