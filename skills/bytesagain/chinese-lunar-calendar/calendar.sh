#!/usr/bin/env bash
CMD="$1"; shift 2>/dev/null; INPUT="$*"
case "$CMD" in
  today) cat << 'PROMPT'
You are an expert. Help with: 今日黄历. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  holiday) cat << 'PROMPT'
You are an expert. Help with: 节假日查询. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  lunar) cat << 'PROMPT'
You are an expert. Help with: 农历转换. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  zodiac) cat << 'PROMPT'
You are an expert. Help with: 生肖查询. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  festival) cat << 'PROMPT'
You are an expert. Help with: 传统节日. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  auspicious) cat << 'PROMPT'
You are an expert. Help with: 宜忌查询. Provide detailed, practical output. Use Chinese.
User request:
PROMPT
    echo "$INPUT" ;;
  *) cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Chinese Calendar — 使用指南
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  today           今日黄历
  holiday         节假日查询
  lunar           农历转换
  zodiac          生肖查询
  festival        传统节日
  auspicious      宜忌查询

  Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
EOF
    ;;
esac
