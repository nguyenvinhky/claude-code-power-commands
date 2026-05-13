# 🤖 Claude Code Power Commands

Bộ setup đầy đủ tính năng cho **Claude Code** — 19 slash commands, 7 subagents, 5 skills, hooks, permissions, statusLine, output styles, MCP template, cost observability. Drop vào bất kỳ project nào để dùng ngay.

## 🚀 Quick Install (one-liner)

Chạy ngay ở **gốc project** bạn muốn cài:

```bash
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash
```

Installer sẽ clone repo vào temp, copy `.claude/`, `CLAUDE.md`, `.mcp.json.example` vào thư mục hiện tại, rồi tự cleanup. An toàn chạy lại — file đã tồn tại sẽ được bỏ qua.

**Tip**: nếu đây là project mới và bạn muốn CLAUDE.md tailored thay vì copy literal của repo này → thêm `--template`. Sẽ bootstrap từ `templates/CLAUDE.template.md` với `{{PROJECT_NAME}}` tự điền theo basename folder; các marker `{{...}}` còn lại để bạn `grep '{{' CLAUDE.md` rồi fill nốt.

### Options nâng cao

```bash
# Pin về version ổn định (khuyến nghị khi đã có release)
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash -s -- --ref v1.0.0

# Cài vào thư mục khác cwd
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash -s -- --dir ~/projects/my-app

# Bootstrap CLAUDE.md từ template (PROJECT_NAME tự điền, các {{...}} khác để user fill)
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash -s -- --template

# Kiểm tra script trước khi chạy (khuyến nghị cho lần đầu)
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh -o install.sh
cat install.sh    # đọc qua
bash install.sh
```

### Cách thủ công (nếu đã clone repo)

```bash
git clone https://github.com/nguyenvinhky/claude-code-power-commands.git
cd your-project
bash /path/to/claude-code-power-commands/setup-claude-commands.sh
```
## Cấu trúc

```
.
├── CLAUDE.md                          # Context auto-load vào Claude mỗi session
├── .mcp.json.example                  # 13 MCP server templates
├── design/                            # UI/UX mockups sinh bởi /design (versioned)
├── decisions/                         # ADRs (MADR format) sinh bởi /adr
├── templates/                         # CLAUDE.template.md cho install --template
└── .claude/
    ├── settings.json                  # Hooks + permissions + statusLine
    ├── settings.local.json.example    # Personal overrides (gitignored)
    ├── commands/                      # 19 slash commands (tiếng Việt)
    ├── agents/                        # 7 subagents (English, sonnet)
    ├── skills/                        # 5 skills (pr-review, changelog-gen, release-notes, incident-report, migration-guide)
    ├── hooks/                         # Python hook scripts + _py.sh cross-platform wrapper
    └── output-styles/                 # senior-mentor, concise
```

## 19 Slash Commands

| Command | Mục đích | Không làm |
|---------|----------|-----------|
| `/spec` | Đọc PRD/spec đa format (md/pdf/docx/xlsx/ảnh/URL), verify alignment với codebase, list ambiguity → `SPEC.md` làm input cho `/plan` | ❌ Không sửa code, không guess ambiguity |
| `/plan` | Phân tích & lên kế hoạch chi tiết (tự đọc `SPEC.md` nếu có) | ❌ Không viết code |
| `/ask` | Hỏi & đáp, giải thích code | ❌ Không tự ý thay đổi file |
| `/brainstorm` | Sinh 6-12 options (divergent), có wild card | ❌ Không đưa recommendation |
| `/code` | Implement code (auto-sync context) | ❌ Không refactor ngoài phạm vi |
| `/review` | Review: bugs, security, performance | ❌ Không tự fix (chỉ report) |
| `/debug` | Root cause analysis cho bugs | ❌ Không fix khi chưa xác nhận cause |
| `/test` | Viết tests chất lượng cao | ❌ Không viết tests chỉ để coverage |
| `/refactor` | Cải thiện code, không đổi behavior | ❌ Không refactor khi chưa có tests |
| `/design` | Sinh UI/UX HTML preview + DESIGN.md, versioning, optional screenshot | ❌ Không đụng code frontend |
| `/sync` | Đọc lại codebase, cập nhật context | ❌ Không thay đổi gì |
| `/ship` | Pre-deploy checklist | ❌ Không tự deploy |
| `/usage` | Thống kê cost/token từ `.claude/usage.jsonl` (today/week/month/by-branch) | ❌ Không edit, không xoá file |
| `/commit` | Smart commit từ staged diff theo Conventional Commits, suggest split nếu lẫn concerns | ❌ Không tự push, không amend mặc định |
| `/pr` | Mở PR với title/body chuyên nghiệp, link issue từ branch name qua `gh` | ❌ Không merge, không force push |
| `/adr` | Sinh Architectural Decision Record vào `decisions/NNNN-slug.md` (MADR format) | ❌ Không tự commit, không overwrite ADR cũ |
| `/checkpoint` | Save/resume mid-task state vào `.claude/.checkpoints/` — branch, edits, where/next prose | ❌ Không tự stash, không tự switch branch |
| `/explain` | Walkthrough 1 file/module: entry → call graph → invariants → notable decisions | ❌ Không sửa code, không trace hết external libs |
| `/migrate` | Migration plan cho framework/lib upgrade — researcher + grep codebase → phased plan | ❌ Không tự install, không tự edit code |

## 7 Subagents

Subagents có **context window riêng** → không làm bẩn main context, có thể chạy song song.

| Agent | Vai trò | Model |
|-------|---------|-------|
| `code-reviewer` | Audit bugs/security/perf/style của diff | sonnet |
| `test-runner` | Chạy test suite, phân tích failures | sonnet |
| `debugger` | Root cause analysis có hệ thống | sonnet |
| `security-auditor` | OWASP Top 10, secret scan | sonnet |
| `doc-writer` | Viết README, API docs, ADR, comments | sonnet |
| `architect` | Review **shape** (boundaries/layering/abstractions) trước khi /code — pair với /plan | sonnet |
| `researcher` | Web research + synthesis cho tech evaluation, API lookup, comparison (có WebSearch + WebFetch) | sonnet |

Cách dùng: `"hãy dùng code-reviewer để audit thay đổi vừa rồi"`.

## 5 Skills

Skills là các capabilities file-based trong `.claude/skills/<name>/SKILL.md`. Mỗi skill có `name` + `description` ở frontmatter để Claude biết khi nào trigger.

| Skill | Trigger | Vai trò |
|-------|---------|---------|
| `pr-review` | "review PR #N", PR URL | Fetch diff qua `gh`, audit 5 dimensions, report blockers/suggestions |
| `changelog-gen` | "generate changelog", "update CHANGELOG.md" | Group commits theo conventional-commit → Keep-a-Changelog format (technical/internal) |
| `release-notes` | "release notes for vX", "announcement post" | User-facing release notes — selective + customer-framed (sister của `changelog-gen`) |
| `incident-report` | "post-mortem", "RCA for ...", "incident report" | Blameless post-mortem template: timeline + impact + root cause + SMART action items |
| `migration-guide` | "migration guide v1→v2", "breaking changes doc" | User-facing guide cho lib/API mình OWN bị breaking changes (sister của `/migrate` command nhưng outward) |

Thêm skill mới: tạo `.claude/skills/<name>/SKILL.md` với frontmatter đầy đủ.

## Hooks (8 events / 9 hook entries — tự động hoá, an toàn, observability)

Configured trong `.claude/settings.json`. Hooks ngắn viết inline (Python `-c`); hooks dài extract sang `.claude/hooks/<name>.py`. Tất cả Python hooks chạy qua wrapper `.claude/hooks/_py.sh` để cross-platform (`py` → `python3` → `python`, filter Windows Store stub).

| Hook | Khi nào | Hành động |
|------|---------|-----------|
| **PreToolUse/Bash** | Trước mọi Bash command | Nếu match `rm -rf /`, `git push --force main`, `git reset --hard`, `DROP TABLE`... → hỏi lại user |
| **PostToolUse/Write\|Edit** (edit-log) | Sau khi ghi/sửa file | Append log vào `.claude/edit-log.txt` |
| **PostToolUse/Write\|Edit** (lint-on-save) | Sau khi ghi/sửa file | Auto-format file vừa lưu (`prettier`/`black`/`gofmt`/`rustfmt`) — chỉ chạy nếu binary có **và** project có config tương ứng. Opt-out: `CLAUDE_DISABLE_LINT_ON_SAVE=1` |
| **UserPromptSubmit** | Mỗi prompt user | Inject working tree state + last test result (im lặng nếu không có gì mới). Opt-out: `CLAUDE_DISABLE_PROMPT_CONTEXT=1` |
| **SessionStart** | Đầu session | Inject `git branch` + last commit vào context |
| **PreCompact** | Trước khi Claude compact context | Inject snapshot: branch, last commit, 15 file vừa edit — giữ continuity sau compact |
| **Notification** | Claude cần notify user (task xong, cần input) | Desktop notification cross-platform (macOS osascript / Linux notify-send / Windows PowerShell). Log vào `.claude/.notifications.log`. Opt-out: `CLAUDE_DISABLE_NOTIFY=1` |
| **SubagentStop** | Sau khi subagent (delegated task) xong | Append cost/agent metadata vào `.claude/usage.jsonl` với `kind=subagent` + `agent=<name>`. Cho phép `/usage --by-agent` break down spend per agent (không double-count với main `Stop` total) |
| **Stop** | Sau mỗi assistant turn | Append cost/session metadata vào `.claude/usage.jsonl` (cumulative; `/usage` dedupe theo `session_id`) |

Tất cả hooks viết bằng **Python** (không cần `jq`).

**Budget warning (opt-in)**: set `CLAUDE_SESSION_BUDGET_USD=0.50` trong `.claude/settings.local.json` → record vượt ngưỡng sẽ có field `"warn":"over_budget"`.

## Permissions mở rộng

`.claude/settings.json` cho phép sẵn ~40+ lệnh an toàn (git read-only, ls, cat, npm/pnpm/yarn/bun, python/pytest, go/cargo, docker read-only…) → ít prompt hỏi hơn.

Lệnh nguy hiểm (`rm`, `git push`, `git reset --hard`, `docker rm`) → ở trạng thái `ask`.
File nhạy cảm (`.env`, `*.pem`, `*.key`, `*credentials*`) → `deny`.

**Monorepo / sibling repos**: thêm `permissions.additionalDirectories` trong `.claude/settings.local.json` (gitignored) để cho Claude đọc thư mục ngoài cwd. Xem ví dụ trong `.claude/settings.local.json.example`.

## Output Styles

| Style | Khi nào dùng |
|-------|--------------|
| `senior-mentor` | Cần giải thích sâu, trade-offs, teaching |
| `concise` | Tác vụ đơn giản, muốn cực ngắn gọn |

Đặt trong `.claude/settings.local.json`: `"outputStyle": "senior-mentor"`.

## MCP Integration (2-tier setup)

**Tier 1 — Global** (dùng cho mọi project, setup 1 lần):
```bash
bash setup-mcp.sh --global   # in ra commands để copy-paste
```
→ Thích hợp cho: `filesystem`, `github`, `puppeteer`, `slack`, `linear`, `notion` (credential cá nhân dùng chung).

**Tier 2 — Per-project** (credential riêng từng project):
```bash
cd your-project
bash /path/to/claude-commands/setup-mcp.sh --project
```
→ Thích hợp cho: `postgres`, `mssql`, `mssql-dab`, `sentry`, `redis`, `jira`, `postman`, custom APIs.

**Nguyên tắc**:
- Token cá nhân dùng chung (GitHub, Slack) → **global**
- Credential project-specific (DB, Sentry org) → **per-project**, `.mcp.json` **gitignored**
- Global chỉ bật ≤4 server thực sự dùng hàng tuần

## StatusLine

Hiển thị `[Model] project-name | $cost` ở dưới màn hình Claude Code.

## Luồng làm việc điển hình

```
Feature mới (có BA spec — docx/xlsx/pdf/...):
/sync → /spec <files> → trả lời Ambiguities → /plan → /design → /code → use test-runner → use code-reviewer → /commit → /ship → /pr

Feature mới (không có spec hình thức):
/sync → /plan <desc> → /design <screen> → /code <task> → use test-runner → use code-reviewer → /commit → /ship → /pr

Feature UI-only (chưa cần backend):
/design <screen> → preview trong browser → /code port vào src/

Chưa biết đi hướng nào:
/brainstorm <problem> → pick 1-2 options → /plan <chosen> → /code

Fix bug:
/debug <symptom> → /code <fix> → use test-runner

Refactor:
/test (viết tests trước) → /refactor → use code-reviewer

Trước release:
/ship → use security-auditor → use test-runner
```

## Trước / Sau

| Khía cạnh | Trước | Sau |
|---|---|---|
| Slash commands | 9 | 19 |
| Subagents | 0 | 7 |
| Skills | 0 | 5 |
| CLAUDE.md | ❌ | ✅ |
| Hooks | ❌ | ✅ (8 events / 9 hooks) |
| Decision records | ❌ | ✅ (`/adr` + `decisions/`) |
| Checkpoint save/resume | ❌ | ✅ (`/checkpoint`) |
| Cross-platform Python | ❌ | ✅ (`.claude/hooks/_py.sh` wrapper) |
| Per-agent cost tracking | ❌ | ✅ (`SubagentStop` + `/usage --by-agent`) |
| CLAUDE.md template bootstrap | ❌ | ✅ (`install.sh --template`) |
| StatusLine | ❌ | ✅ |
| Output styles | 0 | 2 |
| Permissions | ~3 rules | ~40+ rules |
| MCP template | ❌ | ✅ (13 servers) |
| Dangerous cmd guard | ❌ | ✅ (ask mode) |
| Secret file block | ❌ | ✅ (deny) |
| Cost observability | ❌ | ✅ (`/usage` + Stop hook) |

## Optional dependencies cho `/spec`

`/spec` đọc native được `.md` / `.txt` / `.pdf` / ảnh / URL / text. Để parse `.docx` / `.xlsx` cần thêm:

```bash
pip install python-docx openpyxl
# hoặc cài pandoc làm fallback (handle docx phức tạp tốt hơn)
```

Không cài cũng OK — `/spec` sẽ in fallback message và bỏ qua file không parse được, gợi ý user export sang `.md`/`.pdf`.

## Ghi chú bảo mật

- **Không commit**: `.claude/settings.local.json`, `.mcp.json`, `.claude/edit-log.txt`, `.claude/usage.jsonl`, `PLAN.md`, `SPEC.md` (hai cái cuối ephemeral — dùng `/spec --save=docs/specs/<slug>.md` nếu cần track)
- Settings hooks ở `ask` mode — bạn vẫn có quyền approve/deny từng lệnh
- `deny` rules block Claude đọc `.env`, `*.pem`, `*.key`, files chứa "credentials"
