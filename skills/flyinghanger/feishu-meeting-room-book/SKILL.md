---
name: feishu-meeting-room-book
description: |
  飞书会议室偏好初始化与预定。适用于：初始化/刷新个人会议室列表、创建会议并预定会议室、
  给已有会议补订会议室。使用本地状态文件保存首选会议室列表；第一版只维护一个 default_city
  的会议室列表，跨城市时只创建会议不自动订房。
user-invocable: true
---

# Feishu Meeting Room Book

基于飞书日历事件学习个人常用会议室，并按本地偏好列表预定会议室。

## Paths

- State file: `state/feishu-meeting-room-book.json`
- Helper script: `skills/feishu-meeting-room-book/scripts/meeting_room_booker.py`

## Dependencies And Permissions

- Required OpenClaw plugin:
  - `openclaw-lark` or any equivalent Feishu/Lark plugin that exposes:
    - `feishu_calendar_event`
    - `feishu_calendar_event_attendee`
    - `feishu_calendar_freebusy`
- Required local runtime:
  - `python3`
  - the bundled helper script uses Python standard library only and does not require extra pip packages
- Local file access:
  - persistent state is written to `state/feishu-meeting-room-book.json`
  - temp working files may be written under `tmp/meeting-room-events.json` and `tmp/meeting-room-candidates.json`
- Required Feishu OAuth scopes:
  - `calendar:calendar.event:read` for reading recent calendar events during init/refresh
  - `calendar:calendar.event:create` for creating new calendar events
  - `calendar:calendar.event:update` for attaching meeting rooms and updating event attendees
  - `calendar:calendar.free_busy:read` for checking room availability
- Booking model:
  - this skill does not call a separate meeting-room booking service
  - room booking is performed by creating or updating Feishu calendar events and attaching the room as a `resource attendee`

## Required Tools

- `feishu_calendar_event`
- `feishu_calendar_event_attendee`
- `feishu_calendar_freebusy`

If any Feishu tool returns auth or scope errors, finish the OAuth flow first and retry. The normal scopes for this skill are:

- `calendar:calendar.event:read`
- `calendar:calendar.event:create`
- `calendar:calendar.event:update`
- `calendar:calendar.free_busy:read`

## Product Rules

- Manual refresh only. Never auto-refresh cached rooms.
- The cached room list is single-city v1. Store one `default_city` and one ordered room list.
- On first use, if `state/feishu-meeting-room-book.json` does not exist and the user asked to create/book a room or book an existing event, do not ask the user to initialize separately. Tell the user you are starting first-time initialization, run init immediately, and continue the original request after the default room order has been saved.
- During init/refresh, the extracted candidate order is the default priority order. Do not reshuffle it unless the user explicitly changes it.
- When creating a new event, use defaults instead of asking follow-up questions for common omissions:
  - missing title: use summary `会议`
  - missing attendees: create a self-only event with no extra attendees
  - missing duration/end time: default to 1 hour
- If the user does not specify a city, use `default_city`.
- If the user specifies a different city from `default_city`, create the event but do not auto-book a room. Explain that the current cache only covers `default_city`, and tell the user to seed that city manually and run refresh.
- When no preferred room is free:
  - `create_and_book`: still create the event without a room
  - `book_existing`: keep the event unchanged and tell the user to refresh after manually seeding more rooms

## Updating Candidate Rooms

Use these rules when the user asks how to update the candidate room list.

- To add a new candidate room:
  1. Ask the user to create any calendar event within the next 20 days.
  2. Tell the user to attach the desired meeting room to that event as a `resource attendee`.
  3. Then tell the user to say `刷新会议室列表` or `重新学习会议室`.
  4. The refresh flow will scan the event window again and include that room in the new candidate set if it appears in the event payload.
- To remove a room from the candidate list:
  - Run refresh and keep only the rooms the user still wants.
  - Or keep the current list and overwrite the state with a smaller subset and a new order.
- To change room priority:
  - Run refresh and let the user reply with the final room order.
  - Or keep the current rooms and overwrite the state with a reordered `--room-id` list.
- Window limitation:
  - Only events in the current scan window affect candidates.
  - The current scan window is `now - 20 days` to `now + 20 days - 1 minute`.
  - A seeding event outside that window will not update the candidate list.

## Init Or Refresh

Use this flow when the user says:

- "初始化会议室偏好"
- "刷新会议室列表"
- "重新学习会议室"
- or the state file does not exist

When init is triggered implicitly because the state file does not exist, explicitly tell the user:

- this is the first use of the skill
- you are learning their recent meeting room history now
- you will save a default room priority order first
- you will continue the current booking request automatically after init finishes

Steps:

1. Query one event window with `feishu_calendar_event` `action=list`.
   Use a window slightly less than 40 days to satisfy `instance_view`.
   Recommended window:
   - `start_time = now - 20 days`
   - `end_time = now + 20 days - 1 minute`
2. Save the raw tool result to a temp file if needed.
3. Run:

```bash
python3 skills/feishu-meeting-room-book/scripts/meeting_room_booker.py extract \
  --input tmp/meeting-room-events.json \
  > tmp/meeting-room-candidates.json
```

4. Choose a provisional `default_city`:
   - Prefer the existing state file's `default_city` if one already exists.
   - Otherwise use `default_city_hint` from the extract result.
   - If `default_city_hint` is empty, use the top `location_hints` item.
5. Save the provisional state immediately with the extracted default order. Do not pass `--room-id` when keeping the current default order:

```bash
python3 skills/feishu-meeting-room-book/scripts/meeting_room_booker.py save \
  --input tmp/meeting-room-candidates.json \
  --state state/feishu-meeting-room-book.json \
  --default-city "<city>"
```

6. Show the candidate rooms to the user with explicit priority numbers. Tell the user:
   - this is the current default priority order
   - it has already been saved as the fallback order
   - if the user does not reply, future bookings will use this default order
   - if this init was triggered by a booking request, the current request will proceed with this default order
   - if the user wants to adjust it, reply with:
     - `default_city` if they want to change it
     - which rooms to keep
     - the final room order
7. If the user replies with a custom order or subset, overwrite the state with:

```bash
python3 skills/feishu-meeting-room-book/scripts/meeting_room_booker.py save \
  --input tmp/meeting-room-candidates.json \
  --state state/feishu-meeting-room-book.json \
  --default-city "<city>" \
  --room-id omm_first \
  --room-id omm_second
```

Rules:

- Learn only from resource attendees already attached to real events.
- Prefer resource attendees with `rsvp_status=accept`.
- If `rsvp_status` is missing in the event payload, keep the room candidate.
- The helper script's candidate order is already the default priority order.
- If the user gives no reordering instructions, keep the saved default order unchanged.

## Create And Book

Use this flow when the user wants to create a new event and also book a meeting room.

Steps:

1. If `state/feishu-meeting-room-book.json` is missing, run init first.
   - Tell the user you detected first use and are initializing meeting room preferences before booking.
   - After init saves the default order, continue this create-and-book flow automatically.
2. Load the state:

```bash
python3 skills/feishu-meeting-room-book/scripts/meeting_room_booker.py show --state state/feishu-meeting-room-book.json --json
```

3. Parse:
   - title
   - start time
   - end time or duration
   - attendees
   - city
4. Apply defaults before asking any follow-up:
   - If title is missing, set it to `会议`.
   - If attendees are missing, use no extra attendees. The event is still created for the current user because `user_open_id` is always passed.
   - If both end time and duration are missing, set end time to `start_time + 1 hour`.
5. If city is missing, use `default_city`.
6. If city is not `default_city`, create the event without a room and explain the single-city v1 limitation.
7. Otherwise, iterate the cached rooms in rank order. For each room, call `feishu_calendar_freebusy` with `action=list` and `room_id=<room_id>`.
8. Pick the first room whose `freebusy_items` is empty.
9. Create the event with `feishu_calendar_event` `action=create`.
   - Always pass `user_open_id`
   - Put normal attendees in `attendees` only when the user explicitly provided them
   - Do not put the room into the initial create call
10. If a free room was found, attach it with `feishu_calendar_event_attendee` `action=create`.
11. Immediately call `feishu_calendar_event_attendee` `action=list` once to inspect the room attendee status.

Do not tell the user that topic, attendees, and duration are required. The user can simply give a start time; the defaults above fill the rest.

Interpretation:

- `accept`: room booked successfully
- `needs_action`: event created and room booking submitted; tell the user it is pending
- `decline` or attendee-create failure: keep the event and tell the user no room was booked

## Book Existing Event

Use this flow when the user wants to add a room to an existing event.

Steps:

1. If `state/feishu-meeting-room-book.json` is missing, run init first.
   - Tell the user you detected first use and are initializing meeting room preferences before booking.
   - After init saves the default order, continue this booking flow automatically.
2. Resolve the target event:
   - Prefer an explicit `event_id`
   - Otherwise search by title/time with `feishu_calendar_event` `action=search` or `action=list`
   - If multiple plausible matches remain, ask the user to choose before mutating
3. Read attendees first with `feishu_calendar_event_attendee` `action=list`.
4. If the event already has a resource attendee in `accept` or `needs_action`, stop and report the current room state.
5. If the requested city is different from `default_city`, do not try booking; explain the single-city v1 limitation.
6. Otherwise, iterate cached rooms with `feishu_calendar_freebusy` and attach the first free room with `feishu_calendar_event_attendee`.
7. Re-read attendees once and report the resulting room RSVP state.

## Local State Shape

The helper script writes:

```json
{
  "version": 1,
  "default_city": "Shanghai",
  "updated_at": "2026-03-17T20:00:00+08:00",
  "rooms": [
    {
      "room_id": "omm_xxx",
      "display_name": "A5-01",
      "rank": 1,
      "score": 18,
      "last_seen_at": "2026-03-16T10:00:00+08:00",
      "location_hints": ["Shanghai HQ"]
    }
  ]
}
```

This file is renewable runtime state. Keep it in `state/`.
