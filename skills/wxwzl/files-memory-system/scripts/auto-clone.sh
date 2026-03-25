#!/bin/bash
# auto-clone.sh - 自动克隆项目到正确的目录
# 根据当前上下文决定克隆位置

set -e

REPO_URL="$1"
PROJECT_NAME="${2:-$(basename $REPO_URL .git)}"

# 从环境变量获取上下文
if [ -n "$GROUP_ID" ] && [ -n "$CHANNEL" ]; then
    # 在群组上下文中 - 先确保目录存在（方案 B）
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/ensure-group-memory.sh" "$CHANNEL" "$GROUP_ID"
    
    GROUP_DIR="memory/group_${CHANNEL}_${GROUP_ID}"
    TARGET_DIR="${GROUP_DIR}/repos/${PROJECT_NAME}"
    
    echo "📁 检测到群组上下文，克隆到: ${TARGET_DIR}"
    
elif [ -n "$IS_PRIVATE" ]; then
    # 在私聊上下文中 - 先确保目录存在（方案 B）
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/ensure-private-memory.sh"
    
    PRIVATE_DIR="memory/private"
    TARGET_DIR="${PRIVATE_DIR}/repos/${PROJECT_NAME}"
    
    echo "📁 检测到私聊上下文，克隆到: ${TARGET_DIR}"
    
else
    # 默认到全局 - 先确保全局记忆目录存在（方案 B）
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/ensure-global-memory.sh"
    
    TARGET_DIR="repos/${PROJECT_NAME}"
    
    # 确保目录存在
    mkdir -p "repos"
    
    echo "📁 未检测到特定上下文，克隆到全局: ${TARGET_DIR}"
fi

# 检查目标是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  目标目录已存在: ${TARGET_DIR}"
    echo "💡 如需重新克隆，请先删除该目录"
    exit 1
fi

# 克隆
echo "🔄 正在克隆 ${REPO_URL}..."
git clone "$REPO_URL" "$TARGET_DIR"

echo ""
echo "✅ 克隆完成: ${TARGET_DIR}"
echo "📝 记得更新 GLOBAL.md 记录此项目！"
echo ""
echo "项目内容:"
ls -la "$TARGET_DIR"
