#!/bin/bash

# ============================================================
# Claude Code Power Commands — Setup Script
# Chạy script này ở thư mục gốc của bất kỳ project nào
# Usage:   bash setup-claude-commands.sh
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

# Flag parsing. Also honors CLAUDE_TEMPLATE env (set by install.sh --template).
USE_TEMPLATE="${CLAUDE_TEMPLATE:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --template) USE_TEMPLATE=1; shift ;;
    -h|--help)
      echo "Usage: bash setup-claude-commands.sh [--template]"
      echo "  --template   Bootstrap CLAUDE.md from templates/CLAUDE.template.md."
      echo "               PROJECT_NAME is auto-substituted from target dir basename."
      echo "               Other {{...}} markers stay so the user can fill them in."
      echo "               Default (no flag): copy this repo's CLAUDE.md verbatim."
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

echo "🤖 Claude Code Power Commands Setup"
echo "===================================="
echo "   Target: $PWD"

# Tạo các thư mục cần thiết
mkdir -p .claude/commands .claude/agents .claude/output-styles .claude/skills .claude/hooks
echo "✅ Tạo thư mục .claude/{commands,agents,output-styles,skills,hooks}"

# Copy commands
cp "$SCRIPT_DIR"/.claude/commands/*.md .claude/commands/
echo "✅ Copy 18 slash commands"

# Copy agents
cp "$SCRIPT_DIR"/.claude/agents/*.md .claude/agents/
echo "✅ Copy 7 subagents (sonnet)"

# Copy output styles
cp "$SCRIPT_DIR"/.claude/output-styles/*.md .claude/output-styles/
echo "✅ Copy 2 output styles"

# Copy skills (each skill is a subdirectory with SKILL.md)
if [ -d "$SCRIPT_DIR"/.claude/skills ]; then
  cp -r "$SCRIPT_DIR"/.claude/skills/* .claude/skills/ 2>/dev/null || true
  SKILL_COUNT=$(find .claude/skills -name SKILL.md 2>/dev/null | wc -l)
  echo "✅ Copy $SKILL_COUNT skills"
fi

# Copy hook scripts (.py hooks + _py.sh cross-platform Python wrapper)
if [ -d "$SCRIPT_DIR"/.claude/hooks ]; then
  cp "$SCRIPT_DIR"/.claude/hooks/*.py "$SCRIPT_DIR"/.claude/hooks/*.sh .claude/hooks/ 2>/dev/null || true
  chmod +x .claude/hooks/*.sh 2>/dev/null || true
  HOOK_COUNT=$(ls .claude/hooks/*.py 2>/dev/null | wc -l)
  echo "✅ Copy $HOOK_COUNT hook scripts (+ _py.sh wrapper)"
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

# Copy CLAUDE.md nếu chưa có (template mode hoặc verbatim copy).
if [ ! -f CLAUDE.md ]; then
  if [ -n "$USE_TEMPLATE" ] && [ -f "$SCRIPT_DIR"/templates/CLAUDE.template.md ]; then
    PROJECT_NAME="$(basename "$PWD")"
    # sed -i differs BSD vs GNU; redirect to file is portable.
    sed "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" "$SCRIPT_DIR"/templates/CLAUDE.template.md > CLAUDE.md
    echo "✅ Copy CLAUDE.md (template — PROJECT_NAME=$PROJECT_NAME; grep '{{' CLAUDE.md để fill nốt)"
  else
    cp "$SCRIPT_DIR"/CLAUDE.md CLAUDE.md
    echo "✅ Copy CLAUDE.md"
  fi
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
.claude/usage.jsonl
.claude/.session/
.claude/.notifications.log
.claude/.last-test
.claude/.checkpoints/
.claude/hooks/__pycache__/
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
echo "   Hooks:    $(ls .claude/hooks/*.py 2>/dev/null | wc -l) script(s) + 4 inline"

echo ""
echo "✨ Hoàn tất! Bước tiếp theo:"
echo "   1. Mở Claude Code trong project này"
echo "   2. Claude sẽ tự đọc CLAUDE.md"
echo "   3. Thử: /sync → /plan → /code → /test → /review → /ship"
echo ""
echo "💡 Tùy chọn:"
echo "   - Copy .claude/settings.local.json.example → .claude/settings.local.json"
echo "   - Copy .mcp.json.example → .mcp.json (để bật MCP servers)"
