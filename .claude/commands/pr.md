# /pr — Open Pull Request

## Mission
Mở PR từ branch hiện tại lên base (default `main`) với title + body chuyên nghiệp, link issue tự động khi detect được. **Không merge, không force push.**

## Input
$ARGUMENTS
(Optional: `--base <branch>` để đổi base, `--draft` để mở draft PR, `--title "..."` để override title)

---

## Process

### Step 1 — Pre-flight
```bash
git status                           # phải clean
git branch --show-current            # branch name
gh auth status                       # gh đã login
git fetch origin <base>              # sync base
git log <base>..HEAD --oneline       # commits sẽ vào PR
```

**Refuse khi**:
- Working tree dirty (uncommitted changes) → "commit hoặc stash trước"
- Branch == base (vd đang ở `main`) → "tạo branch mới trước: `git checkout -b feat/xxx`"
- `gh` chưa auth → "chạy `gh auth login`"
- Branch chưa push lên remote → hỏi: "push branch trước? (y/n)"

### Step 2 — Detect metadata

**Issue link** (auto-detect từ branch name):
- `feat/123-add-login` → `Closes #123`
- `fix/JIRA-456-null-check` → ghi `JIRA-456` vào body, không Closes (Jira khác)
- Nếu không match pattern → bỏ qua

**Base branch**:
- Default `main`. Nếu repo có `master` (legacy) → dùng `master`.
- Override bằng `--base`.

### Step 3 — Compose

**Title** (≤70 char):
- Single-commit branch → dùng commit subject
- Multi-commit branch → tổng hợp 1 dòng (không liệt kê từng commit)
- Format: `<type>: <description>` (giữ Conventional Commits convention nếu repo dùng)

**Body** template:
```markdown
## Summary
- bullet 1 (high-level WHAT + WHY)
- bullet 2
- bullet 3

## Test plan
- [ ] step 1
- [ ] step 2
- [ ] step 3

## Closes
#123  <!-- chỉ thêm nếu detect được -->

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 4 — Preview & confirm
Show full title + body, chờ user "ok" / "sửa Y thành Z".

### Step 5 — Open PR
```bash
gh pr create \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)" \
  [--base <base>] \
  [--draft]
```

In ra **URL PR** trả về cho user.

### Step 6 — Suggest next
- "PR mở rồi: <url>"
- "Chạy `/pr-review <N>` (hoặc skill pr-review) để self-review trước khi request reviewer"
- KHÔNG `gh pr merge` — user/reviewer quyết định merge

---

## Don't
- ❌ Tạo PR khi working tree dirty
- ❌ Force push để fix branch (`git push --force` blocked by hook anyway)
- ❌ Merge PR sau khi tạo — chờ review
- ❌ Tạo PR với body trống / chỉ có "fix"
- ❌ Auto-request reviewer trừ khi user chỉ định
- ❌ Tự đổi base branch của PR sau khi tạo
