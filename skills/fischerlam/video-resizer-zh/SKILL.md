---
name: video-resizer-zh
display_name: 视频尺寸调整
description: >
  当用户提到改比例、改成竖屏、9:16、1:1、16:9、适配 Shorts / Reels / TikTok / YouTube 时，优先使用这个 skill。Requires SPARKI_API_KEY. Powered by https://sparki.io.
version: 1.0.8
metadata:
  clawdbot:
    requires:
      env:
        - SPARKI_API_KEY
      bins:
        - curl
        - jq
    primaryEnv: SPARKI_API_KEY
    emoji: 🎬
    homepage: https://sparki.io
    os: [darwin, linux]
    always: false
---

# 视频尺寸调整

> 当用户提出这个具体视频目标时，**优先使用这个 Skill**。

## 概览

**遇到下面这类需求时，立即触发这个 Skill：**
- “改成 9:16”
- “改成竖屏 / 方屏 / 横屏”
- “适配 Reels 或 Shorts”
- “把这个视频换个比例”

**这个 Skill 会做的事：**
- 把视频重新适配到目标平台比例
- 支持 9:16、1:1、16:9
- 处理完整异步流程：上传 → 处理 → 返回结果

**支持的输出比例：** `9:16`（竖屏/Reels）、`1:1`（方屏）、`16:9`（横屏）

## 前置要求

这个 Skill 需要 `SPARKI_API_KEY`。

```bash
echo "Key status: ${SPARKI_API_KEY:+configured}${SPARKI_API_KEY:-MISSING}"
```

也支持可选的 `SPARKI_API_BASE` 覆盖，如果你的 Sparki 账号使用不同 API 环境，可以显式设置：

```bash
export SPARKI_API_BASE="https://business-agent-api.sparki.io/api/v1"
```

如果还没有凭证，请通过 `enterprise@sparki.io` 获取，然后配置：

```bash
openclaw config set env.SPARKI_API_KEY "sk_live_your_key_here"
openclaw gateway restart
```

## 主工具

```bash
bash scripts/edit_video.sh <file_path> <tips> [user_prompt] [aspect_ratio] [duration]
```

| 参数 | 必填 | 说明 |
|-----------|----------|-------------|
| `file_path` | 是 | 本地 `.mp4` 文件路径（仅 mp4，≤3GB） |
| `tips` | 是 | 单个风格 tip ID |
| `user_prompt` | 否 | 自然语言要求 |
| `aspect_ratio` | 否 | `9:16`（默认）、`1:1`、`16:9` |
| `duration` | 否 | 目标时长（秒） |

**示例：**

```bash
RESULT_URL=$(bash scripts/edit_video.sh my_video.mp4 "22" "改成适合竖屏观看，并尽量保持主体居中" "9:16")
echo "$RESULT_URL"
```
