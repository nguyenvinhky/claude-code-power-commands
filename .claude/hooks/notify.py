#!/usr/bin/env python3
"""Notification hook — desktop notification when Claude Code pings the user.

Cross-platform best-effort: macOS (osascript), Linux (notify-send),
Windows (PowerShell BurntToast or NotifyIcon fallback).
Always also appends a line to .claude/.notifications.log for traceability.
Never fails — silent skip if platform tooling missing.

Opt-out: set CLAUDE_DISABLE_NOTIFY=1.
"""
import datetime
import json
import os
import platform
import shutil
import subprocess
import sys


if os.environ.get("CLAUDE_DISABLE_NOTIFY"):
    sys.exit(0)

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

msg = (data.get("message") or "Claude Code needs your attention").strip()
title = "Claude Code"

# Trace log first (always works)
try:
    os.makedirs(".claude", exist_ok=True)
    with open(".claude/.notifications.log", "a", encoding="utf-8") as f:
        f.write(f"{datetime.datetime.now().isoformat(timespec='seconds')}\t{msg}\n")
except Exception:
    pass


def _shell_safe(s: str) -> str:
    return s.replace('"', "'").replace("\n", " ")


sys_name = platform.system()
msg_safe = _shell_safe(msg)
title_safe = _shell_safe(title)

try:
    if sys_name == "Darwin":
        subprocess.run(
            ["osascript", "-e", f'display notification "{msg_safe}" with title "{title_safe}"'],
            capture_output=True, timeout=5,
        )
    elif sys_name == "Linux":
        if shutil.which("notify-send"):
            subprocess.run(["notify-send", title_safe, msg_safe], capture_output=True, timeout=5)
    elif sys_name == "Windows":
        # Try BurntToast (PowerShell module); fall back to balloon tip via NotifyIcon.
        ps = (
            f"if (Get-Module -ListAvailable -Name BurntToast) {{ "
            f"  New-BurntToastNotification -Text '{title_safe}','{msg_safe}' "
            f"}} else {{ "
            f"  Add-Type -AssemblyName System.Windows.Forms; "
            f"  $n = New-Object System.Windows.Forms.NotifyIcon; "
            f"  $n.Icon = [System.Drawing.SystemIcons]::Information; "
            f"  $n.Visible = $true; "
            f"  $n.ShowBalloonTip(5000, '{title_safe}', '{msg_safe}', "
            f"  [System.Windows.Forms.ToolTipIcon]::Info); "
            f"  Start-Sleep -Milliseconds 5500; $n.Dispose() "
            f"}}"
        )
        subprocess.run(
            ["powershell", "-NoProfile", "-WindowStyle", "Hidden", "-Command", ps],
            capture_output=True, timeout=8,
        )
except Exception:
    pass

sys.exit(0)
