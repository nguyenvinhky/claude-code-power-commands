#!/usr/bin/env python3
"""SubagentStop hook — log subagent completion to usage.jsonl.

Fires when a delegated subagent task completes. Records cost/duration with
kind=subagent and the agent name, so /usage --by-agent can break down spend
per agent independently from main-turn aggregation. Main-turn aggregation
should EXCLUDE kind=subagent records (the parent Stop record already includes
those costs in its total — counting both would double-count).

Silent on failure; never blocks the parent turn.
"""
import datetime
import json
import os
import sys


try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

cost = (data.get("cost") or {}).get("total_cost_usd", 0) or 0
sid = data.get("session_id", "") or ""
m = data.get("model", {})
model = (m.get("display_name") if isinstance(m, dict) else m) or ""
dur = data.get("duration_ms", 0) or 0

# Field name varies across Claude Code versions — try the likely candidates.
agent = (
    data.get("subagent_type")
    or data.get("agent_name")
    or data.get("agent_type")
    or "unknown"
)

branch = "no-git"
if os.path.exists(".git/HEAD"):
    try:
        branch = open(".git/HEAD", "r", encoding="utf-8").read().strip().split("/")[-1] or "no-git"
    except Exception:
        pass

cwd = os.path.basename(os.getcwd())

rec = {
    "ts": datetime.datetime.now().isoformat(timespec="seconds"),
    "session_id": sid,
    "model": model,
    "cost_usd": cost,
    "duration_ms": dur,
    "branch": branch,
    "cwd": cwd,
    "agent": agent,
    "kind": "subagent",
}

p = ".claude/usage.jsonl"
try:
    os.makedirs(".claude", exist_ok=True)
    lines = open(p, "r", encoding="utf-8").readlines() if os.path.exists(p) else []
    lines.append(json.dumps(rec) + "\n")
    if len(lines) > 5000:
        lines = lines[-4000:]
    open(p, "w", encoding="utf-8").writelines(lines)
except Exception:
    pass

sys.exit(0)
