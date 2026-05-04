#!/usr/bin/env python3
"""PostToolUse lint-on-save — auto-format the file Claude just wrote.

Runs after Write/Edit. Only runs a formatter if (a) the binary is on PATH AND
(b) the project shows it has the formatter configured (avoids forcing prettier
defaults on a project that uses different style).

Opt-out: set CLAUDE_DISABLE_LINT_ON_SAVE=1.
Silent on success and on any failure — never blocks the user.
"""
import json
import os
import shutil
import subprocess
import sys


if os.environ.get("CLAUDE_DISABLE_LINT_ON_SAVE"):
    sys.exit(0)

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = data.get("tool_input", {}) or {}
tr = data.get("tool_response", {}) or {}
fp = ti.get("file_path") or (tr.get("filePath") if isinstance(tr, dict) else "") or ""
if not fp or not os.path.exists(fp):
    sys.exit(0)

ext = os.path.splitext(fp)[1].lower()


def _pkg_has_key(key: str) -> bool:
    if not os.path.exists("package.json"):
        return False
    try:
        with open("package.json", "r", encoding="utf-8") as f:
            return key in json.load(f)
    except Exception:
        return False


def _file_contains(path: str, needle: str) -> bool:
    if not os.path.exists(path):
        return False
    try:
        with open(path, "r", encoding="utf-8") as f:
            return needle in f.read()
    except Exception:
        return False


def has_config(formatter: str) -> bool:
    if formatter == "prettier":
        configs = [".prettierrc", ".prettierrc.json", ".prettierrc.js",
                   ".prettierrc.yml", ".prettierrc.yaml", "prettier.config.js"]
        return any(os.path.exists(c) for c in configs) or _pkg_has_key("prettier")
    if formatter == "black":
        return _file_contains("pyproject.toml", "[tool.black]")
    if formatter == "ruff":
        return _file_contains("pyproject.toml", "[tool.ruff") or os.path.exists("ruff.toml") or os.path.exists(".ruff.toml")
    if formatter == "rustfmt":
        return os.path.exists("Cargo.toml")
    if formatter == "gofmt":
        return os.path.exists("go.mod")
    return True


FORMATTERS = {
    ".py": ("black", ["black", "--quiet", fp]),
    ".js": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".jsx": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".ts": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".tsx": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".json": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".md": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".css": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".scss": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".html": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".yml": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".yaml": ("prettier", ["prettier", "--write", "--log-level=silent", fp]),
    ".go": ("gofmt", ["gofmt", "-w", fp]),
    ".rs": ("rustfmt", ["rustfmt", fp]),
}

picked = FORMATTERS.get(ext)
if not picked:
    sys.exit(0)

formatter, cmd = picked
if not shutil.which(cmd[0]):
    sys.exit(0)
if not has_config(formatter):
    sys.exit(0)

try:
    subprocess.run(cmd, capture_output=True, timeout=10, check=False)
except Exception:
    pass

sys.exit(0)
