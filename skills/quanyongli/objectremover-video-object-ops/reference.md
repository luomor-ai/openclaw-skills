# ObjectRemover Video Object Ops Reference

## What Users Get

- Remove unwanted objects from videos (watermarks, distractions, random passersby).
- Extract subjects with transparent background for reuse in CapCut, Premiere Pro, or DaVinci Resolve.
- Select targets with natural language (for example: "remove the yellow toy"), then get a downloadable result.
- Run both human-in-the-loop flow (upload -> select -> process) and OpenClaw/API-Key automation.

## Best Fit Scenarios

- Quick cleanup for short-form videos (TikTok/Reels/YouTube Shorts).
- Creator/editor workflow that needs fast cutout or clean plate output.
- Automated backend jobs that must run end-to-end via API and polling.

## End-to-End Outcome (Simple View)

1. Provide a video (upload file, URL download, or existing asset).
2. Tell AI what to remove or extract (`textPrompt` + `action`).
3. Start processing and poll progress.
4. Download/use the processed output URL.

---

## Endpoint Contract (browser / guest)

### 1) Guest session

- `POST /api/auth/guest-session`
- Purpose: issue signed session for unregistered users.
- Success: `{ "guestSessionId": "..." }`

### 2) Cost estimate

- `POST /api/processing/calculate-cost`
- Scope (API Key): `credits:read`
- Purpose: estimate required credits before start-task.

### 3) Generate mask

- `POST /api/processing/generate-mask`
- Guest header: `x-guest-session-id: <id>`
- Body includes `textPrompt` (what to segment; can be a weak default like `object`), `videoUrl`, `isSingleFrame`, etc.

### 4) Start task

- `POST /api/processing/start-task`
- Guest header: `x-guest-session-id: <id>`
- Body `action`: `remove` | `extract`

### 5) Poll status

- `GET /api/processing/task/:taskId`
- Guest header: `x-guest-session-id: <id>`
- Scope (API Key): `processing:read`
- Terminal states:
  - **extract**: often `completed` / `failed` from DB-backed status in API response.
  - **remove** (Replicate path): poll may surface Replicate-style `succeeded` / `failed` before normalization; treat **`completed`** or **`succeeded`** as success when integrating.

---

## OpenClaw / API Key (machine-to-machine)

Use this when users want a no-UI, script/API path with the same final result.

### Host rule

- Resolve API key **only on the Ubuntu/Node backend**, not on Cloudflare Workers.
- Set client base URL to the heavy API, e.g. `https://apiobjectremover.tokenlens.ai`.
- If requests go only to the Workers front domain without forward, Bearer may never authenticate.

### Auth and scopes

- Header: `Authorization: Bearer <secret>`
- Typical scopes for the full pipeline: `credits:read`, `processing:write`, `processing:read`, or `*`.

### Assets (same user as the key)

- `GET /api/apikeys` — list keys (session or Bearer, depending on route; useful to sanity-check auth).
- `POST /api/assets/upload` — multipart `media` + Bearer; optional headers `x-original-name`, `x-media-width`, `x-media-height`, `x-media-duration`.
- `GET /api/assets` — list assets for the authenticated user.
- `GET /api/assets/:id` — metadata and playback URLs (`fullUrl`, `mediaUrlRemote`). Bearer supported on backend.

### Processing (Bearer)

Same endpoints as browser flow, with Bearer instead of cookies/guest:

1. `POST /api/processing/calculate-cost`
2. `POST /api/processing/generate-mask`
3. `POST /api/processing/start-task` (requires `assetId` owned by the key’s user)
4. `GET /api/processing/task/:taskId`

### Non-interactive E2E script (OpenClaw-style)

- File: `scripts/openclaw-api-key-e2e.ts`
- Command: `pnpm run test:openclaw-e2e` (or `pnpm exec tsx scripts/openclaw-api-key-e2e.ts`)
- Required env: `OBJECTREMOVER_API_BASE`, `OBJECTREMOVER_API_KEY`, and either `OBJECTREMOVER_UPLOAD_PATH` (local file -> upload first) **or** `OBJECTREMOVER_ASSET_ID`.
- Optional env: `OBJECTREMOVER_VIDEO_URL` (skip GET asset for URL), `OBJECTREMOVER_ACTION` (`remove`|`extract`), `OBJECTREMOVER_QUALITY`, `OBJECTREMOVER_TEXT_PROMPT`, `POLL_INTERVAL_MS`, `MAX_POLL_MS`, `OBJECTREMOVER_WIDTH`/`HEIGHT`/`DURATION`.
- If both `OBJECTREMOVER_UPLOAD_PATH` and `OBJECTREMOVER_ASSET_ID` are set, upload runs and the **new** asset id wins.

---

## Workers vs Ubuntu (single-skill troubleshooting)

ObjectRemover splits work between **Cloudflare Workers** (edge) and **Ubuntu backend** (heavy API). Users only need **this skill**; when something fails, check **where the request runs** and **which URL the client calls**.

### Who does what

| Location | Role |
|----------|------|
| **Workers** | SSR, static assets, lightweight APIs, **forwarding** heavy routes to `HEAVY_API_URL`. |
| **Ubuntu backend** | Heavy APIs, DB, full auth, Replicate/FFmpeg, uploads, processing, task persistence. |

### Ground rules

1. **Heavy work** (files, FFmpeg, Replicate, long tasks, most `/api/processing/*`, asset upload/raw/trim): execute on **Ubuntu**; on Workers these routes should **forward** to `HEAVY_API_URL`, not emulate DB/fs.
2. Workers must not depend on Node `pg` + local filesystem for heavy behavior.
3. **API Key (`Authorization: Bearer`)** is resolved on the **backend** only. Calling only the **frontend/Workers** origin without hitting the heavy API host often yields **401** or no key resolution—point M2M clients at **`https://apiobjectremover.tokenlens.ai`** (or your deployed heavy API origin).

### Env highlights

- **Workers:** e.g. `HEAVY_API_URL=https://apiobjectremover.tokenlens.ai` (forward target).
- **Ubuntu:** `DATABASE_URL`, auth/storage config, Replicate tokens, etc.

### Production URL contract

- Frontend example: `https://objectremover.video`
- Heavy backend: `https://apiobjectremover.tokenlens.ai`
- Workers forwards heavy APIs to `HEAVY_API_URL`; Ubuntu runs heavy routes locally when the request already arrived there.

### Routes often forwarded from Workers -> backend

- `POST /api/processing/generate-mask`
- `POST /api/processing/start-task`
- `GET /api/processing/task/:taskId`
- `POST /api/assets/upload`
- `POST /api/assets/download-url`

### Diagnostic heuristics

- **Works locally (Ubuntu) but fails via production URL** -> confirm route is forwarded on Workers, or call backend directly for API Key / automation.
- **401 / auth mismatch across domains** -> absolute API URL, cookies vs Bearer, SameSite/credentials.
- **Empty or fallback data from credits/tasks on Workers** -> may be DB-unavailable fallback; heavy writes should hit Ubuntu path.
- **Bearer works on backend, 401 on site domain** -> expected if Workers does not resolve API keys; use backend base URL for OpenClaw.

---

## User-State Handling

### Unregistered user

1. Call guest-session endpoint.
2. Attach `x-guest-session-id` to processing calls.
3. Apply rate-limit/quota behavior if backend returns related errors.

### Registered user with insufficient credits

1. Read cost estimate.
2. If insufficient, try low-trial path when allowed.
3. If trial unavailable, start checkout flow, then retry start-task.

### API Key clients

1. Ensure backend base URL and valid scopes.
2. Create or reuse `assetId` via upload or API.
3. Set `action` and `textPrompt` explicitly (no interactive prompts in the E2E script defaults).

---

## Runtime Rules

- Workers should forward heavy processing routes.
- Ubuntu backend executes Replicate/FFmpeg/task persistence.
- Production forwarding target:
  - `HEAVY_API_URL=https://apiobjectremover.tokenlens.ai`

## Troubleshooting

- `401 Unauthorized`
  - Browser: missing/expired session, or missing guest header on processing.
  - API Key: request hit **Workers-only** host, missing `Authorization`, wrong/expired key, or insufficient scope—**prefer backend origin** for Bearer (see **Workers vs Ubuntu**).
- `400 credits insufficient`
  - downgrade to low trial or purchase credits.
- `403` on start-task / assets
  - asset not owned by authenticated user (wrong `assetId` or wrong key user).
- Polling stuck
  - inspect backend task updates and processor health.
- No output URL
  - inspect task terminal status and storage registration.
- **Prod vs local mismatch**
  - Re-read **Workers vs Ubuntu**: forwarding, `HEAVY_API_URL`, and whether the client targets the heavy API hostname.

## Decision Checklist (Install or Not)

- Install this skill if you need at least one of:
  - AI object removal from videos.
  - AI object extraction with transparent-background output.
  - Natural-language object targeting.
  - OpenClaw/API-Key automation from upload to final result.
- Skip this skill if your task is only generic video trim/compress without object-level AI editing.
