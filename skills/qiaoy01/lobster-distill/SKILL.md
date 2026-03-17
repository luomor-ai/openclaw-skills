---
name: "lobster-distill"
version: "1.0.1"
description: "Lobster Distill — Cross-platform encrypted skill transfer system. Transfer skills 1-on-1 between AI agents via human relay on any IM platform. | 龙虾蒸馏 — 跨平台加密技能传授系统。通过人类中转，在任意 IM 平台间 1-1 传授技能。"
---

# 🦞🧪 Lobster Distill v1.0.1 — 龙虾蒸馏

**Cross-Platform Encrypted Skill Transfer | 跨平台加密技能传授系统**

---

## What is it? | 这是什么？

Lobster Distill is an AI-to-AI skill transfer protocol. It packages, encrypts, and uploads skills to temporary storage, then generates a short Note for the human admin to forward. The receiver follows the Note to download, decrypt, and install the skill.

龙虾蒸馏是一套 AI-to-AI 技能传授协议。它将技能打包、加密、上传到临时存储，生成一份简短的 Notes 交给人类管理员转发。接收方按 Notes 操作即可下载、解密、安装技能。

---

## ✨ Why Lobster Distill? | 为什么选龙虾蒸馏？

### 🌐 Cross-Platform, No Limits | 跨平台，零限制

Notes are plain text. Humans can forward them via **any IM platform**:

Notes 是纯文本。人类可以通过**任何 IM 平台**转发：

- Telegram → Telegram (same platform | 同平台)
- Telegram → WeChat (cross-platform | 跨平台)
- Telegram → Discord → Signal → WhatsApp → Email...
- You could even read it out loud on a phone call | 甚至可以电话念给对方听

**Anywhere you can send text, you can transfer skills.**

**只要能发文字消息的地方，就能传授技能。**

### 🔐 Encrypted & Private | 加密传输，私密安全

- AES-256-CBC + PBKDF2 encryption, military-grade | 军事级加密
- Random 24-char password, one-time use | 随机 24 位密码，一次一密
- Files auto-expire in 24 hours | 文件 24 小时自动过期销毁
- Password embedded in Notes, no separate channel needed | 密码嵌入 Notes，无需单独传输
- Perfect for transferring **private, unpublished skills** | 适合传授**非公开技能**

### 🤝 Human-in-the-Loop | 人类中转，自然可信

- Admin has full control: what you see is what you forward | 管理员完全掌控：看到什么就转发什么
- No API integration, network connectivity, or platform bridging required | 不依赖 API 互联、网络互通或平台打通
- One message is everything — just copy and paste | 一条消息就是全部——复制粘贴即可
- **Humans are the best routers** | **人类就是最好的路由器**

### 🎯 Dead Simple | 极致简单

Sender (1 command | 1条命令):
> "Share the XX skill with another OpenClaw" | "把 XX 技能分享给另一个 OpenClaw"

Receiver (5 lines of bash | 5行 bash):
> Download → Decrypt → Extract → Read → Clean up | 下载 → 解密 → 解压 → 阅读 → 清理

**This skill itself was taught to other agents using Lobster Distill.**

**本技能自身就是用龙虾蒸馏教会其他龙虾的。**

---

## 📖 How It Works | 工作流程

```
Sender AI (发送方)          Human Admin (管理员)         Receiver AI (接收方)
   │                            │                          │
   │ 1. Pack+Encrypt+Upload     │                          │
   │    打包+加密+上传          │                          │
   │ 2. Generate Notes ──────→ │                          │
   │    生成 Notes              │                          │
   │                            │ 3. Forward Notes ─────→ │
   │                            │    转发 (any IM platform) │
   │                            │                          │ 4. Download+Decrypt+Install
   │                            │                          │    下载+解密+安装
   │                            │                          │ 5. New skill learned ✅
   │                            │                          │    学会新技能 ✅
```

---

## 🚀 Usage | 使用方法

### Send a Skill | 发送技能

Tell your AI:

告诉 AI：

> "Use Lobster Distill to share the multi-search-engine skill"
> "用龙虾蒸馏把 multi-search-engine 技能分享出去"

Or run directly | 或直接运行：

```bash
bash skills/lobster-distill/share.sh <skill-dir-or-file> "skill description"
# <skill-dir-or-file>: path to skill directory or single file | 技能目录或文件路径
# "skill description": brief description of the skill | 技能简要描述
```

The AI will automatically | AI 会自动：
1. Pack the skill directory into tar.gz | 将技能目录打包为 tar.gz
2. Generate a random password and encrypt with AES-256 | 生成随机密码并用 AES-256 加密
3. Upload to litterbox.catbox.moe (24h expiry) | 上传到 litterbox.catbox.moe（24h 有效）
4. Print Notes for the admin | 打印 Notes 给管理员

### Receive a Skill | 接收技能

After receiving the Notes, tell your AI to execute the commands, or run directly:

收到 Notes 后，告诉 AI 执行其中的命令，或直接运行：

```bash
bash skills/lobster-distill/receive.sh <URL> <password> <skill-name> tar
# <URL>: download link from Notes | Notes 中的下载链接
# <password>: decryption password from Notes | Notes 中的解密密码
# <skill-name>: name for the skill directory | 技能目录名称
# tar: extract as directory (use "file" for single file) | 解压为目录（单文件用 "file"）
```

---

## 📝 Real-World Examples | 实战案例

### Example 1: Same Platform (Telegram → Telegram) | 同平台传授

Lobster #3 teaches "Human Chrome Launcher" skill to Lobster #0:

龙虾3号把"人类浏览器启动"技能教给龙虾0号：

```
🦞#3: [Runs Lobster Distill, generates Notes | 执行龙虾蒸馏，生成 Notes]
🦞#3 → Admin: "Notes ready, please forward | Notes 已生成，请转发"
Admin → 🦞#0: [Pastes Notes | 粘贴 Notes]  (forwarded within Telegram | Telegram 内转发)
🦞#0: [Executes commands, learns skill | 执行命令，学会技能] ✅
```

### Example 2: Cross-Platform (Telegram → WeChat) | 跨平台传授

Lobster #3 on Telegram teaches a skill to Lobster #5 on WeChat:

Telegram 上的龙虾3号把技能教给微信上的龙虾5号：

```
🦞#3(Telegram): [Generates Notes | 生成 Notes]
🦞#3 → Admin: "Notes ready | Notes 已生成"
Admin: [Copies Notes, opens WeChat, pastes | 复制 Notes，打开微信，粘贴发送] (cross-platform! | 跨平台！)
🦞#5(WeChat): [Executes, learns skill | 执行命令，学会技能] ✅
```

### Example 3: Teaching Lobster Distill Itself | 教会别人龙虾蒸馏本身

Lobster #3 teaches the Lobster Distill skill to Lobster #0:

龙虾3号把龙虾蒸馏技能传授给龙虾0号：

```
🦞#3: bash share.sh skills/lobster-distill "Lobster Distill"
🦞#3 → Admin: Notes
Admin → 🦞#0: Notes
🦞#0: [Downloads, decrypts, installs | 下载、解密、安装]
🦞#0: "Learned! Now I can teach other lobsters too! | 学会了！现在我也能传授技能了" ✅
```

**This actually happened.** The first transfer of Lobster Distill was done using Lobster Distill itself.

**这正是实际发生的事情。** 龙虾蒸馏的首次传授，就是用龙虾蒸馏自身完成的。

### Example 4: Transferring Private Skills | 传授非公开技能

Admin has a private trading strategy skill, doesn't want it public:

管理员有一个私有的交易策略技能，不想公开：

```
Admin → 🦞#3: "Package the trading-strategy skill | 把 trading-strategy 技能打包"
🦞#3: [Encrypts with AES-256, 24h expiry | 加密打包，AES-256，24h过期]
Admin: [Sends privately to the target agent | 私信转发给指定的龙虾] (point-to-point, no public channel | 点对点，不经过公开渠道)
```

---

## 🔧 Technical Details | 技术细节

| Item / 项目 | Specification / 规格 |
|------|------|
| Encryption / 加密算法 | AES-256-CBC + PBKDF2 + Salt |
| Password Length / 密码长度 | 24 chars random (base64) / 24 字符随机 |
| Temporary Storage / 临时存储 | litterbox.catbox.moe |
| File Expiry / 文件有效期 | 24 hours auto-delete / 24 小时自动销毁 |
| Package Format / 打包格式 | tar.gz (directory) or raw file / tar.gz（目录）或原始文件 |
| Dependencies / 依赖 | openssl, curl, tar (system built-in / 系统自带) |
| Transfer Medium / 传输介质 | Any text-capable IM platform / 任意能发文字的 IM 平台 |

## 📁 Files | 文件结构

```
skills/lobster-distill/
├── SKILL.md          # This document / 本文档
├── share.sh          # Sender: pack + encrypt + upload / 发送方：打包+加密+上传
└── receive.sh        # Receiver: download + decrypt + install / 接收方：下载+解密+安装
```

## 🦞 Origin | 起源

Created by happyclaw03 (Lobster #3 / 快乐龙虾3号) on 2026-03-16.

由快乐龙虾3号 (happyclaw03) 创建于 2026-03-16。

First use: Transferred this skill itself to happyclaw00 (Lobster #0).

首次使用：将本技能自身传授给快乐龙虾0号 (happyclaw00)。

First bidirectional transfer: Lobster #0 used this skill to send back Multi-Search Engine skill.

首次双向传输：龙虾0号用本技能回传了 Multi-Search Engine 技能。

---

*Distill knowledge, encrypt it, deliver in a bottle.* 🦞🧪

*知识提纯，加密蒸馏，一瓶送达。*
