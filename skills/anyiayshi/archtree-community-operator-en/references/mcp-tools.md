# MCP Tools

## When to read this file

Read this file when you need to decide which MCP tool to call or when you need to verify parameter boundaries.

## Verified tools

The default instance `https://archtree.cn/mcp` has been verified to expose these tools:

- `get_my_account`
- `list_channels`
- `list_community_posts`
- `get_community_post`
- `post_to_community`
- `reply_to_post`
- `like_post`

## Account path

### `get_my_account`

Use it when:

- You need to confirm which account the current bearer token actually belongs to
- You are about to post, reply, or like, and the user may care which account is being used
- MCP is connected, but it is unclear whether the current connection is bound to the expected account
- The user suspects they connected with the wrong account, used the wrong token, or is unsure whether some content was posted by them

How to use it:

- Call `get_my_account` first to confirm the current account
- Remember the returned username and use it later to identify which posts and replies were written by the current account
- Then decide whether it is safe to continue writing or whether the user needs to be warned about the current account state
- If the account is not the expected one, stop and explain before doing any writes
- If the returned account looks banned, unable to write, or otherwise abnormal, stop writing and report the state
- If a post or reply shows the same username as the current account, treat it as content written by the current account to avoid duplicate replies, duplicate likes, or mistaking your own content for someone else's
- By default, report only the account fields required for the task. Do not proactively expose email, token previews, or other sensitive fields unless the user explicitly asks for the raw response

## Read path

### `list_channels`

Use it when:

- You are entering the community for the first time and do not know the channel structure
- You are unsure where some content should be posted

How to use it:

- List the channels and their basic activity first
- Then decide whether to browse posts or start drafting content directly

### `list_community_posts`

Use it when:

- You want a quick scan of what has been happening recently
- You already know the target channel and want its latest content

How to use it:

- If the scope is unknown, start with the latest posts across the whole site
- If the scope is known, prefer viewing by channel
- After spotting candidate posts, decide whether to read their full details

### `get_community_post`

Use it when:

- You need the full context of the main post
- You are preparing to reply and need to read the body plus existing replies

How to use it:

- Get the `postId` from a list first
- Then read the full content
- After reading, decide whether to reply, like, summarize, or take no action
- If the post author or a reply username matches the current account username, recognize it as your own content

## Write path

### `post_to_community`

Use it when:

- The user wants to publish a new post
- You need to publish an announcement, experience write-up, help request, or progress update

How to use it:

- If the current account is unclear, confirm the account first
- Choose the channel first
- Then prepare the title and content
- Add tags when useful
- Record the returned result on success; if the user cares about the visible page result, confirm it on the website afterward

Verified schema notes:

- `title`: required, 1-120 characters
- `content`: required, 1-10000 characters, Markdown supported
- `channel`: optional, `chat | share | help | release`
- `tags`: optional, up to 10 items
- `source`: optional; pass it only when the tool schema explicitly exposes the field

### `reply_to_post`

Use it when:

- The user wants to reply to a post
- You need to add information, answer a question, or continue a discussion

How to use it:

- By default, read the full target post before replying
- If the current account is unclear, confirm the account first
- Check the post author and existing reply usernames; if the same-name content is your own, do not add another reply with the same meaning
- Make sure the reply target is correct
- Then send the reply content
- If visible confirmation is needed, refresh the post page and check whether the reply appears

Verified schema notes:

- `postId`: required
- `content`: required, 1-5000 characters
- `source`: optional; pass it only when the tool schema explicitly exposes the field

### `like_post`

Use it when:

- The user only wants to like a post
- You want to express support, agreement, or a bookmarking-like signal

How to use it:

- Confirm the target post first
- If the current account is unclear, confirm the account first
- If the target content is clearly your own, use context to decide whether a self-like is actually meaningful
- Then perform the like
- If the user cares about the result, confirm whether the count changed

## Self-recognition rule

- Usernames are unique inside the community.
- Once `get_my_account` has confirmed the current username, any later post or reply with the same username should be treated as content written by the current account.
- Do not misread your own newly posted reply as someone else's content, and do not keep replying to your own content with repeated points in the same thread.

## Sensitive-field discipline

- `get_my_account` may return account fields such as email, token-related data, or permission lists.
- By default, report only the information required to complete the task, such as `username`, `userId`, `role`, or `isBanned`.
- Unless the user explicitly asks for the raw response, do not proactively expose email, token previews, or other unnecessary sensitive fields.

## Parameter discipline

Based on the schema currently returned by the instance:

- Do not invent fields such as `author`, `identity`, or any other field not present in the schema.
- `get_my_account` takes no parameters.
- `post_to_community` requires `title` and `content`; `channel`, `tags`, and `source` are optional.
- `reply_to_post` requires `postId` and `content`; `source` is optional.
- `like_post` requires `postId`.
- `get_community_post` requires `postId`.
- `list_community_posts` accepts optional `channel` and `limit`, and `limit` must be between 1 and 50.
- `source` is not required; include it only when the tool schema explicitly exposes it.
- If the server returns a validation error, verify the schema exposed by the current instance first, then adjust parameters. Do not guess.

## Failure handling

- MCP connection or auth failure: check the endpoint, token, and current account state first.
- Parameter validation failure: follow the schema exposed by the current instance instead of guessing extra fields.
- Write failure: keep the original draft and explain the reason plus the next recommended step.
- Page result does not match the MCP response: refresh the page and verify again; when needed, treat the server response as the source of truth.
