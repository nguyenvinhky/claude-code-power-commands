#!/bin/bash

# ============================================================
# MCP Servers Setup Helper for Gemini CLI
# Sets up commonly-used MCP servers at the correct scope.
#
# Usage:
#   bash setup-mcp.sh              # interactive
#   bash setup-mcp.sh --global     # print generic servers commands
#   bash setup-mcp.sh --project    # add project-specific servers
# ============================================================

set -e

MODE="${1:-}"

echo "🔌 MCP Setup Helper (Gemini CLI)"
echo "================================"
echo ""
echo "Scope rules:"
echo "  🌐 GLOBAL  (Local config)             — generic tools used everywhere"
echo "             filesystem, github, google-search, slack"
echo "  📁 PROJECT (./.mcp.json)              — project-specific credentials"
echo "             postgres, mssql, sentry, custom APIs"
echo ""

# ---- GLOBAL SERVERS ----

setup_global() {
  echo "--- GLOBAL MCP servers instructions ---"
  echo ""
  echo "Gemini CLI loads MCP servers from its global configuration."
  echo ""

  # Filesystem: access to ~/Documents and ~/Downloads
  echo "→ filesystem (access ~/Documents, ~/Downloads)"
  echo "  npx -y @modelcontextprotocol/server-filesystem \"\$HOME/Documents\" \"\$HOME/Downloads\""
  echo ""

  # GitHub: requires GITHUB_TOKEN
  echo "→ github (requires GITHUB_TOKEN env var)"
  echo "  export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx"
  echo "  npx -y @modelcontextprotocol/server-github"
  echo ""

  # Google Search:
  echo "→ google-search (requires API key)"
  echo "  npx -y @modelcontextprotocol/server-google-search"
  echo ""

  cat <<'EOF'
Note: Gemini CLI configuration for MCP may vary depending on your installation.
Please check your local gemini config directory.

Why these are global:
  - Same credentials/paths across every project
  - One setup, reused everywhere

EOF
}

# ---- PROJECT SERVERS ----

setup_project() {
  if [ ! -d .gemini-commands ]; then
    echo "⚠️  Run this from a project root (no .gemini-commands/ here)."
    exit 1
  fi

  echo "--- Setting up PROJECT MCP (./.mcp.json) ---"
  echo ""

  if [ -f .mcp.json ]; then
    echo "⚠️  .mcp.json already exists — not overwriting."
    exit 0
  fi

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/.mcp.json.example" ]; then
    cp "$SCRIPT_DIR/.mcp.json.example" .mcp.json
    echo "✅ Copied .mcp.json.example → .mcp.json"
  fi

  # Ensure .mcp.json is gitignored (contains credentials)
  if [ -f .gitignore ]; then
    grep -q "^.mcp.json$" .gitignore || echo ".mcp.json" >> .gitignore
    echo "✅ Added .mcp.json to .gitignore"
  fi

  cat <<'EOF'

Next steps:
  1. Open .mcp.json
  2. Delete servers you don't need (keep only postgres/mssql/sentry/etc. that are project-specific)
  3. Replace placeholders (connection strings, org names)
  4. Restart Gemini CLI to load new MCP servers

EOF
}

case "$MODE" in
  --global)
    setup_global
    ;;
  --project)
    setup_project
    ;;
  *)
    echo "Choose one:"
    echo "  bash setup-mcp.sh --global    # print commands to set up global servers"
    echo "  bash setup-mcp.sh --project   # copy .mcp.json.example into current project"
    echo ""
    setup_global
    echo ""
    echo "----"
    echo "For per-project setup, cd into the project and run:"
    echo "  bash $(pwd)/setup-mcp.sh --project"
    ;;
esac
