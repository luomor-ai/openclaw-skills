#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from datetime import datetime
from pathlib import Path


def load_json(path: str) -> object:
    if path == "-":
        return json.load(sys.stdin)
    return json.loads(Path(path).read_text(encoding="utf-8"))


def dump_json(data: object) -> None:
    json.dump(data, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")


def parse_events(payload: object) -> list[dict]:
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    if isinstance(payload, dict):
        for key in ("events", "items"):
            value = payload.get(key)
            if isinstance(value, list):
                return [item for item in value if isinstance(item, dict)]
    raise SystemExit("input must be a JSON array or an object with `events`/`items`")


def parse_candidates(payload: object) -> list[dict]:
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    if isinstance(payload, dict):
        value = payload.get("candidates")
        if isinstance(value, list):
            return [item for item in value if isinstance(item, dict)]
    raise SystemExit("input must be a candidate array or an object with `candidates`")


def location_text(event: dict) -> str | None:
    location = event.get("location")
    if isinstance(location, str) and location.strip():
        return location.strip()
    if isinstance(location, dict):
        parts = []
        for key in ("name", "address"):
            value = location.get(key)
            if isinstance(value, str) and value.strip():
                parts.append(value.strip())
        if parts:
            return " / ".join(parts)
    return None


def room_id_from_attendee(attendee: dict) -> str | None:
    for key in ("room_id", "attendee_id", "id"):
        value = attendee.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return None


def room_name_from_attendee(attendee: dict, room_id: str) -> str:
    for key in ("name", "display_name", "resource_custom_name", "room_name", "title"):
        value = attendee.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return room_id


def iso_now() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def cmd_extract(args: argparse.Namespace) -> int:
    events = parse_events(load_json(args.input))
    rooms: dict[str, dict] = {}
    all_locations: Counter[str] = Counter()

    for event in events:
        event_start = event.get("start_time")
        if not isinstance(event_start, str):
            event_start = None
        hint = location_text(event)
        if hint:
            all_locations[hint] += 1

        attendees = event.get("attendees")
        if not isinstance(attendees, list):
            continue

        for attendee in attendees:
            if not isinstance(attendee, dict):
                continue
            if attendee.get("type") != "resource":
                continue

            rsvp_status = attendee.get("rsvp_status")
            if isinstance(rsvp_status, str) and rsvp_status not in {"accept", ""}:
                continue

            room_id = room_id_from_attendee(attendee)
            if not room_id:
                continue

            entry = rooms.setdefault(
                room_id,
                {
                    "room_id": room_id,
                    "score": 0,
                    "last_seen_at": None,
                    "_names": Counter(),
                    "_locations": Counter(),
                },
            )
            entry["score"] += 1
            entry["_names"][room_name_from_attendee(attendee, room_id)] += 1
            if hint:
                entry["_locations"][hint] += 1
            if event_start and (
                entry["last_seen_at"] is None or event_start > entry["last_seen_at"]
            ):
                entry["last_seen_at"] = event_start

    candidates = []
    for room in rooms.values():
        names = room.pop("_names")
        locations = room.pop("_locations")
        display_name = names.most_common(1)[0][0] if names else room["room_id"]
        candidates.append(
            {
                "room_id": room["room_id"],
                "display_name": display_name,
                "score": room["score"],
                "last_seen_at": room["last_seen_at"],
                "location_hints": [name for name, _ in locations.most_common(5)],
            }
        )

    candidates.sort(
        key=lambda item: (
            int(item.get("score") or 0),
            item.get("last_seen_at") or "",
            item.get("display_name") or "",
        ),
        reverse=True,
    )

    default_city_hint = None
    if all_locations:
        default_city_hint = all_locations.most_common(1)[0][0]
    elif candidates:
        hints = candidates[0].get("location_hints")
        if isinstance(hints, list):
            for hint in hints:
                if isinstance(hint, str) and hint.strip():
                    default_city_hint = hint.strip()
                    break

    result = {
        "generated_at": iso_now(),
        "event_count": len(events),
        "candidate_count": len(candidates),
        "default_city_hint": default_city_hint,
        "location_hints": [
            {"name": name, "count": count}
            for name, count in all_locations.most_common(10)
        ],
        "default_order_room_ids": [item["room_id"] for item in candidates],
        "default_priority_preview": [
            {
                "rank": index,
                "room_id": item["room_id"],
                "display_name": item.get("display_name") or item["room_id"],
                "score": item.get("score", 0),
            }
            for index, item in enumerate(candidates, start=1)
        ],
        "candidates": candidates,
    }
    dump_json(result)
    return 0


def cmd_save(args: argparse.Namespace) -> int:
    candidates = parse_candidates(load_json(args.input))
    by_room_id = {item.get("room_id"): item for item in candidates if item.get("room_id")}

    selected = []
    if args.room_id:
        missing = [room_id for room_id in args.room_id if room_id not in by_room_id]
        if missing:
            raise SystemExit(f"unknown room_id(s): {', '.join(missing)}")
        for room_id in args.room_id:
            selected.append(by_room_id[room_id])
    else:
        selected = list(candidates)

    if args.top is not None:
        selected = selected[: args.top]

    if not selected:
        raise SystemExit("no rooms selected")

    state = {
        "version": 1,
        "default_city": args.default_city,
        "updated_at": iso_now(),
        "rooms": [
            {
                "room_id": item["room_id"],
                "display_name": item.get("display_name") or item["room_id"],
                "rank": index,
                "score": item.get("score", 0),
                "last_seen_at": item.get("last_seen_at"),
                "location_hints": item.get("location_hints", []),
            }
            for index, item in enumerate(selected, start=1)
        ],
    }

    path = Path(args.state)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    dump_json(state)
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    state = load_json(args.state)
    if args.json:
        dump_json(state)
        return 0

    if not isinstance(state, dict):
        raise SystemExit("state file is not a JSON object")

    rooms = state.get("rooms")
    if not isinstance(rooms, list):
        raise SystemExit("state file does not contain a room list")

    print(f"default_city: {state.get('default_city', '')}")
    print(f"updated_at: {state.get('updated_at', '')}")
    for room in rooms:
        if not isinstance(room, dict):
            continue
        line = (
            f"{room.get('rank', '?')}. {room.get('display_name', room.get('room_id', ''))} "
            f"({room.get('room_id', '')}) score={room.get('score', 0)}"
        )
        if room.get("last_seen_at"):
            line += f" last_seen_at={room['last_seen_at']}"
        print(line)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Meeting room preference helper")
    subparsers = parser.add_subparsers(dest="command", required=True)

    extract = subparsers.add_parser("extract", help="extract room candidates from calendar events")
    extract.add_argument("--input", default="-", help="JSON file path or - for stdin")
    extract.set_defaults(func=cmd_extract)

    save = subparsers.add_parser("save", help="save confirmed room preferences")
    save.add_argument("--input", required=True, help="candidate JSON file path")
    save.add_argument("--state", required=True, help="state file path")
    save.add_argument("--default-city", required=True, help="default city label")
    save.add_argument(
        "--room-id",
        action="append",
        help="room id to keep, in final rank order; omit to save the extracted default order",
    )
    save.add_argument("--top", type=int, help="keep only the first N selected rooms")
    save.set_defaults(func=cmd_save)

    show = subparsers.add_parser("show", help="show saved room preferences")
    show.add_argument("--state", required=True, help="state file path")
    show.add_argument("--json", action="store_true", help="print raw JSON")
    show.set_defaults(func=cmd_show)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
