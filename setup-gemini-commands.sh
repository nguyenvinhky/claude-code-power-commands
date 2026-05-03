#!/bin/bash

# ============================================================
# Gemini Power Commands — Setup Script
# Chạy script này ở thư mục gốc của bất kỳ project nào
# Usage:   bash setup-gemini-commands.sh
# Env:     INSTALL_TARGET=<path>  cài vào <path> thay vì cwd
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Honor INSTALL_TARGET env var (set by install.sh one-liner).
# Fall back to current working directory for standalone use.
if [ -n "${INSTALL_TARGET:-}" ]; then
  if [ ! -d "$INSTALL_TARGET" ]; then
    echo "❌ INSTALL_TARGET không tồn tại: $INSTALL_TARGET" >&2
    exit 1
  fi
  cd "$INSTALL_TARGET"
fi

echo "🤖 Gemini Power Commands Setup"
echo "===================================="
echo "   Target: $PWD"

# Tạo các thư mục cần thiết
mkdir -p .gemini-commands/commands .gemini-commands/agents .gemini-commands/output-styles .gemini-commands/skills
echo "✅ Tạo thư mục .gemini-commands/{commands,agents,output-styles,skills}"

# Copy commands
cp "$SCRIPT_DIR"/.gemini-commands/commands/*.md .gemini-commands/commands/
echo "✅ Copy slash commands"

# Copy agents
cp "$SCRIPT_DIR"/.gemini-commands/agents/*.md .gemini-commands/agents/
echo "✅ Copy subagents"

# Copy output styles
cp "$SCRIPT_DIR"/.gemini-commands/output-styles/*.md .gemini-commands/output-styles/
echo "✅ Copy output styles"

# Copy skills
if [ -d "$SCRIPT_DIR"/.gemini-commands/skills ]; then
  cp -r "$SCRIPT_DIR"/.gemini-commands/skills/* .gemini-commands/skills/ 2>/dev/null || true
  SKILL_COUNT=$(find .gemini-commands/skills -name SKILL.md 2>/dev/null | wc -l)
  echo "✅ Copy $SKILL_COUNT skills"
fi

# Copy settings.json nếu chưa có
if [ ! -f .gemini-commands/settings.json ]; then
  cp "$SCRIPT_DIR"/.gemini-commands/settings.json .gemini-commands/settings.json 2>/dev/null || true
  echo "✅ Copy .gemini-commands/settings.json"
fi

# Copy settings.local.json.example
cp "$SCRIPT_DIR"/.gemini-commands/settings.local.json.example .gemini-commands/settings.local.json.example 2>/dev/null || true
echo "✅ Copy .gemini-commands/settings.local.json.example"

# Copy GEMINI.md nếu chưa có
if [ ! -f GEMINI.md ]; then
  cp "$SCRIPT_DIR"/GEMINI.md GEMINI.md
  echo "✅ Copy GEMINI.md"
else
  echo "⚠️  GEMINI.md đã tồn tại — bỏ qua"
fi

# Copy .mcp.json.example
cp "$SCRIPT_DIR"/.mcp.json.example .mcp.json.example
echo "✅ Copy .mcp.json.example"

# Gitignore cho các file không nên commit
if [ -f .gitignore ]; then
  grep -q "^.gemini-commands/settings.local.json$" .gitignore || cat >> .gitignore <<'EOF'

# Gemini CLI Power Commands local files
.gemini-commands/settings.local.json
.gemini-commands/edit-log.txt
.gemini-commands/usage.jsonl
.gemini-commands/.session/
.gemini-commands/skills/*.local.md
.mcp.json
GEMINI.local.md
EOF
  echo "✅ Cập nhật .gitignore"
fi

echo ""
echo "📋 Đã cài đặt:"
echo "   Commands: $(ls .gemini-commands/commands/*.md 2>/dev/null | wc -l)"
echo "   Agents:   $(ls .gemini-commands/agents/*.md 2>/dev/null | wc -l)"
echo "   Styles:   $(ls .gemini-commands/output-styles/*.md 2>/dev/null | wc -l)"
echo "   Skills:   $(find .gemini-commands/skills -name SKILL.md 2>/dev/null | wc -l)"

echo ""
echo "✨ Hoàn tất! Bước tiếp theo:"
echo "   1. Mở Gemini CLI trong project này"
echo "   2. Gemini sẽ tự đọc GEMINI.md"
echo "   3. Thử: /sync → /plan → /code → /test → /review → /ship"
echo ""
echo "💡 Tùy chọn:"
echo "   - Copy .gemini-commands/settings.local.json.example → .gemini-commands/settings.local.json"
echo "   - Copy .mcp.json.example → .mcp.json (để bật MCP servers)"
