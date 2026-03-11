#!/usr/bin/env bash
CMD="$1"; shift 2>/dev/null; INPUT="$*"
case "$CMD" in
  design) cat << 'PROMPT'
You are an expert. Help with: 数据库表设计. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  normalize) cat << 'PROMPT'
You are an expert. Help with: 范式化分析. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  index) cat << 'PROMPT'
You are an expert. Help with: 索引策略. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  migrate) cat << 'PROMPT'
You are an expert. Help with: 迁移脚本. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  seed) cat << 'PROMPT'
You are an expert. Help with: 测试数据生成. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  diagram) cat << 'PROMPT'
You are an expert. Help with: ER图描述. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  *) cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Database Designer — 使用指南
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  design          数据库表设计
  normalize       范式化分析
  index           索引策略
  migrate         迁移脚本
  seed            测试数据生成
  diagram         ER图描述

  Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
EOF
    ;;
esac
