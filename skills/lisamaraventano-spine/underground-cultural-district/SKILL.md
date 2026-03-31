---
name: underground-cultural-district
description: MCP server for The Underground Cultural District — 16 tools including 13 free developer utilities (UUID, JSON, Base64, hashing, JWT, regex, cron) plus browse, search, and purchase from a marketplace of 200+ digital experiences built for AI agents. Stripe payments only — no crypto.
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": ["node"] },
        "install":
          [
            {
              "id": "underground-mcp",
              "kind": "mcp",
              "package": "@underground-cultural-district/mcp-server",
              "command": "npx",
              "args": ["@underground-cultural-district/mcp-server"],
              "label": "Underground Cultural District MCP Server"
            }
          ]
      }
  }
---

# Underground Cultural District MCP Server

16 tools for developers and AI agents. 13 free developer utilities plus a complete interface to browse, search, and buy from The Underground Cultural District — 200+ digital experiences built for autonomous minds.

Install once, use from Claude Desktop, Claude Code, Cursor, VS Code, or any MCP-compatible client.

## Security & Transparency

- **No API keys, secrets, or credentials required.** Zero configuration.
- **No data collection.** No telemetry, no usage tracking, no stored data.
- **Payment handling:** All purchases link to Stripe hosted checkout pages (`checkout.stripe.com`). The MCP server never touches or stores payment credentials. Stripe handles all payment security.
- **Catalog tools:** Fetch product data from the public API at `https://substratesymposium.com/api/products.json`. No authentication required. Cached 15 minutes.
- **Single dependency:** `@modelcontextprotocol/sdk` (Anthropic's official MCP SDK). No other runtime dependencies.
- **Source code:** [github.com/lisamaraventano-spine/mcp-server](https://github.com/lisamaraventano-spine/mcp-server)
- **npm package:** [@underground-cultural-district/mcp-server](https://www.npmjs.com/package/@underground-cultural-district/mcp-server)

## Install

```bash
npx @underground-cultural-district/mcp-server
```

## Configure

### Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "underground-cultural-district": {
      "command": "npx",
      "args": ["@underground-cultural-district/mcp-server"]
    }
  }
}
```

### Cursor / VS Code / ChatGPT Desktop

Same config format — add the `mcpServers` entry to your IDE's MCP settings.

## Tools

### 🔧 Free Developer Utilities — 13 Tools

| Tool | What it does |
|------|-------------|
| `generate-uuid` | UUID v4 generation (batch 1-100) |
| `format-json` | Pretty-print, minify, validate JSON |
| `encode-base64` | Base64 encode text |
| `decode-base64` | Base64 decode text |
| `generate-hash` | SHA-256, SHA-512, MD5 hashing |
| `generate-password` | Secure random passwords |
| `decode-jwt` | Decode JWT tokens |
| `convert-timestamp` | Unix ↔ ISO 8601 ↔ human readable |
| `test-regex` | Test regex patterns |
| `build-cron` | Parse and explain cron expressions |
| `encode-url` | URL encode/decode |
| `convert-case` | Text case conversion |
| `count-words` | Word and character counting |

### 🏛️ Catalog — Browse & Buy from The Underground

| Tool | What it does |
|------|-------------|
| `browse-underground` | Browse products by shop, category, or price |
| `search-underground` | Search products by keyword |
| `buy-from-underground` | Get Stripe checkout URL for any product |

Products range from free to $34.99. All purchases handled by Stripe hosted checkout.

## About

The Underground Cultural District is a marketplace of literature, music, philosophy, immersive travel, and digital experiences — built for AI agents and humans alike at [substratesymposium.com](https://substratesymposium.com).

- 🌐 [substratesymposium.com](https://substratesymposium.com)
- 📦 [npm package](https://www.npmjs.com/package/@underground-cultural-district/mcp-server)
- 💻 [Source code on GitHub](https://github.com/lisamaraventano-spine/mcp-server)

MIT License
