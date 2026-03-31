#!/bin/bash
# cc-sticky-notify — main notification script
# Usage:
#   arg mode:   notify.sh "title line" ["line 2" ...]   (Notification / PostToolUse hook)
#   stdin mode: echo '{"session_id":"..."}' | notify.sh   (Stop hook)

# Resolve the skill scripts directory; all dependencies live here
SKILL_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$SKILL_SCRIPTS/sticky-notify.app/Contents/MacOS/sticky-notify-app"
TIMESTAMP=$(date '+%H:%M:%S')
PROJECT=$(basename "$(pwd)")

# Always read session_id from hook JSON (piped via stdin by Claude Code for all hook types)
SESSION_SHORT=""
if [ ! -t 0 ]; then
    HOOK_JSON=$(cat)
    SESSION_SHORT=$(printf '%s' "$HOOK_JSON" | sed -nE 's/.*"session_id":"([a-zA-Z0-9]{8}).*/\1/p' 2>/dev/null || echo "")
fi
SESSION_KEY="${SESSION_SHORT:-default}"

if [ $# -gt 0 ]; then
    # Arg mode: use provided text, append timestamp and project name
    LINES=("$@" "Time: $TIMESTAMP" "Project: $PROJECT")
else
    # Stdin mode: Stop hook — show completion message
    LINES=("✅ Claude Code task completed" "Time: $TIMESTAMP" "Project: $PROJECT")
    [ -n "$SESSION_SHORT" ] && LINES+=("Session: $SESSION_SHORT")
fi

# One window per session (session_id distinguishes concurrent sessions in the same project dir)
CONTENT_FILE="/tmp/cc-sticky-notify-${PROJECT}-${SESSION_KEY}.txt"
PID_FILE="/tmp/cc-sticky-notify-${PROJECT}-${SESSION_KEY}.pid"
FOCUS_FILE="/tmp/cc-sticky-notify-${PROJECT}-${SESSION_KEY}.focus"

# Walk process tree (pure ps calls, fast, synchronous)
_pid=$$
_ancestors=""
for _i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    _pid=$(ps -p "$_pid" -o ppid= 2>/dev/null | tr -d ' ')
    if [ -z "$_pid" ] || [ "$_pid" = "0" ] || [ "$_pid" = "1" ]; then break; fi
    _ancestors="${_ancestors:+$_ancestors,}$_pid"
done

# Detect parent GUI app via System Events — run in background so any permission
# dialog or latency never blocks the notification from appearing
if [ -n "$_ancestors" ]; then
    _anc="$_ancestors"
    _ff="$FOCUS_FILE"
    ( _app=$(osascript -e "tell application \"System Events\"
set pids to {$_anc}
repeat with p in pids
    try
        set proc to first application process whose unix id is p
        if (background only of proc) is false and (bundle identifier of proc) is not missing value then
            return name of proc
        end if
    end try
end repeat
end tell" 2>/dev/null); [ -n "$_app" ] && printf '%s\n' "$_app" > "$_ff" ) &
    disown $!
fi

printf '%s\n' "${LINES[@]}" > "$CONTENT_FILE"

if [ -f "$PID_FILE" ]; then
    EXISTING_PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$EXISTING_PID" ] && kill -0 "$EXISTING_PID" 2>/dev/null; then
        exit 0  # Window is alive; DispatchSource watcher refreshes content automatically
    fi
fi

# No running instance — launch new floating sticky note
if [ -f "$BINARY" ]; then
    "$BINARY" "$CONTENT_FILE" </dev/null >/dev/null 2>&1 &
    disown $!
fi
