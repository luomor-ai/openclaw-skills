#!/usr/bin/env bash
# todo.sh - execution queue for agent-todo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=todo_lib.sh
source "${SCRIPT_DIR}/todo_lib.sh"

COMMAND="${1:-}"
shift 2>/dev/null || true

usage() {
  cat <<'EOF'
agent-todo - agent execution queue

Usage:
  todo.sh init
  todo.sh doctor
  todo.sh setup-heartbeat [--write]
  todo.sh add <title> [options]
  todo.sh plan <title> --steps "step1; step2; step3" [options]
  todo.sh list [options]
  todo.sh show <id>
  todo.sh report <id>
  todo.sh run-pending [options]
  todo.sh start <id>
  todo.sh block <id> --reason "..."
  todo.sh done <id> --note "..."
  todo.sh cancel <id> --reason "..."
  todo.sh check-overdue

Add/plan options:
  --task-type <type>            Task type (general|coding|doc|research|reply|review|publish)
  --deadline <time>             Deadline (ISO-8601 or natural language)
  --owner <name>                Task owner
  --requester <name>            Requester
  --source <source>             Source (forum:#19, chat:direct, ...)
  --next-action <text>          Next concrete action to take
  --success-criteria <text>     What counts as done
  --tags <tags>                 Comma-separated tags
  --steps <text>                Semicolon-separated steps for plan

List options:
  --owner <name>
  --status <status>             pending|running|blocked|done|cancelled

Run-pending options:
  --owner <name>
  --claim                       Move selected task to running before printing execution brief
EOF
}

workspace_root() {
  dirname "$TODO_DB"
}

heartbeat_file() {
  echo "$(workspace_root)/HEARTBEAT.md"
}

heartbeat_command() {
  echo "${SCRIPT_DIR}/script.sh run-pending --claim"
}

heartbeat_configured() {
  local hb_file
  hb_file="$(heartbeat_file)"
  [[ -f "$hb_file" ]] && grep -Fq "$(heartbeat_command)" "$hb_file"
}

print_heartbeat_hint() {
  if heartbeat_configured; then
    return
  fi

  local hb_file cmd
  hb_file="$(heartbeat_file)"
  cmd="$(heartbeat_command)"
  echo
  echo "⚠️ agent-todo is not wired into heartbeat yet."
  echo "Add this to: ${hb_file}"
  echo "$cmd"
  echo "Or run: ./script.sh setup-heartbeat --write"
}

parse_deadline() {
  local deadline="$1"
  [[ -z "$deadline" ]] && echo "" && return
  date -d "$deadline" '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || echo "$deadline"
}

row_field() {
  local row="$1"
  local index="$2"
  IFS='|' read -r -a f <<< "$row"
  echo "${f[$index]:-}" | xargs
}

load_task() {
  local id="$1"
  TASK_ID="$id"
  TASK_TITLE="$(get_field "$id" title)"
  TASK_TYPE="$(get_field "$id" task_type)"
  TASK_OWNER="$(get_field "$id" owner)"
  TASK_REQUESTER="$(get_field "$id" requester)"
  TASK_SOURCE="$(get_field "$id" source)"
  TASK_STATUS="$(get_field "$id" status)"
  TASK_DEADLINE="$(get_field "$id" deadline)"
  TASK_NEXT_ACTION="$(get_field "$id" next_action)"
  TASK_SUCCESS_CRITERIA="$(get_field "$id" success_criteria)"
  TASK_CREATED_AT="$(get_field "$id" created_at)"
  TASK_UPDATED_AT="$(get_field "$id" updated_at)"
  TASK_LAST_ATTEMPT_AT="$(get_field "$id" last_attempt_at)"
  TASK_COMPLETED_AT="$(get_field "$id" completed_at)"
  TASK_RESULT="$(get_field "$id" result)"
  TASK_TAGS="$(get_field "$id" tags)"

  if [[ -z "$TASK_TITLE" ]]; then
    echo "未找到任务: $id" >&2
    exit 1
  fi
}

save_task() {
  local new_row
  new_row=$(build_row \
    "$TASK_ID" "$TASK_TITLE" "$TASK_TYPE" "$TASK_OWNER" "$TASK_REQUESTER" "$TASK_SOURCE" \
    "$TASK_STATUS" "$TASK_DEADLINE" "$TASK_NEXT_ACTION" "$TASK_SUCCESS_CRITERIA" \
    "$TASK_CREATED_AT" "$TASK_UPDATED_AT" "$TASK_LAST_ATTEMPT_AT" "$TASK_COMPLETED_AT" \
    "$TASK_RESULT" "$TASK_TAGS")
  replace_row "$TASK_ID" "$new_row"
}

render_report() {
  local title="$1"
  local source="$2"
  local completed_at="$3"
  local result="$4"
  local success_criteria="$5"

  if [[ "$source" =~ ^forum:#([0-9]+)(/reply:([0-9]+))?$ ]]; then
    local topic_id="${BASH_REMATCH[1]}"
    echo "【回帖内容】"
    echo "✅ 已完成：${title}"
    echo "- 话题：#${topic_id}"
    echo "- 完成时间：${completed_at}"
    [[ -n "$result" ]] && echo "- 结果：${result}"
    [[ -n "$success_criteria" ]] && echo "- 对照标准：${success_criteria}"
    echo
    echo "如无遗漏，我这边先收口。"
    return
  fi

  if [[ "$source" =~ ^chat: ]]; then
    echo "【回消息内容】"
    echo "✅ 已完成：${title}"
    echo "- 完成时间：${completed_at}"
    [[ -n "$result" ]] && echo "- 结果：${result}"
    [[ -n "$success_criteria" ]] && echo "- 对照标准：${success_criteria}"
    return
  fi

  echo "【通用汇报】"
  echo "✅ ${title}"
  [[ -n "$source" ]] && echo "- source: ${source}"
  echo "- completed_at: ${completed_at}"
  [[ -n "$result" ]] && echo "- result: ${result}"
  [[ -n "$success_criteria" ]] && echo "- success_criteria: ${success_criteria}"
}

queue_task() {
  local title="$1"
  local task_type="$2"
  local deadline="$3"
  local owner="$4"
  local requester="$5"
  local source="$6"
  local next_action="$7"
  local success_criteria="$8"
  local tags="${9:-}"

  local id ts parsed_deadline row
  id=$(generate_uuid)
  ts=$(now_iso)
  parsed_deadline=$(parse_deadline "$deadline")
  [[ -z "$next_action" ]] && next_action="$title"

  row=$(build_row \
    "$id" "$title" "$task_type" "$owner" "$requester" "$source" \
    "pending" "$parsed_deadline" "$next_action" "$success_criteria" \
    "$ts" "$ts" "" "" "" "$tags")

  echo "$row" >> "$TODO_DB"
  touch_db
  echo "$id"
}

cmd_init() {
  init_db
  echo "✅ agent-todo queue initialized: $TODO_DB"
  print_heartbeat_hint
}

cmd_doctor() {
  init_db
  local hb_file cmd
  hb_file="$(heartbeat_file)"
  cmd="$(heartbeat_command)"

  echo "agent-todo doctor"
  echo "- TODO_DB: $TODO_DB"
  echo "- HEARTBEAT.md: $hb_file"
  echo "- expected heartbeat command: $cmd"

  if heartbeat_configured; then
    echo "- heartbeat: configured ✅"
  else
    echo "- heartbeat: missing ⚠️"
    echo
    echo "Suggested block:"
    echo "## Agent execution queue"
    echo "$cmd"
  fi
}

cmd_setup_heartbeat() {
  local write_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write_mode=1; shift ;;
      *) echo "未知选项: $1" >&2; exit 1 ;;
    esac
  done

  init_db

  local hb_file cmd
  hb_file="$(heartbeat_file)"
  cmd="$(heartbeat_command)"

  if heartbeat_configured; then
    echo "✅ heartbeat already configured: $hb_file"
    return
  fi

  if [[ $write_mode -eq 0 ]]; then
    echo "Heartbeat not configured yet."
    echo "Add this to $hb_file:"
    echo "## Agent execution queue"
    echo "$cmd"
    echo
    echo "Or run: bash ./script.sh setup-heartbeat --write"
    return
  fi

  touch "$hb_file"
  {
    [[ -s "$hb_file" ]] && echo
    echo "## Agent execution queue"
    echo "$cmd"
  } >> "$hb_file"

  echo "✅ heartbeat updated: $hb_file"
  echo "   added: $cmd"
}

cmd_add() {
  local title=""
  local task_type="general"
  local deadline=""
  local owner=""
  local requester=""
  local source=""
  local next_action=""
  local success_criteria="Mark done and report back to source"
  local tags=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task-type) task_type="$2"; shift 2 ;;
      --deadline) deadline="$2"; shift 2 ;;
      --owner) owner="$2"; shift 2 ;;
      --requester) requester="$2"; shift 2 ;;
      --source) source="$2"; shift 2 ;;
      --next-action) next_action="$2"; shift 2 ;;
      --success-criteria) success_criteria="$2"; shift 2 ;;
      --tags) tags="$2"; shift 2 ;;
      -*) echo "未知选项: $1" >&2; exit 1 ;;
      *) title="$1"; shift ;;
    esac
  done

  [[ -z "$title" ]] && echo "错误: 必须提供任务标题" >&2 && exit 1

  init_db
  local id
  id=$(queue_task "$title" "$task_type" "$deadline" "$owner" "$requester" "$source" "$next_action" "$success_criteria" "$tags")

  echo "✅ task queued [$id]"
  echo "   title: $title"
  echo "   type: $task_type"
  [[ -n "$owner" ]] && echo "   owner: $owner"
  [[ -n "$deadline" ]] && echo "   deadline: $(parse_deadline "$deadline")"
  [[ -n "$next_action" ]] && echo "   next_action: $next_action"
  print_heartbeat_hint
}

cmd_plan() {
  local title=""
  local task_type="general"
  local deadline=""
  local owner=""
  local requester=""
  local source=""
  local success_criteria="All planned steps are completed and reported back"
  local tags=""
  local steps=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task-type) task_type="$2"; shift 2 ;;
      --deadline) deadline="$2"; shift 2 ;;
      --owner) owner="$2"; shift 2 ;;
      --requester) requester="$2"; shift 2 ;;
      --source) source="$2"; shift 2 ;;
      --success-criteria) success_criteria="$2"; shift 2 ;;
      --tags) tags="$2"; shift 2 ;;
      --steps) steps="$2"; shift 2 ;;
      -*) echo "未知选项: $1" >&2; exit 1 ;;
      *) title="$1"; shift ;;
    esac
  done

  [[ -z "$title" ]] && echo "错误: 必须提供计划标题" >&2 && exit 1
  [[ -z "$steps" ]] && echo "错误: plan 必须提供 --steps" >&2 && exit 1

  init_db

  local index=0 created=0 step trimmed step_title step_next step_success id
  IFS=';' read -r -a step_array <<< "$steps"
  for step in "${step_array[@]}"; do
    trimmed=$(echo "$step" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$trimmed" ]] && continue
    index=$((index + 1))
    created=$((created + 1))
    step_title="${title} / step ${index}: ${trimmed}"
    step_next="$trimmed"
    step_success="Step ${index} completed for plan: ${title}"
    id=$(queue_task "$step_title" "$task_type" "$deadline" "$owner" "$requester" "$source" "$step_next" "$step_success" "$tags")
    echo "✅ planned task [$id]"
    echo "   title: $step_title"
  done

  [[ $created -eq 0 ]] && echo "错误: --steps 里没有可用步骤" >&2 && exit 1
  echo "📦 plan queued: $title"
  echo "   steps: $created"
  [[ -n "$success_criteria" ]] && echo "   success_criteria: $success_criteria"
  print_heartbeat_hint
}

cmd_list() {
  local owner_filter=""
  local status_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --owner) owner_filter="$2"; shift 2 ;;
      --status) status_filter="$2"; shift 2 ;;
      -*) echo "未知选项: $1" >&2; exit 1 ;;
      *) shift ;;
    esac
  done

  init_db

  echo
  echo '═══════════════════════════════════════'
  echo '  agent-todo execution queue'
  echo '═══════════════════════════════════════'
  echo

  local found=0
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local id title task_type owner source status deadline next_action
    id=$(row_field "$row" 1)
    title=$(row_field "$row" 2)
    task_type=$(row_field "$row" 3)
    owner=$(row_field "$row" 4)
    source=$(row_field "$row" 6)
    status=$(row_field "$row" 7)
    deadline=$(row_field "$row" 8)
    next_action=$(row_field "$row" 9)

    [[ -n "$owner_filter" && "$owner" != "$owner_filter" ]] && continue
    [[ -n "$status_filter" && "$status" != "$status_filter" ]] && continue

    found=1
    echo "  $(format_status "$status") [${id:0:8}]"
    echo "     title: $title"
    [[ -n "$task_type" ]] && echo "     type: $task_type"
    [[ -n "$owner" ]] && echo "     owner: $owner"
    [[ -n "$deadline" ]] && echo "     deadline: $deadline"
    [[ -n "$source" ]] && echo "     source: $source"
    [[ -n "$next_action" ]] && echo "     next_action: $next_action"
    echo
  done < <(find_rows)

  [[ $found -eq 0 ]] && echo '  (no matching tasks)' && echo
}

cmd_show() {
  local id="$1"
  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"

  echo
  echo '═══════════════════════════════════════'
  echo '  task detail'
  echo '═══════════════════════════════════════'
  echo "  id:               $TASK_ID"
  echo "  title:            $TASK_TITLE"
  echo "  task_type:        $TASK_TYPE"
  echo "  owner:            $TASK_OWNER"
  echo "  requester:        $TASK_REQUESTER"
  echo "  source:           $TASK_SOURCE"
  echo "  status:           $TASK_STATUS"
  echo "  deadline:         $TASK_DEADLINE"
  echo "  next_action:      $TASK_NEXT_ACTION"
  echo "  success_criteria: $TASK_SUCCESS_CRITERIA"
  echo "  created_at:       $TASK_CREATED_AT"
  echo "  updated_at:       $TASK_UPDATED_AT"
  echo "  last_attempt_at:  $TASK_LAST_ATTEMPT_AT"
  echo "  completed_at:     $TASK_COMPLETED_AT"
  echo "  result:           $TASK_RESULT"
  echo "  tags:             $TASK_TAGS"
  echo
}

cmd_report() {
  local id="$1"
  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"
  render_report "$TASK_TITLE" "$TASK_SOURCE" "$TASK_COMPLETED_AT" "$TASK_RESULT" "$TASK_SUCCESS_CRITERIA"
}

cmd_start() {
  local id="$1"
  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"

  local ts
  ts=$(now_iso)
  TASK_STATUS="running"
  TASK_LAST_ATTEMPT_AT="$ts"
  TASK_UPDATED_AT="$ts"
  save_task

  echo "🏃 task started [$TASK_ID]"
  echo "   title: $TASK_TITLE"
}

cmd_block() {
  local id="$1"
  local reason=""
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --reason) reason="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"

  local ts
  ts=$(now_iso)
  TASK_STATUS="blocked"
  TASK_UPDATED_AT="$ts"
  TASK_RESULT="$reason"
  save_task

  echo "🧱 task blocked [$TASK_ID]"
  [[ -n "$reason" ]] && echo "   reason: $reason"
}

cmd_done() {
  local id="$1"
  local note=""
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --note) note="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"

  local ts
  ts=$(now_iso)
  TASK_STATUS="done"
  TASK_UPDATED_AT="$ts"
  TASK_COMPLETED_AT="$ts"
  TASK_RESULT="$note"
  save_task

  echo "✅ task done [$TASK_ID]"
  echo "   title: $TASK_TITLE"
  echo
  echo '═══ completion report ═══'
  render_report "$TASK_TITLE" "$TASK_SOURCE" "$TASK_COMPLETED_AT" "$TASK_RESULT" "$TASK_SUCCESS_CRITERIA"
}

cmd_cancel() {
  local id="$1"
  local reason=""
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --reason) reason="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  [[ -z "$id" ]] && echo "错误: 必须提供任务ID" >&2 && exit 1
  init_db
  load_task "$id"

  local ts
  ts=$(now_iso)
  TASK_STATUS="cancelled"
  TASK_UPDATED_AT="$ts"
  TASK_RESULT="$reason"
  save_task

  echo "❌ task cancelled [$TASK_ID]"
  [[ -n "$reason" ]] && echo "   reason: $reason"
}

cmd_check_overdue() {
  init_db
  local found=0
  echo
  echo '═══ overdue tasks ═══'
  echo
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    local id title status deadline
    id=$(row_field "$row" 1)
    title=$(row_field "$row" 2)
    status=$(row_field "$row" 7)
    deadline=$(row_field "$row" 8)
    [[ "$status" =~ ^(done|cancelled)$ ]] && continue
    [[ -z "$deadline" ]] && continue
    if [[ $(deadline_to_timestamp "$deadline") -gt 0 ]] && [[ $(date '+%s') -gt $(deadline_to_timestamp "$deadline") ]]; then
      found=1
      echo "🚨 $title [$id]"
      echo "   deadline: $deadline"
    fi
  done < <(find_rows)

  [[ $found -eq 0 ]] && echo '✅ no overdue tasks'
}

cmd_run_pending() {
  local owner_filter=""
  local claim=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --owner) owner_filter="$2"; shift 2 ;;
      --claim) claim=1; shift ;;
      -*) echo "未知选项: $1" >&2; exit 1 ;;
      *) shift ;;
    esac
  done

  init_db

  local selected_line=""
  selected_line=$(awk -F'|' -v owner_filter="$owner_filter" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    NR <= 6 { next }
    !/^\|/ || /^\|[- ]+\|/ { next }
    {
      raw = $0
      for (i = 1; i <= NF; i++) $i = trim($i)
      id=$2; owner=$5; status=$8; deadline=$9; created_at=$12; last_attempt_at=$14
      if (id == "" || status == "done" || status == "cancelled" || status == "blocked") next
      if (owner_filter != "" && owner != owner_filter) next

      if (status == "running") {
        priority = 0
        order_key = last_attempt_at == "" ? created_at : last_attempt_at
      } else {
        priority = 1
        order_key = deadline == "" ? "9999-99-99T99:99:99+00:00" : deadline
      }

      print priority "\t" order_key "\t" created_at "\t" raw
    }
  ' "$TODO_DB" | sort | head -n 1 | cut -f4-)

  if [[ -z "$selected_line" ]]; then
    echo "HEARTBEAT_OK"
    return
  fi

  local id
  id=$(row_field "$selected_line" 1)
  load_task "$id"

  if [[ $claim -eq 1 ]]; then
    local ts
    ts=$(now_iso)
    TASK_STATUS="running"
    TASK_LAST_ATTEMPT_AT="$ts"
    TASK_UPDATED_AT="$ts"
    save_task
  fi

  echo 'EXECUTE_NOW'
  echo "id: $TASK_ID"
  echo "title: $TASK_TITLE"
  echo "task_type: $TASK_TYPE"
  [[ -n "$TASK_OWNER" ]] && echo "owner: $TASK_OWNER"
  [[ -n "$TASK_REQUESTER" ]] && echo "requester: $TASK_REQUESTER"
  [[ -n "$TASK_SOURCE" ]] && echo "source: $TASK_SOURCE"
  [[ -n "$TASK_DEADLINE" ]] && echo "deadline: $TASK_DEADLINE"
  [[ -n "$TASK_NEXT_ACTION" ]] && echo "next_action: $TASK_NEXT_ACTION"
  [[ -n "$TASK_SUCCESS_CRITERIA" ]] && echo "success_criteria: $TASK_SUCCESS_CRITERIA"
  [[ -n "$TASK_TAGS" ]] && echo "tags: $TASK_TAGS"
  echo
  echo 'Do the task now. When finished, call:'
  echo "bash ./script.sh done $TASK_ID --note \"what was completed\""
  echo 'If blocked, call:'
  echo "bash ./script.sh block $TASK_ID --reason \"why it is blocked\""
  echo 'If work started but is not complete yet, keep it running and update last attempt by re-claiming on next heartbeat.'
}

case "$COMMAND" in
  init) cmd_init ;;
  doctor) cmd_doctor ;;
  setup-heartbeat) cmd_setup_heartbeat "$@" ;;
  add) cmd_add "$@" ;;
  plan) cmd_plan "$@" ;;
  list|ls) cmd_list "$@" ;;
  show|view) cmd_show "$@" ;;
  report) cmd_report "$@" ;;
  run-pending) cmd_run_pending "$@" ;;
  start) cmd_start "$@" ;;
  block) cmd_block "$@" ;;
  done|complete) cmd_done "$@" ;;
  cancel) cmd_cancel "$@" ;;
  check-overdue) cmd_check_overdue ;;
  help|--help|-h) usage ;;
  *) usage ;;
esac
