#!/bin/bash
set -euo pipefail
# FeedTo Feed Poller — fetches pending feeds for the agent to process
# Requires: curl, FEEDTO_API_KEY env var
# No python3/macOS dependencies

API_URL="${FEEDTO_API_URL:-https://feedto.ai}"
API_KEY="${FEEDTO_API_KEY:-}"

if [ -z "$API_KEY" ]; then
  echo "ERROR: FEEDTO_API_KEY not set."
  echo "Configure it in openclaw.json:"
  echo '  { "skills": { "entries": { "feedto": { "env": { "FEEDTO_API_KEY": "your-key" } } } } }'
  echo "Get your key at: https://feedto.ai/settings"
  exit 1
fi

# Fetch pending feeds
RESPONSE=$(curl -s -f --max-time 15 --connect-timeout 5 \
  -H "X-API-Key: $API_KEY" \
  "${API_URL}/api/feeds/pending?limit=10" 2>&1) || {
  echo "ERROR: Failed to fetch feeds from ${API_URL}"
  exit 1
}

# Check for empty feeds array using grep (no python3 needed)
# API returns {"feeds": [...]}
if echo "$RESPONSE" | grep -q '"feeds":\s*\[\s*\]'; then
  echo "NO_NEW_FEEDS"
  exit 0
fi

# Count feeds by counting "id" occurrences
FEED_COUNT=$(echo "$RESPONSE" | grep -o '"id"' | wc -l | tr -d ' ')

if [ "${FEED_COUNT:-0}" = "0" ]; then
  echo "NO_NEW_FEEDS"
  exit 0
fi

# Output raw JSON for the agent to parse
echo "NEW_FEEDS: $FEED_COUNT"
echo ""
echo "$RESPONSE"
