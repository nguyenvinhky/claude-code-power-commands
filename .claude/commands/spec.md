# /spec — Spec Ingest & Verification Mode

## Mission
Đọc spec/PRD/ticket từ BA dù format `.docx` / `.xlsx` / `.pdf` / `.md` / ảnh / URL / text dán thẳng → normalize thành `SPEC.md` canonical với requirements + business rules + acceptance criteria + codebase alignment + ambiguity list. **Read-only — không sửa code.** Output là input upstream cho `/plan`.

> VN: Bước trung gian giữa "BA gửi file" và `/plan`. Bắt ambiguity ở giai đoạn chữ, không phải code.

## Input
`$ARGUMENTS` = 1 hoặc nhiều path tới spec files / URL / pasted text. Ví dụ:

- `/spec docs/PRD.md`
- `/spec docs/PRD.docx docs/data_dict.xlsx docs/wireframe.png`
- `/spec` rồi paste nội dung text vào turn tiếp theo
- `/spec https://notion.so/your-public-page`

Optional flags:

| Flag | Effect |
|------|--------|
| `--save=<path>` | Lưu vào path tùy chỉnh (vd `--save=docs/specs/checkout.md` để track trong git) thay vì `SPEC.md` root (default ephemeral, gitignored) |
| `--no-codebase-check` | Skip section "Codebase Alignment" — dùng cho greenfield project chưa có code |
| `--lang=vi\|en` | Output language (default `vi`) |
| `--max-req=N` | Cap số requirements (default 30) — spec to thì gợi ý chia feature |

---

## Process

### Step 1 — Ingest tất cả input

Cho mỗi path / URL / text trong `$ARGUMENTS`:

| Format | Cách đọc |
|---|---|
| `.md` / `.txt` | Read tool trực tiếp |
| `.pdf` | Read tool (native PDF support) — nếu >10 trang phải truyền `pages` range |
| `.png` / `.jpg` / `.jpeg` | Read tool (multimodal — đọc được ảnh whiteboard/wireframe) |
| `.docx` / `.xlsx` | Office helper — xem **Office ingest flow** bên dưới |
| `http://` / `https://` | WebFetch (public Notion/Confluence link) |
| Pasted text | Từ `$ARGUMENTS` hoặc nội dung user dán turn tiếp theo |

Path validation: nếu file không tồn tại → báo path sai, STOP (không skip silently).

#### Office ingest flow (`.docx` / `.xlsx`)

Vì `_py.sh` exit 0 silently nếu Python không có, ta phải probe trước rồi mới quyết định strategy:

1. **Probe Python availability** (1 lần đầu session):
   ```bash
   bash .claude/hooks/_py.sh -c "print('ok')"
   ```
   Stdout chứa `ok` → Python OK, sang bước 2. Stdout rỗng → Python thiếu, nhảy thẳng bước 3 (pandoc).

2. **Run helper** (path PHẢI quote để chống space-in-filename):
   ```bash
   bash .claude/hooks/_py.sh .claude/hooks/spec_ingest.py "<file1>" "<file2>"
   ```
   - Exit 0 + stdout non-empty → ingest thành công, dùng stdout
   - Exit ≠ 0 hoặc stdout empty → helper fail (deps thiếu hoặc parse error) → sang bước 3
   - Stderr có thông điệp deps thiếu cụ thể → quote vào fallback message

3. **Pandoc fallback** (chỉ cho `.docx`; `.xlsx` không hỗ trợ):
   ```bash
   command -v pandoc >/dev/null && pandoc -- "<file>" -t markdown
   ```
   - `--` cần thiết để filename bắt đầu bằng `-` không bị parse như flag
   - Quote `"<file>"` chống command injection qua filename chứa `;` hoặc backtick
   - Nếu `pandoc` không có trên PATH → sang bước 4

4. **Final fallback** — in message và bỏ qua file đó:
   > ⚠️ Không parse được `<file>` — vui lòng `pip install python-docx openpyxl` HOẶC cài `pandoc` HOẶC export sang `.md`/`.pdf`.

   Các file còn lại trong batch vẫn được xử lý bình thường.

### Step 2 — Normalize → canonical blob

- Merge nội dung từ tất cả sources thành 1 markdown blob in-memory
- Đánh dấu nguồn mỗi đoạn quan trọng: `[from: PRD.docx §4.2]` hoặc `[from: data_dict.xlsx, sheet "Pricing"]`
- Detect contradictions giữa các sources → flag để vào section Ambiguities (Step 7)

### Step 3 — Reformulate requirements (atomic, testable)

Tách spec thành các requirement đo được:

```
R1: <subject> <verb> <object> [<condition>]
```

**Forbid từ mơ hồ**: "nhanh", "tốt hơn", "user-friendly", "robust", "scalable" — nếu spec dùng các từ này, không paraphrase; chuyển thành Ambiguity ("Define 'fast' — SLO bao nhiêu ms?").

### Step 3.5 — Enforce `--max-req` cap (HARD STOP)

Default `--max-req=30`. Sau khi extract xong:

- Đếm số requirements `R<n>` đã viết ra
- Nếu **count ≤ N** → tiếp tục Step 4
- Nếu **count > N** → **HALT trước Step 4**. Output bản partial (R1..RN) + message:
  > ⚠️ Spec sinh ra `<count>` requirements (vượt cap `<N>`). Đề xuất chia feature thành sub-features và chạy `/spec` cho từng cái. Hoặc tăng cap qua `--max-req=<higher>` nếu bạn chắc.

  Không proceed Steps 4-9. User quyết định.

### Step 4 — Extract business rules (preserve high-stakes)

Tìm logic conditional trong spec:
- "Nếu X thì Y" → Rule statement
- Pricing / discount / tax / permission tables → **preserve nguyên dạng table** trong SPEC.md, không paraphrase
- Quote nguyên văn các điều khoản high-stakes (tài chính, pháp lý, quyền truy cập)

### Step 5 — Codebase alignment check (skip nếu `--no-codebase-check`)

Cho mỗi noun phrase quan trọng (entity/feature/endpoint/role names) trong requirements:

```bash
# Pseudocode — dùng Grep tool, không spawn shell
grep -ri "<entity>" --include="*.{ts,js,py,go,rs,java}"
```

Mark mỗi entity:
- ✅ Match found, semantic có vẻ đúng
- ⚠️ Match found nhưng terminology drift (vd spec "tab", code "session")
- ❌ Không tìm thấy → cần build mới hoặc clarify

Specifically:
- Spec mention API endpoint → grep `routes/` `controllers/` `handlers/` `api/`
- Spec mention DB field → grep schema/migration files
- Spec mention permission/role → grep auth modules

### Step 6 — Acceptance criteria (Given-When-Then)

Cho mỗi requirement R<n>, viết ≥1 Given-When-Then:
- **Given** <pre-condition>
- **When** <action>
- **Then** <expected outcome>

Nếu **không viết được** Given-When-Then → đó là dấu hiệu requirement còn mơ hồ → flag vào Ambiguities (Step 7).

### Step 7 — List ambiguities (most critical part)

Categorize theo severity:

**🔴 Critical (block /plan)** — không trả lời không design được:
- Số thiếu (SLO, max count, limit)
- Conflict giữa sources
- Permission mơ hồ
- Term không định nghĩa

**🟡 Important (block /code)** — design được nhưng implement sẽ vướng:
- Edge case bỏ qua
- Error handling không nói

**🟢 Nice to clarify** — có thể assume rồi confirm sau:
- UI detail nhỏ
- Wording

Sort: Critical → Important → Nice.

### Step 8 — Compose & write SPEC.md

**Output language** (`--lang=vi|en`, default `vi`):
- `vi` → giữ tiếng Việt cho prose + section headers như template dưới
- `en` → translate section headers + prose sang English: `## 🎯 Goal` giữ nguyên (icons universal), nội dung mô tả + ambiguity descriptions sang English. **Source attributions giữ nguyên** (`[from: PRD §4.2]`), tên file giữ nguyên, business rule tables giữ nguyên ngôn ngữ gốc.

Template canonical (FULL — không bỏ section nào, để trống nếu N/A):

```markdown
# SPEC — <Feature Name>

> Generated by `/spec` on YYYY-MM-DD from <list of sources>.
> Status: draft

## 📌 Sources
- `docs/PRD.docx` — primary requirements (12 trang, 4 sections)
- `docs/data_dict.xlsx` — data model (3 sheets)
- `docs/wireframe.png` — UI mockup

## 🎯 Goal
[1-2 câu restated, không mơ hồ]

## 📖 Reformulated Requirements
- **R1**: <atomic, testable> [from: PRD §2.1]
- **R2**: ...

## 🧭 Business Rules
- **Rule 1** — Condition X → Action Y. [from: PRD §4.2]
- **Rule 2** — Pricing table (preserve nguyên):

  | Tier | Discount | Min spend |
  |---|---|---|
  | Bronze | 5% | $0 |
  | Silver | 10% | $500 |

## ✅ Acceptance Criteria
**AC for R1:**
- Given <pre>, When <action>, Then <outcome>

**AC for R2:**
- ...

## 🔍 Codebase Alignment
- ✅ `Order.total_amount` exists in `src/models/order.ts:42` — matches R1
- ⚠️ Spec dùng "tab" nhưng codebase dùng "session" — terminology drift, cần align
- ❌ `SplitPayment` model chưa exist — cần build mới cho R3

## ❓ Ambiguities (need clarification before /plan)

### 🔴 Critical
1. **Max split count?** Spec không định nghĩa giới hạn — 2? 10? unlimited?
2. **Rounding logic?** $33.33 / 3 ways → ai gánh phần lẻ (0.01)?

### 🟡 Important
3. **Refund cho split payment?** PRD không cover — defer hay implement luôn?

### 🟢 Nice to clarify
4. **UI: badge "split" ở đâu?** — assume sidebar nếu BA không reply

## 🚫 Out of Scope (explicit)
- Subscription billing (defer v2)
- Multi-currency support

## 🔜 Next
- Trả lời Critical ambiguities → re-run `/spec` để update
- Khi clean → `/plan <feature>` (sẽ tự đọc file này)
```

### Step 9 — Save

- **Default**: write `SPEC.md` ở project root (gitignored, ephemeral — mirror `PLAN.md` pattern)
- **`--save=<path>`**: write vào path đó; tạo thư mục cha nếu cần
- **Nếu file đích đã tồn tại** (overwrite protection):
  1. Read existing file
  2. Present inline before/after **chỉ cho 2 sections quan trọng**: `## 📌 Sources` và `## ❓ Ambiguities` (3 buckets Critical/Important/Nice). Không show full diff — quá ồn.
  3. Liệt kê thêm 1-line summary "Requirements: +N / -M / ~K" (added/removed/changed counts)
  4. Hỏi user "Overwrite? (yes/no)" → chỉ write khi user xác nhận

### Step 10 — Report

```
✅ Wrote SPEC.md  (hoặc <path>)
- Sources ingested:  N file(s)
- Requirements:      R1..RN
- Business rules:    M
- Codebase gaps:     X items (red)
- Ambiguities:       🔴 C  🟡 I  🟢 N

🔜 Next:
  - Trả lời các Critical ambiguities với BA → re-run /spec để update
  - Khi clean → /plan <feature>  (sẽ tự đọc SPEC.md)
```

Nếu có 🔴 Critical → KHÔNG suggest `/plan` ngay; nhấn mạnh cần clarify trước.

---

## Don't
- ❌ Không sửa code — chỉ đọc spec + grep codebase
- ❌ Không overwrite SPEC.md mà không show diff
- ❌ Không guess answer cho Ambiguities — list chúng để user/BA quyết
- ❌ Không paraphrase business rules high-stakes (pricing, tax, permission, legal) — quote nguyên văn
- ❌ Không skip Codebase Alignment trừ khi `--no-codebase-check`
- ❌ Không generate >`--max-req` requirements — spec quá to → suggest split feature
- ❌ Không commit hay auto-save vào `docs/specs/` — `--save` opt-in
