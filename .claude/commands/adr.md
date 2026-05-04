# /adr — Architectural Decision Record

## Mission
Sinh ADR theo MADR format vào `decisions/NNNN-slug.md`. Capture **WHY** đằng sau quyết định cấu trúc (DB choice, framework, boundary, deprecation...) để 6 tháng sau team — và Claude — vẫn hiểu được context. **Chỉ ghi lại; không tự apply quyết định.**

## Input
$ARGUMENTS
(Title của decision, vd: `use Postgres over Mongo for user data`)

Optional flags:
- `--status=proposed|accepted|deprecated` (default: `proposed`)
- `--supersedes=NNNN` (đánh dấu ADR cũ là superseded)
- `--enrich` (delegate sang `doc-writer` agent để ra ADR dày dặn hơn)

---

## Process

### Step 1 — Determine ID & slug

```bash
mkdir -p decisions
ls decisions/[0-9]*.md 2>/dev/null     # tìm ADR hiện có
```

- Tìm số NNNN cao nhất (bỏ qua `0000-template.md`) → +1, zero-padded 4 chữ số
- Slug từ title: lowercase, kebab-case, drop stop words (`the`, `a`, `for`, `of`, `to`...), ≤50 char
  - vd: `use Postgres over Mongo for user data` → `0007-postgres-over-mongo`

### Step 2 — Ensure folder + template

```bash
[ -f decisions/0000-template.md ] || (write template từ inline content bên dưới)
```

Inline template fallback (nếu user không có sẵn):
```markdown
---
date: YYYY-MM-DD
status: proposed
deciders: [name]
---

# NNNN. Title

## Context and Problem Statement
[Vấn đề + ràng buộc]

## Considered Options
1. **Option A** — ...
2. **Option B** — ...

## Decision Outcome
Chosen **Option X**, because [...].

### Positive Consequences
- ...

### Negative Consequences
- ...

## Pros and Cons of the Options
### Option A
- ✅ Pro: ...
- ❌ Con: ...
```

### Step 3 — Gather inputs (conversation, không hỏi 1 lần)

Hỏi tuần tự, mỗi câu sau khi user trả lời câu trước:

1. **Context**: "Vấn đề là gì? Ràng buộc nào quan trọng (latency / cost / team familiarity / lock-in)?"
2. **Options considered**: "Đã cân nhắc những phương án nào? Liệt kê 2-3 cái, mỗi cái 1 dòng."
3. **Decision**: "Chốt cái nào, vì sao? (1-2 câu)"

Optional follow-up:
4. **Consequences**: "Hệ quả tích cực + tiêu cực? (skip nếu chỉ cần ADR ngắn)"

User có thể paste full content thay vì trả lời từng câu — Claude tự parse vào các section.

### Step 4 — Optional: enrich qua doc-writer

Nếu user gọi `--enrich` hoặc câu trả lời quá ngắn để compose ADR đầy đủ:
> Delegate sang `doc-writer` agent với inputs đã gather → nhận lại ADR text dày dặn hơn (thêm context, sources, cross-refs).

### Step 5 — Compose & preview

Build full ADR theo template, fill placeholders bằng user inputs. Show preview inline.

### Step 6 — Confirm & write

Chờ user "ok" / "đổi X thành Y" → write `decisions/NNNN-slug.md`.

Nếu `--supersedes=NNNN`:
- Cập nhật `decisions/NNNN-old.md`: status frontmatter → `superseded by ZZZZ`, thêm "Superseded by [./ZZZZ-...](./ZZZZ-new.md)" ở cuối
- ADR mới thêm "Supersedes [./NNNN-old.md](./NNNN-old.md)" trong Links section

### Step 7 — Suggest commit

```
✅ Wrote decisions/NNNN-slug.md

Suggested commit:
  git add decisions/NNNN-slug.md
  git commit -m "docs(adr): NNNN <title>"
```

KHÔNG tự commit — user quyết định.

---

## Don't
- ❌ Tự `git commit` — ADR là docs nhạy cảm, user review trước
- ❌ Overwrite ADR đã có — luôn dùng số mới
- ❌ Mặc định status `accepted` — bắt đầu `proposed`, user upgrade khi đồng thuận
- ❌ Sinh ADR cho quyết định trivial (đặt tên biến, format) — ADR là cho **structural** decisions
- ❌ Đánh số trùng — `decisions/0007-foo.md` đã có thì lùi sang `0008`
- ❌ Edit ADR cũ trừ khi explicit `--supersedes` flag
