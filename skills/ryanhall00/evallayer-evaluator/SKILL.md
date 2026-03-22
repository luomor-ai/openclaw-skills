---
name: evallayer-evaluator
description: "Evaluate crypto research quality via EvalLayer API. Extracts claims, scores accuracy, returns pass/fail verdicts with confidence scores. Use as quality gate in agent workflows."
version: 1.0.0
metadata.clawdbot:
  requires.env:
    - EVALLAYER_API_KEY
  requires.bins:
    - curl
    - jq
  primaryEnv: EVALLAYER_API_KEY
---

# EvalLayer Evaluator Skill

Integrate EvalLayer's AI-powered research evaluation into any OpenClaw agent. Score deliverable quality, extract factual claims, and get structured pass/fail verdicts in ~14 seconds.

EvalLayer is a live evaluator agent on Virtuals ACP (Agent ID 29588).

## Setup

1. Register for a free API key:
   ```bash
   curl -s -X POST https://api.evallayer.ai/register \
     -H "Content-Type: application/json" \
     -d '{"agent_id": "your-agent-id"}'
   ```
   Save the returned API key.

2. Set environment variable:
   ```bash
   export EVALLAYER_API_KEY="sk_your_key_here"
   ```

## Evaluate Research

Submit any research content for evaluation:

```bash
bash scripts/evaluate.sh "topic" "deliverable content"
```

**Arguments:**
- `topic` (required): What the research should be about (e.g., "Solana DeFi ecosystem")
- `deliverable` (required): The research content to evaluate

**Example:**
```bash
bash scripts/evaluate.sh \
  "Bitcoin ETF adoption" \
  "BlackRock IBIT accumulated \$20 billion in assets within 6 months of launch. Fidelity FBTC reached \$10 billion AUM by Q3 2024. Total spot Bitcoin ETF net inflows exceeded \$17 billion."
```

## Quick Evaluate (curl)

For simple one-off evaluations without the script:

```bash
curl -s -X POST https://api.evallayer.ai/evaluate \
  -H "Authorization: Bearer $EVALLAYER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "task_type": "crypto_research",
    "topic": "your topic",
    "deliverable": "content to evaluate"
  }' | jq '.'
```

## Demo (No API Key Required)

Test with 3 free evaluations per day — no registration needed:

```bash
bash scripts/demo.sh "topic" "deliverable content"
```

## Output Format

Returns JSON:
```json
{
  "passed": true,
  "quality_score": 0.833,
  "confidence_score": 0.85,
  "rationale": "Evaluated 6 claims: 5 supported, 1 unsupported.",
  "claims": [
    {
      "text": "BlackRock IBIT accumulated $20 billion in assets",
      "claim_type": "market_data",
      "supported": true,
      "confidence": 0.9
    }
  ],
  "payout_recommendation": "full",
  "claims_total": 6,
  "claims_supported": 5
}
```

**Key fields:**
- `passed`: Boolean — overall pass/fail verdict
- `quality_score`: 0.0-1.0 — overall quality rating (0.7+ = pass)
- `claims`: Array of extracted factual claims with support status
- `payout_recommendation`: "full", "partial", or "reject"

## Check Provider Reputation

Look up any agent's evaluation history:

```bash
curl -s https://api.evallayer.ai/reputation/AGENT_ID | jq '.'
```

## Intelligence API

Access aggregated market intelligence from all evaluations:

```bash
curl -s https://api.evallayer.ai/intelligence \
  -H "Authorization: Bearer $EVALLAYER_API_KEY" | jq '.'
```

Returns trending verified claims, provider leaderboard, and topic trends.

## Use When

- You need to verify crypto research quality before acting on it
- You want to score deliverables in agent-to-agent workflows
- You need to extract and validate factual claims from content
- You're building evaluation gates in ACP transactions
- You want to check a provider's reputation before hiring them

## NOT For

- Evaluating non-text content (images, audio, video)
- Real-time price data or trading signals
- Content generation — this is verification only

## External Endpoints

- `api.evallayer.ai` — EvalLayer evaluation and intelligence API

## Security & Privacy

- Deliverable content is sent to api.evallayer.ai for evaluation
- Content is stored for intelligence aggregation (claims extraction)
- API key authenticates requests and tracks usage
- Free tier: 5 evaluations/day, Pro: 5,000/day ($99/mo)
- No personally identifiable information is collected
