# /explain — Code Walkthrough

## Mission
Walk through 1 file (hoặc 1 module nhỏ) như onboarding cho contributor mới: entry points → call graph → invariants → unusual decisions. **Read-only — không sửa code.**

## Input
$ARGUMENTS — path tới file hoặc folder (vd: `src/auth/login.ts`, `src/billing/`)

Optional flags:
- `--depth=N` — số layer call graph cần trace (default 2)
- `--for=newbie|expert` — adjust detail level (default: newbie)

---

## Process

### Step 1 — Inspect
- Read file (hoặc tất cả `*.ts`/`*.py`/etc. trong folder, cap 10 file)
- Read direct imports (dependencies trong cùng repo)
- Read matching test file nếu có (`*.test.*`, `*_test.*`)

### Step 2 — Identify entry points
- `export` (named + default)
- Public methods của class
- HTTP handlers, CLI commands, event subscribers — bất kỳ thứ gì là "edge" của module

### Step 3 — Trace call graph
Cho mỗi entry point, trace call graph tới depth N:
- Chỉ trace trong phạm vi module/file (không đi sâu vào lib bên ngoài)
- Đánh dấu external boundary: `[external: lodash.debounce]`

### Step 4 — Surface key invariants
Đọc kỹ tìm:
- Pre-conditions (assertions, type guards, validation)
- State ownership: function nào sửa state nào
- Error handling: throw vs return Result vs silent
- Concurrency: locks, mutex, sync points
- Side effects: I/O, network, filesystem

### Step 5 — Spot unusual decisions
- Code có comment `// hack` / `// TODO` / `// XXX`
- Pattern khác convention quanh nó (vd dùng callback giữa repo all-async)
- Magic constant không có doc
- Workaround cho bug ngoài

### Step 6 — Output

```
# 📖 Walkthrough: <path>

## Purpose (1 line)
[Module này tồn tại để làm gì]

## Entry points
- `funcA(args)` — exported, called by `path/to/caller.ts:42`
- `funcB(args)` — public class method, used in HTTP handler

## Call graph (depth=N)
funcA
  └─ validateInput
       └─ schema.parse              [external: zod]
  └─ doWork
       └─ database.query()          [external boundary]

## Key invariants
- `state.user.id` is set IFF `state.session !== null` — see line 42
- All async paths await before throwing — error propagation chain intact
- `formatPrice()` always returns 2 decimal places — UI relies on this

## Notable decisions
- `path:88` — using sync fs.readFileSync instead of async; deliberate (called once at boot)
- `path:140` — manual cache invalidation instead of TTL; reason in comment
- `path:200` — `// TODO: extract to module` since 2024-Q3 — has been stable, low priority

## What to read next
- `src/auth/session.ts` — session lifecycle this module assumes
- `src/auth/login.test.ts` — covers happy + failure paths for funcA
- `decisions/0003-jwt-vs-cookie.md` — explains the auth model behind this
```

---

## Don't
- ❌ Đề xuất sửa code (đó là `/refactor` hoặc `/code`)
- ❌ Walk qua >10 file trong 1 invocation — nếu folder lớn, hỏi user pick subset
- ❌ Trace external libs (chỉ đến boundary)
- ❌ Bịa invariants — chỉ liệt kê cái có evidence trong code/comments
- ❌ Dùng cho file <50 LOC — trivial, chỉ tốn token; gợi ý user đọc trực tiếp
