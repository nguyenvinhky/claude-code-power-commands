# /goal — Autonomous Goal Loop (Hard-Verified)

## Mission

Set một **goal verifiable** và Claude tự chạy across multiple turns cho đến khi condition met — **verify bằng cách thực sự chạy command** (test, lint, type-check, git status...), không chỉ đọc transcript. Override built-in `/goal` của Claude Code với 8 lợi thế: hard verifier, multi-condition, auto-import từ SPEC/PLAN, persistent state (resume sau /compact), hard budget caps, auto-checkpoint trước destructive ops, failure recovery sang `/debug`, composable với các slash commands khác.

> **Khác built-in `/goal` chỗ nào?** Built-in dùng evaluator (Haiku) đọc transcript để check goal — vague condition burn token, không thấy được "test có thực sự pass không". Phiên bản này **chạy command thật** rồi parse exit code → ground truth, không phụ thuộc Claude tự đánh giá Claude.

## Input

`$ARGUMENTS`

Modes (chọn 1, default = **start**):

| Mode | Cú pháp | Tác dụng |
|------|---------|----------|
| **start** | `/goal <condition>` | Bắt đầu goal mới |
| **start (multi)** | `/goal --all "<c1>" "<c2>" ...` | AND — tất cả phải met |
| **start (any)** | `/goal --any "<c1>" "<c2>" ...` | OR — một cái met là đủ |
| **status** | `/goal` (no args) | Show goal đang active + progress |
| **resume** | `/goal --resume` | Resume goal sau /compact, quit, đổi máy |
| **import** | `/goal --from-spec` / `--from-plan` | Auto-load từ SPEC.md Acceptance Criteria hoặc PLAN.md unchecked tasks |
| **clear** | `/goal --clear` (aliases: `stop`, `off`, `reset`, `none`, `cancel` cho parity với built-in) | Cancel goal đang active |
| **list** | `/goal --list` | Liệt kê goals đã chạy (lịch sử) |

### Flags

| Flag | Default | Effect |
|------|---------|--------|
| `--verify=<cmd>` | (auto-detect) | Override verifier command. Vd `--verify="npm test -- --silent"`. Có thể repeat nhiều lần cho multi-verify. |
| `--max-turns=N` | 20 | Hard cap — exceed → HALT, report. Tránh runaway. |
| `--max-cost=N` | 5 (USD) | **Lagging** cap — checked đầu mỗi turn mới (đọc `.claude/usage.jsonl` đã ghi bởi Stop hook của turn trước). KHÔNG enforce được mid-turn vì usage.jsonl chỉ được append sau khi turn kết thúc. Exceed → HALT trước khi vào turn kế. |
| `--strict` | off | Refuse start nếu condition vague (xem Step 1.5). |
| `--no-checkpoint` | off | Không auto-checkpoint trước destructive ops. |
| `--debug-after=N` | 3 | Sau N turn liên tiếp không tiến bộ → switch sang `/debug` mode. |
| `--quiet` | off | Chỉ in pass/fail mỗi turn, không log chi tiết. |
| `--dry-run` | off | Parse condition, show verify plan, KHÔNG chạy gì. |

### Argument parsing rules

`$ARGUMENTS` được parse theo thứ tự ưu tiên (first match wins):

1. **Empty** → Mode **status**.
2. **Bare alias** (toàn bộ args là 1 trong `clear|stop|off|reset|none|cancel`) → Mode **clear**.
3. **Starts with** `--list` | `--resume` | `--from-spec` | `--from-plan` → mode tương ứng.
4. **Starts with** `--all` | `--any` → multi-condition; conditions là các quoted strings còn lại (vd `/goal --all "tests pass" "no lint errors"`).
5. **Otherwise** → Mode **start** single condition; toàn bộ remaining args (sau khi strip các flag `--max-*`, `--verify=`, `--strict`, `--no-checkpoint`, `--debug-after=`, `--quiet`, `--dry-run`) ghép lại thành condition string.

**Pairing `--verify` với conditions** (multi-mode):
- Repeat `--verify=<cmd>` theo thứ tự, pair-by-position: verifier thứ N pair với condition thứ N.
- Fewer verifiers than conditions → còn lại auto-detect theo Step 2.
- More verifiers than conditions → STOP với error rõ ràng (mismatch).

---

## Mode 1 — Start (default)

### Step 1 — Parse & validate condition

Phân loại condition thành 1 trong 4 categories:

| Category | Ví dụ | Verifier strategy |
|----------|-------|-------------------|
| **command-exit** | "npm test exits 0", "all tests pass" | Run command, check exit code |
| **file-state** | "git status clean", "no .md files modified" | Run `git status --porcelain`, parse |
| **grep-absence** | "no TODO in src/", "no console.log left" | Shell verifier: `! grep -rq <pattern> <path>` — exit 0 nếu không match |
| **grep-presence** | "src/auth.ts exports loginWithOAuth" | Shell verifier: `grep -q <pattern> <file>` — exit 0 nếu match |

Nếu condition không fit category nào (vd "code is clean") → **vague**, không verify được — xem Step 1.5.

### Step 1.5 — Vague condition handling (no transcript fallback)

**Forbid words**: "clean", "good", "better", "nice", "robust", "production-ready", "high-quality", "elegant", "user-friendly", "performant" — KHÔNG translate được thành verifier nào.

| Mode | Hành vi khi condition vague |
|------|------------------------------|
| `--strict` ON | Reject thẳng, STOP. |
| Default (`--strict` off) | **Vẫn reject** — print gợi ý verifier cụ thể, chờ user re-run. KHÔNG silently fallback sang transcript eval — fallback đó phá killer feature ("không phụ thuộc Claude tự đánh giá Claude"). |

Cả hai mode đều show cùng message:

```
❌ Condition "code is clean" không verifiable bằng external command.
   Suggest cụ thể:
   - /goal "eslint src/ exits 0"
   - /goal "no TODO in src/" --verify="! grep -rq TODO src/"
   - /goal "all tests pass" --verify="npm test -- --silent"
   Re-run với một trong các forms trên.
```

Sự khác biệt duy nhất giữa `--strict` ON vs default: `--strict` ON cũng reject **non-vague-but-still-not-categorized** conditions (vd ngôn ngữ ambiguous như "API responds correctly"); default cho qua nếu Step 1 categorize được vào 4 loại.

### Step 2 — Auto-detect verifier nếu không có `--verify`

Detect từ project structure:

```
package.json có "test" script           → npm test
pyproject.toml + pytest installed       → pytest
go.mod                                  → go test ./...
Cargo.toml                              → cargo test
.eslintrc* + condition mention "lint"   → npm run lint (hoặc eslint .)
tsconfig.json + condition mention type  → tsc --noEmit
```

Nếu condition là **command-exit** kiểu generic ("tests pass") + multiple test runners → list options, hỏi user pick. Không guess.

### Step 3 — Create goal state file

Path: `.claude/.goals/YYYYMMDD-HHMM-<slug>.md` (slug ≤ 30 char, kebab-case từ condition).

Initial content:

```markdown
# Goal — <slug>

**Started**: <ISO timestamp>
**Branch**: <branch>
**Start commit**: <commit>
**Status**: active
**Mode**: <strict|loose>

## Conditions (gate: AND | OR | single)
- [ ] C1: <condition 1> | verifier: `<cmd>`
- [ ] C2: <condition 2> | verifier: `<cmd>`

## Budget
- Max turns: <N> (used: 0)
- Max cost: $<N> (used: $0)

## Turn log
<filled per turn>

## Decisions / blockers
<filled khi user input giữa loop>
```

### Step 4 — Pre-flight checks

Trước khi bắt đầu loop:

1. **Working tree status** — nếu dirty và `--no-checkpoint` off → tự write checkpoint snapshot vào `.claude/.checkpoints/<timestamp>-goal-<slug>.md` theo đúng format `/checkpoint` tạo (branch, last commit, dirty files, "where = pre-goal-snapshot"). KHÔNG invoke `/checkpoint` programmatically — slash commands không gọi nhau được từ trong loop.
2. **Verify command sanity** — chạy verifier 1 lần để đảm bảo command exists, không lỗi syntax. Nếu fail vì command not found → STOP, báo cụ thể.
3. **Baseline measurement** — chạy verifier, record kết quả initial. Nếu **goal đã met ngay từ đầu** → report "Goal already satisfied", không vào loop, mark goal done.

### Step 5 — The loop

Lặp các bước sau cho đến khi một trong các exit conditions ở **5e** trigger (goal met, max-turns, max-cost, stuck-after-N, user interrupt):

#### 5a. Plan turn

Claude đọc state file + condition + last verifier output → quyết định turn này làm gì. Nếu turn ≥ 2, so sánh verifier output với turn trước để biết có tiến bộ không.

#### 5b. Execute

Claude làm việc (read code, edit, run commands). **Trước mỗi destructive op** (`rm`, `git reset --hard`, mass delete), nếu `--no-checkpoint` off → snapshot vào `.claude/.goals/<slug>.snapshots/turn-<N>-pre.diff` (sibling directory, KHÔNG nest under state file — state file vẫn flat: `.claude/.goals/<slug>.md`).

#### 5c. Verify (HARD CHECK — đây là killer feature)

Run **all verifiers** trong condition list:

```
for each condition Cn:
  run verifier
  parse exit code + stdout
  mark Cn = ✅ (exit 0 + assertion matches) hoặc ❌
```

Apply gate logic:
- `--all` (AND): all ✅ → goal met
- `--any` (OR): ≥1 ✅ → goal met
- Single condition: that ✅ → goal met

#### 5d. Append turn log

Vào state file:

```markdown
### Turn 3 — 2026-05-18 14:30
- Action: edited src/auth.ts — added JWT verification
- Verifier `npm test`: ❌ exit 1, 2 failing (auth.test.ts:42, 78)
- Progress vs turn 2: ⬆ 5 fewer failures
- Cost: _(appended retroactively từ Stop hook của turn này — usage.jsonl chỉ ghi sau khi turn end)_
```

#### 5e. Check exit conditions

In order:

1. **Goal met** → break, go to Step 6 (success).
2. **Max turns exceeded** → break, go to Step 7 (budget exhausted).
3. **Max cost exceeded** → break, go to Step 7.
4. **Stuck**: N turns liên tiếp không có progress (verifier output identical hoặc worse) where N = `--debug-after` → switch sang **debug mode** (xem 5f).
5. **User interrupt** (Ctrl+C, manual stop) → save state, break.

#### 5f. Debug mode (stuck recovery)

Khi stuck:

1. Pause loop, không edit thêm.
2. Invoke `debugger` subagent (Agent tool, subagent_type=`debugger`) với context: condition, verifier output 3 turn gần nhất, files đã edit.
3. Subagent trả về root cause analysis.
4. Append vào state file dưới `## Decisions / blockers`.
5. **Hỏi user**: "Stuck after N turns. Debugger says: <summary>. Options: (a) continue with new hypothesis, (b) abandon goal, (c) modify condition". User reply → tiếp tục theo lựa chọn.

### Step 6 — Success path

Khi goal met:

1. Mark `Status: done` trong state file.
2. Run all verifiers 1 lần nữa để đảm bảo không flaky.
3. Report:
   ```
   ✅ Goal MET in <N> turns, $<cost> spent.
      Conditions:
      - ✅ C1: <condition>
      - ✅ C2: <condition>
      State file: .claude/.goals/<slug>.md

   🔜 Next:
      - /commit (suggest message dựa trên turn log)
      - /pr (nếu muốn open PR luôn)
      - /goal --clear (remove active marker)
   ```

### Step 7 — Budget exhausted

```
⚠️ Goal NOT met — <reason>
   Reason: max-turns reached (20/20) | max-cost reached ($5.02/$5) | stuck (3 turns no progress)
   Last verifier state:
   - ✅ C1: passed
   - ❌ C2: still failing — <last output excerpt>
   State file: .claude/.goals/<slug>.md (preserved for resume)

   Options:
   - /goal --resume --max-turns=30   (extend budget)
   - /debug                          (investigate why stuck)
   - /goal --clear                   (give up)
```

KHÔNG auto-extend budget. User quyết.

---

## Mode 2 — Status (no args)

Đọc most recent active goal trong `.claude/.goals/`. Show:

```
🎯 Active goal: <slug>
   Started: <when> (<elapsed>)
   Branch: <branch>
   Conditions:
   - ✅ C1: <condition>
   - ❌ C2: <condition>  ← verifier last: <excerpt>
   Budget: <N>/<max> turns, $<cost>/$<max>
   Last turn: <when> — <summary>

   /goal --resume    để tiếp tục
   /goal --clear     để cancel
```

Không có active goal → show last 3 completed goals (filename + status + condition).

---

## Mode 3 — Resume (`--resume [slug-prefix]`)

1. Find latest active goal trong `.claude/.goals/` (Status: active), hoặc match prefix nếu cung cấp.
2. Read state file, restore conditions + budget remaining + turn count.
3. **Budget overrides** (nếu user pass `--max-turns=N` / `--max-cost=N` ở câu lệnh resume):
   - **Replace** stored cap với giá trị mới — KHÔNG cộng dồn vào used count.
   - Vd: state file có `max-turns: 20, used: 15`. User chạy `/goal --resume --max-turns=30` → mới: `max-turns: 30, used: 15` → còn 15 turn budget.
   - Nếu cap mới < used → STOP với error "new cap (<N>) < already used (<M>) — không thể resume". User phải bump cap cao hơn.
   - Append decision vào `## Decisions / blockers`: "budget extended: max-turns 20 → 30".
4. **Sanity check**:
   - Branch hiện tại ≠ branch trong goal → warn, KHÔNG tự switch.
   - Working tree có changes mới sau goal start (mtime > goal start time) → warn "some files changed outside goal loop, may invalidate progress".
5. Re-run verifier ngay 1 lần để biết baseline hiện tại (có thể goal đã met trong khi quit).
6. Quay vào loop ở **Step 5**.

---

## Mode 4 — Import từ SPEC.md / PLAN.md

### `--from-spec`

Đọc `SPEC.md` ở root. Extract:
- Mỗi mục dưới `## ✅ Acceptance Criteria` → ứng viên condition
- Filter những item viết dạng Given-When-Then có verifiable outcome
- Suggest verifier cho mỗi cái:
  ```
  AC: "When user submits empty email, Then form shows 'required'"
  → verifier candidate: grep test file for that scenario, run pytest -k empty_email
  ```
- Hỏi user pick (multi-select) → set goal với gate = AND.

Reject nếu không có SPEC.md hoặc section AC rỗng.

### `--from-plan`

Đọc `PLAN.md` ở root. Extract unchecked `- [ ]` items dưới `## 📋 Execution Plan`. Goal = "all listed tasks checked off".

Verifier (real shell command, exit code ground truth):
```bash
test "$(grep -c '^- \[ \]' PLAN.md)" -eq 0
```
Exit 0 khi không còn unchecked item. Claude tick boxes trong PLAN.md mỗi turn; verifier là **external grep với exit code**, không phải Claude tự đọc tự đánh giá.

---

## Mode 5 — Clear

Aliases đã liệt kê trong bảng Modes ở đầu file. Parsing rule: bare alias chỉ valid khi là **toàn bộ** `$ARGUMENTS` — vd `/goal stop` OK, `/goal stop now` → treated as condition `"stop now"` (Mode start).

1. Find active goal.
2. Mark `Status: cancelled` + append cancel timestamp.
3. Confirm: `✅ Cleared goal: <slug>`.

KHÔNG xoá state file — chỉ flip status. Để xoá hẳn → `--list` xem rồi `rm` thủ công.

---

## Mode 6 — List

```
| When | Slug | Status | Conditions | Turns | Cost |
|------|------|--------|------------|-------|------|
| 2026-05-18 14:30 | fix-auth-tests | ✅ done | npm test exits 0 | 4/20 | $0.84 |
| 2026-05-17 09:00 | type-check-clean | ⚠️ cancelled | tsc --noEmit | 7/20 | $1.20 |
| 2026-05-15 16:45 | no-todo-src | ✅ done | grep TODO src/ = 0 | 2/20 | $0.31 |
```

Sort desc by start time. Show last 10 by default.

---

## Composability — Goal + other commands

Slash commands **KHÔNG thể** invoke nhau programmatically từ trong loop (giới hạn của Claude Code — slash commands là user-typed). Composition xảy ra qua 3 cơ chế hợp lệ:

- **Subagents qua Agent tool** — Claude trong loop có thể spawn `debugger`, `test-runner`, `code-reviewer`, `security-auditor`... để delegate phần việc chuyên biệt. Vd stuck → spawn `debugger`; cần verify test → spawn `test-runner`.
- **Shell tương đương** — thay vì "gọi /test", chạy thẳng `npm test` / `pytest` / `go test`. Thay vì "gọi /code", Claude tự edit file theo style mà `/code` mô tả.
- **User-driven pipeline** — user gõ `/spec` → `/plan` → `/goal --from-plan` tuần tự (mỗi cái là 1 turn riêng). Sau khi `/goal` met, **suggest** user gõ `/commit` + `/pr` (không auto-invoke).

---

## Safety rails (hard)

- ❌ **Không bao giờ `git push --force`** trong loop, kể cả khi goal "merged to main". User phải push thủ công.
- ❌ **Không touch** `.claude/settings.json`, `.mcp.json`, `.env`, secrets.
- ❌ **Không skip pre-commit hooks** (`--no-verify`).
- ❌ **Không tự `git stash`** khi resume — chỉ warn nếu dirty.
- ⚠️ **Destructive ops** (`rm -rf`, `git reset --hard`, mass file delete) — nếu `--no-checkpoint` off, snapshot diff trước; nếu on, ASK user confirm.
- ⚠️ **Database/network ops**: nếu verifier touch DB / external API → require explicit `--allow-external` flag, không default ON.

---

## State file format (reference)

`.claude/.goals/YYYYMMDD-HHMM-<slug>.md` — gitignored.

```markdown
# Goal — <slug>

**Started**: 2026-05-18T14:30:00+07:00
**Ended**: 2026-05-18T14:45:00+07:00      ← present khi done/cancelled
**Branch**: feat/auth
**Start commit**: abc1234
**End commit**: def5678                    ← present khi done
**Status**: active | done | cancelled | budget-exhausted
**Mode**: strict | loose

## Conditions (gate: AND | OR | single)
- [x] C1: npm test exits 0 | verifier: `npm test -- --silent`
- [ ] C2: no TODO in src/ | verifier: `! grep -rq TODO src/`  *(exit 0 nếu không match, exit 1 nếu có TODO)*

## Budget
- Max turns: 20 (used: 4)
- Max cost: $5 (used: $0.84)

## Turn log

### Turn 1 — 2026-05-18T14:30
- Action: read failing test, identified missing JWT verify
- Verifier `npm test`: ❌ exit 1, 3 failures
- Cost: $0.20 (total: $0.20)
- Progress vs baseline: same (initial)

### Turn 2 — ...

## Decisions / blockers

- 2026-05-18T14:35 — user: "skip migration test, will fix separately" → removed from gate
- 2026-05-18T14:40 — debugger subagent: root cause is stale mock in setup.ts:12

## Pre-op snapshots (destructive ops)

- `<slug>.snapshots/turn-3-pre.diff` (before `git reset HEAD~1`)
```

---

## Don't

- ❌ Không vào loop khi condition vague + `--strict` ON — reject thẳng.
- ❌ Không tin Claude tự đánh giá Claude — verifier phải là **external command** với exit code thật.
- ❌ Không exceed `--max-turns` hay `--max-cost` — HALT cứng, không hỏi xin extend.
- ❌ Không modify state file ngoài các append points đã định nghĩa (turn log, decisions/blockers, status flip, end commit, condition tick). Không sửa Conditions/Budget retroactively.
- ❌ Không auto-clear state files — user gọi `--list` rồi xoá tay.
- ❌ Không commit state files — `.claude/.goals/` phải gitignored.
- ❌ Không gọi `git push --force` hay `--no-verify` dưới bất kỳ goal nào.
- ❌ Không proceed nếu verifier command not found — STOP với message rõ.
- ❌ Không silently fallback sang transcript eval khi user đã set verifier — báo lỗi và STOP.
