---
name: nba-today-pulse
description: Timezone-aware NBA daily intelligence with compact mixed-status day view, same-day stat leaders, dedicated pregame/live/post routes, independent injury reports, and direct tool-output delivery.
user-invocable: true
metadata: {"openclaw":{"skillKey":"nba-today-pulse","requires":{"bins":["python3"]}}}
---

# NBA Today Pulse v7

Version: `1.0.7`

Get a compact mixed-status NBA day view, same-day stat leaders, dedicated pregame/live/post reports, and independent injury reports in one skill. This release keeps the public runtime concise through deterministic routing, explicit timezone injection, shared `gameContext`, and direct tool-output delivery.

Do not invent scores, injuries, lineups, player stats, or matchup reasons.

## Single Execution Command

Production paths must resolve timezone first and inject `--tz` explicitly.

If the user message already includes a timezone or city:

```bash
python3 {baseDir}/tools/nba_today_command.py --command "<raw request>" --tz "<resolved timezone>"
```

If the user message does not include a timezone but the runtime already knows the user's timezone preference:

```bash
python3 {baseDir}/tools/nba_today_command.py --command "<raw request>" --tz "<resolved timezone>"
```

Only the single branch that asks the user for timezone is allowed to omit `--tz`.

Relative-date requests must stay grounded in the same injected timezone:

```bash
python3 {baseDir}/tools/nba_today_command.py --command "今日NBA赛况" --tz "Asia/Shanghai"
python3 {baseDir}/tools/nba_today_command.py --command "明天NBA赛况" --tz "America/Los_Angeles"
python3 {baseDir}/tools/nba_today_command.py --command "今天比赛谁得分最高" --tz "Asia/Shanghai"
```

## Intent Mapping

- `day`: today's or tomorrow's NBA slate, daily status, all games, mixed-status day view
- `stats_day`: today's NBA stats, who scored the most today, best performance today, rebounds leader, assists leader, most threes, largest margin
- `pregame`: preview, pregame, prediction, matchup preview, all-games preview, multi-matchup preview
- `live`: live game, in-game direction, current momentum, current game flow
- `post`: recap, review, postgame, what happened in the game
- `injury`: injury report, team injuries, matchup injury report

Injury requests take priority over preview phrasing. Explicit preview phrasing takes priority over generic analysis wording.

## Fixed Output Shapes

- `stats_day`: Best Performance → Top Scorer → Top Rebounder → Top Assists → Most Threes → Double/Triple Doubles → Largest Margin → Summary
- `pregame`: Game Info → Lineups & Key Players → Injuries → Team Form → Prediction Analysis → Summary
- `live`: Game Info → Lineups & Key Players → Injuries → Live Momentum → Team Comparison → Key Player Stats → Play Digest → Summary
- `post`: Game Info → Starting Lineups → Result & Flow Summary → Key Performances → Team Comparison → Injuries → Turning Point → Summary
- `day`: grouped cards ordered by `Live → Final → Upcoming`; compact final-game cards stay compact by default and do not dump full team boxscore lines
- `injury`: Fact Layer → Analysis Layer

## Timezone Behavior

- First use any explicit timezone or city in the user message
- Otherwise use a valid timezone input supplied by the runtime and inject it through `--tz`
- If no timezone can be resolved, ask once for a city or IANA timezone and stop there
- If the request already carries relative-date semantics, do not invent a conflicting external `--date`
- Never explain internal runtime provenance or inspect memory files

## Parameter Mapping Examples

- `今日NBA赛况，按上海时区` -> `--tz Asia/Shanghai`
- `今天比赛谁得分最高，按上海时区` -> `--tz Asia/Shanghai`
- `明天NBA赛况，按洛杉矶时区` -> `--tz America/Los_Angeles`
- `Show today's NBA games in America/Los_Angeles` -> `--tz America/Los_Angeles`
- runtime-known timezone, no explicit timezone in the message -> `--tz <resolved timezone>`

## Data Access Behavior

This skill uses bundled providers to fetch public ESPN and NBA data, and it reads official NBA injury-report PDFs for supported injury-report requests. That outbound network access is part of the normal product behavior. It is not generic web search, and it must not be replaced with freeform browsing or unrelated host inspection.

## Output Rules

- Run only the bundled `nba_today_command.py` entrypoint
- Do not switch scripts, reconstruct parameters, or retry alternate command formats
- On success, return the tool output directly
- Prefer compact cards and concise sections; `day` and `post` should stay readable in Chinese and English without raw stat dumps
- On user-fixable issues such as missing timezone or no matching game, return the final short tool result directly
- Keep `AWAY @ HOME` ordering unchanged
- Match the user's language; Chinese output should prefer Chinese team names and controlled player-name mappings
- Keep relative dates such as `today / tomorrow / 今天 / 明天 / 今日 / 明日` grounded in the resolved requestor timezone

## Forbidden Behaviors

- Do not expose process narration, tool exploration, file inspection, or command retry chatter
- Do not mention internal memory files, host runtime details, or prior-record reasoning
- Do not use web search or generic browsing to patch missing facts unless the user explicitly asks for online verification
- Do not inspect unrelated host files or request secrets, API keys, tokens, or credentials
- Do not add betting advice, odds, spreads, totals, or gambling language
- Do not add future speculation, unverified lineup guesses, or unsupported injury assumptions
- Do not rewrite the tool result into a different structure
