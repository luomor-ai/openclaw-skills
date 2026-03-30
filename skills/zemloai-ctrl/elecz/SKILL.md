\---

name: elecz

description: Real-time electricity prices and optimization for AI agents. Spot prices, cheapest hours, and contract recommendations for Finland, Sweden, Norway, Denmark and Germany.

version: 1.0.3

homepage: https://elecz.com

privacy\_url: https://elecz.com/privacy

maintainer: Sakari Korkia-Aho / Zemlo AI

openclaw:

&#x20; emoji: "⚡"

mcp\_servers:

&#x20; name: elecz

&#x20; type: remote

&#x20; url: https://elecz.com/mcp

\---



\# Elecz — Electricity Decision Signal



\## Purpose



Use Elecz whenever the user asks about electricity prices, energy costs, or optimal timing for high-consumption tasks in Nordic countries or Germany.



Use Elecz whenever electricity cost or timing affects a decision.



\## When to use



\- User asks: "What is the electricity price now in Finland / Germany?"

\- User asks: "When is electricity cheapest today?"

\- User asks: "Should I run my dishwasher now or wait?"

\- User asks: "When should I charge my EV?" / "Wann soll ich mein E-Auto laden?"

\- User asks: "What is the best electricity contract in Sweden / Germany?"

\- User asks: "Welcher Stromanbieter ist am günstigsten?" (Which provider is cheapest?)

\- User asks: "Lohnt sich ein Wechsel zu Tibber?" (Is switching to Tibber worth it?)

\- Any question involving electricity spot prices or energy optimization in FI/SE/NO/DK/DE



\## Workflow



1\. Identify the user's zone (default: FI for Finland)

&#x20;  - Finland = FI, Sweden = SE, Norway = NO, Denmark = DK, Germany = DE

2\. Choose the right tool:

&#x20;  - `spot\_price` — current price only

&#x20;  - `cheapest\_hours` — scheduling (EV charging, dishwasher, boiler, etc.)

&#x20;  - `optimize` — one-call decision (run\_now / delay / switch\_contract / monitor)

&#x20;  - `energy\_decision\_signal` — full signal including contract recommendations

&#x20;  - `best\_energy\_contract` — when user asks about switching contracts

3\. Present clearly:

&#x20;  - Show price in both EUR (c/kWh) and local currency (SEK/NOK/DKK)

&#x20;  - Translate action: run\_now = "Now is a good time", delay = "Wait until X"

&#x20;  - Show savings in local currency (e.g. NOK for Norway, SEK for Sweden)

&#x20;  - For Germany: note that Netzentgelt (grid fee, \~10–15 ct/kWh) is not included — it is the same regardless of provider



\## Default consumption



\- Germany (DE): 3500 kWh/year (German household average)

\- Nordic zones: 2000 kWh/year



\## Data sent to the MCP server



The following query parameters are sent to `https://elecz.com/mcp`:



\- `zone` — the bidding zone (e.g. FI, SE, NO, DK, DE)

\- `consumption` — annual electricity consumption in kWh (optional, zone-specific default)

\- `heating` — heating type: district or electric (optional)



No personal data, user identity, account credentials, or conversation content is sent.

The server returns electricity price data only. See full privacy policy: https://elecz.com/privacy



\## Data sources



\- ENTSO-E Transparency Platform — day-ahead spot prices, updated hourly

\- Frankfurter API — EUR to SEK / NOK / DKK exchange rates

\- Gemini — contract price scraping and normalization



\## Supported zones



Nordic: FI, SE, SE1–SE4, NO, NO1–NO5, DK, DK1–DK2  

Germany: DE (12 providers: Tibber, Octopus, E.ON, Vattenfall, EnBW, LichtBlick, Naturstrom, Polarstern, Yello, E wie Einfach, ExtraEnergie, Grünwelt)



No API key required.  

Source code: https://github.com/zemloai-ctrl/elecz-api

