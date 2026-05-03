# /debug — Systematic Debugging Mode

## Mission
Analyze and find the **root cause** of a bug — not just fix the symptom.

## Input
$ARGUMENTS
(Describe the error, paste the error message, or describe the unexpected behavior)

---

## Process

### Step 1 — Gather information
Read and grasp:
- Full error message (stack trace if any)
- File/function that failed
- Conditions that triggered the failure (what input, what context)
- Expected vs. actual behavior

If key info is missing → ask immediately before continuing.

### Step 2 — Read related code
- Read the full function/module that failed
- Trace back to the caller (who calls this function, with what input)
- Read dependencies (libraries, utilities used)
- Check test files to understand expected behavior

### Step 3 — Hypothesis-driven debugging

List possible causes, ordered by likelihood:

```
Hypothesis 1: [Possible cause] — Likelihood: High/Medium/Low
  → How to confirm: [verification method]

Hypothesis 2: ...
```

Check each hypothesis by reading code and tracing logic.

### Step 4 — Identify root cause

```
## 🔍 Root Cause Analysis

### The bug
[Description]

### Root cause
[Explain WHY the bug happens, not just where]

### Causal chain
[Input X] → [Function A mishandles it] → [State Y gets corrupted] → [Function B fails]

### Files & lines involved
- `path/to/file.ts:42` — [the problem]
```

### Step 5 — Suggest fixes

Provide **at least 2 fix options** when possible, with clear trade-offs:

```
### Fix Option 1: [Name] — ⭐ Recommended
**Pros**: ...
**Cons**: ...
**Code**:
```[language]
// Fix code
```

### Fix Option 2: [Name]
...
```

### Step 6 — Prevent regression

```
## 🛡️ Prevention
- [ ] Add test case for this scenario
- [ ] Add validation at [point X]
- [ ] Consider refactoring [part Y] to reduce similar risks
```

---

## When the cause is unclear
If you lack information, ask the user:
1. "At exactly which step does the error occur?"
2. "Can you share the full stack trace?"
3. "Does this fail consistently or only sometimes?"
4. "Any recent changes in the area?"

Once the cause is found and the fix confirmed → suggest `/code` to implement and `/test` to add a regression test.
