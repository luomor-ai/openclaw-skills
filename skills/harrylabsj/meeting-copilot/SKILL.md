---
name: Meeting Copilot
slug: meeting-copilot
version: 1.0.2
description: Meeting operations copilot for pre-meeting briefings, structured meeting notes, post-meeting action tracking, and follow-up drafts. Designed for professionals who need to manage the full meeting lifecycle with both boss mode and executor mode outputs. Does not provide real-time transcription, calendar integration, or automated reminders.
---

# Meeting Ops Copilot

Meeting lifecycle copilot covering pre-meeting briefing, in-meeting structured note organization, and post-meeting action tracking plus follow-up drafts. Supports both boss and executor output modes.

## Overview

This skill helps users manage the full meeting lifecycle in a structured way:

- **Before the meeting**: generate briefing material from the agenda and background so the host or presenter can get aligned quickly
- **During or after the meeting**: turn messy discussion text into structured notes with discussion points, decisions, and action items with owners
- **After the meeting**: extract action items and generate follow-up email or message drafts

**Disclaimer**: This tool does not provide real-time transcription, calendar integration, or notification sending. Output quality depends on the completeness and quality of the user-provided input.

## When to Use This Skill

- You need to prepare a meeting briefing quickly before a meeting
- You need structured notes during or after a meeting
- You need an action tracker extracted from meeting notes
- You need a follow-up email or message draft for a manager in boss mode or for collaborators in executor mode

## Workflow

### Mode 1: boss mode (upward reporting view)

Output priority: conclusion first, clear decisions, visible risks.

```
Input: meeting topic + agenda + background notes (or raw discussion text)
↓ identify key decisions, supporting reasoning, and potential risks
↓ output: boss-friendly briefing (conclusion + key points + risks + recommended actions)
```

### Mode 2: executor mode (downward execution view)

Output priority: explicit tasks, clear ownership, and clear timing.

```
Input: meeting notes / discussion points / decisions
↓ extract action items with owner, deadline, and priority
↓ output: structured action list + follow-up draft
```

## Input

| Field | Type | Required | Description |
|------|------|------|------|
| `task` | string | ✅ | Task type: `briefing` / `minutes` / `followup` |
| `meeting_topic` | string | ✅ | Meeting topic |
| `meeting_date` | string | ✅ | Meeting date in YYYY-MM-DD |
| `mode` | string | ✅ | `boss` or `executor` |
| `agenda` | string | Conditionally required | Agenda points separated by `\|` (required for `briefing`) |
| `raw_text` | string | Conditionally required | Raw discussion text (required for `minutes`) |
| `decisions` | string | Optional | Decisions already made, separated by `\|` |
| `participants` | string | Optional | Participant list, separated by `\|` |

## Output

### briefing (boss mode)

```json
{
  "status": "success",
  "task": "briefing",
  "mode": "boss",
  "meeting_topic": "...",
  "meeting_date": "...",
  "sections": {
    "conclusion": "one-line conclusion",
    "key_points": ["key point 1", "key point 2"],
    "decisions_needed": ["decision still needed"],
    "risks": ["risk 1", "risk 2"],
    "suggested_actions": ["recommended action 1"]
  },
  "briefing_text": "formatted briefing text"
}
```

### minutes (executor mode)

```json
{
  "status": "success",
  "task": "minutes",
  "mode": "executor",
  "meeting_topic": "...",
  "meeting_date": "...",
  "minutes": {
    "discussion_points": ["discussion point 1", "discussion point 2"],
    "decisions": ["decision 1"],
    "action_items": [
      {"task": "task description", "owner": "owner name", "deadline": "YYYY-MM-DD", "priority": "high|medium|low"}
    ]
  },
  "minutes_text": "formatted meeting notes text"
}
```

### followup

```json
{
  "status": "success",
  "task": "followup",
  "mode": "boss|executor",
  "meeting_topic": "...",
  "followup_items": [...],
  "draft_email": "email draft text",
  "draft_message": "short message draft"
}
```

## Safety & Disclaimer

- This skill does not integrate with calendars, send notifications, or perform real-time transcription
- Output completeness and accuracy depend on the quality of the user-provided input
- This tool is an assistant, not a replacement for professional note-taking, legal review, or compliance review
- For high-stakes decisions, users should apply their own judgment or consult the appropriate professionals

## Constraints

- No real-time voice transcription
- No calendar integration such as Google Calendar or enterprise calendars
- No automatic sending of notifications or emails; drafts only
- No meeting recording storage

## Examples

### Pre-meeting briefing (boss mode)

**Input**:
```
task: briefing
meeting_topic: Q2 Product Planning Review
meeting_date: 2026-04-05
mode: boss
agenda: Q2 goals alignment|technical direction choice|resource review
participants: product manager|engineering lead|design lead
```

**Output**: a boss-friendly briefing with a conclusion-first structure, key points, risks, and recommended actions.

### Meeting notes organization (executor mode)

**Input**:
```
task: minutes
meeting_topic: Weekly Team Sync
meeting_date: 2026-03-31
mode: executor
raw_text: We discussed the risk of feature A slipping; decided to use the backup plan; Alex will coordinate with the vendor; Jamie will own testing.
decisions: Use the backup plan
participants: Alex|Jamie|Taylor
```

**Output**: structured meeting notes plus extracted action items with owners.

### Post-meeting follow-up (executor mode)

**Input**:
```
task: followup
meeting_topic: Weekly Team Sync
mode: executor
decisions: Use the backup plan
（action_items from minutes output）
```

**Output**: an action tracker plus email and message drafts.

## Acceptance Criteria

- [ ] Supports `briefing`, `minutes`, and `followup`
- [ ] Supports both `boss` and `executor` modes
- [ ] Briefing output includes conclusion, key_points, risks, and suggested_actions
- [ ] Minutes output includes discussion_points, decisions, and action_items with owner, deadline, and priority
- [ ] Follow-up output includes a structured action list plus email and message drafts
- [ ] `handler.py` includes a `if __name__ == "__main__":` self-test path and runs directly with `python3 handler.py`
- [ ] `skill.json`, `.claw/identity.json`, and `tests/test_handler.py` are all present in the release bundle
- [ ] The disclaimer is preserved in both documentation and outputs
