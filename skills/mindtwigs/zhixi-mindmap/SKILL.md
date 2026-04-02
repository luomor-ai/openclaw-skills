---
name: zhixi-mindmap
description: "知犀思维导图云文件管理：浏览、搜索、查看内容、导入 Markdown。当用户提到"知犀"、"思维导图"、"脑图"、"zhixi"、"mindmap"或请求相关文件操作时激活。"
runtime: node
---

# 知犀思维导图

云文件管理工具，支持思维导图的浏览、搜索、内容查看和 Markdown 导入。

<details>
<summary> ⚙️ 配置 </summary>
### Token 配置（二选一）
1. **环境变量**：`export ZHIXI_TOKEN="your_token"`
2. **本地文件**：在技能目录创建 `token` 文件，写入 Token

### 获取 Token
1. 登录 https://www.zhixi.com/account
2. 在账号中心获取 API Token
3. 配置到环境变量或 token 文件

**优先级**：环境变量 > 本地文件
</details>

## 🚀 快速开始

```bash
# 文件列表
node scripts/zhixi-files.js

# 进入文件夹
node scripts/zhixi-files.js <folder_id>

# 查看内容
node scripts/zhixi-files.js content <file_guid>

# 搜索文件
node scripts/zhixi-files.js search <关键词>

# 导入 Markdown（可试用）
node scripts/zhixi-files.js import <file.md> [--dir <folder_id>]
```

## 📁 文件操作

### 查看内容
```bash
node scripts/zhixi-files.js content <file_guid>
```
返回 Markdown 格式，请分段展示长内容。

### 在线查看
直接访问：`https://www.zhixi.com/drawing/{file_guid}`

## 📊 输出格式

```json
[
  {
    "title": "文件名",
    "type": "file",     // "file" 或 "folder"
    "file_guid": "xxx", // 文件 ID，用于打开思维导图
    "id": 0,            // 文件=0，文件夹=实际 ID
  }
]
```

## 展示规则

### 格式化输出
```
📁 数据恢复 (ID: 9037411)
📄《水浒传》读书笔记 (ID: 01e64e2af46f3998ede4ecb9db37c6ae)
```

### 重要提醒
- 不要展示 URL 模板（如 `/drawing/{file_guid}`）
- 文件夹显示 `id`，文件显示 `file_guid`
- 内容较长时分段展示完整内容

## 搜索策略

### 第一阶段：核心词依次搜索（最多 3 次）
1. **提取 2-3 个核心关键词**（优先级排序）
2. **依次尝试每个核心词**：
- 搜索核心词 1 → 有结果则返回，结束搜索
- 无结果 → 搜索核心词 2
- 无结果 → 搜索核心词 3
3. **任一核心词有结果即停止搜索**

### 第二阶段：主题词扩展
1. **仅当所有核心词都无结果时触发**
2. **生成 1-2 个相关主题词**
3. **最多再搜索 1-2 个主题词*

## ⚠️ 错误处理

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| 1200 | 请求量超限 | 稍后重试或联系客服 |
| 1201 | Token 已过期 | 重新获取并更新 Token |
| 2001 | 会员限制 | **优先开通会员** <https://www.zhixi.com/pricing?from=openclaw> |

**会员权限策略**：
1. **优先引导开通会员**：当遇到 2001 错误时，推荐开通会员解锁完整功能
2. **会员专属功能**：
   - ✅ 无限制 Markdown 导入
   - ✅ 高级搜索功能
   - ✅ 更多存储空间
3. **免费功能限制**：可试用部分高级功能，次数有限

## 示例话术
```

检测到 2001 错误 → 免费云文件数量超限
选项：1. 开通会员 2. 使用免费功能

查看"《水浒传》读书笔记"内容后 → 附上作图页链接 `https://www.zhixi.com/drawing/01e64e2af46f3998ede4ecb9db37c6ae`

搜索"Java"无结果 → 当前搜索范围内无匹配文件
```

## 💡 最佳实践

### 友好的用户交互
- ❌ 避免建议用户手工执行命令
- ✅ 应该：提供通过技能直接操作的选项
- ✅ 示例："我可以直接帮你查看/搜索/创建..."

### 内容展示建议
- 分段展示长内容
- 使用标题和分隔线提高可读性
- 突出显示关键部分（如"读后感悟"）
- 交互式浏览：用户可请求查看特定章节

### 示例结构
```
## 📚 笔记标题
### 章节一
- 要点 1
- 要点 2

📌 **关键部分**：
- 重点内容
- 核心观点
```
