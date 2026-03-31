---
name: openclaw-config-master
description: Edit and validate OpenClaw Gateway config (openclaw.json / JSON5). Use when adding/changing config keys (gateway.*, agents.defaults.*, agents.list.*, channels.*, models.*, auth.*, tools.*, skills.*, plugins.*, $include) or diagnosing openclaw doctor/config validation errors, to avoid schema mismatches that prevent the Gateway from starting or weaken security policies.
---

# OpenClaw Config

## 一句话

用 schema-first 工作流安全编辑 OpenClaw 配置文件，验证先行，避免无效 key 导致 Gateway 无法启动或安全策略被破坏。

---

## 核心要点（5条）

1. **Schema 先行** — 不猜 key，从 running Gateway 或源码获取权威 schema
2. **最小修改面** — 优先用 `openclaw config set/get/unset`，不用直接编辑文件
3. **验证不可跳** — 每次改完后必须跑 `openclaw doctor`
4. **严格模式** — 大多数对象是 `.strict()`，未知 key 会导致 Gateway 拒绝启动
5. **不轻易用 --fix** — `openclaw doctor --fix/--yes` 会写文件，需用户明确同意

---

## 详细内容

### 工作流程（Safe Edit）

**1. 定位配置文件**
- 优先级：`OPENCLAW_CONFIG_PATH` > `OPENCLAW_STATE_DIR/openclaw.json` > `~/.openclaw/openclaw.json`
- 配置文件是 **JSON5**（支持注释和尾逗号）

**2. 获取权威 schema**
- Gateway 运行中：`openclaw gateway call config.schema --params '{}'`
- Gateway 未运行：参考 OpenClaw 源码
  - `src/config/zod-schema.ts`（根 key：`gateway`/`skills`/`plugins`）
  - `src/config/zod-schema.*.ts`（子模块：channels/providers/models/agents/tools）
  - `docs/gateway/configuration.md`

**3. 应用变更**
- 最小修改：使用 `openclaw config get|set|unset`
- Gateway 在线时可一步完成"写入+验证+重启"：RPC `config.patch` 或 `config.apply`
- 复杂配置可用 `$include` 分割

**4. 严格验证**
- 运行 `openclaw doctor`，按报告的 `path` + `message` 修复
- **禁止自行运行 `--fix/--yes`**，除非用户明确同意

---

### Guardrails（避免 Schema 错误）

- **大多数对象是 strict** (`.strict()`)：未知 key 导致 Gateway 拒绝启动
- `channels` 是 `.passthrough()`：扩展 channels（matrix/zalo/nostr 等）可添加自定义 key
- `env` 是 `.catchall(z.string())`：可直接放字符串环境变量，也可用 `env.vars`
- **密钥处理**：优先用环境变量文件，避免将 token/API key 写入 `openclaw.json`

---

### $include（模块化配置）

`$include` 在 schema 验证前解析，支持将配置分割到多个 JSON5 文件：

- 支持 `"$include": "./base.json5"` 或数组
- 相对路径相对于当前配置文件目录
- 深度合并规则：
  - 对象：递归合并
  - 数组：**拼接**（不替换）
  - 原始值：后者覆盖前者
- 若 `$include` 与同级 key 共存，**同级 key 覆盖 include 的值**
- 限制：最大深度 10；循环 include 被检测并拒绝

---

### 常用配方（Common Recipes）

**设置默认 workspace**
```bash
openclaw config set agents.defaults.workspace '"~/.openclaw/workspace"' --json
openclaw doctor
```

**修改 Gateway 端口**
```bash
openclaw config set gateway.port 18789 --json
openclaw doctor
```

**分割配置文件**
```json5
// ~/.openclaw/openclaw.json
{
  "$include": ["./gateway.json5", "./channels/telegram.json5"],
}
```

**Telegram 开放 DMs（需显式允许发送者）**
```bash
openclaw config set channels.telegram.dmPolicy '"open"' --json
openclaw config set channels.telegram.allowFrom '["*"]' --json
openclaw doctor
```

**Discord Token**
```bash
# 方式 A：写入配置
openclaw config set channels.discord.token '"YOUR_DISCORD_BOT_TOKEN"' --json

# 方式 B：环境变量回退
# export DISCORD_BOT_TOKEN="..."

openclaw doctor
```

**启用 web_search**
```bash
openclaw config set tools.web.search.enabled true --json
openclaw config set tools.web.search.provider '"brave"' --json
# 建议通过环境变量提供 key
# export BRAVE_API_KEY="..."

openclaw doctor
```

---

### 复杂配置操作流程

复杂配置变更（添加新模型提供者、配置新频道等）遵循增强流程：

1. **前置检查** — 确认凭证/参数、验证平台可用性、备份配置、停止 Gateway
2. **详细配置** — 参考 `references/complex-operations.md`，遵循渐进式修改原则
3. **验证测试** — `openclaw doctor` 验证 + 逐步测试 + 准备回滚
4. **文档记录** — 记录变更、更新文档、保存版本信息

---

### 版本升级流程

1. **升级前准备** — 参阅 `references/version-migration.md`、创建备份、检查兼容性矩阵、查看破坏性变更
2. **执行迁移** — 使用迁移脚本、更新字段、处理废弃字段、验证完整性
3. **验证回滚** — 运行测试套件、监控行为、准备快速回滚

---

### 快速链接

**Channel 配置**
- Telegram 配置 → `references/channels-config.md#telegram`
- Feishu 配置 → `references/channels-config.md#feishu飞书`
- Discord 配置 → `references/channels-config.md#discord`
- Slack 配置 → `references/channels-config.md#slack`
- WhatsApp 配置 → `references/channels-config.md#whatsapp`
- Signal 配置 → `references/channels-config.md#signal`
- iMessage 配置 → `references/channels-config.md#imessage-macos`
- Channel 通用字段 → `references/channels-config.md#通用-channel-字段`

**复杂配置操作**
- 添加新模型提供者 → `references/complex-operations.md#1-添加新的模型提供者`
- 配置新频道 → `references/channels-config.md`
- 修改 Agent 工具 → `references/complex-operations.md#3-修改-agent-工具配置`
- 诊断和日志 → `references/complex-operations.md#4-调整诊断和日志设置`

**故障诊断**
- `openclaw doctor` — 快速诊断
- `scripts/openclaw-config-check.sh` — 配置验证
- `~/.openclaw/logs/openclaw.log` — 日志分析

**版本升级**
- `references/version-migration.md` — 完整迁移指南
- 快速检查清单：备份 → 兼容性 → 破坏性变更 → 回滚方案 → 测试验证

---

### 参考资源

**快速参考**
- `references/openclaw-config-fields.md` — 根 key 索引 + 字段来源（`agents.list`、安全字段、`models.providers`、`auth.profiles` 等完整覆盖）
- `references/channels-config.md` — 所有 Channel（Telegram/Feishu/Discord/Slack/WhatsApp/Signal/iMessage）完整配置字段
- `references/schema-sources.md` — schema 定位和约束说明

**深度指南**
- `references/complex-operations.md` — 复杂配置操作完整指南
- `references/version-migration.md` — 版本迁移和升级指南

**工具脚本**
- `scripts/openclaw-config-check.sh` — 打印配置路径 + 执行 doctor
