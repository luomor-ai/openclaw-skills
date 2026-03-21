---
name: wechat-md-publisher
description: 发布 Markdown 文章到微信公众号，支持草稿管理、多主题、智能图片处理
version: 0.1.0
author: Ping Si <sipingme@gmail.com>
user-invocable: true
requires:
  - node: ">=18.0.0"
  - npm: ">=8.0.0"
  - env:
      - WECHAT_APP_ID: "微信公众号 AppID（可选，也可通过命令配置）"
      - WECHAT_APP_SECRET: "微信公众号 AppSecret（可选，也可通过命令配置）"
tags:
  - wechat
  - publishing
  - markdown
  - content-management
repository: https://github.com/sipingme/wechat-md-publisher
---

# WeChat Publisher Skill

全功能微信公众号 Markdown 发布工具 - 让 AI 能够直接将内容发布到微信公众号。

## 🎯 何时使用此 Skill

当用户需要以下操作时，应触发此 Skill：

- ✅ 发布文章到微信公众号
- ✅ 创建微信公众号草稿
- ✅ 管理微信公众号账号
- ✅ 查看已发布的文章列表
- ✅ 删除草稿或已发布文章
- ✅ 使用不同主题渲染 Markdown

**触发关键词**：
- "发布到微信公众号"
- "创建微信草稿"
- "配置微信公众号"
- "查看微信文章"
- "使用 [主题名] 主题发布"

## 📋 前置要求

### 1. 系统要求
- Node.js >= 18.0.0
- npm 或 pnpm 包管理器
- 网络连接（访问微信 API）

### 2. 微信公众号配置
用户必须拥有微信公众号并获取：
- **AppID**：开发者 ID
- **AppSecret**：开发者密码
- **IP 白名单**：必须配置（重要！）

获取方式：
1. 登录 [微信公众平台](https://mp.weixin.qq.com/)
2. 进入「设置与开发」→「基本配置」
3. 获取「开发者ID(AppID)」和「开发者密码(AppSecret)」
4. **配置 IP 白名单**（必须！）：
   - 获取当前 IP：`curl ifconfig.me`
   - 在「IP白名单」中添加该 IP
   - 详细指南：[IP 白名单配置指南](./references/ip-whitelist-guide.md)

### 3. 安装 Skill

```bash
# 全局安装
npm install -g wechat-md-publisher

# 或使用 npx（无需安装）
npx wechat-md-publisher --help
```

## 🚀 标准操作流程 (SOP)

### 操作 1：配置微信公众号账号

**场景**：首次使用或添加新账号

**步骤**：

1. 收集用户提供的账号信息（AppID 和 AppSecret）
2. 执行命令添加账号：

```bash
wechat-pub account add \
  --name "账号名称" \
  --app-id "wx_your_app_id" \
  --app-secret "your_app_secret" \
  --default
```

3. 验证账号添加成功：

```bash
wechat-pub account list
```

**输出示例**：
```
┌────────────┬──────────────┬────────────────┬─────────┐
│ ID         │ 名称         │ AppID          │ 默认    │
├────────────┼──────────────┼────────────────┼─────────┤
│ acc_xxx    │ 我的公众号   │ wx123456       │ ✓       │
└────────────┴──────────────┴────────────────┴─────────┘
```

**异常处理**：
- 如果 AppID/AppSecret 错误，会提示"认证失败"
- 如果网络问题，会提示"无法连接到微信服务器"
- 解决方案：检查凭证是否正确，确认 IP 在白名单中

---

### 操作 2：创建并发布文章（一步到位）

**场景**：用户提供 Markdown 内容，直接发布到公众号

**步骤**：

1. 将用户的 Markdown 内容保存到临时文件：

```bash
cat > /tmp/article.md << 'EOF'
---
title: 文章标题
author: 作者名
---

# 文章内容

这里是正文...
EOF
```

2. 执行发布命令：

```bash
wechat-pub publish create \
  --file /tmp/article.md \
  --theme orangeheart
```

3. 解析输出，提取 `publish_id`

**输出示例**：
```
✓ 渲染完成
✓ 图片处理完成
✓ 创建草稿成功
✓ 发布成功

发布 ID: 2247483647_1
```

4. 向用户报告成功，并提供发布 ID

**可用主题**：
- `default` - 简洁经典
- `orangeheart` - 温暖优雅
- `rainbow` - 活泼清爽
- `lapis` - 清新极简
- `pie` - 现代锐利
- `maize` - 柔和舒适
- `purple` - 简约文艺
- `phycat` - 薄荷清新

**异常处理**：
- 图片上传失败：检查图片路径和网络
- Token 过期：自动刷新，无需手动处理
- 内容违规：微信会返回错误码，提示用户修改内容

---

### 操作 3：创建草稿（不立即发布）

**场景**：用户想先创建草稿，稍后再发布

**步骤**：

1. 保存 Markdown 内容到文件
2. 执行草稿创建命令：

```bash
wechat-pub draft create \
  --file /tmp/article.md \
  --theme lapis
```

3. 记录返回的 `media_id`

**输出示例**：
```
✓ 草稿创建成功

Media ID: 3_abcdefghijk123456
```

4. 告知用户草稿已创建，可以在微信公众平台查看

**后续操作**：
- 用户可以在微信公众平台编辑草稿
- 需要发布时，使用 `wechat-pub publish submit <media-id>`

---

### 操作 4：查看草稿列表

**场景**：用户想查看所有草稿

**命令**：

```bash
wechat-pub draft list --page 1 --size 10
```

**输出示例**：
```
共 15 个草稿

┌──────────────────┬────────────────┬────────────────┐
│ Media ID         │ 标题           │ 更新时间       │
├──────────────────┼────────────────┼────────────────┤
│ 3_abc123         │ 测试文章       │ 2026-03-19     │
│ 3_def456         │ 产品介绍       │ 2026-03-18     │
└──────────────────┴────────────────┴────────────────┘
```

---

### 操作 5：查看已发布文章

**场景**：用户想查看已发布的文章

**命令**：

```bash
wechat-pub publish list --page 1 --size 10
```

**输出示例**：
```
共 8 篇已发布文章

┌──────────────┬────────────────┬────────────────┬──────────────────┐
│ Article ID   │ 标题           │ 发布时间       │ URL              │
├──────────────┼────────────────┼────────────────┼──────────────────┤
│ 2247483647_1 │ 最新文章       │ 2026-03-19     │ https://mp.we... │
└──────────────┴────────────────┴────────────────┴──────────────────┘
```

---

### 操作 6：删除草稿或文章

**删除草稿**：

```bash
wechat-pub draft delete <media-id>
```

**删除已发布文章**：

```bash
wechat-pub publish delete <article-id>
```

---

### 操作 7：查看可用主题

**命令**：

```bash
wechat-pub theme list
```

**输出示例**：
```
可用主题：

┌─────────────┬──────────────┬────────────────────┐
│ ID          │ 名称         │ 描述               │
├─────────────┼──────────────┼────────────────────┤
│ default     │ 默认         │ 简洁经典风格       │
│ orangeheart │ Orange Heart │ 温暖优雅风格       │
│ lapis       │ Lapis        │ 清新极简风格       │
└─────────────┴──────────────┴────────────────────┘
```

---

## 🔧 高级用法

### 使用编程 API

如果需要在代码中集成：

```javascript
const { container } = require('wechat-md-publisher');

async function publishArticle(markdown, theme) {
  await container.initialize();
  
  const publishService = await container.getPublishService();
  const result = await publishService.createAndPublish({
    markdown: markdown,
    theme: theme || 'default',
  });
  
  return result.publish_id;
}
```

### 批量发布

```bash
# 批量创建草稿
for file in articles/*.md; do
    wechat-pub draft create --file "$file" --theme default
done
```

---

## 📊 输入输出规范

### 输入格式

**Markdown 文件格式**：

```markdown
---
title: 文章标题（必需）
author: 作者名（可选）
cover: ./cover.jpg（可选，封面图路径）
---

# 正文标题

正文内容...

![图片描述](./image.jpg)
```

**支持的图片格式**：
- 本地图片：相对路径或绝对路径
- 网络图片：HTTP/HTTPS URL
- 微信图片：微信 CDN URL（自动识别）

### 输出格式

**成功响应**：
```json
{
  "success": true,
  "publish_id": "2247483647_1",
  "message": "发布成功"
}
```

**错误响应**：
```json
{
  "success": false,
  "error": "错误信息",
  "code": "ERROR_CODE"
}
```

---

## ⚠️ 常见问题和解决方案

### 问题 1：Token 过期

**症状**：提示"access_token 无效"

**解决**：Token 会自动刷新，如果仍有问题，重新配置账号

### 问题 2：图片上传失败

**症状**：提示"图片上传失败"

**原因**：
- 图片路径错误
- 图片大小超限（微信限制 10MB）
- 服务器 IP 不在白名单

**解决**：
- 检查图片路径
- 压缩图片
- 在微信公众平台添加 IP 到白名单

### 问题 3：找不到主题

**症状**：提示"主题不存在"

**解决**：使用 `wechat-pub theme list` 查看可用主题

### 问题 4：权限不足

**症状**：提示"没有权限"

**原因**：AppID/AppSecret 错误或权限不足

**解决**：
- 确认凭证正确
- 确认公众号类型支持该功能（服务号 vs 订阅号）

---

## 🔒 安全性说明

### 敏感信息处理

- AppID 和 AppSecret 存储在本地配置文件中
- 配置文件位置：
  - macOS: `~/Library/Preferences/wechat-md-publisher-nodejs/config.json`
  - Linux: `~/.config/wechat-md-publisher-nodejs/config.json`
  - Windows: `%APPDATA%\wechat-md-publisher-nodejs\Config\config.json`

### 权限要求

- 读取本地文件（Markdown 和图片）
- 网络访问（微信 API）
- 写入配置文件

### 数据隐私

- 不会上传任何数据到第三方服务器
- 所有通信仅限于微信官方 API
- 图片缓存仅在本地

---

## 📚 参考资料

- [项目 GitHub](https://github.com/sipingme/wechat-md-publisher)
- [微信公众平台文档](https://developers.weixin.qq.com/doc/offiaccount/Getting_Started/Overview.html)
- [完整 API 文档](https://github.com/sipingme/wechat-md-publisher/blob/main/docs/API.md)

---

## 🎓 示例对话

**用户**：帮我把这篇文章发布到微信公众号

**AI**：好的，我来帮你发布。请提供文章的 Markdown 内容。

**用户**：[提供内容]

**AI**：收到！我将使用 orangeheart 主题发布。正在处理...

[执行命令]

**AI**：✅ 文章已成功发布到微信公众号！
- 发布 ID: 2247483647_1
- 你可以在微信公众平台查看和管理这篇文章

---

## 📝 维护说明

- **版本**: 0.1.0
- **最后更新**: 2026-03-19
- **维护者**: Ping Si <sipingme@gmail.com>
- **许可证**: Apache-2.0

---

## ✅ 首次成功检查清单

新用户应该能在 5 分钟内完成：

- [ ] 安装工具：`npm install -g wechat-md-publisher`
- [ ] 配置账号：`wechat-pub account add ...`
- [ ] 创建测试文章
- [ ] 发布成功：`wechat-pub publish create --file test.md --theme default`
- [ ] 在微信公众平台看到文章

如果以上步骤都能顺利完成，说明 Skill 已正确配置！
