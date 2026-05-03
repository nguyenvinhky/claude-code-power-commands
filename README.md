# 🤖 Power Commands for Gemini CLI

Bộ setup đầy đủ tính năng cho **Gemini CLI** — slash commands, subagents, context optimization, và quy trình làm việc chuẩn mực. Drop vào bất kỳ project nào để dùng ngay.

## 🚀 Quick Install (one-liner)

Chạy ngay ở **gốc project** bạn muốn cài:

```bash
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/gemini-power-commands/main/install.sh | bash
```

Installer sẽ clone repo vào temp, copy `.gemini-commands/`, `GEMINI.md`, `.mcp.json.example` vào thư mục hiện tại, rồi tự cleanup. An toàn chạy lại — file đã tồn tại sẽ được bỏ qua.

### Options nâng cao

```bash
# Cài vào thư mục khác cwd
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/gemini-power-commands/main/install.sh | bash -s -- --dir ~/projects/my-app

# Kiểm tra script trước khi chạy (khuyến nghị cho lần đầu)
curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/gemini-power-commands/main/install.sh -o install.sh
cat install.sh    # đọc qua
bash install.sh
```

### Cách thủ công (nếu đã clone repo)

```bash
git clone https://github.com/nguyenvinhky/gemini-power-commands.git
cd your-project
bash /path/to/gemini-power-commands/setup-gemini-commands.sh
```
## Cấu trúc

```
.
├── GEMINI.md                          # Context auto-load vào Gemini CLI mỗi session
├── .mcp.json.example                  # Template MCP servers
├── design/                            # UI/UX mockups sinh bởi /design (versioned)
└── .gemini-commands/
    ├── commands/                      # 12 slash commands (mô phỏng, tiếng Việt)
    ├── agents/                        # 5 subagents (English, tối ưu cho Gemini)
    ├── skills/                        # File-based skills (pr-review, changelog-gen)
    └── output-styles/                 # senior-mentor, concise
```

## 12 Slash Commands

| Command | Mục đích | Không làm |
|---------|----------|-----------|
| `/plan` | Phân tích & lên kế hoạch chi tiết | ❌ Không viết code |
| `/ask` | Hỏi & đáp, giải thích code | ❌ Không tự ý thay đổi file |
| `/brainstorm` | Sinh 6-12 options (divergent), có wild card | ❌ Không đưa recommendation |
| `/code` | Implement code (auto-sync context) | ❌ Không refactor ngoài phạm vi |
| `/review` | Review: bugs, security, performance | ❌ Không tự fix (chỉ report) |
| `/debug` | Root cause analysis cho bugs | ❌ Không fix khi chưa xác nhận cause |
| `/test` | Viết tests chất lượng cao | ❌ Không viết tests chỉ để coverage |
| `/refactor` | Cải thiện code, không đổi behavior | ❌ Không refactor khi chưa có tests |
| `/design` | Sinh UI/UX HTML preview + DESIGN.md, versioning | ❌ Không đụng code frontend |
| `/sync` | Đọc lại codebase, cập nhật context | ❌ Không thay đổi gì |
| `/ship` | Pre-deploy checklist | ❌ Không tự deploy |
| `/usage` | Thống kê cost/token (nếu có hỗ trợ từ CLI) | ❌ Không edit, không xoá file |

## 5 Subagents

Subagents của Gemini CLI được gọi qua `invoke_agent` → giúp xử lý các tác vụ phức tạp mà không làm loãng context chính.

| Agent | Vai trò | Công cụ chủ đạo |
|-------|---------|-----------------|
| `code-reviewer` | Audit bugs/security/perf/style | `read_file`, `grep_search` |
| `test-runner` | Chạy test suite, phân tích failures | `run_shell_command` |
| `debugger` | Root cause analysis có hệ thống | `grep_search`, `read_file` |
| `security-auditor` | OWASP Top 10, secret scan | `grep_search` |
| `doc-writer` | Viết README, API docs, ADR, comments | `read_file`, `write_file` |

Cách dùng: `"hãy dùng code-reviewer để audit thay đổi vừa rồi"`.

## Skills

Skills là các capabilities file-based trong `.gemini-commands/skills/<name>/SKILL.md`.

| Skill | Trigger | Vai trò |
|-------|---------|---------|
| `pr-review` | "review PR #N", PR URL | Fetch diff qua `gh`, audit 5 dimensions, report |
| `changelog-gen` | "generate changelog" | Group commits theo format Keep-a-Changelog |

## MCP Integration

Hỗ trợ tích hợp mạnh mẽ với các MCP servers (Postgres, GitHub, Google Search, ...) giúp Gemini truy cập dữ liệu bên ngoài thời gian thực.

## Luồng làm việc điển hình

```
Feature mới:
/sync → /plan <desc> → /design <screen> → /code <task> → use test-runner → use code-reviewer → /ship
```

## Ghi chú bảo mật

- **Không commit**: `.gemini-commands/settings.local.json`, `.mcp.json`
- `deny` rules block Gemini đọc `.env`, `*.pem`, `*.key`, files chứa "credentials"
