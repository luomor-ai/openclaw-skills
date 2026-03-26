---
name: objectremover-video-object-ops
description: Remove or extract objects from videos with AI. Supports watermark/distraction removal, subject extraction with transparent background, natural-language object selection, upload-or-URL input, and end-to-end processing from input to downloadable result.
tags:
  - ai-video-editing
  - object-removal
  - object-extraction
  - watermark-removal
  - natural-language-selection
  - capcut-premiere-davinci
  - openclaw-ready
---

# ObjectRemover Video Object Ops

## Use This First

- **Single install for users:** this one skill is enough from upload to final result, including troubleshooting.
- Best for common ObjectRemover jobs: remove watermarks/distracting objects, or extract a subject for reuse in CapCut/Premiere/DaVinci.
- Supports both **chat-like natural language selection** and API-style automated processing.

## Production Contract

- Backend: `https://apiobjectremover.tokenlens.ai`
- Server-side forwarding env:
  - `HEAVY_API_URL=https://apiobjectremover.tokenlens.ai`

## Two Auth Modes

### A) Browser or guest (human flow)

1. If unregistered: `POST /api/auth/guest-session`, then send `x-guest-session-id` on processing calls.
2. Prepare asset (upload in UI, or existing asset id).
3. `POST /api/processing/calculate-cost` (optional).
4. `POST /api/processing/generate-mask`
5. `POST /api/processing/start-task`
6. `GET /api/processing/task/:taskId` until terminal state.
7. Read `outputUrl` / UI when completed.

### B) API Key / OpenClaw (M2M)

- **Always call the backend origin directly** (same host as `HEAVY_API_URL`). **Do not** rely on Cloudflare Workers to validate `Authorization: Bearer`; API key resolution runs on the Node/Ubuntu app only.
- Header: `Authorization: Bearer <api_key>` (prefix e.g. `orsk_live_...`).
- Scopes typically needed end-to-end: `credits:read`, `processing:write`, `processing:read` (or `*`).
- **Asset ownership**: `start-task` requires an `assetId` belonging to the key’s user. Obtain by:
  - `POST /api/assets/upload` with the same Bearer (multipart field `media`, optional `x-original-name`, `x-media-*`), **or**
  - reuse an existing id from `GET /api/assets` (same auth).
- Mask semantics: `textPrompt` in `generate-mask` (script/env: `OBJECTREMOVER_TEXT_PROMPT`, default `object`). Action `remove` vs `extract` is `OBJECTREMOVER_ACTION` / request body `action`.
- **Reference E2E script** (env-driven, non-interactive): `scripts/openclaw-api-key-e2e.ts` — `pnpm run test:openclaw-e2e`

## Required Request Rules

- **Guest path**: `x-guest-session-id` on processing endpoints when using guest identity.
- **API Key path**: Bearer on backend; no guest header unless mixing flows (not typical).
- **Production**: processing and API-key calls must hit the **backend domain**.

## Fallback Rules

- No credits: low-trial when allowed, else checkout / top-up.
- 401 on guest flow: issue guest session first, retry with `x-guest-session-id`.
- 401 on API key: wrong host (Workers), missing scope, or invalid/revoked key.

## When Something Breaks

- Use **[reference.md](reference.md)** sections **Workers vs Ubuntu** and **Troubleshooting** first: same skill covers “works locally, fails in prod”, “Bearer 401”, and “should this route hit Workers or backend”.

## Additional Resources

- Full contracts, OpenClaw, deployment matrix: [reference.md](reference.md)
