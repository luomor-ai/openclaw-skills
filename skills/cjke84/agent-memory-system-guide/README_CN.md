# agent-memory-system-guide

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

GitHub 仓库：[cjke84/agent-memory-system-guide](https://github.com/cjke84/agent-memory-system-guide)

Canonical OpenClaw skill id：`memory-system`

面向 OpenClaw 和 Obsidian 工作流的 Agent 长期记忆搭建指南。

GitHub 发布归档：[v0.1.0](https://github.com/cjke84/agent-memory-system-guide/releases/tag/v0.1.0)

当前已发布 skill 版本：`1.1.1`

## 是什么

这个 skill 说明如何给 Agent 搭建长期记忆：用精简的 `MEMORY.md`、每日笔记、记忆蒸馏和 Obsidian 备份组成一套稳定的记忆层。
OpenViking 是可选增强层，用来补充语义召回和摘要。

## 可选增强

如果你后面想补语义召回和摘要，可以再加 OpenViking，但它不是核心流程的必需项。

## 适合谁

- 需要长期记忆的 Agent
- 需要保留每日笔记并蒸馏稳定事实的 Agent
- 想把 Obsidian 作为长期归档的用户

## 怎么用

1. 安装这个 skill。
2. 先复制 `templates/SESSION-STATE.md` 和 `templates/working-buffer.md`，再配合 `MEMORY.md` 和每日笔记使用。
3. 把稳定事实蒸馏进长期记忆，原始记录留在每日笔记里。
4. 将稳定知识归档到 Obsidian。

## 文件边界

- `SESSION-STATE.md` 使用仓库模板的简洁结构：`当前任务`、`已完成`、`卡点`、`下一步`、`恢复信息`
- 不要把它扩展成另一套详细版 schema，例如 `Task`、`Status`、`Owner`、`Last Updated`、`Cleanup Rule`
- 如果外部 workflow 已经产出这些字段，应该合并回简洁版栏目，而不是新增标题
- `working-buffer.md` 是唯一的短期毛坯区；如果别的 skill 也有 working buffer / WAL 概念，应复用这个文件
- `MEMORY.md` 用于启动时快速参考
- `memory/` 用于每日笔记和深度归档
- 两层允许有内容重叠，但职责不同，不视为冲突
- 检索顺序：先 `SESSION-STATE.md`，再 recent daily notes，再 `MEMORY.md` 或 `memory_search`，最后才进入 Obsidian / 深度归档

## 记忆捕获升级

- 用 `templates/memory-capture.md` 作为任务结束时的轻量记录模板。
- 任务进行中，把毛坯先写进 `working-buffer.md` 的 `临时决策`、`新坑`、`待蒸馏`。
- 任务结束后先花 30 秒产出候选记忆，再决定哪些内容真正进入 `MEMORY.md`。
- 真正落到工作区时，可以运行 `python3 scripts/memory_capture.py --workspace /path/to/workspace` 或 `python3 scripts/memory_capture.py bootstrap --workspace /path/to/workspace` 一键补齐基础文件。

## 跨设备迁移：导出备份与导入恢复

- 在旧设备导出备份：`python3 scripts/memory_capture.py export --workspace /path/to/workspace --output /path/to/memory-backup.zip`
- 把备份包带到新设备后导入恢复：`python3 scripts/memory_capture.py import --workspace /path/to/new-workspace --input /path/to/memory-backup.zip`
- 导入前备份：导入会先把目标工作区当前的记忆文件打成一个 zip，再执行覆盖恢复。
- 备份包会包含存在的 `MEMORY.md`、`SESSION-STATE.md`、`working-buffer.md`、`memory-capture.md`、`memory/` 和 `attachments/`。

## Obsidian 原生笔记

- 稳定知识建议用 `templates/OBSIDIAN-NOTE.md`：包含 YAML frontmatter、wikilink、embeds、attachments 约定。
- 如果使用 Dataview，可以按 `type`、`status`、`tags`、`related` 做查询。

## 包含文件

- `SKILL.md`：技能契约与工作流
- `manifest.toml`：面向 OpenClaw / ClawHub 风格发布流程的元数据
- `INSTALL.md`：可直接发给 Agent 的安装指令
- `templates/SESSION-STATE.md` 和 `templates/working-buffer.md`：恢复模板
- `templates/memory-capture.md`：任务结束时的候选记忆模板
- `scripts/memory_capture.py`：初始化、导出备份、导入恢复的辅助脚本

发布说明：后续版本号与虾评更新目标 `skill_id` 以 `manifest.toml` 为准。
