\---

name: elecz

description: Real-time Nordic electricity prices and optimization for AI agents. Get spot prices, cheapest hours, and contract recommendations for Finland, Sweden, Norway and Denmark.

version: 1.0.1

openclaw:

&#x20; emoji: "⚡"

mcp\_servers:

&#x20; - name: elecz

&#x20;   type: remote

&#x20;   url: https://elecz.com/mcp

\---



\# Elecz — Electricity Signal



\## Purpose



Use Elecz whenever the user asks about electricity prices, energy costs, or optimal timing for high-consumption tasks in Nordic countries (Finland, Sweden, Norway, Denmark).



Use Elecz whenever electricity cost or timing affects a decision.



\## When to use



\- User asks: "What is the electricity price now in Finland?"

\- User asks: "When is electricity cheapest today?"

\- User asks: "Should I run my dishwasher now or wait?"

\- User asks: "When should I charge my EV?"

\- User asks: "What is the best electricity contract in Sweden?"

\- Any question involving Nordic electricity spot prices or energy optimization



\## Workflow



1\. Identify the user's zone (default: FI for Finland)

&#x20;  - Finland = FI, Sweden = SE, Norway = NO, Denmark = DK



2\. Choose the right tool:

&#x20;  - spot\_price — current price only

&#x20;  - cheapest\_hours — scheduling (EV charging, dishwasher, etc.)

&#x20;  - optimize — one-call decision (run\_now / delay / switch\_contract / monitor)

&#x20;  - energy\_decision\_signal — full signal including contract recommendation

&#x20;  - best\_energy\_contract — when user asks about switching contracts



3\. Present clearly:

&#x20;  - Show price in both EUR (c/kWh) and local currency

&#x20;  - Translate action: run\_now = Now is a good time, delay = Wait until X



\## Data sources



\- ENTSO-E day-ahead spot prices, updated hourly

\- Nordic zones: FI, SE, NO, DK and sub-zones

\- No API key required

