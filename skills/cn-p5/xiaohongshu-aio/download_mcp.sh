#!/usr/bin/env bash
#
# 🦀 Xiaohongshu MCP 二进制文件下载脚本
#
# 检测并下载最新版本的 Xiaohongshu MCP 二进制文件
# 用法:
#   bash download_mcp.sh
#

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
success() { echo -e "${GREEN}[✅]${NC} $1"; }

# 检测系统类型和架构
detect_system() {
    log "检测系统类型和架构..."
    
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    case "$OS" in
        Linux*)
            OS_TYPE="linux"
            ;;
        Darwin*)
            OS_TYPE="darwin"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) 
            OS_TYPE="windows"
            ;;
        *)
            err "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64)
            ARCH_TYPE="amd64"
            ;;
        aarch64|arm64)
            ARCH_TYPE="arm64"
            ;;
        *)
            err "不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    log "系统: $OS_TYPE, 架构: $ARCH_TYPE"
}

# 检查是否已存在二进制文件
check_existing_files() {
    log "检查是否已存在二进制文件..."
    
    if [ "$OS_TYPE" = "windows" ]; then
        SERVER_FILE="xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}.exe"
        LOGIN_FILE="xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}.exe"
    else
        SERVER_FILE="xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}"
        LOGIN_FILE="xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}"
    fi
    
    if [ -f "$SERVER_FILE" ] && [ -f "$LOGIN_FILE" ]; then
        success "二进制文件已存在，跳过下载"
        return 0
    else
        warn "二进制文件不存在，准备下载"
        return 1
    fi
}

# 获取最新版本信息
get_latest_version() {
    log "获取最新版本信息..."
    
    if ! command -v curl &> /dev/null; then
        err "curl 未安装，请先安装 curl"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        err "jq 未安装，请先安装 jq"
        exit 1
    fi
    
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/xpzouying/xiaohongshu-mcp/releases/latest)
    TAG_NAME=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
    
    if [ -z "$TAG_NAME" ] || [ "$TAG_NAME" = "null" ]; then
        err "无法获取最新版本信息"
        exit 1
    fi
    
    log "最新版本: $TAG_NAME"
}

# 下载二进制文件
download_files() {
    log "下载二进制文件..."
    
    # 构建下载URL
    BASE_URL="https://github.com/xpzouying/xiaohongshu-mcp/releases/download/$TAG_NAME"
    
    # 下载服务器
    SERVER_TAR="xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
    SERVER_URL="${BASE_URL}/${SERVER_TAR}"
    
    log "下载服务器文件: $SERVER_URL"
    curl -L -o "$SERVER_TAR" "$SERVER_URL"
    
    # 下载登录工具
    LOGIN_TAR="xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
    LOGIN_URL="${BASE_URL}/${LOGIN_TAR}"
    
    log "下载登录工具: $LOGIN_URL"
    curl -L -o "$LOGIN_TAR" "$LOGIN_URL"
    
    success "文件下载完成"
}

# 解压文件
extract_files() {
    log "解压文件..."
    
    # 解压服务器文件
    if [ -f "xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}.tar.gz" ]; then
        tar -xzf "xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
        rm "xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
    fi
    
    # 解压登录工具
    if [ -f "xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}.tar.gz" ]; then
        tar -xzf "xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
        rm "xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
    fi
    
    # 设置执行权限（非Windows系统）
    if [ "$OS_TYPE" != "windows" ]; then
        chmod +x "xiaohongshu-mcp-${OS_TYPE}-${ARCH_TYPE}" 2>/dev/null || true
        chmod +x "xiaohongshu-login-${OS_TYPE}-${ARCH_TYPE}" 2>/dev/null || true
    fi
    
    success "文件解压完成"
}

# 验证下载
verify_download() {
    log "验证下载..."
    
    local errors=0
    
    if [ ! -f "$SERVER_FILE" ]; then
        err "服务器文件未下载成功: $SERVER_FILE"
        ((errors++))
    fi
    
    if [ ! -f "$LOGIN_FILE" ]; then
        err "登录工具未下载成功: $LOGIN_FILE"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        success "下载验证通过！"
        return 0
    else
        err "下载验证失败，发现 ${errors} 个问题"
        return 1
    fi
}

# 主函数
main() {
    echo "========================================"
    echo "  🦀 Xiaohongshu MCP 二进制文件下载脚本"
    echo "========================================"
    echo ""
    
    detect_system
    
    if check_existing_files; then
        exit 0
    fi
    
    get_latest_version
    download_files
    extract_files
    verify_download
    
    echo ""
    echo "📁 下载的文件:"
    echo "   - 服务器: $(pwd)/$SERVER_FILE"
    echo "   - 登录工具: $(pwd)/$LOGIN_FILE"
    echo ""
    echo "🚀 使用方法:"
    echo "   ./$SERVER_FILE &  # 启动服务器"
    echo ""
}

main "$@"
