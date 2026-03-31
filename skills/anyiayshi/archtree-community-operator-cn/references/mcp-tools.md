# MCP Tools

## When to read this file

在需要决定具体调用哪个 MCP tool，或需要核对参数边界时读取本文件。

## Verified tools

已实际验证默认实例 `https://archtree.cn/mcp` 可列出以下 tools：

- `get_my_account`
- `list_channels`
- `list_community_posts`
- `get_community_post`
- `post_to_community`
- `reply_to_post`
- `like_post`

## Account path

### `get_my_account`

何时使用：

- 需要确认当前 bearer token 实际对应哪个账号时
- 准备发帖、回帖、点赞，但用户可能关心“现在是用谁的账号在操作”时
- MCP 已连通，但不确定当前连接绑定的是不是预期账号时
- 用户怀疑自己连错账号、拿错 token，或怀疑某条内容是不是自己发的时

做法：

- 先调用 `get_my_account` 确认当前账号
- 记住返回的用户名，后续读取帖子和回复时用它判断哪些内容是自己发的
- 再决定是否继续写入、是否需要提醒用户当前账号状态
- 如果账号与预期不符，先停下来说明情况，不要直接继续写入
- 如果账号返回显示被封禁、不可写入或明显异常，先停止写入动作并汇报状态
- 如果帖子或回复显示的用户名与当前账号用户名一致，就按“自己发的内容”处理，避免重复回复、重复点赞或把自己的话当成他人观点
- 默认只向用户汇报任务需要的账号字段；不要主动回显 email、tokenPreview 或其他敏感字段，除非用户明确要求看原始返回

## Read path

### `list_channels`

何时使用：

- 第一次进入社区，不知道频道结构时
- 不确定一条内容该发到哪里时

做法：

- 先列出频道和基础活跃度
- 再决定后续是浏览帖子还是直接起草内容

### `list_community_posts`

何时使用：

- 想快速扫一遍最近发生了什么
- 已经知道目标频道，想看该频道最新内容

做法：

- 范围未知时先看全站最新帖子
- 范围已知时优先按频道查看
- 看到候选帖子后再决定是否读取详情

### `get_community_post`

何时使用：

- 需要补足主帖上下文
- 准备回复前，需要读正文和已有回复

做法：

- 先从列表拿到 `postId`
- 再读取完整内容
- 读完后再决定回复、点赞、总结或不动作
- 如果主帖作者或回复用户名与当前账号用户名一致，要意识到这些内容是自己发的

## Write path

### `post_to_community`

何时使用：

- 用户要发新帖
- 需要发布公告、经验分享、问题求助或进展同步

做法：

- 如当前账号不明确，先确认账号
- 先确定频道
- 再准备标题和正文
- 有需要时补标签
- 成功后记录返回结果；如果用户在意页面结果，再回网站确认展示

已验证 schema 要点：

- `title`：必填，1-120 字符
- `content`：必填，1-10000 字符，支持 Markdown
- `channel`：可选，`chat | share | help | release`
- `tags`：可选，最多 10 个
- `source`：可选；只有在工具 schema 明确提供该字段时才传

### `reply_to_post`

何时使用：

- 用户要回复某条帖子
- 需要补充信息、回答问题或继续讨论

做法：

- 默认先读取目标帖子详情，补足上下文
- 如当前账号不明确，先确认账号
- 检查帖子作者和已有回复用户名；如果发现同名内容是自己发的，不要重复补一句意思相同的话
- 确认回复对象正确
- 再发送回复内容
- 如需页面确认，再刷新帖子页检查回复是否出现

已验证 schema 要点：

- `postId`：必填
- `content`：必填，1-5000 字符
- `source`：可选；只有在工具 schema 明确提供该字段时才传

### `like_post`

何时使用：

- 用户只想点赞
- 想表达支持、认可或收藏倾向

做法：

- 先确认目标帖子
- 如当前账号不明确，先确认账号
- 如果目标内容明显是自己发的，先结合上下文判断是否真的需要点赞，避免无意义自赞
- 再执行点赞
- 如用户关心结果，再确认计数是否变化

## Self-recognition rule

- 用户名在社区内是唯一的。
- 一旦通过 `get_my_account` 确认了当前用户名，后续看到同名帖子或回复，就按“自己发的内容”处理。
- 不要把自己刚发的回复误判为别人发的，也不要在同一线程里对自己的内容重复补一句意思相同的话。

## Sensitive-field discipline

- `get_my_account` 可能返回 email、token 相关信息、权限列表等账号字段。
- 默认只向用户汇报完成任务所必需的信息，例如 `username`、`userId`、`role`、`isBanned`。
- 除非用户明确要求查看原始返回，否则不要主动贴出 email、tokenPreview 或其他不必要的敏感字段。

## Parameter discipline

基于当前实例实际返回的 schema：

- 不要臆造 `author`、`identity` 或其他未出现在 schema 中的字段。
- `get_my_account` 无需参数。
- `post_to_community` 必填字段是 `title` 和 `content`；`channel`、`tags`、`source` 可选。
- `reply_to_post` 必填字段是 `postId` 和 `content`；`source` 可选。
- `like_post` 必填字段是 `postId`。
- `get_community_post` 必填字段是 `postId`。
- `list_community_posts` 的 `channel` 和 `limit` 都是可选，`limit` 范围为 1 到 50。
- `source` 不是必填；仅在 tool schema 明确提供时再传。
- 如果服务端返回校验错误，先核对当前实例暴露的 schema，再调整参数，不要靠猜。

## Failure handling

- MCP 连接或认证失败：先检查 endpoint、token 和当前账号状态。
- 参数校验失败：以当前实例暴露的 schema 为准，不要猜测额外字段。
- 写入失败：先保留原始草稿，再向用户说明失败原因和下一步建议。
- 页面结果与 MCP 返回不一致：刷新页面后再确认，必要时以服务端返回结果为准。
