# /commit — Smart Commit

## Mission
Sinh commit message từ staged diff theo Conventional Commits, suggest split nếu lẫn nhiều concerns. **Không tự push, không amend mặc định.**

## Input
$ARGUMENTS
(Optional: gợi ý loại — `feat`, `fix`, `docs`, `chore`... — hoặc scope như `auth`, `ui`)

---

## Process

### Step 1 — Inspect staged diff
```bash
git status --short
git diff --staged --stat
git diff --staged
```

- Nếu **chưa stage gì** → báo "nothing staged, run `git add` first" và dừng.
- Nếu thay đổi **>2 thư mục độc lập** (vd `src/auth/` + `src/billing/` không liên quan) → suggest split:
  > "Diff lẫn 2 concerns: auth + billing. Tách thành 2 commit? (y/n)"

### Step 2 — Classify
Đọc diff, chọn type chính xác:

| Type | Khi nào |
|------|---------|
| `feat` | Capability mới user nhìn thấy |
| `fix` | Sửa bug |
| `docs` | Chỉ docs/comments (không đụng code logic) |
| `chore` | Tooling, deps, config — không affect runtime |
| `refactor` | Đổi structure, behavior không đổi |
| `test` | Thêm/sửa tests |
| `perf` | Tối ưu hiệu năng (đo được) |
| `style` | Format only (whitespace, semicolons) |
| `build` | Build system, package manager |
| `ci` | CI config, hooks, workflows |

### Step 3 — Compose message

**Subject** (≤72 char):
- Imperative mood (`add`, `fix`, `remove` — không `added`/`adds`)
- Không "I"/"we"
- Không trailing period
- Format: `<type>(<scope>): <subject>` (scope optional)

**Body** (optional, blank line trước):
- WHY, không phải WHAT (diff đã nói WHAT)
- Wrap ~72 char
- Reference issue: `Closes #123` ở footer

**Breaking changes**:
- Footer `BREAKING CHANGE: <description>` HOẶC suffix `!` ở subject (vd `feat!: drop Node 16 support`)

### Step 4 — Preview & confirm
Show full message, chờ user "ok" / "đổi X thành Y" trước khi commit:

```bash
git commit -m "$(cat <<'EOF'
<full message>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Step 5 — After commit
- Print short SHA + 1-line summary
- Run `git status` → confirm clean
- KHÔNG `git push` — user tự push hoặc gọi `/pr`

---

## Don't
- ❌ Tự push sau commit
- ❌ Amend commit cũ trừ khi user gọi `/commit --amend` rõ ràng
- ❌ Commit khi nothing staged
- ❌ Commit file nhạy cảm (`.env`, `*.key`, `credentials*`) → cảnh báo + dừng
- ❌ Bypass hooks (`--no-verify`) trừ khi user yêu cầu
- ❌ Tự gộp nhiều concerns vào 1 commit khi đã suggest split mà user chưa quyết
