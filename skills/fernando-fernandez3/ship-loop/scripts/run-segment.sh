#!/usr/bin/env bash
# run-segment.sh — Orchestrate a single ship-loop segment
# Usage: bash scripts/run-segment.sh <segment-name> <prompt-file-path> [shiploop.yml]
#
# Flow: read prompt from file → run coding agent → preflight → ship → cleanup
# Prompt is read from a FILE PATH (never shell arguments) to prevent injection.
#
# Exit 0 = segment shipped and verified
# Exit 1 = failure (agent, preflight, or ship)

set -euo pipefail

SEGMENT_NAME="${1:?Usage: run-segment.sh <segment-name> <prompt-file-path> [shiploop.yml]}"
PROMPT_FILE="${2:?Usage: run-segment.sh <segment-name> <prompt-file-path>}"
SHIPLOOP_FILE="${3:-SHIPLOOP.yml}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_DIR"

# --------------------------------------------------------------------------
# Validate inputs
# --------------------------------------------------------------------------

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "❌ Prompt file not found: $PROMPT_FILE"
    exit 1
fi

if [[ ! -f "$SHIPLOOP_FILE" ]]; then
    echo "❌ SHIPLOOP.yml not found: $SHIPLOOP_FILE"
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")
if [[ -z "$PROMPT" ]]; then
    echo "❌ Prompt file is empty: $PROMPT_FILE"
    exit 1
fi

# --------------------------------------------------------------------------
# Parse timeout from SHIPLOOP.yml
# --------------------------------------------------------------------------
AGENT_TIMEOUT=$(grep -A5 "^timeouts:" "$SHIPLOOP_FILE" 2>/dev/null \
    | grep "agent:" \
    | sed 's/.*agent:[[:space:]]*//' \
    | xargs 2>/dev/null || echo "900")
[[ -z "$AGENT_TIMEOUT" || "$AGENT_TIMEOUT" == "null" ]] && AGENT_TIMEOUT=900

# Parse agent command from SHIPLOOP.yml (user-configured, required)
AGENT_COMMAND=$(grep "^agent_command:" "$SHIPLOOP_FILE" 2>/dev/null \
    | sed 's/^agent_command:[[:space:]]*//' \
    | sed 's/^["'"'"']//' | sed 's/["'"'"']$//' \
    | xargs 2>/dev/null || echo "")

if [[ -z "$AGENT_COMMAND" ]]; then
    echo "❌ No agent_command defined in $SHIPLOOP_FILE"
    echo "   Add something like: agent_command: \"claude --print --permission-mode bypassPermissions\""
    echo "   Or: agent_command: \"codex exec --full-auto\""
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚢 SEGMENT: $SEGMENT_NAME"
echo "   Agent timeout: ${AGENT_TIMEOUT}s"
echo "   Prompt file: $PROMPT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# --------------------------------------------------------------------------
# Step 1: Run coding agent
# --------------------------------------------------------------------------
echo ""
echo "🤖 Running coding agent: $AGENT_COMMAND"

AGENT_START=$(date +%s)

# Run user-configured agent command
# Prompt is piped via stdin, NOT passed as argument
if timeout "${AGENT_TIMEOUT}" $AGENT_COMMAND < "$PROMPT_FILE" > /tmp/shiploop-agent-output-${SEGMENT_NAME}.log 2>&1; then
    AGENT_ELAPSED=$(( $(date +%s) - AGENT_START ))
    echo "✅ Agent completed in ${AGENT_ELAPSED}s"
else
    EXIT_CODE=$?
    AGENT_ELAPSED=$(( $(date +%s) - AGENT_START ))
    if [[ $EXIT_CODE -eq 124 ]]; then
        echo "❌ Agent timed out after ${AGENT_TIMEOUT}s"
    else
        echo "❌ Agent failed (exit $EXIT_CODE, ${AGENT_ELAPSED}s)"
    fi
    echo "   Last 20 lines of output:"
    tail -20 /tmp/shiploop-agent-output-${SEGMENT_NAME}.log 2>/dev/null | sed 's/^/   │ /' || true
    exit 1
fi

# --------------------------------------------------------------------------
# Step 2: Run preflight checks (build + lint + test)
# --------------------------------------------------------------------------
echo ""
echo "🛫 Running preflight checks..."

if bash "$SCRIPT_DIR/preflight.sh" "$SHIPLOOP_FILE"; then
    echo "✅ Preflight passed"
else
    echo "❌ Preflight FAILED — commit blocked"
    echo "   Fix the issues above and retry this segment."
    exit 1
fi

# --------------------------------------------------------------------------
# Step 3: Ship (stage, commit, push, verify)
# --------------------------------------------------------------------------
echo ""
echo "📦 Shipping..."

if bash "$SCRIPT_DIR/ship.sh" "$SEGMENT_NAME" "$SHIPLOOP_FILE"; then
    echo "✅ Shipped successfully"
else
    echo "❌ Ship FAILED"
    exit 1
fi

# --------------------------------------------------------------------------
# Step 4: Cleanup
# --------------------------------------------------------------------------
echo ""
echo "🧹 Cleanup..."

# Remove temp prompt file
if [[ -f "$PROMPT_FILE" ]]; then
    rm -f "$PROMPT_FILE"
    echo "   Removed prompt file"
fi

# Remove agent output log (keep on failure for debugging)
rm -f "/tmp/shiploop-agent-output-${SEGMENT_NAME}.log"
echo "   Removed agent output log"

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SEGMENT COMPLETE: $SEGMENT_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
