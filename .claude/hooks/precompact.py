#!/usr/bin/env python3
"""PreCompact hook — preserve recent edits + git context across compaction.

Runs before Claude compacts the conversation; injects a snapshot so post-compact
turns still know what was just touched, what branch we're on, and the last commit.
"""
import json
import os
import subprocess


def run(cmd: str) -> str:
    try:
        return subprocess.check_output(
            cmd, shell=True, text=True, stderr=subprocess.DEVNULL, timeout=2
        ).strip()
    except Exception:
        return ""


branch = run("git branch --show-current") or "no-git"
last_commit = run("git log -1 --oneline") or "none"
status_short = run("git status --porcelain")
dirty_count = len([l for l in status_short.splitlines() if l.strip()]) if status_short else 0

edits = []
log_path = ".claude/edit-log.txt"
if os.path.exists(log_path):
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            edits = [l.strip() for l in f.readlines()[-15:] if l.strip()]
    except Exception:
        pass

lines = [
    "## Pre-compact context snapshot",
    f"- Branch: `{branch}` ({dirty_count} dirty file(s))",
    f"- Last commit: {last_commit}",
]
if edits:
    lines.append(f"- Recent edits (last {len(edits)}):")
    for e in edits:
        parts = e.split("\t")
        if len(parts) >= 3:
            lines.append(f"  - {parts[1]}: {parts[2]}")
        else:
            lines.append(f"  - {e}")

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreCompact",
        "additionalContext": "\n".join(lines),
    }
}))
