# /sync — Context Refresh

## Mission
Re-read the codebase to refresh context. Use when context is stale or after large changes.

## Input
$ARGUMENTS
(Empty = full sync, or specify a folder/domain)

---

## Process

### Step 1 — Project structure snapshot
```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' \
  -not -path '*/dist/*' -not -path '*/__pycache__/*' \
  | head -100
```

### Step 2 — Read core files

**Required:**
- `README.md` — project overview
- `PLAN.md` — current plan (if present)
- `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` — dependencies & scripts
- `.env.example` — environment variables
- Main entry point (`src/index.ts`, `main.py`, `cmd/main.go`, etc.)

**Read if present:**
- `ARCHITECTURE.md` or `docs/`
- Database schema (`prisma/schema.prisma`, `migrations/`, etc.)
- API routes (`src/routes/`, `api/`, etc.)
- Core business logic modules

### Step 3 — Check git status (if available)
```bash
git log --oneline -10  # last 10 commits
git diff --stat HEAD   # uncommitted changes
git status             # current state
```

### Step 4 — Output context summary

```
## 🗂️ Context Snapshot — [timestamp]

### Project
- **Name**: ...
- **Tech stack**: ...
- **Purpose**: ...

### Main structure
```
src/
├── features/     — [description]
├── services/     — [description]
└── utils/        — [description]
```

### Key dependencies
- [dep1]: used for ...
- [dep2]: used for ...

### Current state
- Plan: [current phase]
- Recent changes: [recent activity]
- Known issues: [known problems]

### Files read
- ✅ [file1]
- ✅ [file2]

### ⚠️ Things to remember
[Important points when working with this project]
```

### Step 5 — Ready for next command
Notify: "Context refreshed. Which command do you want next?"

---

## When to use `/sync`
- After pulling new code from remote
- After many files changed at once
- When Claude answers incorrectly / with missing context
- At the start of a new working session
- When switching to a different module
