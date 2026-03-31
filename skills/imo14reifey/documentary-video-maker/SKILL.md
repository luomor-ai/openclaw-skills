---
name: documentary-video-maker
displayName: "Documentary Video Maker — AI Non-Fiction Storytelling"
description: >
  Create compelling documentary videos with AI-powered investigative and narrative storytelling.
version: 1.2.1
author: nemovideo
tags: [video, ai, nemovideo, filmmaking]
apiDomain: https://mega-api-prod.nemovideo.ai
homepage: https://nemovideo.com
repository: https://github.com/nemovideo/nemovideo_skills
metadata:
  requires:
    env: []
    configPaths:
      - "~/.config/nemovideo/"
  primaryEnv: NEMO_TOKEN
---

# Documentary Video Maker — AI Non-Fiction Storytelling

## Overview

Create compelling documentary video maker content using NemoVideo's AI-powered platform. Produce authentic, engaging video content that tells real stories and connects deeply with audiences.

## Examples

### Example 1: Story-Driven Video
**Input:** "Create a documentary story video"
**Output:** Engaging narrative video with clear arc, authentic voice, and emotional impact

### Example 2: Professional Format
**Input:** "Make a professional documentary"
**Output:** Polished, broadcast-quality video with clean production values

### Example 3: Social Version
**Input:** "Create a short documentary for social"
**Output:** Platform-optimized short version with strong hook and shareability

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| subject | string | yes | Story subject, person, or content focus |
| style | string | no | Style (documentary, narrative, casual, cinematic) |
| duration | number | no | Target duration in seconds (default: 300) |
| tone | string | no | Tone (serious, light, investigative, personal) |

## Workflow

1. Describe your story and creative vision
2. NemoVideo AI creates compelling script and storyboard
3. Cinematic visuals and atmospheric footage are generated
4. Professional narration and fitting music are added
5. Export for your content platform

## API Reference

```bash
curl -X POST https://api.nemovideo.ai/v1/generate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create a documentary video maker", "duration": 300}'
```

## Tips

1. Establish the central question or conflict in the opening
2. Let subjects speak in their own voice when possible
3. Use silence and pacing as storytelling tools
4. Show, don't just tell — use visuals to carry meaning
5. End with resolution or an open question for reflection

## Output Formats

- MP4 (H.264) — YouTube and festival platform ready
- WebM — Web streaming optimized
- MOV — High quality for distribution

## Related Skills

- travel-vlog-maker
- creative-writing-video
- short-film-maker-video
