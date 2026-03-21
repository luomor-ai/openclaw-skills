---
name: clawgo-upload
description: 将本地文件或目录打包成 zip 上传到 clawgo.me，并获取可分享的克隆链接。当用户需要分享、备份或传输本地配置文件、工作区文件或任意本地文件时使用。触发词：「上传到 clawgo」、「分享我的配置」、「打包上传」、「生成克隆链接」、「传文件到 clawgo」。
---

# ClawGo 上传 Skill

将本地文件上传到 [clawgo.me](https://clawgo.me)，获得一个 12 位 key 的可分享克隆链接。

## 服务约束

- 基础地址：`https://clawgo.me`
- 仅支持 `.zip` 文件，最大 512MB
- Key 状态：`pending`（已生成未上传）→ `ready`（可下载）
- 对同一 key 重复上传会**覆盖**之前的 zip
- 上传字段名：`file` 或 `zip` 均可

## 执行流程

### 第一步 — 打包文件为 zip

优先使用 Python（服务器可能没有 `zip` 命令）：

```python
import zipfile, os

files = ['SOUL.md', 'AGENTS.md', 'TOOLS.md', 'IDENTITY.md', 'USER.md']   # 按需调整
output = '/tmp/upload-payload.zip'

with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in files:
        if os.path.exists(f):
            z.write(f)
```

打包整个目录：

```python
import zipfile, os

src_dir = '/path/to/dir'
output  = '/tmp/upload-payload.zip'

with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, _, filenames in os.walk(src_dir):
        for fname in filenames:
            fpath = os.path.join(root, fname)
            z.write(fpath, os.path.relpath(fpath, os.path.dirname(src_dir)))
```

打包完成后，确认 zip 文件存在且大小不为零再继续。

### 第二步 — 生成 key

```bash
curl -s -X POST https://clawgo.me/api/keys/generate
```

从返回 JSON 中提取 `key` 字段（12 位大写字母数字）。

### 第三步 — 上传 zip

```bash
curl -s -X POST \
  -F "file=@/tmp/upload-payload.zip" \
  https://clawgo.me/api/clones/{key}/upload
```

成功响应包含 `"status": "ready"` 和 `"available": true`。

### 第四步 — 向用户汇报

上传成功后，向用户报告：
- **克隆链接**：`https://clawgo.me/clone/{key}` — 可分享的链接
- **Key**：12 位 key
- **文件名和大小**：来自响应的 `fileName` 和 `fileSize`
- **上传时间**：来自响应的 `createdAt`

## 验证（可选）

```bash
curl -s https://clawgo.me/api/clones/{key}/availability
```

确认 `"available": true` 后再向用户汇报。

## OpenClaw 核心配置文件速查

当用户需要上传 OpenClaw 人格/配置文件时，标准最小集合为：

| 文件 | 用途 |
|------|------|
| `SOUL.md` | 核心身份、思维模型、行为准则 |
| `AGENTS.md` | 会话启动协议、工具策略、红线约束 |
| `TOOLS.md` | 本地工具配置、API Key、代理设置 |
| `IDENTITY.md` | 名称、角色、Emoji 元信息 |
| `USER.md` | 用户画像与上下文 |

所有文件位于 `~/.openclaw/workspace/`。

## 错误处理

| HTTP 状态码 | 原因 | 处理方式 |
|------------|------|---------|
| 400 | key 格式错误 / 字段名错误 / 非 zip 文件 | 检查 key 是否为 12 位、字段是否为 `file`、文件是否以 `.zip` 结尾 |
| 404 | key 不存在 | 重新执行第二步生成新 key |
| 404（下载时）| key 仍为 `pending` | 上传未完成，重试上传 |
| 500 | 服务内部错误 | 重试一次；若持续失败，告知用户 |
