#!/usr/bin/env bash
CMD="$1"; shift 2>/dev/null; INPUT="$*"
case "$CMD" in
  argue) cat << 'PROMPT'
You are an expert. Help with: 论点构建. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  counter) cat << 'PROMPT'
You are an expert. Help with: 反驳策略. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  structure) cat << 'PROMPT'
You are an expert. Help with: 辩论结构. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  evidence) cat << 'PROMPT'
You are an expert. Help with: 论据搜集. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  rebut) cat << 'PROMPT'
You are an expert. Help with: 即兴反驳. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  judge) cat << 'PROMPT'
You are an expert. Help with: 评判标准. Be creative and detailed. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  *) cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Debate Helper — 使用指南
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  argue           论点构建
  counter         反驳策略
  structure       辩论结构
  evidence        论据搜集
  rebut           即兴反驳
  judge           评判标准

  Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
EOF
    ;;
esac
