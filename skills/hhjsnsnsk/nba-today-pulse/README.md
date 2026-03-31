# NBA Today Pulse v7

Version: `1.0.7`

`nba-today-pulse-v7` packages the current `NBA_TR` runtime into a public ClawHub bundle with compact mixed-status day view, same-day stat leaders, dedicated pregame/live/post routes, independent injury reports, and timezone-aware local-date routing. This release also tightens the default `day` and `post` output shapes so long Chinese stat dumps are replaced with cleaner, lower-noise sections.

This release keeps the stable public skill key `nba-today-pulse` rather than registering a new skill identity.

## Highlights

- Mixed-status `dayView` that can show upcoming, live, and final games in one response
- Compact `stats_day` cards for requests such as `today's NBA stats`, `who scored the most today`, and `today's best performance`
- Dedicated `pregame`, `live`, and `post` routing instead of a single generic game scene
- Cleaner default `post` recap layout with starting lineups, key performances, compact team comparison, injuries, turning point, and summary
- More readable Chinese stat lines for key players and tighter final-game day cards
- Shared `gameContext` foundation used across day, pregame, live, and post outputs
- Review-clean public bundle behavior: in-memory caching only, no credentials, no private paths, no internal memory-file references

## Bundle Layout

```text
nba-today-pulse-v7/
  README.md
  SKILL.md
  TOOLS.md
  tools/
    cache_store.py
    entity_guard.py
    nba_advanced_report.py
    nba_common.py
    nba_day_snapshot.py
    nba_game_full_stats.py
    nba_game_live_context.py
    nba_game_locator.py
    nba_game_preview_context.py
    nba_game_recap_context.py
    nba_game_rosters.py
    nba_head_to_head.py
    nba_play_digest.py
    nba_player_names.py
    nba_pulse_core.py
    nba_pulse_router.py
    nba_team_form_snapshot.py
    nba_team_injury_report.py
    nba_team_roster.py
    nba_teams.py
    nba_today_command.py
    nba_today_report.py
    verify_nba_tr.py
    provider_espn.py
    provider_nba.py
    provider_nba_injuries.py
    timezone_resolver.py
    vendor_pdf_text.py
```

## Installation

This bundle is intended for ClawHub publishing and OpenClaw installation as a self-contained natural-language skill.

At runtime, the public entrypoint is:

```bash
python3 {baseDir}/tools/nba_today_command.py --command "<raw request>"
```

Known-timezone production paths should inject `--tz` explicitly:

```bash
python3 {baseDir}/tools/nba_today_command.py --command "<raw request>" --tz "<resolved timezone>"
```

## Runtime Requirements

- `python3`
- outbound network access to ESPN public JSON endpoints
- outbound network access to NBA.com public endpoints used for live, stats, and injury-report fallbacks
- outbound access to official NBA injury-report PDFs for supported injury-report requests

No credentials are required. The bundle only uses public data sources.

Optional timezone environment variables:

- `OPENCLAW_USER_TIMEZONE`
- `OPENCLAW_TIMEZONE`
- `USER_TIMEZONE`
- `TZ`

Notes:

- these are optional runtime/configuration knobs, not secrets
- the public bundle keeps cache behavior in memory only
- the public bundle does not expose cache-specific environment variables
- outbound requests are limited to public NBA/ESPN data and official NBA injury-report documents required for the supported features

## Supported Request Shapes

- Daily NBA status
- Day-level NBA stats for the resolved local date
- Single-game preview and prediction
- Multi-matchup preview and all-games preview
- Single-game live momentum and current state
- Single-game postgame recap
- Team or matchup injury report

## Example Prompts

- `Show today's NBA games in America/Los_Angeles`
- `Show today's NBA stats in Asia/Shanghai`
- `Who scored the most today in Asia/Shanghai?`
- `Preview tomorrow's Celtics vs Hornets game in Asia/Shanghai`
- `Show today's Lakers live game flow in Asia/Shanghai`
- `Recap today's Knicks vs Thunder game in Asia/Shanghai`
- `Show tomorrow's Pistons injury report in Asia/Shanghai`
- `今日NBA赛况，按上海时区`
- `明天NBA赛况，按上海时区`
- `今天比赛谁得分最高，按上海时区`
- `复盘今天尼克斯vs雷霆，按上海时区`

## Packaging Notes

- This public bundle remains skill-only and does not expose a plugin command surface
- All runtime scripts are self-contained and resolve imports from the local `tools/` directory
- `stats_day` is day-level only: it summarizes completed games for the resolved local date and is not a season leaderboard
- The public bundle contains no private deployment paths, host addresses, SSH commands, or internal memory-file references
- The public bundle does not request or require credentials, secrets, or host-specific API keys
