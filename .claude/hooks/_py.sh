#!/usr/bin/env bash
# Cross-platform Python invoker for hooks + statusLine.
# Tries `py` (Windows Python launcher), then `python3`, then `python`, in order.
# Each candidate must actually run — this filters out the Windows App Execution
# Alias stub at C:\Users\*\AppData\Local\Microsoft\WindowsApps\python.exe that
# only opens the Microsoft Store and exits non-zero.
#
# Exit 0 silently if nothing works — hook degrades to no-op rather than
# spamming errors.
if command -v py >/dev/null 2>&1 && py -c "" >/dev/null 2>&1; then
  exec py "$@"
elif command -v python3 >/dev/null 2>&1 && python3 -c "" >/dev/null 2>&1; then
  exec python3 "$@"
elif command -v python >/dev/null 2>&1 && python -c "" >/dev/null 2>&1; then
  exec python "$@"
fi
exit 0
