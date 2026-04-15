# /ship — Pre-Deploy Checklist

## Mission
Run a full checklist before deploy/merge to ensure the code is production-ready.

## Input
$ARGUMENTS
(Branch name, PR description, or change summary)

---

## Process

### Step 1 — Summarize changes

```bash
git diff main --stat        # changed files
git log main.. --oneline    # commits to merge
git diff main               # full diff
```

Read and understand all changes before starting the checklist.

### Step 2 — Run the checklist

#### 🔒 Security
- [ ] No hardcoded secrets, API keys, or passwords
- [ ] Input validation at all entry points
- [ ] Authorization checks in the right places
- [ ] Dependencies free of known vulnerabilities
- [ ] No sensitive data in logs

#### ✅ Correctness
- [ ] Happy paths work correctly
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error handling clear and consistent
- [ ] No unresolved TODO/FIXME in new code

#### 🧪 Testing
- [ ] Tests pass (or skip reasons are documented)
- [ ] Coverage for new code meets the bar
- [ ] No commented-out tests without reason

#### ⚡ Performance
- [ ] No obvious N+1 queries
- [ ] Large queries have proper indexes
- [ ] No blocking operations in the hot path

#### 🗄️ Data & Migration
- [ ] Database migrations written (if schema changed)
- [ ] Migrations can be rolled back
- [ ] No broken backwards compatibility (or breaking changes are documented)

#### 📝 Documentation & Ops
- [ ] README updated if needed
- [ ] New environment variables documented
- [ ] CHANGELOG updated (if project uses one)
- [ ] Monitoring/alerting set up if needed

### Step 3 — Output the report

```
## 🚀 Ship Readiness Report

### Change summary
[Short description of what changed]

### ✅ Checklist Results
🟢 Security: X/Y passed
🟢 Correctness: X/Y passed
🟡 Testing: X/Y passed — [issues]
🟢 Performance: X/Y passed
🟢 Data: X/Y passed
🟢 Docs: X/Y passed

### ⚠️ Items to resolve before shipping
- [ ] [Issue 1] — Critical/Warning
- [ ] [Issue 2] — Critical/Warning

### 📋 Suggested PR description
```
## What changed
[Description]

## Why
[Reason]

## How to test
1. ...
2. ...

## Checklist
- [ ] Tests pass
- [ ] Reviewed by ...
```

---

## Verdict
🟢 READY TO SHIP / 🟡 SHIP WITH CAUTION / 🔴 DO NOT SHIP
```

---

## Notes
- **Critical issues** → DO NOT ship until fixed
- **Warning issues** → note them; can ship if accepted
- Use `/review` for a deeper per-file review
