# /usage — Cost & Token Observability

## Mission
Đọc `.claude/usage.jsonl` và tổng hợp spending (cost, session, model, branch). **Chỉ đọc, không edit, không xoá file.**

## Input
`$ARGUMENTS` = optional flags (không có = summary toàn file).

| Flag | Hiệu ứng |
|------|----------|
| `--today` | Chỉ lấy record có `ts` bắt đầu bằng ngày hôm nay (local) |
| `--week` | 7 ngày gần nhất (tính cả hôm nay) |
| `--month` | 30 ngày gần nhất |
| `--by-branch` | Group by `branch`, sort cost desc |
| `--by-agent` | Group `kind=subagent` records by `agent` name (cần SubagentStop hook); sort cost desc |
| `--top=N` | Top N session đắt nhất (mặc định 5 khi có flag này) |
| `--spike[=USD]` | Highlight 🔴 sessions có cost > threshold (default $0.50, override: `CLAUDE_USAGE_SPIKE_USD`) |
| `--json` | Dump raw aggregated stats dưới dạng JSON thay vì bảng markdown |

Flags có thể kết hợp: `/usage --week --by-branch`, `/usage --month --top=10`.

---

## Process

### Step 1 — Đọc file
- Path: `.claude/usage.jsonl`
- Nếu file **không tồn tại** → trả lời: *"Chưa có session nào được log. Hook `Stop` có thể chưa fire — hãy đóng session này và mở lại để ghi record đầu tiên."* và dừng.
- Nếu file **rỗng** → tương tự.
- Parse từng dòng bằng `json.loads`, **skip dòng lỗi** (đừng crash).

### Step 2 — Lọc theo thời gian
Nếu có `--today` / `--week` / `--month`, lọc record theo `ts` (ISO format, compare string prefix với `date.today()` là đủ):
- `--today`: `rec['ts'].startswith(today_iso)`
- `--week`: `rec['ts'] >= (today - 6 days).isoformat()`
- `--month`: `rec['ts'] >= (today - 29 days).isoformat()`

Không filter = lấy toàn file.

### Step 3 — Split + deduplicate
Hook `Stop` fire mỗi turn → một `session_id` có thể xuất hiện nhiều dòng với cost tăng dần (cumulative). Hook `SubagentStop` (R5+) ghi thêm record với `kind=subagent` — **những record này KHÔNG được aggregate cùng main sessions** (cost subagent đã include trong main `Stop` total → double-count).

```python
main_records = [r for r in records if r.get('kind') != 'subagent']
sub_records  = [r for r in records if r.get('kind') == 'subagent']

# Dedup main: giữ record có cost_usd cao nhất cho mỗi session_id
by_sid = {}
for r in main_records:
    sid = r.get('session_id') or r.get('ts')
    if sid not in by_sid or r['cost_usd'] > by_sid[sid]['cost_usd']:
        by_sid[sid] = r
sessions = list(by_sid.values())

# sub_records giữ nguyên (mỗi entry là 1 lần delegate, không cumulative)
```

### Step 4 — Aggregate

**Summary mặc định (luôn in):**
- Tổng số session
- Tổng cost (USD)
- Avg cost/session
- Khoảng thời gian: min(ts) → max(ts)
- Số session có `warn: over_budget` (nếu > 0, highlight)

**Nếu `--by-branch`:**
- Group `sessions` theo `branch`
- Mỗi branch: số session, tổng cost, avg cost/session
- Sort desc theo tổng cost

**Nếu `--top=N` (hoặc sau --top không có N → mặc định 5):**
- Top N session theo `cost_usd` desc
- Cột: `ts`, `session_id[:8]`, `branch`, `cost_usd`, `duration_ms` (format `m:ss`)

**Nếu `--spike[=USD]`:**
- Threshold = USD arg, hoặc `CLAUDE_USAGE_SPIKE_USD` env var, hoặc default `0.50`
- Lọc `sessions` có `cost_usd > threshold`, sort desc
- Mỗi row mở đầu bằng 🔴
- Footer: gợi ý optimize (vd: "session abc12345 dùng 80% cost cho web research → cân nhắc cap researcher tới N searches")

**Nếu `--by-agent`:**
- Group `sub_records` theo `agent`
- Mỗi agent: số lần invoke, tổng cost, avg cost/invoke, model
- Sort desc theo tổng cost
- Note: nếu `sub_records` rỗng → "Chưa có SubagentStop record nào — hook có thể chưa fire (hãy delegate 1 subagent rồi gọi lại)"

### Step 5 — Render
Mặc định markdown table. Nếu `--json`, dump `json.dumps({'summary':..., 'by_branch':..., 'top':...}, indent=2)`.

**Template markdown:**
```
## 📊 Usage — <phạm vi: today/week/month/all>

- **Sessions**: N
- **Total cost**: $X.XXXX
- **Avg/session**: $X.XXXX
- **Range**: YYYY-MM-DD → YYYY-MM-DD
- **Over-budget sessions**: K ⚠️   [chỉ show nếu K > 0]

### By branch   [chỉ khi --by-branch]
| Branch | Sessions | Total cost | Avg |
|---|---|---|---|
| main | 12 | $0.4200 | $0.0350 |
| ...

### Top N most expensive   [chỉ khi --top]
| # | When | Session | Branch | Cost | Duration |
|---|---|---|---|---|---|
| 1 | 2026-04-19 10:22 | abc12345 | main | $0.0821 | 3:45 |
| ...

### 🔴 Cost spikes   [chỉ khi --spike, > threshold]
| When | Session | Branch | Cost | Duration |
|---|---|---|---|---|
| 🔴 2026-04-19 14:30 | def67890 | feat/x | $0.7200 | 12:10 |

### By agent   [chỉ khi --by-agent]
| Agent | Invokes | Total cost | Avg/invoke | Model |
|---|---|---|---|---|
| code-reviewer | 8 | $0.0421 | $0.0053 | sonnet |
| researcher    | 3 | $0.1980 | $0.0660 | sonnet |
```

---

## Hard Rules
- **Read-only**: không gọi `Write`/`Edit` trên `.claude/usage.jsonl` hay bất kỳ file nào.
- **Không chạy `rm`** trên usage.jsonl. Nếu user muốn xoá, hướng dẫn họ `rm .claude/usage.jsonl` thủ công.
- **Không hallucinate**: nếu file thiếu field nào (vd `duration_ms=0`), hiển thị `-` hoặc `n/a`, đừng bịa.
- **Dedup trước khi aggregate** — bỏ qua bước này = cost bị double/triple count.
- **Cost 0 cũng là valid data** — đừng lọc bỏ (có thể là session chưa cost hoặc API free).

## Ví dụ

```
/usage                          # toàn bộ lịch sử
/usage --today                  # hôm nay
/usage --week --by-branch       # 7 ngày, group theo branch
/usage --month --top=10         # top 10 session đắt nhất trong tháng
/usage --json                   # raw JSON để pipe/parse
```
