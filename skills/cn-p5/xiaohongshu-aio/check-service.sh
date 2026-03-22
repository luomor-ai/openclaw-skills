#!/bin/bash
# 检查并重启 MCP 服务

echo "检查 MCP 服务状态..."

# 检查进程
if pgrep -f "xiaohongshu-mcp" >/dev/null; then
    echo "服务正在运行"
    ps aux | grep xiaohongshu-mcp | grep -v grep
else
    echo "服务未运行，正在启动..."
    nohup ./xiaohongshu-mcp-linux-amd64 >./mcp.log 2>&1 &
    sleep 3
    
    if pgrep -f "xiaohongshu-mcp" >/dev/null; then
        echo "✅ 服务已启动"
        tail -3 ./mcp.log
    else
        echo "❌ 启动失败"
        exit 1
    fi
fi