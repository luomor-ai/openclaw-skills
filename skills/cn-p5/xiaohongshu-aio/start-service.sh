#!/bin/bash
# 检查并释放端口 18060
echo "检查端口 18060..."
PID=$(lsof -ti:18060 2>/dev/null)

if [ -n "$PID" ]; then
    echo "发现占用进程: $PID，正在终止..."
    kill -9 $PID
    sleep 2
    echo "进程已终止"
else
    echo "端口空闲"
fi

# 验证
if lsof -i :18060 >/dev/null 2>&1; then
    echo "错误：端口仍被占用"
    exit 1
else
    echo "端口已释放，可以启动服务"
fi

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
# 测试连接
echo "测试 MCP 连接..."
SESSION=$(curl -s -N -D - -X POST http://localhost:18060/mcp \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}},"id":1}' 2>/dev/null | \
    grep -i "Mcp-Session-Id" | awk '{print $2}' | tr -d '\r')

if [ -n "$SESSION" ]; then
    echo "✅ MCP 连接正常，Session: $SESSION"
else
    echo "❌ MCP 连接失败"
    exit 1
fi