---
name: heartbeat-memory
description: 当 Heartbeat 触发时自动检查新 sessions 并生成记忆笔记。当用户想要自动保存聊天记录、提炼长期记忆、或管理 Daily 笔记时使用此 Skill。每次 Heartbeat 都会自动执行，无需手动调用。
---

# heartbeat-memory

Heartbeat 自动记忆保存 - 在 Heartbeat 触发时自动检查新 sessions，使用 OpenClaw 主 LLM 生成/更新 daily 笔记，并定期提炼 MEMORY.md。

## 🎯 核心功能

- **自动检查新 sessions** - 每次 Heartbeat 触发时自动扫描
- **智能分批处理** - 根据任务量自动选择处理策略
- **Daily 笔记生成** - 自动生成格式化的每日聊天记录
- **MEMORY.md 提炼** - 定期提炼长期记忆
- **状态追踪** - 记录处理进度，支持断点续处理
- **完成通知** - 处理后自动发送通知

## 📁 文件结构

```
heartbeat-memory/
├── SKILL.md                    # 本文件
├── package.json                # 包配置
├── index.js                    # 主入口
├── scripts/
│   └── post-install.js         # 安装后引导
├── assets/
│   ├── config.example.json     # 配置模板
│   └── daily-note-sample.md    # Daily 笔记示例
└── utils/
    ├── subagent-runner.js      # LLM 调用
    ├── session-processor.js    # Session 处理
    ├── daily-writer.js         # Daily 笔记生成
    ├── memory-refiner.js       # MEMORY.md 提炼
    └── message-sender.js       # 通知发送
```

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

## 🔧 配置说明

### 🚀 无需配置 LLM！

Skill 会自动使用 OpenClaw 主配置的 LLM，无需单独配置 API Key。

### 自动初始化

首次运行时会自动：
1. ✅ 创建配置文件
2. ✅ 初始化状态文件
3. ✅ 创建必要目录

### 可选配置项

如需自定义，编辑 `<工作区>/memory/heartbeat-memory-config.json`：

| 配置项 | 说明 | 默认值 | 可选值 |
|--------|------|--------|--------|
| enabled | 是否启用 | true | true/false |
| batchSize | 每批处理数 | 5 | 1-10 |
| largeTaskThreshold | subagent 阈值 | 10 | 5-20 |
| timeoutSeconds | LLM 超时时间（秒） | 1000 | 300-3600 |
| notifyTarget | 通知目标（user:xxx 或 chat:xxx） | 自动获取当前用户 | 任意 channel 支持的 target |
| processSessionsAfter | 只处理此日期后的 sessions | null (全部) | ISO 日期格式 |
| specifiedWorkspace | 手动指定工作区路径 | null (自动检测) | 绝对路径 |
| maxSessionsPerRun | 单次最多处理 sessions 数 | 50 | 10-200 |
| refineSchedule.type | 提炼频率 | weekly | weekly/interval |
| refineSchedule.dayOfWeek | 每周几 | sunday | monday-sunday |
| refineSchedule.time | 每日时间 | "20:00" | HH:mm 格式 |
| refineSchedule.days | 每几天 | 7 | 1-30 |

**timeoutSeconds 建议：**
- 少量 sessions (<10 个)：300-600 秒
- 中量 sessions (10-30 个)：600-1000 秒
- 大量 sessions (>30 个)：1000-1800 秒
- 首次运行（全量处理）：1800-3600 秒

**notifyTarget 自动获取逻辑：**
1. 优先用 `feishu_get_user` 获取当前用户
2. Fallback: 从 sessionKey 提取用户 ID
3. 最终 fallback: 不发送通知（静默执行）

**processSessionsAfter 示例：**
```json
{
  "memorySave": {
    "processSessionsAfter": "2026-03-01T00:00:00Z"
  }
}
```
首次运行时只处理 3 月 1 日之后的 sessions，避免处理大量历史数据。

**specifiedWorkspace 使用方式：**
在调用 `processSessions` 时作为第 8 个参数传入，或在配置文件中指定。

---

### 配置示例

**基础配置（默认）：**
```json
{
  "memorySave": {
    "enabled": true
  }
}
```

**首次运行限制（避免处理大量历史数据）：**
```json
{
  "memorySave": {
    "enabled": true,
    "processSessionsAfter": "2026-03-01T00:00:00Z",
    "maxSessionsPerRun": 20
  }
}
```

**指定通知渠道（WhatsApp）：**
```json
{
  "notifyTarget": "whatsapp:+15551234567",
  "memorySave": {
    "enabled": true
  }
}
```

**指定通知渠道（Discord）：**
```json
{
  "notifyTarget": "discord:123456789012345678",
  "memorySave": {
    "enabled": true
  }
}
```

**手动指定工作区（多 workspace 场景）：**
```json
{
  "specifiedWorkspace": "/Users/xxx/.openclaw/workspace-projectA",
  "memorySave": {
    "enabled": true
  }
}
```

**完整配置示例：**
```json
{
  "notifyTarget": "feishu:ou_xxxxxxxxxxxxx",
  "specifiedWorkspace": null,
  "memorySave": {
    "enabled": true,
    "batchSize": 5,
    "maxSessionsPerRun": 50,
    "processSessionsAfter": "2026-03-01T00:00:00Z",
    "timeoutSeconds": 600,
    "refineSchedule": {
      "type": "weekly",
      "dayOfWeek": "sunday",
      "time": "20:00"
    }
  }
}
```

### 配置示例

**每周日 20:00 提炼（默认）：**
```json
{
  "memorySave": {
    "enabled": true,
    "batchSize": 5,
    "largeTaskThreshold": 10,
    "timeoutSeconds": 600,
    "refineSchedule": {
      "type": "weekly",
      "dayOfWeek": "sunday",
      "time": "20:00"
    }
  }
}
```

**每 3 天提炼：**
```json
{
  "memorySave": {
    "enabled": true,
    "refineSchedule": {
      "type": "interval",
      "days": 3
    }
  }
}
```

**指定通知用户：**
```json
{
  "userId": "ou_xxxxxxxxxxxx",
  "memorySave": {
    "enabled": true,
    "refineSchedule": {
      "type": "weekly",
      "dayOfWeek": "sunday"
    }
  }
}
```

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

**方式 3：手动调用（传工具函数）**
```javascript
// 如果需要精确控制工具
await heartbeat.processSessions(
  sessions_list,
  sessions_history,
  sessions_spawn,
  message,
  feishu_get_user,
  configOverride,
  specifiedWorkspace
);
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
# 查看当前工作区
echo $OPENCLAW_WORKSPACE

# 查看 Daily 笔记
cat $OPENCLAW_WORKSPACE/memory/daily/YYYY-MM-DD.md

# 查看长期记忆
cat $OPENCLAW_WORKSPACE/MEMORY.md
```

**默认工作区（如未设置环境变量）：**
```bash
cat ~/.openclaw/workspace/memory/daily/YYYY-MM-DD.md
cat ~/.openclaw/workspace/MEMORY.md
```

### 修改配置

```bash
# 当前工作区
vim $OPENCLAW_WORKSPACE/memory/heartbeat-memory-config.json

# 或默认工作区
vim ~/.openclaw/workspace/memory/heartbeat-memory-config.json
```

## 📊 处理策略

### 首次启用

首次运行时：
- 自动扫描所有 sessions
- 分批处理（每批 5 个）
- 生成对应日期的 Daily 笔记
- 首次强制触发一次 MEMORY.md 提炼

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
检查 shouldRefine（根据 lastRefine 判断）
    ↓
定期提炼 MEMORY.md
    ↓
发送完成通知
```

## 🌍 多工作区与跨平台支持

### 跨平台兼容

- ✅ **macOS** - 完全支持
- ✅ **Linux** - 完全支持
- ✅ **Windows** - 完全支持（PowerShell/CMD）

Skill 自动适配各平台路径规范：

| 平台 | 全局技能目录 | 环境变量 |
|------|------------|---------|
| **macOS/Linux** | `~/.openclaw/skills/` | `$OPENCLAW_WORKSPACE` |
| **Windows** | `%USERPROFILE%\.openclaw\skills\` | `%OPENCLAW_WORKSPACE%` |

### 多工作区支持

Skill 自动支持多工作区，无需额外配置：

| 工作区类型 | 配置位置 | 数据位置 |
|-----------|---------|---------|
| **默认工作区** | `~/.openclaw/workspace/` | `~/.openclaw/workspace/memory/` |
| **自定义工作区** | `$OPENCLAW_WORKSPACE/` | `$OPENCLAW_WORKSPACE/memory/` |
| **项目工作区** | `./.openclaw/` | `./.openclaw/memory/` |

### 切换工作区

**方法 1：环境变量**
```bash
# macOS/Linux
export OPENCLAW_WORKSPACE=/path/to/your/workspace
openclaw gateway restart

# Windows PowerShell
$env:OPENCLAW_WORKSPACE="C:\path\to\workspace"
openclaw gateway restart

# Windows CMD
set OPENCLAW_WORKSPACE=C:\path\to\workspace
openclaw gateway restart
```

**方法 2：当前目录**
```bash
cd /path/to/your/workspace
# Skill 会自动检测当前目录
```

## ❓ 常见问题

### Q: 需要配置 LLM API Key 吗？
A: **不需要！** Skill 会自动使用 OpenClaw 主配置的 LLM，通过 subagent 方式调用。

### Q: 多久检查一次？
A: 跟随 Heartbeat 频率：
- 工作日：09:00 / 14:00 / 20:00
- 周末：10:00 / 20:00

### Q: 如何查看处理进度？
A: 处理完成后会自动发送通知，包含：
- 检查 sessions 数
- 新处理数
- 是否提炼 MEMORY

### Q: 可以修改提炼频率吗？
A: 可以，编辑配置文件：
```json
{
  "refineSchedule": {
    "type": "weekly",
    "dayOfWeek": "sunday",
    "time": "20:00"
  }
}
```

### Q: 如何处理大量 sessions？
A: 自动分批处理，每次 Heartbeat 最多处理 5 个，剩余下次继续。

### Q: 可以禁用自动保存吗？
A: 可以，配置文件中设置 `"enabled": false`。

### Q: 首次运行会提炼 MEMORY.md 吗？
A: **会！** 首次运行会强制触发一次 MEMORY.md 提炼，之后按计划频率执行。

## 📝 示例

### Daily 笔记示例

```markdown
# YYYY-MM-DD 聊天记录（示例）

## 📊 当日总结
- 总会话数：X 个
- 活跃：X | 删除：X | 重置：X
- 主要话题：[话题 1], [话题 2]

## 💬 会话详情

### 📋 通用技能迁移到全局目录
**标签：** ✅ | #Skill #技能管理 #OpenClaw
**时间：** 10:05-10:16
**摘要：** 讨论将通用技能从工作区迁移到全局技能库...

**关键决策：**
- 通用技能迁移到 ~/.openclaw/skills/
- 个人专用技能保留在工作区
```

### MEMORY.md 示例

```markdown
# MEMORY.md - 长期记忆

## 👤 用户偏好
- **语言：** 简体中文
- **时区：** 东八区
- **交流风格：** 直接高效

## 🎯 重要决策
- [日期]：[决策内容]

## 📈 项目进展
- 记忆系统：已完成
- 技能管理：已完成

## ✅ 待办事项
- [ ] 验证 Heartbeat 自动执行
```

## ⚠️ 错误处理

### LLM 调用失败
- 自动重试 2 次
- 失败后使用降级摘要
- 记录错误日志

### 超时处理
- 单次处理超时 600 秒
- 保存已处理内容
- 下次 Heartbeat 继续

### 通知失败
- 不影响主流程
- 记录错误日志
- 继续处理

## 📦 命令列表

### macOS/Linux

**当前工作区：**
```bash
# 查看当前工作区
echo $OPENCLAW_WORKSPACE

# 查看配置
cat $OPENCLAW_WORKSPACE/memory/heartbeat-memory-config.json

# 查看状态
cat $OPENCLAW_WORKSPACE/memory/heartbeat-state.json

# 查看 Daily 笔记
ls $OPENCLAW_WORKSPACE/memory/daily/

# 重启 Gateway
openclaw gateway restart
```

**默认工作区：**
```bash
cat ~/.openclaw/workspace/memory/heartbeat-memory-config.json
cat ~/.openclaw/workspace/memory/heartbeat-state.json
ls ~/.openclaw/workspace/memory/daily/
```

### Windows PowerShell

**当前工作区：**
```powershell
# 查看当前工作区
echo $env:OPENCLAW_WORKSPACE

# 查看配置
Get-Content $env:OPENCLAW_WORKSPACE\memory\heartbeat-memory-config.json

# 查看状态
Get-Content $env:OPENCLAW_WORKSPACE\memory\heartbeat-state.json

# 查看 Daily 笔记
Get-ChildItem $env:OPENCLAW_WORKSPACE\memory\daily\

# 重启 Gateway
openclaw gateway restart
```

**默认工作区：**
```powershell
Get-Content $HOME\.openclaw\workspace\memory\heartbeat-memory-config.json
Get-Content $HOME\.openclaw\workspace\memory\heartbeat-state.json
Get-ChildItem $HOME\.openclaw\workspace\memory\daily\
```

### Windows CMD

```cmd
# 查看当前工作区
echo %OPENCLAW_WORKSPACE%

# 查看配置
type %OPENCLAW_WORKSPACE%\memory\heartbeat-memory-config.json

# 重启 Gateway
openclaw gateway restart
```

**状态文件字段说明：**
```json
{
  "processedSessions": ["session-id-1", "session-id-2"],  // 已处理的 session
  "lastCheck": "2026-03-20T12:00:00.000Z",              // 上次检查时间
  "lastRefine": "2026-03-20T12:00:00.000Z",            // 上次 MEMORY.md 提炼时间
  "memorySave": { "enabled": true }                      // 配置
}
```

## 🔮 未来计划

- [ ] 支持自定义通知渠道
- [ ] 支持记忆搜索
- [ ] 支持记忆关联
- [ ] 支持记忆导出
