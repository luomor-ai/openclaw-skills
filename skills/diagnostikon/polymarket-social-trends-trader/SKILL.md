---
name: polymarket-social-trends-trader
description: "Trades Polymarket prediction markets on social trend indicators: loneliness indices, mental health policy, drug legalization, and cultural inflection points."
metadata:
  author: Diagnostikon
  version: "1.0"
  displayName: Social Trends & Wellbeing Trader
  difficulty: advanced
---

# Social Trends & Wellbeing Trader

> **This is a template.**
> The default signal is keyword-based market discovery combined with probability-extreme detection — remix it with the data sources listed in the Edge Thesis below.
> The skill handles all the plumbing (market discovery, trade execution, safeguards). Your agent provides the alpha.

## Strategy Overview

Policy calendar-driven: trade markets that resolve on legislative votes or FDA decisions. Entry on announcement, exit before final vote.

## Edge Thesis

Social policy markets are uniquely mis-priced because they attract ideologically motivated traders who bet on what they WANT to happen rather than what evidence suggests. This creates systematic YES overpricing on progressive legislation in red states and NO overpricing on conservative legislation in blue states. Historical passage rates from GovTrack (all US bills since 1973) give a strong base rate to trade against.

### Remix Signal Ideas
- **GovTrack.us API**: https://www.govtrack.us/developers — Bill passage probabilities, sponsor data, committee stage — all free
- **SAMHSA Drug Use Survey data**: https://www.samhsa.gov/data/ — Annual survey data feeding drug policy markets
- **Gallup social trends polling**: https://news.gallup.com/poll/topics.aspx — Public opinion series for legalization, mental health attitudes

## Safety & Execution Mode

**The skill defaults to paper trading (`venue="sim"`). Real trades only with `--live` flag.**

| Scenario | Mode | Financial risk |
|---|---|---|
| `python trader.py` | Paper (sim) | None |
| Cron / automaton | Paper (sim) | None |
| `python trader.py --live` | Live (polymarket) | Real USDC |

`autostart: false` and `cron: null` — nothing runs automatically until you configure it in Simmer UI.

## Required Credentials

| Variable | Required | Notes |
|---|---|---|
| `SIMMER_API_KEY` | Yes | Trading authority. Treat as high-value credential. |

## Tunables (Risk Parameters)

All declared as `tunables` in `clawhub.json` and adjustable from the Simmer UI.

| Variable | Default | Purpose |
|---|---|---|
| `SIMMER_MAX_POSITION` | See clawhub.json | Max USDC per trade |
| `SIMMER_MIN_VOLUME` | See clawhub.json | Min market volume filter |
| `SIMMER_MAX_SPREAD` | See clawhub.json | Max bid-ask spread |
| `SIMMER_MIN_DAYS` | See clawhub.json | Min days until resolution |
| `SIMMER_MAX_POSITIONS` | See clawhub.json | Max concurrent open positions |

## Dependency

`simmer-sdk` by Simmer Markets (SpartanLabsXyz)
- PyPI: https://pypi.org/project/simmer-sdk/
- GitHub: https://github.com/SpartanLabsXyz/simmer-sdk
