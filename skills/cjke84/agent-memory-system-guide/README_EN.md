# agent-memory-system-guide

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

GitHub repository: [cjke84/agent-memory-system-guide](https://github.com/cjke84/agent-memory-system-guide)

Canonical OpenClaw skill id: `memory-system`

An Agent long-term memory guide for OpenClaw, Codex, and Obsidian workflows.

It helps you build a durable memory stack with a compact `MEMORY.md`, daily notes, session recovery files, and Obsidian archiving. OpenViking is included as an optional enhancement for semantic recall and summary support, not as a hard dependency.

GitHub release archive: [v0.1.0](https://github.com/cjke84/agent-memory-system-guide/releases/tag/v0.1.0)

Current published skill version: `1.1.1`

## What it is

This skill explains how to build a durable memory stack for agents: a compact `MEMORY.md`, daily notes, memory distillation, and Obsidian backups.
OpenViking is an optional enhancement for semantic recall and summary support.

## Optional enhancement

OpenViking can be added later if you want semantic recall and summary support, but it is not required for the core workflow.

## Who it is for

- Agents that need persistent memory
- Agents that should keep daily notes and distill stable facts
- Users who want Obsidian as the long-term archive

## How to use

1. Install the skill.
2. Copy `templates/SESSION-STATE.md` and `templates/working-buffer.md`, then use them with `MEMORY.md` and daily notes.
3. Distill stable facts into long-term memory and keep raw notes in daily files.
4. Archive stable knowledge into Obsidian.

## File boundaries

- `SESSION-STATE.md` uses the compact repository template: `当前任务`, `已完成`, `卡点`, `下一步`, and `恢复信息`
- Do not expand it into a second detailed schema such as `Task`, `Status`, `Owner`, `Last Updated`, or `Cleanup Rule`
- If another workflow already emits those fields, merge them back into the compact sections instead of creating new headings
- `working-buffer.md` is the only short-term scratchpad; if another skill has a working buffer or WAL concept, it should reuse this file
- `MEMORY.md` is for startup-time quick reference
- `memory/` is for daily notes and deeper archive material
- Overlap between `MEMORY.md` and `memory/` is acceptable, but their retrieval roles are different
- Lookup order: `SESSION-STATE.md` first, then recent daily notes, then `MEMORY.md` or `memory_search`, and only then Obsidian or deeper archives

## Memory Capture Upgrade

- Use `templates/memory-capture.md` as a low-friction end-of-task capture sheet.
- During the task, write rough notes into `working-buffer.md` under `临时决策`, `新坑`, and `待蒸馏`.
- After the task, spend 30 seconds generating candidate memory before deciding what belongs in `MEMORY.md`.
- To bootstrap those files in a real workspace, run `python3 scripts/memory_capture.py --workspace /path/to/workspace` or `python3 scripts/memory_capture.py bootstrap --workspace /path/to/workspace`.

## Cross-device Backup and Restore

- Export a portable backup zip on the old device with `python3 scripts/memory_capture.py export --workspace /path/to/workspace --output /path/to/memory-backup.zip`.
- Move the archive to a new device and restore with `python3 scripts/memory_capture.py import --workspace /path/to/new-workspace --input /path/to/memory-backup.zip`.
- Import always creates a pre-import backup of the destination memory files before overwrite.
- The archive includes `MEMORY.md`, `SESSION-STATE.md`, `working-buffer.md`, `memory-capture.md`, `memory/`, and `attachments/` when they exist.

## Obsidian-native notes

- Use `templates/OBSIDIAN-NOTE.md` for durable notes: YAML frontmatter, wikilinks, embeds, and attachment conventions.
- With Dataview, you can query your notes by `type`, `status`, `tags`, and `related`.

## Included files

- `SKILL.md`: skill contract and workflow
- `manifest.toml`: publish metadata for OpenClaw / ClawHub style release workflows
- `INSTALL.md`: a copy-paste installation prompt for agents
- `templates/SESSION-STATE.md` and `templates/working-buffer.md`: recovery templates
- `templates/memory-capture.md`: end-of-task candidate-memory template
- `scripts/memory_capture.py`: bootstrap, export backup, and import restore helper

Publish note: `manifest.toml` is the source of truth for skill versioning and the Xiaping skill id used for updates.
