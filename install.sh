#!/usr/bin/env bash
# ============================================================
# Claude Code Power Commands — One-line Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/nguyenvinhky/claude-code-power-commands/main/install.sh | bash
#
# Options (when piping to bash, pass via `bash -s -- <flags>`):
#   --ref <tag|branch|sha>    Pin to a specific git ref (default: main)
#   --dir <path>              Install into <path> instead of current directory
#   --repo <owner/name>       Override source repo (default: nguyenvinhky/claude-code-power-commands)
#
# Examples:
#   curl -fsSL <url>/install.sh | bash -s -- --ref v1.0.0
#   curl -fsSL <url>/install.sh | bash -s -- --dir ~/projects/foo
# ============================================================

set -euo pipefail

REPO="nguyenvinhky/claude-code-power-commands"
REF="main"
TARGET_DIR="$PWD"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)  REF="$2"; shift 2 ;;
    --dir)  TARGET_DIR="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,20p' "$0" 2>/dev/null || echo "See script header for usage."
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

echo "🤖 Claude Code Power Commands — Installer"
echo "=========================================="
echo "   Repo:   $REPO"
echo "   Ref:    $REF"
echo "   Target: $TARGET_DIR"
echo ""

# ---- Env checks ----
for cmd in git bash; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ Required command not found: $cmd" >&2
    echo "   Please install $cmd and try again." >&2
    exit 1
  fi
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

# ---- Clone to temp & cleanup on exit ----
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'ccpc')"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

echo "📥 Cloning $REPO@$REF …"
git clone --depth 1 --branch "$REF" "https://github.com/${REPO}.git" "$TMP_DIR" >/dev/null 2>&1 || {
  # Fallback: branch flag fails on commit SHAs — clone default then checkout
  echo "   (falling back to full clone for ref resolution)"
  rm -rf "$TMP_DIR" && mkdir -p "$TMP_DIR"
  git clone "https://github.com/${REPO}.git" "$TMP_DIR" >/dev/null 2>&1
  git -C "$TMP_DIR" checkout "$REF" >/dev/null 2>&1
}

SETUP_SCRIPT="$TMP_DIR/setup-claude-commands.sh"
if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "❌ setup-claude-commands.sh not found in repo" >&2
  exit 1
fi

echo "⚙️  Running setup in $TARGET_DIR …"
echo ""
( cd "$TARGET_DIR" && INSTALL_TARGET="$TARGET_DIR" bash "$SETUP_SCRIPT" )

echo ""
echo "✨ Done! Open Claude Code in $TARGET_DIR to start."
echo "   Try: /sync → /plan → /code → /test → /review → /ship"
