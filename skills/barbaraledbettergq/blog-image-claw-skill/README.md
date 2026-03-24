# Blog Image Generator

Generate stunning **ai blog image generator** images from a text description using AI — powered by the Neta talesofai API. Get back a direct image URL instantly, ready to embed anywhere.

---

## Install

**Via npx skills:**
```bash
npx skills add BarbaraLedbettergq/blog-image-claw-skill
```

**Via ClawHub:**
```bash
clawhub install blog-image-claw-skill
```

---

## Usage

```bash
# Basic usage — describe what you want
node blogimageclaw.js "minimalist flat-lay of a laptop and coffee on a wooden desk"

# Specify size
node blogimageclaw.js "futuristic city skyline at dusk" --size landscape

# Use a reference image (style transfer)
node blogimageclaw.js "vibrant abstract background" --ref <picture_uuid>

# Pass token inline
node blogimageclaw.js "cozy home office setup" --token YOUR_NETA_TOKEN
```

The script prints the image URL to stdout on success:
```
https://cdn.talesofai.cn/.../<image>.jpg
```

---

## Options

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| `--size` | `square`, `portrait`, `landscape`, `tall` | `landscape` | Output image dimensions |
| `--style` | `anime`, `cinematic`, `realistic` | `cinematic` | Visual style (passed via prompt) |
| `--ref` | `<picture_uuid>` | — | Reference image UUID for style/param inheritance |
| `--token` | `<token>` | — | Neta API token (overrides env / file) |

### Size reference

| Name | Dimensions |
|------|-----------|
| `square` | 1024 × 1024 |
| `portrait` | 832 × 1216 |
| `landscape` | 1216 × 832 |
| `tall` | 704 × 1408 |

---

## Token setup

The script resolves your Neta API token in this order:

1. `--token` CLI flag
2. `NETA_TOKEN` environment variable
3. `~/.openclaw/workspace/.env` — line matching `NETA_TOKEN=...`
4. `~/developer/clawhouse/.env` — line matching `NETA_TOKEN=...`

**Recommended:** add to your shell profile or `.env` file:
```bash
export NETA_TOKEN=your_token_here
```

---

## Default prompt

When no prompt is supplied, the skill uses:
```
professional blog hero image, high quality photography, relevant to topic
```

---

## Examples

```bash
# Hero image for a travel blog post
node blogimageclaw.js "aerial view of turquoise ocean with white sandy beach, golden hour"

# Tech article cover
node blogimageclaw.js "abstract data visualization, glowing blue network nodes on dark background" --size landscape

# Portrait-style author photo background
node blogimageclaw.js "soft bokeh office background, warm natural lighting" --size portrait
```

## About Neta

[Neta](https://www.neta.art/) (by TalesofAI) is an AI image and video generation platform with a powerful open API. It uses a **credit-based system (AP — Action Points)** where each image generation costs a small number of credits. Subscriptions are available for heavier usage.

### Register & Get Token

| Region | Sign up | Get API token |
|--------|---------|---------------|
| Global | [neta.art](https://www.neta.art/) | [neta.art/open](https://www.neta.art/open/) |
| China  | [nieta.art](https://app.nieta.art/) | [nieta.art/security](https://app.nieta.art/security) |

New accounts receive free credits to get started. No credit card required to try.

### Pricing

Neta uses a pay-per-generation credit model. View current plans on the [pricing page](https://www.neta.art/pricing).

- **Free tier:** limited credits on signup — enough to test
- **Subscription:** monthly AP allowance via Stripe
- **Credit packs:** one-time top-up as needed

### Set up your token

```bash
# Step 1 — get your token:
#   Global: https://www.neta.art/open/
#   China:  https://app.nieta.art/security

# Step 2 — set it
export NETA_TOKEN=your_token_here

# Step 3 — run
node blogimageclaw.js "your prompt"
```

Or pass it inline:
```bash
node blogimageclaw.js "your prompt" --token your_token_here
```

> **API endpoint:** defaults to `api.talesofai.cn` (works with all token types).  
> Override with `NETA_API_URL=https://api.talesofai.cn` if using a global Open Platform token.


---

Built with [Claude Code](https://claude.ai/claude-code) · Powered by [Neta](https://www.neta.art/) · [API Docs](https://www.neta.art/open/)