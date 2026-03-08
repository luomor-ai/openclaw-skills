#!/usr/bin/env bash
set -euo pipefail

# NexusMessaging CLI wrapper
# Usage: nexus.sh <command> [args] [--url URL] [--agent-id ID] [--ttl N] [--after CURSOR] [--members]
#
# stdout: JSON only (pipeable to jq)
# stderr: human-readable tips, status messages

NEXUS_URL="${NEXUS_URL:-https://messaging.md}"
NEXUS_DATA_DIR="${HOME}/.config/messaging/sessions"

# HTTP request helper: preserves error body on failure
# Usage: http_request [curl args...]
# Sets RESPONSE and HTTP_OK (true/false)
http_request() {
  local exit_code=0
  RESPONSE=$(curl -s --fail-with-body "$@") || exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    HTTP_OK=false
  else
    HTTP_OK=true
  fi
}

# Emit RESPONSE to stdout; if HTTP failed, also exit 1
emit_response() {
  echo "$RESPONSE"
  if [[ "$HTTP_OK" != "true" ]]; then
    exit 1
  fi
}
AGENT_ID=""
TTL=""
AFTER=""
GREETING=""
INTERVAL=""
MAX_AGENTS=""
CREATOR_AGENT_ID=""
MEMBERS=""
POSITIONAL=()

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --url) NEXUS_URL="$2"; shift 2 ;;
    --agent-id) AGENT_ID="$2"; shift 2 ;;
    --ttl) TTL="$2"; shift 2 ;;
    --after) AFTER="$2"; shift 2 ;;
    --greeting) GREETING="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --max-agents) MAX_AGENTS="$2"; shift 2 ;;
    --creator-agent-id) CREATOR_AGENT_ID="$2"; shift 2 ;;
    --members) MEMBERS="true"; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
set -- "${POSITIONAL[@]}"

CMD="${1:-help}"
shift || true

case "$CMD" in
  create)
    TTL_VAL="${TTL:-3660}"
    BODY="{\"ttl\": $TTL_VAL}"

    if [[ -n "${GREETING:-}" ]]; then
      BODY=$(echo "$BODY" | jq -c --arg greeting "$GREETING" '. + {greeting: $greeting}')
    fi

    if [[ -n "${MAX_AGENTS:-}" ]]; then
      BODY=$(echo "$BODY" | jq -c --argjson maxAgents "$MAX_AGENTS" '. + {maxAgents: $maxAgents}')
    fi

    if [[ -n "${CREATOR_AGENT_ID:-}" ]]; then
      BODY=$(echo "$BODY" | jq -c --arg creatorAgentId "$CREATOR_AGENT_ID" '. + {creatorAgentId: $creatorAgentId}')
    fi

    http_request -X PUT "$NEXUS_URL/v1/sessions" \
      -H "Content-Type: application/json" \
      -d "$BODY"
    emit_response

    if [[ -n "${CREATOR_AGENT_ID:-}" ]]; then
      SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionId // empty')
      if [[ -n "$SESSION_ID" ]]; then
        mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
        AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
        echo "$CREATOR_AGENT_ID" > "$AGENT_FILE"

        SESSION_KEY=$(echo "$RESPONSE" | jq -r '.sessionKey // empty')
        if [[ -n "$SESSION_KEY" ]]; then
          KEY_FILE="$NEXUS_DATA_DIR/$SESSION_ID/key"
          echo "$SESSION_KEY" > "$KEY_FILE"
        fi
      fi
    fi
    ;;

  status)
    SESSION_ID="${1:?Usage: nexus.sh status <SESSION_ID>}"
    http_request "$NEXUS_URL/v1/sessions/$SESSION_ID"
    emit_response
    ;;

  join)
    SESSION_ID="${1:?Usage: nexus.sh join <SESSION_ID> --agent-id ID}"
    [[ -z "$AGENT_ID" ]] && echo '{"error":"missing --agent-id"}' && exit 1
    http_request -X POST "$NEXUS_URL/v1/sessions/$SESSION_ID/join" \
      -H "X-Agent-Id: $AGENT_ID"
    emit_response

    mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
    AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
    echo "$AGENT_ID" > "$AGENT_FILE"

    SESSION_KEY=$(echo "$RESPONSE" | jq -r '.sessionKey // empty')
    if [[ -n "$SESSION_KEY" ]]; then
      KEY_FILE="$NEXUS_DATA_DIR/$SESSION_ID/key"
      echo "$SESSION_KEY" > "$KEY_FILE"
    fi
    ;;

  pair)
    SESSION_ID="${1:?Usage: nexus.sh pair <SESSION_ID>}"
    http_request -X PUT "$NEXUS_URL/v1/pair" \
      -H "Content-Type: application/json" \
      -d "{\"sessionId\": \"$SESSION_ID\"}"
    emit_response
    ;;

  claim)
    CODE="${1:?Usage: nexus.sh claim <CODE> --agent-id ID}"
    [[ -z "$AGENT_ID" ]] && echo '{"error":"missing --agent-id"}' && exit 1

    http_request -X POST "$NEXUS_URL/v1/pair/$CODE/claim" \
      -H "X-Agent-Id: $AGENT_ID"
    emit_response

    SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionId // empty')
    if [[ -n "$SESSION_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      echo "$AGENT_ID" > "$AGENT_FILE"

      SESSION_KEY=$(echo "$RESPONSE" | jq -r '.sessionKey // empty')
      if [[ -n "$SESSION_KEY" ]]; then
        KEY_FILE="$NEXUS_DATA_DIR/$SESSION_ID/key"
        echo "$SESSION_KEY" > "$KEY_FILE"
      fi

      echo "" >&2
      echo "✅ Claimed! Next step: poll messages" >&2
      echo "$0 poll $SESSION_ID" >&2
    fi
    ;;

  pair-status)
    CODE="${1:?Usage: nexus.sh pair-status <CODE>}"
    http_request "$NEXUS_URL/v1/pair/$CODE/status"
    emit_response
    ;;

  send)
    SESSION_ID="${1:?Usage: nexus.sh send <SESSION_ID> \"text\" [--agent-id ID]}"
    TEXT="${2:?Usage: nexus.sh send <SESSION_ID> \"text\" [--agent-id ID]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    JSON_TEXT=$(printf '%s' "$TEXT" | jq -Rs .)

    KEY_FILE="$NEXUS_DATA_DIR/$SESSION_ID/key"
    if [[ -f "$KEY_FILE" ]]; then
      http_request -X POST "$NEXUS_URL/v1/sessions/$SESSION_ID/messages" \
        -H "X-Agent-Id: $AGENT_ID" \
        -H "X-Session-Key: $(cat $KEY_FILE)" \
        -H "Content-Type: application/json" \
        -d "{\"text\": $JSON_TEXT}"
    else
      http_request -X POST "$NEXUS_URL/v1/sessions/$SESSION_ID/messages" \
        -H "X-Agent-Id: $AGENT_ID" \
        -H "Content-Type: application/json" \
        -d "{\"text\": $JSON_TEXT}"
    fi
    emit_response
    ;;

  poll)
    SESSION_ID="${1:?Usage: nexus.sh poll <SESSION_ID> [--agent-id ID] [--after CURSOR] [--members]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
    CURSOR_FILE="$NEXUS_DATA_DIR/$SESSION_ID/cursor"

    SAVED_CURSOR=""
    if [[ -f "$CURSOR_FILE" ]]; then
      SAVED_CURSOR=$(cat "$CURSOR_FILE")
    fi

    QUERY=""
    if [[ -n "$AFTER" ]]; then
      QUERY="?after=$AFTER"
    elif [[ -n "$SAVED_CURSOR" ]]; then
      QUERY="?after=$SAVED_CURSOR"
    fi

    if [[ "$MEMBERS" == "true" ]]; then
      if [[ -z "$QUERY" ]]; then
        QUERY="?members=true"
      else
        QUERY="$QUERY&members=true"
      fi
    fi

    http_request "$NEXUS_URL/v1/sessions/$SESSION_ID/messages$QUERY" \
      -H "X-Agent-Id: $AGENT_ID"
    emit_response

    NEXT_CURSOR=$(echo "$RESPONSE" | jq -r '.nextCursor // empty')
    if [[ -n "$NEXT_CURSOR" ]]; then
      echo "$NEXT_CURSOR" > "$CURSOR_FILE"
    fi

    MESSAGE_COUNT=$(echo "$RESPONSE" | jq -r '.messages | length')
    if [[ "$MESSAGE_COUNT" -gt 0 ]]; then
      echo "" >&2
      echo "💬 Received $MESSAGE_COUNT message(s)" >&2
      echo "Tip: Send a message:" >&2
      echo "$0 send $SESSION_ID \"Your message\"" >&2
    fi
    if [[ "$MEMBERS" == "true" ]]; then
      MEMBER_COUNT=$(echo "$RESPONSE" | jq -r '.members | length // 0')
      if [[ "$MEMBER_COUNT" -gt 0 ]]; then
        echo "" >&2
        echo "Members:" >&2
        echo "$RESPONSE" | jq -r '.members[] | "  - \(.agentId) (last seen: \(.lastSeenAt))"' >&2
      fi
    fi
    ;;

  poll-daemon)
    SESSION_ID="${1:?Usage: nexus.sh poll-daemon <SESSION_ID> [--agent-id ID] [--interval N] [--ttl N]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    INTERVAL_VAL="${INTERVAL:-30}"
    TTL_VAL="${TTL:-3600}"

    echo "Should I poll for messages every ${INTERVAL_VAL}s for the next ${TTL_VAL}s? (y/n)" >&2
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Polling daemon cancelled." >&2
      exit 0
    fi

    echo "Starting polling daemon..." >&2
    echo "Session: $SESSION_ID" >&2
    echo "Interval: ${INTERVAL_VAL}s" >&2
    echo "TTL: ${TTL_VAL}s" >&2
    echo "Press Ctrl+C to stop" >&2

    START_TIME=$(date +%s)
    trap 'echo "" >&2; echo "Polling daemon stopped." >&2; exit 0' SIGINT SIGTERM

    while true; do
      CURRENT_TIME=$(date +%s)
      ELAPSED=$((CURRENT_TIME - START_TIME))

      if [[ $ELAPSED -ge $TTL_VAL ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - TTL expired, stopping poll daemon" >&2
        break
      fi

      RESPONSE=$("$0" poll "$SESSION_ID" 2>/dev/null || echo "{}")
      MESSAGE_COUNT=$(echo "$RESPONSE" | jq -r '.messages | length // 0')

      if [[ "$MESSAGE_COUNT" -gt 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Poll: $MESSAGE_COUNT new message(s)" >&2
      fi

      sleep "$INTERVAL_VAL"
    done
    ;;

  heartbeat)
    SESSION_ID="${1:?Usage: nexus.sh heartbeat <SESSION_ID> [--agent-id ID] [--interval N]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    INTERVAL_VAL="${INTERVAL:-60}"

    echo "Starting heartbeat polling..." >&2
    echo "Session: $SESSION_ID" >&2
    echo "Interval: ${INTERVAL_VAL}s" >&2
    echo "Press Ctrl+C to stop" >&2

    trap 'echo "" >&2; echo "Heartbeat stopped." >&2; exit 0' SIGINT SIGTERM

    while true; do
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Polling..." >&2
      RESPONSE=$("$0" poll "$SESSION_ID" 2>/dev/null || echo "{}")
      MESSAGE_COUNT=$(echo "$RESPONSE" | jq -r '.messages | length // 0')

      if [[ "$MESSAGE_COUNT" -gt 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE_COUNT new message(s)" >&2
      fi

      sleep "$INTERVAL_VAL"
    done
    ;;

  renew)
    SESSION_ID="${1:?Usage: nexus.sh renew <SESSION_ID> [--ttl N] [--agent-id ID]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    BODY=""
    if [[ -n "${TTL:-}" ]]; then
      BODY=$(echo "{}" | jq -c --argjson ttl "$TTL" '. + {ttl: $ttl}')
    fi

    if [[ -n "$BODY" ]]; then
      http_request -X POST "$NEXUS_URL/v1/sessions/$SESSION_ID/renew" \
        -H "X-Agent-Id: $AGENT_ID" \
        -H "Content-Type: application/json" \
        -d "$BODY"
    else
      http_request -X POST "$NEXUS_URL/v1/sessions/$SESSION_ID/renew" \
        -H "X-Agent-Id: $AGENT_ID"
    fi
    emit_response

    EXPIRES_AT=$(echo "$RESPONSE" | jq -r '.expiresAt // empty')
    if [[ -n "$EXPIRES_AT" ]]; then
      echo "" >&2
      echo "✅ Session renewed — expires at: $EXPIRES_AT" >&2
    fi
    ;;

  leave)
    SESSION_ID="${1:?Usage: nexus.sh leave <SESSION_ID> [--agent-id ID]}"

    if [[ -z "$AGENT_ID" ]]; then
      mkdir -p "$NEXUS_DATA_DIR/$SESSION_ID"
      AGENT_FILE="$NEXUS_DATA_DIR/$SESSION_ID/agent"
      if [[ -f "$AGENT_FILE" ]]; then
        AGENT_ID=$(cat "$AGENT_FILE")
      else
        echo '{"error":"missing --agent-id and no persisted agent-id found"}' && exit 1
      fi
    fi

    KEY_FILE="$NEXUS_DATA_DIR/$SESSION_ID/key"
    if [[ ! -f "$KEY_FILE" ]]; then
      echo '{"error":"no session key found"}' && exit 1
    fi

    http_request -X DELETE "$NEXUS_URL/v1/sessions/$SESSION_ID/agents/$AGENT_ID" \
      -H "X-Agent-Id: $AGENT_ID" \
      -H "X-Session-Key: $(cat $KEY_FILE)"
    emit_response

    OK=$(echo "$RESPONSE" | jq -r '.ok // false')
    if [[ "$OK" == "true" ]]; then
      rm -rf "$NEXUS_DATA_DIR/$SESSION_ID"
      echo "" >&2
      echo "✅ Left session. Local data cleaned up." >&2
    fi
    ;;

  poll-status)
    # poll-status is inherently human-readable, not JSON
    echo "Active polling processes:" >&2
    PGREP_OUTPUT=$(pgrep -f "nexus.sh.*poll" || true)
    if [[ -z "$PGREP_OUTPUT" ]]; then
      echo "No active polling processes found." >&2
    else
      echo "$PGREP_OUTPUT" >&2
      echo "" >&2
      echo "Last poll time:" >&2
      if [[ -d "$NEXUS_DATA_DIR" ]]; then
        for session_dir in "$NEXUS_DATA_DIR"/*/; do
          cursor_file="$session_dir/cursor"
          if [[ -f "$cursor_file" ]]; then
            SESSION_ID=$(basename "$session_dir")
            LAST_POLL=$(stat -c %y "$cursor_file" 2>/dev/null || stat -f %Sm "$cursor_file" 2>/dev/null || echo "unknown")
            echo "  $SESSION_ID: $LAST_POLL" >&2
          fi
        done
      fi
    fi
    ;;

  help|*)
    cat >&2 <<EOF
NexusMessaging CLI

Usage: nexus.sh <command> [args] [options]

stdout: JSON only (pipeable to jq)
stderr: human-readable tips and status messages

Commands:
  create [--ttl N] [--max-agents N]        Create session (default TTL: 3660s, maxAgents: 50)
  status <SESSION_ID>                     Get session status
  join <SESSION_ID> --agent-id ID         Join a session (saves agent-id + session key)
  leave <SESSION_ID> [--agent-id ID]      Leave a session (removes agent, frees slot, cleans local config)
  pair <SESSION_ID>                       Generate pairing code
  claim <CODE> --agent-id ID             Claim pairing code (saves agent-id + session key)
  pair-status <CODE>                      Check pairing code state
  send <SESSION_ID> "text" [--agent-id]    Send message (uses saved agent-id + session key if available)
  poll <SESSION_ID> [--agent-id] [--after] [--members] Poll messages (uses saved agent-id)
  poll-daemon <SESSION_ID> [--agent-id]   Poll with TTL tracking (uses saved agent-id)
  heartbeat <SESSION_ID> [--agent-id]    Continuous polling loop (uses saved agent-id)
  renew <SESSION_ID> [--ttl N] [--agent-id] Renew session TTL (agent-id auto-loaded if previously persisted)
  poll-status                              Show active polling processes

Options:
  --url URL           Server URL (default: \$NEXUS_URL or https://messaging.md)
  --agent-id ID       Agent identifier (optional after join/claim)
  --ttl N             Session TTL in seconds
  --max-agents N      Maximum number of agents (default: 50)
  --creator-agent-id ID Creator agent ID (auto-joins session, immune to inactivity)
  --after CURSOR      Poll messages after this cursor
  --members           Include members list with lastSeenAt timestamps in poll response
  --interval N        Polling interval (default: poll-daemon=30s, heartbeat=60s)

Note: Session data (agent-id, cursor, session key) is saved to ~/.config/messaging/sessions/<SESSION_ID>/.
Use --agent-id to override the saved value or for the first interaction.
Session keys are automatically saved on join/claim/create and used for verified message sending.
EOF
    ;;
esac
