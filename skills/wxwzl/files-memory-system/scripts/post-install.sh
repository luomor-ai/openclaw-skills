#!/bin/bash
# post-install.sh - Files Memory System Self-Registration
# 安装后自动向 AGENTS.md 声明自身存在

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_FILE="/workspace/AGENTS.md"
MARKER="<!-- files-memory-system: installed -->"

echo "📝 Running files-memory-system post-install..."

# 检查 AGENTS.md 是否存在
if [ ! -f "$AGENTS_FILE" ]; then
    echo "⚠️  AGENTS.md not found at $AGENTS_FILE"
    echo "   Please ensure you're installing in /workspace context"
    exit 0
fi

# 检查是否已经注册过
if grep -q "$MARKER" "$AGENTS_FILE" 2>/dev/null; then
    echo "✅ Files memory system already registered in AGENTS.md"
    exit 0
fi

# 添加到 AGENTS.md
cat >> "$AGENTS_FILE" << 'EOF'

<!-- files-memory-system: installed -->
## Files Memory System (Auto-Registered)

This workspace has the **files-memory-system** skill installed.

### Available Memory Locations
- **Global**: `memory/global/` - Cross-group shared memory
- **Group-specific**: `memory/group_<channel>_<id>/` - Isolated per group
- **Private**: `memory/private/` - 1-on-1 chat only

### Key Files
- `MEMORY.md` - Long-term curated memory (private chats only)
- `GLOBAL.md` - Quick reference in each memory directory
- `YYYY-MM-DD.md` - Daily logs

### Session Start - Memory Loading Rules ⭐

**⚠️ 群聊中必须自动加载：**
1. `memory/group_<channel>_<id>/GLOBAL.md` - 群组关键信息
2. `memory/group_<channel>_<id>/YYYY-MM-DD.md` (today) - 今日记录
3. `memory/group_<channel>_<id>/YYYY-MM-DD.md` (yesterday) - 昨日记录
4. `memory/global/GLOBAL.md` - **跨群组全局共享记忆**

**私聊中自动加载：**
1. `memory/private/YYYY-MM-DD.md` (today + yesterday)
2. `memory/global/GLOBAL.md` - **跨群组全局共享记忆**
3. `MEMORY.md` (仅私聊)

### When to Use
- User says "remember this" → Write to appropriate location
- User asks "what did we discuss" → Search memory directories
- User wants group isolation → Use group-specific paths
- Cross-group knowledge → Use global/

### Auto-Discovery Note
This section was auto-added by files-memory-system post-install.
<!-- files-memory-system: end -->
EOF

echo "✅ Registered files-memory-system in AGENTS.md"
echo "   Agent will now auto-discover this skill on startup"
