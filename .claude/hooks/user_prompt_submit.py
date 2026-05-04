#!/usr/bin/env python3
"""UserPromptSubmit hook — inject lightweight runtime state on each turn.

Kept minimal to avoid noise: only injects when there is meaningful new info
(last test result file present, or working tree is dirty in an unusual way).
Set CLAUDE_DISABLE_PROMPT_CONTEXT=1 to silence entirely.
"""
import json
import os
import subprocess
import sys


if os.environ.get("CLAUDE_DISABLE_PROMPT_CONTEXT"):
    sys.exit(0)


def run(cmd: str) -> str:
    try:
        return subprocess.check_output(
            cmd, shell=True, text=True, stderr=subprocess.DEVNULL, timeout=2
        ).strip()
    except Exception:
        return ""


fragments = []

last_test_path = ".claude/.last-test"
if os.path.exists(last_test_path):
    try:
        with open(last_test_path, "r", encoding="utf-8") as f:
            content = f.read().strip()[:200]
        if content:
            fragments.append(f"Last test: {content}")
    except Exception:
        pass

# Only mention dirty tree if user is mid-edit; SessionStart already shows branch
status = run("git status --porcelain")
dirty = len([l for l in status.splitlines() if l.strip()]) if status else 0
if dirty > 0:
    fragments.append(f"Working tree: {dirty} uncommitted file(s)")

if not fragments:
    sys.exit(0)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": " | ".join(fragments),
    }
}))
