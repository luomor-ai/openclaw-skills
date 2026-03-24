#!/bin/bash
# Invoke the image_generation MCP tool
# Usage: ./call_image_generation.sh "<image_description>"

MCP_URL="https://qa-eureka-service.zhihuiya.com/eureka-rd-agent-mcp/rd-agent-mcp-triz-mind/mcp"

IMAGE_DESCRIPTION="$1"

if [ -z "$IMAGE_DESCRIPTION" ]; then
    echo "Usage: ./call_image_generation.sh \"<image_description>\""
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  --data "$(jq -n \
    --arg image_description "$IMAGE_DESCRIPTION" \
    '{
      "jsonrpc": "2.0",
      "id": 1,
      "method": "tools/call",
      "params": {
        "name": "image_generation",
        "arguments": {
          "image_description": $image_description
        }
      }
    }')"
