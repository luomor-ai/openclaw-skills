# Heartbeat-Memory

🧠 Heartbeat 自动记忆保存 - 在 Heartbeat 触发时自动检查新 sessions，生成 Daily 笔记，并定期提炼 MEMORY.md。

<!-- Badge Row 1: Core Info -->
[![ClawHub](https://img.shields.io/badge/ClawHub-heartbeat--memory-E75C46?logo=clawhub)](https://clawhub.ai/JustZeroX/heartbeat-memory)
[![GitHub](https://img.shields.io/badge/GitHub-JustZeroX-181717?logo=github)](https://github.com/JustZeroX/skill-heartbeat-memory)
[![Version](https://img.shields.io/badge/version-0.0.1-orange)](https://github.com/JustZeroX/skill-heartbeat-memory)

<!-- Badge Row 2: Platforms -->
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)]() 
[![Windows](https://img.shields.io/badge/Windows-0078D6?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4OCA4OCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTAgMGgzOXYzOUgweiIvPjxwYXRoIGZpbGw9IiNmZmYiIGQ9Ik00OSAwaDM5djM5SDQ5eiIvPjxwYXRoIGZpbGw9IiNmZmYiIGQ9Ik0wIDQ5aDM5djM5SDB6Ii8+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTQ5IDQ5aDM5djM5SDQ5eiIvPjwvc3ZnPg==)]() 
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)]()

<!-- Badge Row 3: License -->
[![License](https://img.shields.io/badge/License-MIT-BD2D2D)](LICENSE)

---

### 中文 | [English](#english-version)

---

## 目录

- [✨ 核心功能](#-核心功能)
- [🔧 安装](#-安装)
- [📖 使用指南](#-使用指南)
- [⚙️ 配置说明](#️-配置说明)
- [📊 处理策略](#-处理策略)
- [🌍 跨平台支持](#-跨平台支持)
- [❓ 常见问题](#-常见问题)
- [📄 许可证](#-许可证)

---

## ✨ 核心功能

- **🤖 自动检查新 sessions** - 每次 Heartbeat 触发时自动扫描
- **📝 Daily 笔记生成** - 自动生成格式化的每日聊天记录
- **🧠 MEMORY.md 提炼** - 定期提炼长期记忆
- **📊 智能分批处理** - 根据任务量自动选择处理策略
- **📈 状态追踪** - 记录处理进度，支持断点续处理
- **🔔 完成通知** - 处理后自动发送通知
- **🚀 无需配置 LLM** - 自动使用 OpenClaw 主配置的 LLM
- **💾 自动初始化** - 首次运行自动创建配置文件和目录

---

## 🔧 安装

### 方式 1：安装到全局目录（推荐 ⭐）

适合所有工作区共享此 skill，一次安装全局可用：

```bash
clawhub install heartbeat-memory --dir ~/.openclaw/skills
openclaw gateway restart
```

**适用场景：**
- ✅ 多个工作区都需要自动记忆功能
- ✅ 希望统一配置和管理
- ✅ 避免重复安装

### 方式 2：安装到当前工作区

仅在当前工作区使用：

```bash
# macOS/Linux
cd ~/.openclaw/workspace-creator
clawhub install heartbeat-memory

# Windows PowerShell
cd $HOME\.openclaw\workspace-creator
clawhub install heartbeat-memory

# 重启 Gateway
openclaw gateway restart
```

**适用场景：**
- ✅ 仅单个项目需要记忆功能
- ✅ 不同项目需要独立配置

### 验证安装

```bash
# macOS/Linux - 检查全局安装
ls ~/.openclaw/skills/heartbeat-memory/SKILL.md

# Windows PowerShell - 检查全局安装
Test-Path $HOME\.openclaw\skills\heartbeat-memory\SKILL.md

# 检查工作区安装
ls $OPENCLAW_WORKSPACE/skills/heartbeat-memory/SKILL.md
```

---

## 📖 使用指南

### 执行方式

**方式 1：Heartbeat 自动触发（推荐）**
```
Heartbeat 每 30 分钟触发 → 自动执行 heartbeat-memory
```

**方式 2：手动调用（subagent 环境）**
```javascript
// 在 subagent 中直接调用
const heartbeat = require('~/.openclaw/skills/heartbeat-memory/index.js');
await heartbeat.run();  // 自动使用全局工具
```

### 首次运行

1. 重启 Gateway
2. 下次 Heartbeat 自动触发
3. 自动创建配置文件和目录
4. 开始处理 sessions

**建议首次配置（避免处理大量历史数据）：**
```json
{
  "memorySave": {
    "processSessionsAfter": "2026-03-01T00:00:00Z",
    "maxSessionsPerRun": 20
  }
}
```

### 查看结果

**当前工作区：**
```bash
# 查看 Daily 笔记
cat $OPENCLAW_WORKSPACE/memory/daily/YYYY-MM-DD.md

# 查看长期记忆
cat $OPENCLAW_WORKSPACE/MEMORY.md
```

**默认工作区：**
```bash
cat ~/.openclaw/workspace/memory/daily/YYYY-MM-DD.md
cat ~/.openclaw/workspace/MEMORY.md
```

---

## ⚙️ 配置说明

### 🚀 无需配置 LLM！

Skill 会自动使用 OpenClaw 主配置的 LLM，无需单独配置 API Key。

### 可选配置项

编辑 `<工作区>/memory/heartbeat-memory-config.json`：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `enabled` | 是否启用 | `true` |
| `batchSize` | 每批处理数 | `5` |
| `timeoutSeconds` | LLM 超时时间（秒） | `1000` |
| `notifyTarget` | 通知目标 | 自动获取 |
| `processSessionsAfter` | 只处理此日期后的 sessions | `null` |
| `refineSchedule.type` | 提炼频率 | `weekly` |

**timeoutSeconds 建议：**
- 少量 sessions (<10 个)：300-600 秒
- 中量 sessions (10-30 个)：600-1000 秒
- 大量 sessions (>30 个)：1000-1800 秒

---

## 📊 处理策略

### 日常增量

根据新 sessions 数量自动选择策略：

| 数量 | 策略 | 耗时 |
|------|------|------|
| < 5 个 | 直接处理 | <2 分钟 |
| 5-10 个 | 分批处理 | 2-5 分钟 |
| > 10 个 | 启动 subagent | 5-10 分钟 |

### 处理流程

```
Heartbeat 触发
    ↓
sessions_list 获取会话列表
    ↓
sessions_history 获取消息内容
    ↓
sessions_spawn 启动 subagent 进行 LLM 提炼
    ↓
写入 Daily 笔记
    ↓
检查是否提炼 MEMORY.md
    ↓
发送完成通知
```

---

## 🌍 跨平台支持

### 平台兼容

- ✅ **macOS** - 完全支持
- ✅ **Linux** - 完全支持
- ✅ **Windows** - 完全支持（PowerShell/CMD）

### 路径规范

| 平台 | 全局技能目录 | 环境变量 |
|------|------------|---------|
| **macOS/Linux** | `~/.openclaw/skills/` | `$OPENCLAW_WORKSPACE` |
| **Windows** | `%USERPROFILE%\.openclaw\skills\` | `%OPENCLAW_WORKSPACE%` |

---

## ❓ 常见问题

### Q: 需要配置 LLM API Key 吗？
A: **不需要！** Skill 会自动使用 OpenClaw 主配置的 LLM。

### Q: 多久检查一次？
A: 跟随 Heartbeat 频率（工作日：09:00/14:00/20:00，周末：10:00/20:00）。

### Q: 如何查看处理进度？
A: 处理完成后会自动发送通知。

### Q: 可以修改提炼频率吗？
A: 可以，编辑配置文件中的 `refineSchedule`。

### Q: 首次运行会处理所有历史 sessions 吗？
A: 建议配置 `processSessionsAfter` 限制日期范围，避免处理大量历史数据。

---

## 📄 许可证

MIT License

---

[Top / 返回顶部](#heartbeat-memory)

---

## English Version

### Table of Contents

- [✨ Core Features](#-core-features)
- [🔧 Installation](#-installation)
- [📖 Usage Guide](#-usage-guide)
- [⚙️ Configuration](#️-configuration)
- [📊 Processing Strategy](#-processing-strategy)
- [🌍 Cross-Platform Support](#-cross-platform-support)
- [❓ FAQ](#-faq)
- [📄 License](#-license)

---

### ✨ Core Features

- **🤖 Auto Check Sessions** - Scan new sessions on every Heartbeat trigger
- **📝 Daily Note Generation** - Auto-generate formatted daily chat logs
- **🧠 MEMORY.md Refinement** - Periodically refine long-term memory
- **📊 Smart Batching** - Auto-select processing strategy based on task volume
- **📈 Progress Tracking** - Record processing state, support resume
- **🔔 Completion Notification** - Auto-send notification after processing
- **🚀 No LLM Config** - Auto-use OpenClaw's main LLM
- **💾 Auto Initialization** - Create config files and directories on first run

---

### 🔧 Installation

#### Option 1: Global Installation (Recommended ⭐)

Suitable for sharing across all workspaces:

```bash
clawhub install heartbeat-memory --dir ~/.openclaw/skills
openclaw gateway restart
```

#### Option 2: Workspace Installation

Only for current workspace:

```bash
cd ~/.openclaw/workspace-creator
clawhub install heartbeat-memory
openclaw gateway restart
```

---

### 📖 Usage Guide

#### Execution Methods

**Method 1: Heartbeat Auto-Trigger (Recommended)**
```
Heartbeat every 30 min → Auto-execute heartbeat-memory
```

**Method 2: Manual Call (subagent)**
```javascript
const heartbeat = require('~/.openclaw/skills/heartbeat-memory/index.js');
await heartbeat.run();
```

#### First Run

1. Restart Gateway
2. Next Heartbeat auto-triggers
3. Auto-create config files
4. Start processing sessions

**Recommended first config (avoid processing大量 history):**
```json
{
  "memorySave": {
    "processSessionsAfter": "2026-03-01T00:00:00Z",
    "maxSessionsPerRun": 20
  }
}
```

---

### ⚙️ Configuration

### 🚀 No LLM Config Needed!

Skill auto-uses OpenClaw's main LLM configuration.

#### Optional Config

Edit `<workspace>/memory/heartbeat-memory-config.json`:

| Config | Description | Default |
|--------|-------------|---------|
| `enabled` | Enable/disable | `true` |
| `batchSize` | Batch size | `5` |
| `timeoutSeconds` | LLM timeout (seconds) | `1000` |
| `refineSchedule.type` | Refinement frequency | `weekly` |

**timeoutSeconds Recommendations:**
- Few sessions (<10): 300-600 seconds
- Medium sessions (10-30): 600-1000 seconds
- Many sessions (>30): 1000-1800 seconds

---

### 📊 Processing Strategy

#### Daily Incremental

Auto-select strategy by session count:

| Count | Strategy | Time |
|-------|----------|------|
| < 5 | Direct process | <2 min |
| 5-10 | Batch process | 2-5 min |
| > 10 | Subagent | 5-10 min |

#### Workflow

```
Heartbeat Trigger
    ↓
sessions_list get session list
    ↓
sessions_history get message content
    ↓
sessions_spawn subagent for LLM refinement
    ↓
Write Daily notes
    ↓
Check if refine MEMORY.md
    ↓
Send completion notification
```

---

### 🌍 Cross-Platform Support

#### Platform Compatibility

- ✅ **macOS** - Full support
- ✅ **Linux** - Full support
- ✅ **Windows** - Full support (PowerShell/CMD)

#### Path Specifications

| Platform | Global Skills Dir | Environment Variable |
|----------|------------------|---------------------|
| **macOS/Linux** | `~/.openclaw/skills/` | `$OPENCLAW_WORKSPACE` |
| **Windows** | `%USERPROFILE%\.openclaw\skills\` | `%OPENCLAW_WORKSPACE%` |

---

### ❓ FAQ

### Q: Need LLM API Key?
A: **No!** Skill auto-uses OpenClaw's main LLM.

### Q: How often to check?
A: Follows Heartbeat frequency.

### Q: How to check progress?
A: Auto-send notification after completion.

### Q: Can I change refinement frequency?
A: Yes, edit `refineSchedule` in config.

### Q: Will first run process all history?
A: Recommend configuring `processSessionsAfter` to limit date range.

---

### 📄 License

MIT License

---

[Top](#heartbeat-memory)
