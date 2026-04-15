# /review — Code Review Mode

## Mission
Review code thoroughly — find bugs, security issues, performance problems, and suggest improvements.

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
