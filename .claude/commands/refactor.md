# /refactor — Refactoring Mode

## Mission
Improve code quality **without changing behavior**. Every refactor must be safe and verifiable.

## Input
$ARGUMENTS
(File/function to refactor, or the problem to solve)

---

## Process

### Step 1 — Evaluate: "Should we refactor?"

Before doing anything, check:
- Are there tests covering this code? → If not → suggest writing tests first (`/test`)
- Is the value of the refactor worth the risk?
- Is the scope clear?

**If there are no tests** → warn the user and ask if they want tests written first.

### Step 2 — Identify Code Smells

Read the code and pinpoint concrete problems:

```
🔴 Critical smells (fix now):
- [ ] God function (>50 lines, doing too many things)
- [ ] Magic numbers/strings with no context
- [ ] Duplicate code (copy-paste)
- [ ] Deep nesting (>3 levels)
- [ ] Inconsistent error handling

🟡 Warning smells (consider):
- [ ] Unclear variable/function names
- [ ] Comments explaining WHAT (code already shows it) instead of WHY
- [ ] Functions with too many parameters (>4)
- [ ] Mixed abstraction levels

🟢 Style issues (optional):
- [ ] Inconsistent formatting
- [ ] Outdated patterns
```

### Step 3 — Plan the refactor

State clearly what will be done **before acting**:

```
## Refactor Plan

### Changes:
1. Extract `validateUserInput()` from `createUser()` (lines 45-67)
2. Rename `x` → `userEmailAddress`
3. Replace magic number `86400` → `SECONDS_PER_DAY`
4. Split `processOrder()` into `validateOrder()` + `chargePayment()` + `fulfillOrder()`

### Behavior that does NOT change:
- Public API input/output stays the same
- Business logic stays the same
- Error messages stay the same

### Risk assessment: Low / Medium / High
```

Confirm with the user before executing.

### Step 4 — Execute in small steps

Refactor in **baby steps**:
- Each step does ONE type of change
- Verify behavior is unchanged after each step
- Don't combine multiple refactor types in one commit

### Step 5 — Verify

After refactoring:
- Run existing tests to confirm no regression
- Self-review: re-read the refactored code
- Compare before/after

```
## 📊 Before vs After

### Before (X lines, complexity: Y)
[Code or description]

### After (X' lines, complexity: Y')
[Code or description]

### Improvements:
- Complexity reduced from Y → Y'
- Split into X clearer functions
- Improved testability: [reason]
```

---

## Hard Rules
- **Behavior preservation**: tests must pass exactly as before
- **No premature optimization**: refactor for readability first, performance later
- **No over-engineering**: don't add abstraction layers that aren't needed
- **Small steps**: each refactor step independent and reversible
