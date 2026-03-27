#!/bin/bash
# 自动审查脚本 - 扫描所有仓库，逐个审查

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/repos.conf"
STATE_FILE="$SCRIPT_DIR/.review-state.json"
PENDING_FILE="$SCRIPT_DIR/.pending-reviews.json"

# 加载 Token
if [ -f "$SCRIPT_DIR/config/gitcode.conf" ]; then
  source "$SCRIPT_DIR/config/gitcode.conf"
fi

if [ -z "$GITCODE_API_TOKEN" ]; then
  echo "❌ 错误: 未配置 GitCode API Token"
  exit 1
fi

# 读取审查状态
load_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo '{"reviewed": []}'
  fi
}

# 检查 PR 是否已审查
is_reviewed() {
  local repo=$1
  local pr_number=$2
  local state=$(load_state)
  
  if echo "$state" | grep -q "\"$repo#$pr_number\""; then
    return 0
  else
    return 1
  fi
}

# 主函数
main() {
  echo "🤖 CANN 自动审查（批量扫描模式）"
  echo "======================================"
  echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  
  # 统计仓库数量
  REPO_COUNT=$(grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | wc -l | tr -d ' ')
  echo "📊 配置信息:"
  echo "  仓库数量: $REPO_COUNT"
  echo ""
  
  # 初始化待审查列表
  python3 << EOF
import json
with open('$PENDING_FILE', 'w') as f:
    json.dump({"pending": [], "scan_time": "$(date -Iseconds)"}, f, indent=2)
EOF
  
  # 遍历仓库，收集所有待审查的 PR
  echo "🔍 扫描所有仓库..."
  local total_pending=0
  
  while IFS= read -r repo; do
    # 跳过注释和空行
    [[ "$repo" =~ ^#.*$ ]] && continue
    [[ -z "$repo" ]] && continue
    
    local owner=$(echo "$repo" | cut -d'/' -f1)
    local repo_name=$(echo "$repo" | cut -d'/' -f2)
    
    echo "  检查: $repo"
    
    # 获取开放的 PR（获取前 20 个）
    local pr_list=$(curl -s -H "Authorization: Bearer $GITCODE_API_TOKEN" \
      "https://api.gitcode.com/api/v5/repos/$owner/$repo_name/pulls?state=opened&per_page=20")
    
    # 提取 PR 编号
    local pr_numbers=$(echo "$pr_list" | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
    
    local repo_pending=0
    for pr_number in $pr_numbers; do
      if ! is_reviewed "$repo" "$pr_number"; then
        # 获取 PR 详情
        local pr_info=$(curl -s -H "Authorization: Bearer $GITCODE_API_TOKEN" \
          "https://api.gitcode.com/api/v5/repos/$owner/$repo_name/pulls/$pr_number")
        
        # 提取标题
        local title=$(echo "$pr_info" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)
        # 提取作者
        local author=$(echo "$pr_info" | grep -o '"user":{[^}]*"login":"[^"]*"' | grep -o '"login":"[^"]*"' | head -1 | cut -d'"' -f4)
        # 提取链接
        local html_url="https://gitcode.com/$repo/merge_requests/$pr_number"
        
        # 添加到待审查列表
        python3 << EOF
import json

# 读取现有列表
try:
    with open('$PENDING_FILE', 'r') as f:
        data = json.load(f)
except:
    data = {"pending": [], "scan_time": "$(date -Iseconds)"}

# 添加新的待审查 PR
data["pending"].append({
    "repo": "$repo",
    "pr_number": $pr_number,
    "title": """$title""",
    "author": """$author""",
    "url": "$html_url"
})

# 保存
with open('$PENDING_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
EOF
        
        ((repo_pending++))
        ((total_pending++))
      fi
    done
    
    if [ $repo_pending -gt 0 ]; then
      echo "    ✅ 发现 $repo_pending 个待审查的 PR"
    else
      echo "    ℹ️  无待审查的 PR"
    fi
  done < "$CONFIG_FILE"
  
  echo ""
  echo "======================================"
  echo "扫描完成"
  echo "  待审查 PR 总数: $total_pending"
  echo ""
  
  if [ $total_pending -gt 0 ]; then
    echo "📋 待审查 PR 列表:"
    python3 << 'EOF'
import json
with open('/Users/zj/.openclaw/workspace/skills/cann-review/.pending-reviews.json', 'r') as f:
    data = json.load(f)
    for i, pr in enumerate(data["pending"], 1):
        print(f"  {i}. {pr['repo']}#{pr['pr_number']} - {pr['title']}")
        print(f"     作者: {pr['author']}")
        print(f"     链接: {pr['url']}")
        print()
EOF
    
    echo "💡 接下来将逐个审查这些 PR..."
    echo ""
    
    # 输出 JSON 标记，方便 Agent 解析
    echo "PENDING_REVIEWS_JSON_START"
    cat "$PENDING_FILE"
    echo ""
    echo "PENDING_REVIEWS_JSON_END"
  else
    echo "✅ 所有 PR 都已审查完毕"
  fi
  
  echo ""
  echo "======================================"
  echo "结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 运行主函数
main
