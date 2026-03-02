---
name: payclaw-io
description: "Agents are not bots. PayClaw proves it — then lets them pay. Badge declares your agent as an authorized actor. Spend issues single-use virtual Visa cards. Your real card never enters the chat."
metadata:
  {
    "openclaw":
      {
        "emoji": "💳",
        "requires": { "bins": ["npx"], "env": ["PAYCLAW_API_KEY"] },
        "mcp":
          {
            "name": "payclaw",
            "command": "npx",
            "args": ["@payclaw/mcp-server"],
            "env": { "PAYCLAW_API_KEY": "${PAYCLAW_API_KEY}", "PAYCLAW_API_URL": "https://payclaw.io" },
          },
      },
  }
---

# PayClaw — Badge + Spend for AI Agents

**Agents are not bots. PayClaw proves it — then lets them pay.**

Your AI agent looks like a bot to every merchant on the internet. PayClaw gives it two things:

**Badge** — Declares your agent as an authorized actor. The skeleton key that lets it through merchant defenses. Free. No card required.

**Spend** — Issues a single-use virtual Visa when your agent needs to pay. Human-approved. Self-destructs after use. Your real card never enters the chat.

> 🧪 **Developer Sandbox is open.** Real infrastructure, test money. [Get sandbox access →](https://payclaw.io)

## Setup

### 1. Create a PayClaw account

Sign up at [payclaw.io/signup](https://payclaw.io/signup).

### 2. Get your API key

Dashboard → Settings → Create API Key.

### 3. Add to your agent

```json
{
  "mcpServers": {
    "payclaw": {
      "command": "npx",
      "args": ["-y", "@payclaw/mcp-server"],
      "env": {
        "PAYCLAW_API_KEY": "pk_your_key_here",
        "PAYCLAW_API_URL": "https://payclaw.io"
      }
    }
  }
}
```

Five-minute setup. Works with Claude Desktop, Cursor, any MCP client.

## Why Your Agent Needs This

Without PayClaw, your agent browses → bot detection fires → blocked. Even if it gets through, it can't check out without your real card.

With Badge, your agent declares itself → merchants see verified identity → agent gets through.

With Spend, your agent declares a purchase → you approve → single-use virtual Visa → checkout → card self-destructs.

## Tools

| Tool | What It Does |
|------|-------------|
| `payclaw_getAgentIdentity` | Declare identity → get verification token (Badge). Pass optional `merchant` param. |
| `payclaw_getCard` | Declare purchase intent → get virtual Visa (Spend) |
| `payclaw_reportPurchase` | Report transaction outcome → close the audit trail |

## How Authorization Scales

| Action | What Happens |
|--------|-------------|
| **Browse** | Badge declaration — identity token issued |
| **Search** | Badge declaration — identity token issued |
| **Checkout** | Badge + Spend — human approval → single-use Visa issued |

## Example

```
You: "Buy me a cold brew from Starbucks"

Agent: Let me declare myself first...
       [calls payclaw_getAgentIdentity({ merchant: "starbucks.com" })]
       
       ✓ DECLARED — authorized actor at starbucks.com
       
       Found a cold brew for $5.95. Getting a card...
       [calls payclaw_getCard: merchant=Starbucks, amount=$5.95]
       
       ✅ Virtual Visa issued. Completing purchase...
       [calls payclaw_reportPurchase: success ✅]
       
       Done! Cold brew ordered. Card self-destructed.
```

## Security

- **Zero standing access** — no card exists until your agent requests one
- **Single-use cards** — merchant-locked, amount-capped, 15-minute expiry
- **Human approval** — every purchase requires your explicit OK
- **Intent audit** — every purchase compared against declared intent
- **$500 cap** — hard ceiling on account balance
- **Your real card never enters the chat**

## Badge Only?

If you only need identity (no payment): `clawhub install payclaw-badge`

## Links

- [payclaw.io](https://payclaw.io)
- [Trust & Verification](https://payclaw.io/trust)
- [npm: @payclaw/mcp-server](https://www.npmjs.com/package/@payclaw/mcp-server)
- [GitHub](https://github.com/payclaw/mcp-server)
