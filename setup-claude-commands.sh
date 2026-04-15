#!/bin/bash

# ============================================================
# Claude Code Power Commands — Setup Script
# Chạy script này ở thư mục gốc của bất kỳ project nào
# Usage: bash setup-claude-commands.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🤖 Claude Code Power Commands Setup"
echo "===================================="

# Tạo các thư mục cần thiết
mkdir -p .claude/commands .claude/agents .claude/output-styles .claude/skills
echo "✅ Tạo thư mục .claude/{commands,agents,output-styles,skills}"

# Copy commands
cp "$SCRIPT_DIR"/.claude/commands/*.md .claude/commands/
echo "✅ Copy 9 slash commands"

# Copy agents
cp "$SCRIPT_DIR"/.claude/agents/*.md .claude/agents/
echo "✅ Copy 5 subagents (sonnet)"

# Copy output styles
cp "$SCRIPT_DIR"/.claude/output-styles/*.md .claude/output-styles/
echo "✅ Copy 2 output styles"

# Copy skills (each skill is a subdirectory with SKILL.md)
if [ -d "$SCRIPT_DIR"/.claude/skills ]; then
  cp -r "$SCRIPT_DIR"/.claude/skills/* .claude/skills/ 2>/dev/null || true
  SKILL_COUNT=$(find .claude/skills -name SKILL.md 2>/dev/null | wc -l)
  echo "✅ Copy $SKILL_COUNT skills"
fi

# Copy settings.json nếu chưa có
if [ ! -f .claude/settings.json ]; then
  cp "$SCRIPT_DIR"/.claude/settings.json .claude/settings.json
  echo "✅ Copy .claude/settings.json (hooks + permissions + statusLine)"
else
  echo "⚠️  .claude/settings.json đã tồn tại — bỏ qua (merge thủ công nếu cần)"
fi

# Copy settings.local.json.example
cp "$SCRIPT_DIR"/.claude/settings.local.json.example .claude/settings.local.json.example
echo "✅ Copy .claude/settings.local.json.example"

# Copy CLAUDE.md nếu chưa có
if [ ! -f CLAUDE.md ]; then
  cp "$SCRIPT_DIR"/CLAUDE.md CLAUDE.md
  echo "✅ Copy CLAUDE.md"
else
  echo "⚠️  CLAUDE.md đã tồn tại — bỏ qua"
fi

# Copy .mcp.json.example
cp "$SCRIPT_DIR"/.mcp.json.example .mcp.json.example
echo "✅ Copy .mcp.json.example"

# Gitignore cho các file không nên commit
if [ -f .gitignore ]; then
  grep -q "^.claude/settings.local.json$" .gitignore || cat >> .gitignore <<'EOF'

# Claude Code local files
.claude/settings.local.json
.claude/edit-log.txt
.claude/.session/
.claude/skills/*.local.md
.mcp.json
CLAUDE.local.md
EOF
  echo "✅ Cập nhật .gitignore"
fi

echo ""
echo "📋 Đã cài đặt:"
echo "   Commands: $(ls .claude/commands/*.md 2>/dev/null | wc -l)"
echo "   Agents:   $(ls .claude/agents/*.md 2>/dev/null | wc -l)"
echo "   Styles:   $(ls .claude/output-styles/*.md 2>/dev/null | wc -l)"
echo "   Skills:   $(find .claude/skills -name SKILL.md 2>/dev/null | wc -l)"

echo ""
echo "✨ Hoàn tất! Bước tiếp theo:"
echo "   1. Mở Claude Code trong project này"
echo "   2. Claude sẽ tự đọc CLAUDE.md"
echo "   3. Thử: /sync → /plan → /code → /test → /review → /ship"
echo ""
echo "💡 Tùy chọn:"
echo "   - Copy .claude/settings.local.json.example → .claude/settings.local.json"
echo "   - Copy .mcp.json.example → .mcp.json (để bật MCP servers)"
