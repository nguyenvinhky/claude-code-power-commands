# /migrate — Framework / Library Migration Plan

## Mission
Sinh migration plan cho framework/library upgrade (vd `React 17 → 18`, `Node 14 → 20`, `Next 13 → 14`, `Postgres 13 → 16`). Read changelog + breaking changes, cross-reference với code thực tế, output execution plan có effort estimate. **Không tự install/upgrade**, chỉ planning.

## Input
$ARGUMENTS — vd `React 17 to 18`, `Node 14 to 20`, `tailwind 3 to 4`

---

## Process

### Step 1 — Identify current state
```bash
# Auto-detect package manifest
cat package.json | jq .dependencies     # JS/TS
cat go.mod                              # Go
cat Cargo.toml | grep version           # Rust
cat pyproject.toml | grep python        # Python
```

Confirm với user: "Đang ở `<X>`, target `<Y>`, đúng chưa?"

### Step 2 — Delegate research (cost-efficient)
Spawn `researcher` subagent với prompt:
> "Find official migration guide cho `<X>` → `<Y>`. List breaking changes. Cite primary sources only (changelog, official docs, RFC). Cap 4 web searches."

Researcher trả về:
- Official migration URL
- List breaking changes (concise)
- Notable behavior changes (silent — không phải compile error nhưng đổi semantic)

### Step 3 — Cross-reference codebase
Cho mỗi breaking change từ researcher, grep codebase:
```bash
grep -rn "<deprecatedAPI>" src/ --include="*.ts"
```

Record:
- API X — N occurrence(s) trong file paths
- API Y — N occurrence(s)
- API Z — không dùng (skip phase)

### Step 4 — Compose migration plan

Group thành phases theo risk:

**Phase 1 — Mechanical (low risk)**: rename APIs có 1-1 mapping (vd `componentWillMount` → `componentDidMount`)
**Phase 2 — Behavioral (medium risk)**: API thay đổi semantic, cần đọc lại logic
**Phase 3 — Architectural (high risk)**: breaking changes đòi hỏi đổi approach

Effort estimate per phase: S (≤2h), M (≤1 day), L (>1 day).

### Step 5 — Output

```
## 🚚 Migration: <X> → <Y>

### Current state
- Version: `<X>` (from `package.json`)
- Affected deps: list those will need bump too

### Source references
- Official migration guide: <URL>
- Changelog: <URL>
- Breaking changes RFC: <URL>

### Breaking changes affecting THIS codebase

| Change | Impact | Where used (count) | Phase |
|--------|--------|--------------------|-------|
| `oldAPI()` → `newAPI()` | Mechanical rename | 12 files (23 lines) | P1 |
| Default export removed | Need named import | 4 files | P1 |
| `useEffect` cleanup semantics | Behavioral | 8 files | P2 |
| Strict mode double-render | Need guards in side-effecting hooks | unknown — need audit | P3 |

### Migration phases

**Phase 1 — Mechanical (S)**
- [ ] Run codemod: `npx <codemod>` (if available)
- [ ] Rename N call sites
- [ ] Verify via `<test cmd>`

**Phase 2 — Behavioral (M)**
- [ ] Audit useEffect cleanups in 8 files
- [ ] Add tests for race conditions
- [ ] Verify

**Phase 3 — Architectural (L)**
- [ ] Strict mode audit
- [ ] Refactor hooks vi phạm
- [ ] Verify under React Strict Mode

### Risks
- ⚠️ Tailwind v4 changes default config location — check `tailwind.config.*`
- ⚠️ Vite/Webpack cache phải clear sau bump

### Total estimated effort
P1: S (~2h) | P2: M (~1 day) | P3: L (~2-3 days)

### Suggested next
- `/plan migrate <X> to <Y> phase 1` — start with mechanical
- `/code` from PLAN.md after each phase
- `use test-runner` between phases to catch regressions
```

---

## Don't
- ❌ Tự `npm install <new-version>` — user quyết khi nào bump
- ❌ Tự edit code áp dụng migration — chỉ planning
- ❌ Skip changelog reading — bịa breaking changes là tệ hơn không có plan
- ❌ Gộp tất cả vào 1 phase — phân theo risk giúp ship-and-test incremental
- ❌ Hứa "no breaking changes affect us" mà chưa grep — luôn cross-reference
- ❌ Trust SEO blog post — researcher phải cite official primary source
