#!/bin/bash

# ============================================================
# MCP Servers Setup Helper
# Sets up commonly-used MCP servers at the correct scope.
#
# Usage:
#   bash setup-mcp.sh              # interactive
#   bash setup-mcp.sh --global     # add generic servers globally
#   bash setup-mcp.sh --project    # add project-specific servers
# ============================================================

set -e

MODE="${1:-}"

echo "🔌 MCP Setup Helper"
echo "==================="
echo ""
echo "Scope rules:"
echo "  🌐 GLOBAL  (claude mcp add -s user)  — generic tools used everywhere"
echo "             filesystem, github, puppeteer, slack"
echo "  📁 PROJECT (./.mcp.json)             — project-specific credentials"
echo "             postgres, mssql, mssql-dab, sentry, custom APIs"
echo ""

# ---- GLOBAL SERVERS ----

setup_global() {
  echo "--- Setting up GLOBAL MCP servers (claude mcp add -s user) ---"
  echo ""

  # Filesystem: access to ~/Documents and ~/Downloads
  echo "→ filesystem (access ~/Documents, ~/Downloads)"
  echo "  claude mcp add -s user filesystem -- npx -y @modelcontextprotocol/server-filesystem \"\$HOME/Documents\" \"\$HOME/Downloads\""
  echo ""

  # GitHub: requires GITHUB_TOKEN
  echo "→ github (requires GITHUB_TOKEN env var)"
  echo "  export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx"
  echo "  claude mcp add -s user github -e GITHUB_PERSONAL_ACCESS_TOKEN=\$GITHUB_TOKEN -- npx -y @modelcontextprotocol/server-github"
  echo ""

  # Puppeteer: browser automation
  echo "→ puppeteer (browser automation, no creds)"
  echo "  claude mcp add -s user puppeteer -- npx -y @modelcontextprotocol/server-puppeteer"
  echo ""

  cat <<'EOF'
Run the commands above in your shell to actually add them globally.
Then verify with:
  claude mcp list

Why these are global:
  - Same credentials/paths across every project
  - No risk of committing secrets to a project .mcp.json
  - One setup, reused everywhere

EOF
}

# ---- PROJECT SERVERS ----

setup_project() {
  if [ ! -d .claude ]; then
    echo "⚠️  Run this from a project root (no .claude/ here)."
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
  4. Set any required env vars:
       export SENTRY_AUTH_TOKEN=...
       export MSSQL_CONNECTION_STRING="Server=...;Database=...;..."
  5. For mssql-dab (Microsoft official): install .NET 8+ and run:
       dotnet tool install -g Microsoft.DataApiBuilder
       dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')"
       dab add <TableName> --source dbo.<TableName> --permissions "anonymous:read"
  6. Restart Claude Code → run /mcp to verify

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
