#!/bin/bash
# Invoke the batch_solution_workflow MCP tool
# Usage: ./call_batch_solution_workflow.sh '<problems_json>'
# problems_json example: '[{"problem_type":"xxx","problem_description":"xxx"}]'

MCP_URL="https://qa-eureka-service.zhihuiya.com/eureka-rd-agent-mcp/rd-agent-mcp-triz-mind/mcp"

PROBLEMS_JSON="$1"

if [ -z "$PROBLEMS_JSON" ]; then
    echo "Usage: ./call_batch_solution_workflow.sh '<problems_json>'"
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  --data "$(jq -n \
    --argjson problems "$PROBLEMS_JSON" \
    '{
      "jsonrpc": "2.0",
      "id": 1,
      "method": "tools/call",
      "params": {
        "name": "batch_solution_workflow",
        "arguments": {
          "problems": $problems
        }
      }
    }')"
