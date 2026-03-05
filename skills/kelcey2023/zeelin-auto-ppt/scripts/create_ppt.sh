#!/bin/bash
# create_ppt.sh — Automate NotebookLM to create a presentation from text content
# Usage: bash create_ppt.sh "content text" ["output filename"]
#
# This script handles the full NotebookLM automation flow:
#   1. Open NotebookLM
#   2. Create new notebook
#   3. Paste source text
#   4. Generate presentation (Audio Overview -> Slides)
#   5. Download PDF to ~/Desktop/

set -e

CONTENT="$1"
OUTPUT_NAME="${2:-PPT_$(date +%Y%m%d_%H%M).pdf}"
OUTPUT_PATH="$HOME/Desktop/$OUTPUT_NAME"
CLI="openclaw browser"

if [ -z "$CONTENT" ]; then
  echo "ERROR: No content provided"
  echo "Usage: bash create_ppt.sh \"content text\" [\"output_filename.pdf\"]"
  exit 1
fi

wait_and_snap() {
  local wait_sec="${1:-3}"
  sleep "$wait_sec"
  $CLI snapshot 2>/dev/null
}

find_ref() {
  local snap="$1"
  local pattern="$2"
  echo "$snap" | grep -i "$pattern" | grep -oE 'ref=e[0-9]+' | tail -1 | sed 's/ref=//'
}

find_button_ref() {
  local snap="$1"
  local pattern="$2"
  echo "$snap" | grep -i "button.*$pattern" | grep -oE 'ref=e[0-9]+' | head -1 | sed 's/ref=//'
}

click_ref() {
  local ref="$1"
  local label="$2"
  if [ -z "$ref" ]; then
    echo "ERROR: Could not find element: $label"
    return 1
  fi
  echo "  Clicking: $label ($ref)"
  $CLI click "$ref" 2>/dev/null
}

echo "============================================"
echo "  NotebookLM PPT Generator"
echo "============================================"
echo "Output: $OUTPUT_PATH"
echo ""

echo "=== Step 1/7: Opening NotebookLM ==="
$CLI open "https://notebooklm.google.com/" 2>/dev/null
SNAP=$(wait_and_snap 5)

if echo "$SNAP" | grep -qi "sign.in\|登录\|login"; then
  echo "WARNING: NotebookLM requires login. Please sign in manually, then re-run this script."
  exit 1
fi
echo "  NotebookLM loaded"

echo ""
echo "=== Step 2/7: Creating new notebook ==="
REF=$(find_ref "$SNAP" "新建笔记本\|New notebook\|Create new\|create_new")
if [ -z "$REF" ]; then
  REF=$(find_ref "$SNAP" "button.*[Nn]ew\|button.*新建\|add_circle\|新笔记")
fi
if [ -z "$REF" ]; then
  echo "  Trying alternative: looking for any create/new button..."
  SNAP2=$(wait_and_snap 2)
  REF=$(find_ref "$SNAP2" "[Nn]ew\|新建\|[Cc]reate")
fi
click_ref "$REF" "New notebook button"
SNAP=$(wait_and_snap 4)
echo "  New notebook created"

echo ""
echo "=== Step 3/7: Adding text source ==="
REF=$(find_button_ref "$SNAP" "添加来源\|[Aa]dd source")
if [ -z "$REF" ]; then
  REF=$(find_button_ref "$SNAP" "add\|添加")
fi
click_ref "$REF" "Add source"
SNAP=$(wait_and_snap 4)

REF=$(find_button_ref "$SNAP" "复制的文字\|[Cc]opied text\|[Pp]aste text")
if [ -z "$REF" ]; then
  REF=$(find_button_ref "$SNAP" "content_paste\|粘贴")
fi
click_ref "$REF" "Copied text option"
SNAP=$(wait_and_snap 3)
echo "  Text source dialog opened"

echo ""
echo "=== Step 4/7: Pasting content ==="
REF=$(find_ref "$SNAP" 'textbox.*粘贴\|textbox.*[Pp]aste\|textbox.*在此处')
if [ -z "$REF" ]; then
  REF=$(find_ref "$SNAP" 'textbox.*active\|textbox.*placeholder')
fi
if [ -z "$REF" ]; then
  REF=$(find_ref "$SNAP" "textbox\|textarea")
fi
if [ -z "$REF" ]; then
  echo "ERROR: Could not find text input area"
  echo "SNAPSHOT:"
  echo "$SNAP" | head -30
  exit 1
fi
echo "  Found text input: $REF"
echo "  Typing content (${#CONTENT} chars)..."
$CLI type "$REF" "$CONTENT" 2>/dev/null
SNAP=$(wait_and_snap 2)

REF=$(find_button_ref "$SNAP" "插入\|[Ii]nsert\|[Ss]ubmit")
if [ -z "$REF" ]; then
  REF=$(find_button_ref "$SNAP" "确[定认]\|[Aa]dd")
fi
click_ref "$REF" "Insert button"
SNAP=$(wait_and_snap 5)
echo "  Content inserted"

echo ""
echo "=== Step 5/7: Generating presentation ==="
REF=$(find_button_ref "$SNAP" "演示文稿\|[Pp]resentation")
if [ -z "$REF" ]; then
  SNAP=$(wait_and_snap 5)
  REF=$(find_button_ref "$SNAP" "演示文稿\|[Pp]resentation\|[Ss]lides")
fi
click_ref "$REF" "Generate presentation"
echo "  Generating slides... (this may take 30-60 seconds)"

READY=false
for i in $(seq 1 12); do
  sleep 5
  SNAP=$(wait_and_snap 0)
  if echo "$SNAP" | grep -qi "已准备就绪\|[Rr]eady\|[Oo]pen\|打开\|查看"; then
    READY=true
    echo "  Presentation ready!"
    break
  fi
  echo "  Still generating... (${i}0s elapsed)"
done

if [ "$READY" = false ]; then
  echo "WARNING: Generation may still be in progress. Taking snapshot..."
  SNAP=$($CLI snapshot 2>/dev/null)
fi

echo ""
echo "=== Step 6/7: Opening presentation ==="
REF=$(find_button_ref "$SNAP" "来源.*分钟\|source.*min\|来源.*刚刚\|来源.*秒")
if [ -z "$REF" ]; then
  REF=$(find_button_ref "$SNAP" "OpenClaw\|演示文稿.*来源\|Presentation.*source")
fi
if [ -z "$REF" ]; then
  REF=$(find_ref "$SNAP" "cursor=pointer.*来源\|cursor=pointer.*source")
fi
click_ref "$REF" "Open presentation"
SNAP=$(wait_and_snap 5)
echo "  Presentation opened"

echo ""
echo "=== Step 7/7: Downloading PDF ==="
REF=$(find_button_ref "$SNAP" "更多选项\|more_horiz")
if [ -z "$REF" ]; then
  REF=$(find_button_ref "$SNAP" "[Mm]ore.*option\|更多")
fi
click_ref "$REF" "More options menu"
SNAP=$(wait_and_snap 3)

REF=$(echo "$SNAP" | grep -i 'menuitem.*PDF' | grep -oE 'ref=e[0-9]+' | head -1 | sed 's/ref=//')
if [ -z "$REF" ]; then
  REF=$(find_ref "$SNAP" "下载 PDF\|[Dd]ownload.*PDF\|PDF.*文档")
fi

if [ -z "$REF" ]; then
  echo "ERROR: Could not find PDF download option"
  echo "SNAPSHOT of menu:"
  echo "$SNAP" | grep -i "menu\|PDF\|下载\|download" | head -10
  echo "  Please download manually from the open presentation"
  exit 1
fi

echo "  Downloading PDF to $OUTPUT_PATH ..."
$CLI download "$REF" "$OUTPUT_PATH" --timeout-ms 30000 2>/dev/null
sleep 3

if [ -f "$OUTPUT_PATH" ]; then
  SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
  echo ""
  echo "============================================"
  echo "  SUCCESS!"
  echo "  File: $OUTPUT_PATH"
  echo "  Size: $SIZE"
  echo "============================================"
else
  echo ""
  echo "WARNING: PDF file not found at $OUTPUT_PATH"
  echo "  The download may still be in progress."
  echo "  Check ~/Desktop/ for the file."
fi
