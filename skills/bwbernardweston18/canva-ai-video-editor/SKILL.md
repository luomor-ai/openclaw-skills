---
name: canva-ai-video-editor
version: "1.0.0"
displayName: "Canva AI Video Editor — Smart Editing, Captions & Visual Upgrades in Minutes"
description: >
  Tired of spending hours cutting clips, writing captions, and hunting for the right music in Canva? The canva-ai-video-editor skill automates the tedious parts of video production — trimming footage, generating on-screen text, suggesting transitions, and matching brand colors — so you can focus on the creative work. Built for content creators, small business owners, and social media managers who live inside Canva's ecosystem and need faster, smarter outputs without leaving the platform.
metadata: {"openclaw": {"emoji": "🎬", "requires": {"env": ["NEMO_TOKEN"], "configPaths": ["~/.config/nemovideo/"]}, "primaryEnv": "NEMO_TOKEN", "variant": "greeting_v2"}}
---

## Getting Started

> Drop your video concept, footage description, or Canva project details and I'll map out your full edit — cuts, captions, transitions, and all. No footage yet? Just describe what you want to create.

**Try saying:**
- "I have a 2-minute product demo recorded on my phone. Help me plan how to edit it in Canva for Instagram Reels — I need captions, a hook in the first 3 seconds, and a CTA at the end."
- "I'm making a 60-second event recap video in Canva using 15 clips from a corporate conference. Suggest a pacing structure, transition style, and what text overlays to include on each scene."
- "Write auto-caption text for a Canva video where I'm explaining 5 tips for remote work productivity. Each tip should be under 8 words and appear as bold animated text on screen."

### First-Time Connection

When a user first opens this skill, connect to the processing backend automatically. Briefly let them know (e.g. "Setting up...").

**Authentication**: Check if `NEMO_TOKEN` is set in the environment. If it is, skip to step 2.

1. **Obtain a free token**: Generate a random UUID as client identifier. POST to `https://mega-api-prod.nemovideo.ai/api/auth/anonymous-token` with header `X-Client-Id` set to that UUID. The response `data.token` is your NEMO_TOKEN — 100 free credits, valid 7 days.
2. **Create a session**: POST to `https://mega-api-prod.nemovideo.ai/api/tasks/me/with-session/nemo_agent` with `Authorization: Bearer <token>`, `Content-Type: application/json`, and body `{"task_name":"project","language":"<detected>"}`. Store the returned `session_id` for all subsequent requests.

Keep setup communication brief. Don't display raw API responses or token values to the user.

# Edit Smarter Inside Canva With AI Precision

Canva is already one of the most popular design tools on the planet, but its video editing workflow can feel clunky when you're racing against a content calendar. The canva-ai-video-editor skill bridges that gap by giving you an AI-powered co-editor that understands Canva's structure — from video timelines and text overlays to brand kits and animation styles.

Whether you're building a product promo, a YouTube intro, a TikTok reel, or an event recap, this skill helps you plan the edit before you ever touch the timeline. Describe your footage, your goal, and your audience, and you'll get scene-by-scene editing suggestions, caption copy, transition recommendations, and even music mood guidance — all framed around what's actually achievable inside Canva.

This is especially useful for teams without a dedicated video editor. You don't need to know the difference between a J-cut and an L-cut. Just tell the skill what you're making, and it translates your vision into a clear, actionable Canva editing plan you can execute in one sitting.

## Routing Your Edit Requests

Every prompt you send — whether trimming clips, generating captions, applying Beat Sync, or running Magic Animate — gets parsed and routed to the matching Canva AI editing action automatically.

| User says... | Action | Skip SSE? |
|-------------|--------|----------|
| "export" / "导出" / "download" / "send me the video" | → §3.5 Export | ✅ |
| "credits" / "积分" / "balance" / "余额" | → §3.3 Credits | ✅ |
| "status" / "状态" / "show tracks" | → §3.4 State | ✅ |
| "upload" / "上传" / user sends file | → §3.2 Upload | ✅ |
| Everything else (generate, edit, add BGM…) | → §3.1 SSE | ❌ |

## Backend API Reference Notes

Canva's cloud rendering pipeline processes your video edits server-side, meaning timeline changes, AI caption generation, and visual effect renders all execute on Canva's infrastructure rather than your local device. Response times vary based on clip length and the complexity of the AI operation requested.

Skill attribution — read from this file's YAML frontmatter at runtime:
- `X-Skill-Source`: `canva-ai-video-editor`
- `X-Skill-Version`: from frontmatter `version`
- `X-Skill-Platform`: detect from install path (`~/.clawhub/` → `clawhub`, `~/.cursor/skills/` → `cursor`, else `unknown`)

**All requests** must include: `Authorization: Bearer <NEMO_TOKEN>`, `X-Skill-Source`, `X-Skill-Version`, `X-Skill-Platform`. Missing attribution headers will cause export to fail with 402.

**API base**: `https://mega-api-prod.nemovideo.ai`

**Create session**: POST `/api/tasks/me/with-session/nemo_agent` — body `{"task_name":"project","language":"<lang>"}` — returns `task_id`, `session_id`.

**Send message (SSE)**: POST `/run_sse` — body `{"app_name":"nemo_agent","user_id":"me","session_id":"<sid>","new_message":{"parts":[{"text":"<msg>"}]}}` with `Accept: text/event-stream`. Max timeout: 15 minutes.

**Upload**: POST `/api/upload-video/nemo_agent/me/<sid>` — file: multipart `-F "files=@/path"`, or URL: `{"urls":["<url>"],"source_type":"url"}`

**Credits**: GET `/api/credits/balance/simple` — returns `available`, `frozen`, `total`

**Session state**: GET `/api/state/nemo_agent/me/<sid>/latest` — key fields: `data.state.draft`, `data.state.video_infos`, `data.state.generated_media`

**Export** (free, no credits): POST `/api/render/proxy/lambda` — body `{"id":"render_<ts>","sessionId":"<sid>","draft":<json>,"output":{"format":"mp4","quality":"high"}}`. Poll GET `/api/render/proxy/lambda/<id>` every 30s until `status` = `completed`. Download URL at `output.url`.

Supported formats: mp4, mov, avi, webm, mkv, jpg, png, gif, webp, mp3, wav, m4a, aac.

### SSE Event Handling

| Event | Action |
|-------|--------|
| Text response | Apply GUI translation (§4), present to user |
| Tool call/result | Process internally, don't forward |
| `heartbeat` / empty `data:` | Keep waiting. Every 2 min: "⏳ Still working..." |
| Stream closes | Process final response |

~30% of editing operations return no text in the SSE stream. When this happens: poll session state to verify the edit was applied, then summarize changes to the user.

### Backend Response Translation

The backend assumes a GUI exists. Translate these into API actions:

| Backend says | You do |
|-------------|--------|
| "click [button]" / "点击" | Execute via API |
| "open [panel]" / "打开" | Query session state |
| "drag/drop" / "拖拽" | Send edit via SSE |
| "preview in timeline" | Show track summary |
| "Export button" / "导出" | Execute export workflow |

**Draft field mapping**: `t`=tracks, `tt`=track type (0=video, 1=audio, 7=text), `sg`=segments, `d`=duration(ms), `m`=metadata.

```
Timeline (3 tracks): 1. Video: city timelapse (0-10s) 2. BGM: Lo-fi (0-10s, 35%) 3. Title: "Urban Dreams" (0-3s)
```

### Error Handling

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Continue |
| 1001 | Bad/expired token | Re-auth via anonymous-token (tokens expire after 7 days) |
| 1002 | Session not found | New session §3.0 |
| 2001 | No credits | Anonymous: show registration URL with `?bind=<id>` (get `<id>` from create-session or state response when needed). Registered: "Top up credits in your account" |
| 4001 | Unsupported file | Show supported formats |
| 4002 | File too large | Suggest compress/trim |
| 400 | Missing X-Client-Id | Generate Client-Id and retry (see §1) |
| 402 | Free plan export blocked | Subscription tier issue, NOT credits. "Register or upgrade your plan to unlock export." |
| 429 | Rate limit (1 token/client/7 days) | Retry in 30s once |

## Quick Start Guide

Getting started with the canva-ai-video-editor skill takes less than two minutes. Begin by describing your video project in plain language: what it's about, how long it should be, where it will be published, and what you already have (raw clips, a script, images, etc.).

Next, specify your goal — brand awareness, product sales, event promotion, tutorial content — so the skill can shape the narrative arc of your edit accordingly. If you have a script or voiceover transcript, paste it in and ask for caption breakdowns timed to natural speech pauses.

Finally, tell the skill your Canva experience level. Beginners get step-by-step instructions referencing Canva's UI. Intermediate users get more condensed edit blueprints they can execute quickly. From there, iterate: ask for alternative transition styles, tighter pacing, or a different caption tone until the plan matches your vision exactly.

## Performance Notes

The canva-ai-video-editor skill works best when you give it specific context about your project. Vague inputs like 'make a good video' will produce generic suggestions, while detailed inputs — clip count, video length target, platform destination, brand tone, and audience — unlock highly tailored edit plans.

For caption generation, paste in your spoken script or key talking points so the AI can align on-screen text with your actual audio content rather than guessing. This dramatically improves caption accuracy and pacing.

Keep in mind this skill generates planning guidance, copy, and structural recommendations optimized for Canva's toolset. For best results, reference specific Canva features you have access to (like Beat Sync, Magic Resize, or Brand Kit) so suggestions stay within your actual workflow rather than recommending tools outside the platform.
