---
name: local-stt-workflow
description: Local speech-to-text workflow for an OpenAI-compatible STT server on http://127.0.0.1:8000/v1. Use when configuring, testing, debugging, or validating audio transcription with `/v1/audio/transcriptions` or `/v1/audio/translations`, especially for OpenClaw audio pipelines, multipart upload compatibility, model registration, streaming SSE behavior, response_format handling, and “did the request reach the server or not?” investigations.
---

# Local STT Workflow

Use this skill to debug the **full transcription path**, not just the model.

Default assumption: the local STT server lives at `http://127.0.0.1:8000/v1`.

## Workflow

### 1. Verify the server before blaming OpenClaw

Check the basics first:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/v1/models
```

Confirm that the intended STT model exists, usually `qwen3-asr`.

If the server is task-gated, ensure STT is enabled:

```bash
MLX_AUDIO_SERVER_TASKS=stt uv run python server.py
```

If the model is missing, register it before testing clients.

## 2. Prove the raw STT endpoint works

Always isolate the server from the client stack.

Minimal direct transcription test:

```bash
curl -X POST http://127.0.0.1:8000/v1/audio/transcriptions \
  -F file=@sample.wav \
  -F model=qwen3-asr \
  -F response_format=json
```

Useful richer test:

```bash
curl -X POST http://127.0.0.1:8000/v1/audio/transcriptions \
  -F file=@sample.wav \
  -F model=qwen3-asr \
  -F response_format=verbose_json \
  -F 'timestamp_granularities[]=segment' \
  -F 'timestamp_granularities[]=word'
```

If direct `curl` works but OpenClaw does not, the bug is probably in the **message ingestion or routing layer**, not the STT backend.

## 3. Distinguish server failure from routing failure

Use this rule hard:

- **Direct curl fails** → fix the local STT server first
- **Direct curl works, but OpenClaw shows no transcript** → inspect OpenClaw audio pipeline / attachment routing
- **OpenClaw sends requests, but fields are wrong** → inspect request shape compatibility

This distinction saves a shitload of time.

## 4. Check the request shape

This server is designed around **OpenAI-style multipart form upload**.

Expected core fields for `/v1/audio/transcriptions`:

- `file`
- `model`
- optional `language`
- optional `response_format`
- optional `prompt`
- optional `stream`
- optional `timestamp_granularities[]`

If a client is suspected of sending the wrong shape, inspect traffic with a temporary dump proxy or server logs.

## 5. Use the reference doc when exact fields matter

Read `references/stt-api.md` when you need exact behavior for:

- `response_format=json|text|verbose_json|srt|vtt`
- `stream=true` SSE events
- `timestamp_granularities[]`
- `include[]`
- translation endpoint semantics
- error envelope shape
- current compatibility limits

Do **not** guess field support from generic OpenAI docs when this local server may intentionally differ.

## 6. OpenClaw-specific debugging pattern

When OpenClaw STT appears broken:

1. Confirm `tools.media.audio` is configured, not `messages.stt`
2. Confirm base URL points at `http://127.0.0.1:8000/v1`
3. Confirm the chosen model exists in `/v1/models`
4. Send the exact inbound audio file directly to `/v1/audio/transcriptions`
5. Inspect gateway logs for any sign of transcription dispatch
6. If there is **no** `/audio/transcriptions` request at all, the problem is upstream of STT

If OpenClaw never hits the server, stop tweaking model params. That would be cargo-cult debugging.

## 7. Preferred test ladder

Use this order:

1. `GET /health`
2. `GET /v1/models`
3. direct `curl` transcription with the same audio file
4. direct `curl` translation if relevant
5. OpenAI client compatibility test
6. OpenClaw integration test
7. dump-proxy / log inspection only if still ambiguous

## 8. Common conclusions

### Server good, client bad

Typical signs:

- manual `curl` returns `{ "text": ... }`
- OpenClaw logs show no transcription request
- changing model/language does nothing

Conclusion: fix routing, not inference.

### Multipart mismatch

Typical signs:

- server is up
- model exists
- client gets 400 errors
- direct `curl` works but app client does not

Conclusion: compare multipart field names and values.

### Feature mismatch

Typical signs:

- client expects diarization, logprobs, or richer streaming fields
- local server only implements a smaller compatible subset

Conclusion: align expectations with `references/stt-api.md`.

## Resources

### references/

- `references/stt-api.md` — exact local API behavior, schema, response formats, SSE events, limits, and compatibility notes
