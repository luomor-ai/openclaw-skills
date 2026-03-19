#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "fal-client>=0.5.0",
# ]
# ///
"""
Unified fal.ai client for image, video, audio generation and utilities.

Supports two modes:
  1. Direct fal.ai access: set FAL_KEY
  2. Via CS gateway:      set CS_FAL_GATEWAY_BASE_URL + CS_FAL_GATEWAY_API_TOKEN

When CS_FAL_GATEWAY_BASE_URL is set (e.g. https://gateway.corespeed.io/fal),
the script rewrites FAL_RUN_HOST and FAL_QUEUE_RUN_HOST so the fal SDK
routes all traffic through the gateway. The gateway proxies to fal.run and
injects the real FAL_KEY, so instances only need a user token.

Usage:
    uv run fal.py ENDPOINT [--json '{"prompt":"..."}'] -f out.png [-i input.png]

Examples:
    # Direct
    FAL_KEY=xxx uv run fal.py fal-ai/flux/schnell --json '{"prompt":"a fox"}' -f fox.png

    # Via gateway (instances use this)
    CS_FAL_GATEWAY_BASE_URL=https://gw.corespeed.io/fal CS_FAL_GATEWAY_API_TOKEN=user-tok \
      uv run fal.py fal-ai/flux/schnell --json '{"prompt":"a fox"}' -f fox.png
"""

import argparse
import json
import os
import sys
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

# ---------------------------------------------------------------------------
# Gateway setup — must run BEFORE importing fal_client because the SDK reads
# FAL_RUN_HOST / FAL_QUEUE_RUN_HOST at import time.
# ---------------------------------------------------------------------------
def _configure_gateway():
    """If CS_FAL_GATEWAY_BASE_URL is set, rewrite fal SDK env vars to route
    through the gateway instead of hitting fal.run directly.

    Gateway contract (mirrors the LLM gateway pattern):
      - CS_FAL_GATEWAY_BASE_URL  e.g. https://fal.gateway.corespeed.io
        The gateway proxies all fal.run + queue.fal.run traffic.
        The fal SDK auto-derives the queue host as queue.{FAL_RUN_HOST},
        so the gateway must handle both:
          fal.gateway.corespeed.io/*       → fal.run/*
          queue.fal.gateway.corespeed.io/* → queue.fal.run/*
      - CS_FAL_GATEWAY_API_TOKEN  user-scoped token sent as FAL_KEY
        (the gateway validates this and swaps it for the real key).
    """
    base_url = os.environ.get("CS_FAL_GATEWAY_BASE_URL", "")
    api_token = os.environ.get("CS_FAL_GATEWAY_API_TOKEN", "")
    if not base_url:
        return

    parsed = urlparse(base_url.rstrip("/"))
    host = parsed.hostname or ""
    port = f":{parsed.port}" if parsed.port and parsed.port not in (80, 443) else ""

    # Set FAL_RUN_HOST only — the SDK auto-derives:
    #   FAL_QUEUE_RUN_HOST = queue.{FAL_RUN_HOST}
    # So gateway needs:
    #   {host}       → proxies to fal.run
    #   queue.{host} → proxies to queue.fal.run
    os.environ["FAL_RUN_HOST"] = f"{host}{port}"

    # Use the user token as FAL_KEY — the gateway swaps it for the real key
    if api_token:
        os.environ["FAL_KEY"] = api_token

_configure_gateway()


# ---------------------------------------------------------------------------
# Input key mapping
# ---------------------------------------------------------------------------
START_IMAGE_ENDPOINTS = {"fal-ai/kling-video"}
VIDEO_INPUT_ENDPOINTS = {"fal-ai/topaz/upscale/video", "fal-ai/sync-lipsync"}


def get_input_key(endpoint: str, count: int) -> str:
    for prefix in VIDEO_INPUT_ENDPOINTS:
        if endpoint.startswith(prefix):
            return "video_url"
    for prefix in START_IMAGE_ENDPOINTS:
        if endpoint.startswith(prefix):
            return "start_image_url"
    if count > 1:
        return "image_urls"
    return "image_url"


def extract_output_url(result: dict) -> str | None:
    """Try common fal output keys: images[], image{}, video{}, audio{}, output{}."""
    images = result.get("images")
    if isinstance(images, list) and images:
        return images[0].get("url")
    for key in ("image", "video", "audio", "output"):
        obj = result.get(key)
        if isinstance(obj, dict) and "url" in obj:
            return obj["url"]
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Unified fal.ai client",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("endpoint", help="fal.ai endpoint (e.g. fal-ai/nano-banana-2)")
    parser.add_argument("--json", "-j", default="{}", dest="json_args",
                        help='Model parameters as JSON (e.g. \'{"prompt":"..."}\')')
    parser.add_argument("--filename", "-f", required=True, help="Output filename")
    parser.add_argument("--input", "-i", action="append", dest="inputs", metavar="FILE",
                        help="Input file(s) to upload. Repeat for multiple.")
    parser.add_argument("--audio", default="", help="Audio input file (for lipsync)")
    parser.add_argument("--api-key", "-k", help="fal.ai API key (overrides FAL_KEY)")

    args = parser.parse_args()

    # API key: gateway token (primary) or direct FAL_KEY (fallback)
    if args.api_key:
        os.environ["FAL_KEY"] = args.api_key
    if not os.environ.get("FAL_KEY"):
        print("Error: No credentials. Set CS_FAL_GATEWAY_API_TOKEN + CS_FAL_GATEWAY_BASE_URL, or FAL_KEY for direct access.", file=sys.stderr)
        sys.exit(1)

    import fal_client

    endpoint = args.endpoint
    output_path = Path(args.filename)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Parse JSON args
    try:
        request_args: dict = json.loads(args.json_args)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)

    # Upload input files
    if args.inputs:
        uploaded = []
        for fpath in args.inputs:
            if fpath.startswith("http"):
                uploaded.append(fpath)
                print(f"Using URL: {fpath}")
            else:
                url = fal_client.upload_file(fpath)
                uploaded.append(url)
                print(f"Uploaded: {fpath} → {url}")

        key = get_input_key(endpoint, len(uploaded))
        if key == "image_urls":
            request_args[key] = uploaded
        else:
            request_args[key] = uploaded[0]

    # Upload audio input
    if args.audio:
        if args.audio.startswith("http"):
            request_args["audio_url"] = args.audio
        else:
            audio_url = fal_client.upload_file(args.audio)
            print(f"Uploaded audio: {args.audio} → {audio_url}")
            request_args["audio_url"] = audio_url

    print(f"Calling {endpoint}...")
    print(f"Args: {json.dumps(request_args, ensure_ascii=False)[:200]}")

    try:
        result = fal_client.subscribe(
            endpoint,
            arguments=request_args,
            with_logs=True,
            on_queue_update=lambda update: (
                print(f"Queue: {update.status}") if hasattr(update, "status") else None
            ),
        )

        # Save output
        output_url = extract_output_url(result)
        if not output_url:
            print(f"Error: Cannot find output URL. Keys: {list(result.keys())}", file=sys.stderr)
            print(f"Response: {json.dumps(result, default=str)[:500]}", file=sys.stderr)
            sys.exit(1)

        urllib.request.urlretrieve(output_url, str(output_path))
        full_path = output_path.resolve()
        print(f"\nSaved: {full_path}")
        print(f"MEDIA: {full_path}")

        # Print extra images if present
        images = result.get("images", [])
        for idx, img in enumerate(images[1:], start=2):
            extra_path = output_path.parent / f"{output_path.stem}-{idx}{output_path.suffix}"
            img_url = img.get("url", "")
            if img_url:
                urllib.request.urlretrieve(img_url, str(extra_path))
                efp = extra_path.resolve()
                print(f"Saved: {efp}")
                print(f"MEDIA: {efp}")

        # Print metadata
        if result.get("description"):
            print(f"\nModel: {result['description']}")
        if result.get("duration_ms"):
            print(f"Duration: {result['duration_ms']}ms")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
