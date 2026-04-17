# 🤖 Claude Code Power Commands

Bộ setup Claude Code đầy đủ tính năng — slash commands, subagents, hooks, permissions, statusLine, output styles, MCP template. Drop vào bất kỳ project nào để dùng ngay.

## 🚀 Quick Install (one-liner)

Chạy ngay ở **gốc project** bạn muốn cài:

```bash
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash
```

Installer sẽ clone repo vào temp, copy `.claude/`, `CLAUDE.md`, `.mcp.json.example` vào thư mục hiện tại, rồi tự cleanup. An toàn chạy lại — file đã tồn tại sẽ được bỏ qua.

### Options nâng cao

```bash
# Pin về version ổn định (khuyến nghị khi đã có release)
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash -s -- --ref v1.0.0

# Cài vào thư mục khác cwd
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash -s -- --dir ~/projects/my-app

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
├── .mcp.json.example                  # Template MCP servers
├── design/                            # UI/UX mockups sinh bởi /design (versioned)
└── .claude/
    ├── settings.json                  # Hooks + permissions + statusLine
    ├── settings.local.json.example    # Personal overrides (gitignored)
    ├── commands/                      # 10 slash commands (tiếng Việt)
    ├── agents/                        # 5 subagents (English, sonnet)
    ├── skills/                        # File-based skills (pr-review, changelog-gen)
    └── output-styles/                 # senior-mentor, concise
```

## 10 Slash Commands

| Command | Mục đích | Không làm |
|---------|----------|-----------|
| `/plan` | Phân tích & lên kế hoạch chi tiết | ❌ Không viết code |
| `/ask` | Hỏi & đáp, giải thích code | ❌ Không tự ý thay đổi file |
| `/code` | Implement code (auto-sync context) | ❌ Không refactor ngoài phạm vi |
| `/review` | Review: bugs, security, performance | ❌ Không tự fix (chỉ report) |
| `/debug` | Root cause analysis cho bugs | ❌ Không fix khi chưa xác nhận cause |
| `/test` | Viết tests chất lượng cao | ❌ Không viết tests chỉ để coverage |
| `/refactor` | Cải thiện code, không đổi behavior | ❌ Không refactor khi chưa có tests |
| `/design` | Sinh UI/UX HTML preview + DESIGN.md, versioning, optional screenshot | ❌ Không đụng code frontend |
| `/sync` | Đọc lại codebase, cập nhật context | ❌ Không thay đổi gì |
| `/ship` | Pre-deploy checklist | ❌ Không tự deploy |

## 5 Subagents

Subagents có **context window riêng** → không làm bẩn main context, có thể chạy song song.

| Agent | Vai trò | Model |
|-------|---------|-------|
| `code-reviewer` | Audit bugs/security/perf/style | sonnet |
| `test-runner` | Chạy test suite, phân tích failures | sonnet |
| `debugger` | Root cause analysis có hệ thống | sonnet |
| `security-auditor` | OWASP Top 10, secret scan | sonnet |
| `doc-writer` | Viết README, API docs, ADR, comments | sonnet |

Cách dùng: `"hãy dùng code-reviewer để audit thay đổi vừa rồi"`.

## Skills

Skills là các capabilities file-based trong `.claude/skills/<name>/SKILL.md`. Mỗi skill có `name` + `description` ở frontmatter để Claude biết khi nào trigger.

| Skill | Trigger | Vai trò |
|-------|---------|---------|
| `pr-review` | "review PR #N", PR URL | Fetch diff qua `gh`, audit 5 dimensions, report blockers/suggestions |
| `changelog-gen` | "generate changelog", "release notes" | Group commits theo conventional-commit → Keep-a-Changelog format |

Thêm skill mới: tạo `.claude/skills/<name>/SKILL.md` với frontmatter đầy đủ.

## Hooks (tự động hoá & an toàn)

Configured trong `.claude/settings.json`:

| Hook | Khi nào | Hành động |
|------|---------|-----------|
| **PreToolUse/Bash** | Trước mọi Bash command | Nếu match `rm -rf /`, `git push --force main`, `git reset --hard`, `DROP TABLE`... → hỏi lại user |
| **PostToolUse/Write\|Edit** | Sau khi ghi/sửa file | Append log vào `.claude/edit-log.txt` |
| **SessionStart** | Đầu session | Inject `git branch` + last commit vào context |

Tất cả hooks viết bằng **Python** (không cần `jq`).

## Permissions mở rộng

`.claude/settings.json` cho phép sẵn ~40+ lệnh an toàn (git read-only, ls, cat, npm/pnpm/yarn/bun, python/pytest, go/cargo, docker read-only…) → ít prompt hỏi hơn.

Lệnh nguy hiểm (`rm`, `git push`, `git reset --hard`, `docker rm`) → ở trạng thái `ask`.
File nhạy cảm (`.env`, `*.pem`, `*.key`, `*credentials*`) → `deny`.

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
→ Thích hợp cho: `filesystem`, `github`, `puppeteer`, `slack` (credential cá nhân dùng chung).

**Tier 2 — Per-project** (credential riêng từng project):
```bash
cd your-project
bash /path/to/claude-commands/setup-mcp.sh --project
```
→ Thích hợp cho: `postgres`, `mssql`, `mssql-dab`, `sentry`, `redis`, custom APIs.

**Nguyên tắc**:
- Token cá nhân dùng chung (GitHub, Slack) → **global**
- Credential project-specific (DB, Sentry org) → **per-project**, `.mcp.json` **gitignored**
- Global chỉ bật ≤4 server thực sự dùng hàng tuần

## StatusLine

Hiển thị `[Model] project-name | $cost` ở dưới màn hình Claude Code.

## Luồng làm việc điển hình

```
Feature mới:
/sync → /plan <desc> → /design <screen> → /code <task> → use test-runner → use code-reviewer → /ship

Feature UI-only (chưa cần backend):
/design <screen> → preview trong browser → /code port vào src/

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
| Slash commands | 9 | 10 |
| Subagents | 0 | 5 |
| Skills | 0 | 2 |
| CLAUDE.md | ❌ | ✅ |
| Hooks | ❌ | ✅ (3 events) |
| StatusLine | ❌ | ✅ |
| Output styles | 0 | 2 |
| Permissions | ~3 rules | ~40+ rules |
| MCP template | ❌ | ✅ (8 servers) |
| Dangerous cmd guard | ❌ | ✅ (ask mode) |
| Secret file block | ❌ | ✅ (deny) |

## Ghi chú bảo mật

- **Không commit**: `.claude/settings.local.json`, `.mcp.json`, `.claude/edit-log.txt`
- Settings hooks ở `ask` mode — bạn vẫn có quyền approve/deny từng lệnh
- `deny` rules block Claude đọc `.env`, `*.pem`, `*.key`, files chứa "credentials"
