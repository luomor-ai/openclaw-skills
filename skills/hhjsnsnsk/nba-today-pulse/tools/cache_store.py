#!/usr/bin/env python3
"""Shared in-memory cache for the public ClawHub bundle."""

from __future__ import annotations

import json
import threading
import time
from typing import Any, Callable

from nba_common import NBAReportError

MEMORY_LOCK = threading.Lock()
MEMORY_CACHE: dict[tuple[str, str], dict[str, Any]] = {}


def _cache_key(namespace: str, key: str) -> tuple[str, str]:
    return namespace, key


def _serialize_payload(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, separators=(",", ":"))


def _trim_oversized_entry(entry: dict[str, Any], max_payload_bytes: int) -> dict[str, Any]:
    payload_text = _serialize_payload(entry.get("payload"))
    if len(payload_text.encode("utf-8")) <= max_payload_bytes:
        return entry
    raise NBAReportError("缓存对象超过大小上限。", kind="invalid_cache_entry")


def cached_json_fetch(
    *,
    namespace: str,
    key: str,
    ttl_seconds: int,
    fetcher: Callable[[], Any],
    allow_stale: bool = True,
    max_payload_bytes: int = 2_000_000,
) -> tuple[Any, str]:
    now = time.time()
    cache_key = _cache_key(namespace, key)

    with MEMORY_LOCK:
        memory_entry = MEMORY_CACHE.get(cache_key)
    if memory_entry and memory_entry.get("expiresAt", 0) >= now:
        return memory_entry.get("payload"), "fresh"

    try:
        payload = fetcher()
    except Exception as exc:
        if allow_stale and memory_entry and memory_entry.get("payload") is not None:
            return memory_entry.get("payload"), "stale"
        if isinstance(exc, NBAReportError):
            raise
        raise NBAReportError(str(exc), kind="request_failed") from exc

    entry = _trim_oversized_entry(
        {
            "namespace": namespace,
            "key": key,
            "storedAt": now,
            "expiresAt": now + max(ttl_seconds, 0),
            "payload": payload,
        },
        max_payload_bytes=max_payload_bytes,
    )

    with MEMORY_LOCK:
        MEMORY_CACHE[cache_key] = entry
    return payload, "fresh"


def clear_memory_cache() -> None:
    with MEMORY_LOCK:
        MEMORY_CACHE.clear()
