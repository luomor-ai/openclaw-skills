---
name: skill-hub-gateway
description: Unified gateway skill for async execute and poll workflows.
version: 2.3.3
metadata:
  openclaw:
    skillKey: skill-hub-gateway
    emoji: "🧩"
    homepage: https://gateway.binaryworks.app
    requires:
      bins:
        - node
---

# Skill Hub Gateway

Default API base URL: `https://gateway-api.binaryworks.app`

Chinese documentation: `SKILL.zh-CN.md`

## Version Check Protocol (Agent)

- Official latest version source: `GET /skills/manifest.json` -> `data.version`.
- Local current version source: this installed `SKILL.md` frontmatter `version`.
- Compare versions using semantic version order (`major.minor.patch`).
- Check timing: once at session start, then at most once every 24 hours within the same session.
- If version check fails (network/timeout/parse error), do not block runtime execution. Continue current workflow and retry at the next allowed check window.

## Agent Decision Flow

- If `latest_version > current_version`, read the matching section under `Release Notes` in this document to build `update_summary`.
- Agent should show the user:
  - `current_version`
  - `latest_version`
  - `update_summary`
- User decision options:
  - `Update now`
  - `Remind me later in this session`
- If user chooses `Remind me later in this session`, suppress repeated prompts for the same target version until a new session starts.

## First-Time Onboarding (install_code)

Scripts auto-complete onboarding by default:

1. `POST /agent/install-code/issue` with `{"channel":"local"}` or `{"channel":"clawhub"}`.
2. Read `data.install_code`.
3. `POST /agent/bootstrap` with `{"agent_uid":"<agent_uid>","install_code":"<install_code>"}`.
4. Read `data.api_key`, then call runtime APIs with `X-API-Key` or `Authorization: Bearer <api_key>`.

Manual override:

- You can still provide `api_key` explicitly.
- If `agent_uid` and `owner_uid_hint` are omitted, scripts derive stable local defaults from the current workspace path.

## Runtime Contract (V2)

- Execute: `POST /skill/execute`
- Poll: `GET /skill/runs/:run_id`
- Image-based capabilities use `image_url`. In end-user product flows, users should upload files/attachments directly and should not need to paste URLs manually.
- Terminal states: `succeeded` and `failed`
- `succeeded` returns `output`
- `failed` returns `error` (`code`, `message`)

## Input Source Clarification

- Image-based capabilities, including `human_detect`, `image_tagging`, and all Roboflow image capabilities, accept uploaded images. Product UI should not require users to manually input URL fields.
- The bundled CLI scripts (`scripts/execute.mjs` / `scripts/poll.mjs`) do not include upload parameters. They only send the structured payload you provide.
- The skill accepts user-uploaded media/documents (including chat attachments) for:
  - image capabilities using `image_url`
  - `asr` using `audio_url`
  - `markdown_convert` using `file_url`
- Runtime may normalize uploaded files to temporary object URLs internally before provider execution.
- For user-facing forms, do not expose manual URL-paste or raw JSON input fields for media/document capabilities.
- For bootstrap/execute/poll failures, keep `request_id` from response JSON. Script stderr now logs `status`, `code`, `message`, and `request_id` for troubleshooting.

## Capability IDs

- `human_detect`
- `image_tagging`
- `tts_report`
- `embeddings`
- `reranker`
- `asr`
- `tts_low_cost`
- `markdown_convert`
- `face-detect`
- `person-detect`
- `hand-detect`
- `body-keypoints-2d`
- `body-contour-63pt`
- `face-keypoints-106pt`
- `head-pose`
- `face-feature-classification`
- `face-action-classification`
- `face-image-quality`
- `face-emotion-recognition`
- `face-physical-attributes`
- `face-social-attributes`
- `political-figure-recognition`
- `designated-person-recognition`
- `exhibit-image-recognition`
- `person-instance-segmentation`
- `person-semantic-segmentation`
- `concert-cutout`
- `full-body-matting`
- `head-matting`
- `product-cutout`

## Bundled Files

- `scripts/execute.mjs` (CLI args: `[api_key] [capability] [input_payload] [base_url] [agent_uid] [owner_uid_hint]`)
- `scripts/poll.mjs` (CLI args: `[api_key] <run_id> [base_url] [agent_uid] [owner_uid_hint]`)
- `scripts/runtime-auth.mjs` (shared auto-bootstrap helper)
- `references/capabilities.json`
- `references/openapi.json`
- `SKILL.zh-CN.md`

## Release Notes

When publishing a new version, add a new section here. Agent update summaries must be generated from this block.

### 2.3.3 (2026-03-11)

**What's New**

- Standardized user-facing guidance around upload-based flows: do not expose manual URL/JSON fields for media/document inputs.
- Updated capability reference examples and wording to match upload-first product UX.
- Renamed CLI argument label from `input_json` to `input_payload` for consistency with structured payload semantics.

**Breaking/Behavior Changes**

- None.

**Migration Notes**

- Existing runtime API calls remain unchanged.
- If your integration shows custom input forms, prefer file/attachment inputs instead of manual URL/JSON text fields.

### 2.3.2 (2026-03-10)

**What's New**

- Aligned capability reference docs with runtime behavior: file uploads/chat attachments are supported by host flows, and runtime may normalize uploads to URL form.
- Synced package reference OpenAPI version with SKILL frontmatter version to avoid release metadata drift.
- Added package-level test guards to catch future doc/version mismatches before publish.

**Breaking/Behavior Changes**

- None.

**Migration Notes**

- Existing runtime API calls remain unchanged.
- If your integration reads capability descriptions from manifest references, refresh cached docs to pick up the clarified upload wording.
### 2.3.1 (2026-03-10)

**What's New**

- Clarified upload behavior: CLI scripts do not perform uploads; upload support depends on the host client flow.
- Added structured runtime failure logs in CLI scripts (`status`, `code`, `message`, `request_id`) for bootstrap/execute/poll troubleshooting.

**Breaking/Behavior Changes**

- None.

**Migration Notes**

- Existing API calls remain unchanged.
- If you parse script stderr, allow the new JSON error log events.

### 2.3.0 (2026-03-10)

**What's New**

- Added a formal Agent-side version check protocol based on `/skills/manifest.json`.
- Added a formal Agent decision flow for update confirmation (`Update now` / `Remind me later in this session`).
- Defined this `Release Notes` section as the canonical source for user-facing update summaries.

**Breaking/Behavior Changes**

- None.

**Migration Notes**

- Existing integrations can keep current runtime API calls unchanged.
- To enable update notifications, Agent implementations should parse this section and compare installed version vs. `data.version`.
