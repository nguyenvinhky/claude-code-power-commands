# /checkpoint — Save / Resume Mid-Task State

## Mission
Save snapshot work-in-progress (files đã touch, decisions đã chốt, next steps) vào `.claude/.checkpoints/<timestamp>-<slug>.md` để resume sau khi quit, compact, hoặc đổi machine. **Không thay code**, chỉ tạo file metadata. **Không commit** — folder gitignored.

## Input
$ARGUMENTS

Modes (chọn 1, default = save):
- _(no flag)_ — **save** snapshot mới
- `--resume` — restore từ checkpoint mới nhất
- `--resume <prefix>` — restore từ checkpoint match prefix (vd `--resume 2026-05-04` hoặc `--resume add-auth`)
- `--list` — liệt kê tất cả checkpoint
- `--clear-old` — xoá checkpoint > 30 ngày

---

## Mode 1 — Save (default)

### Step 1 — Refuse khi nothing đang dở
```bash
git status --short        # nếu clean
tail -5 .claude/edit-log.txt 2>/dev/null   # nếu rỗng / cũ > 1 ngày
```
→ Nếu working tree clean **và** edit-log không có gì gần đây → notify "Không có gì để save", dừng.

### Step 2 — Gather state automatically
```bash
git branch --show-current
git log -1 --oneline
git status --short                       # dirty file count
tail -20 .claude/edit-log.txt 2>/dev/null  # recent edits
```

### Step 3 — Hỏi user 2 câu (conversation)

1. **"Where are you?"** — 1-2 câu prose mô tả task đang làm dở
2. **"Next steps?"** — bullet list (3-5 items) gì cần làm tiếp

User có thể skip bằng "skip" → checkpoint chỉ chứa auto-state + placeholder.

### Step 4 — Generate file

- Path: `.claude/.checkpoints/YYYY-MM-DD-HHMM-<slug>.md`
- Slug từ "where" prose (ngắn ≤30 char, kebab-case) hoặc `auto` nếu skip
- Content:
  ```markdown
  # Checkpoint <ISO timestamp>

  **Branch**: <branch>
  **Last commit**: <commit>
  **Working tree**: <N> dirty file(s)

  ## Recent edits (last 20)
  - <tool>: <path>
  - ...

  ## Where I am
  <user prose>

  ## Next steps
  - <bullet 1>
  - <bullet 2>
  ```

### Step 5 — Confirm
```
✅ Checkpoint saved: .claude/.checkpoints/2026-05-04-1530-add-auth.md
   Resume: /checkpoint --resume
```

---

## Mode 2 — Resume (`--resume [prefix]`)

### Step 1 — Find checkpoint
- `--resume` (no prefix): file mới nhất trong `.claude/.checkpoints/` theo mtime
- `--resume <prefix>`: match prefix trên filename (case-insensitive). Nếu nhiều match → liệt kê + hỏi pick.

### Step 2 — Read & inject
Print full content checkpoint.

### Step 3 — Sanity checks
- Nếu **branch hiện tại ≠ branch trong checkpoint** → cảnh báo:
  > "⚠️ Checkpoint trên branch X, đang ở Y. Switch trước khi resume? (chỉ khuyến nghị, không tự switch)"
- Nếu **working tree dirty** → cảnh báo, KHÔNG tự stash

### Step 4 — Suggest next action
Đọc "Next steps" trong checkpoint, gợi ý slash command cụ thể:
- "viết tests" → `/test`
- "fix bug X" → `/debug` + `/code`
- "open PR" → `/pr`

---

## Mode 3 — List (`--list`)

```
| File | Branch | When | Where |
|------|--------|------|-------|
| 2026-05-04-1530-add-auth.md | feat/auth | 2 hours ago | Adding OAuth flow |
| 2026-05-03-1100-fix-leak.md | fix/leak  | yesterday   | Investigating memory leak |
```

Sort by mtime desc.

---

## Mode 4 — Clear old (`--clear-old`)

```bash
find .claude/.checkpoints -name "*.md" -mtime +30
```

Show count + list → confirm "delete N file(s)? (y/n)" → `rm` nếu y.

---

## Don't
- ❌ Tự `git stash` khi resume — user quyết
- ❌ Tự switch branch — chỉ cảnh báo
- ❌ Commit `.claude/.checkpoints/` — đã gitignored
- ❌ Resume vào branch khác mà không cảnh báo
- ❌ Save checkpoint khi nothing dở (return early)
- ❌ Save checkpoint trùng tên — append `-2`, `-3` nếu slug trùng cùng phút
- ❌ Auto-clear checkpoints — luôn cần user gọi `--clear-old`
