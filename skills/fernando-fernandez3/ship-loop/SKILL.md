---
name: ship-loop
description: >
  Run a chained build→ship→verify→notify pipeline for multi-segment feature work.
  Use when implementing multiple features in sequence, each as a coding agent task
  that gets committed, deployed, and verified before moving to the next. Prevents
  dropped handoffs between segments.
metadata:
  openclaw:
    emoji: "🚢"
    version: "2.0.1"
    requires:
      bins: ["git", "bash", "curl"]
    trigger_phrases:
      - "ship loop"
      - "keep building"
      - "run the next segment"
      - "build these features"
      - "multi-feature pipeline"
      - "ship these segments"
---

# Ship Loop

Orchestrate multi-segment feature work as an automated pipeline. Each segment runs a coding agent, passes preflight checks (build + lint + test), ships the result with explicit file staging, verifies the deploy on production, and moves to the next segment. No manual handoffs, no unsafe commits, no skipped gates.

## When to Use

- Building multiple features for a project in sequence
- Any work that follows: code → preflight → commit → deploy → verify → next
- When you need checkpointing so progress survives session restarts
- When you want rollback safety with tagged deploys

## Prerequisites

- A git repository with a remote (GitHub, GitLab, etc.)
- A deployment pipeline triggered by push (Vercel, Netlify, GitHub Pages, or custom)
- A coding agent CLI (Claude Code, Codex, OpenCode, etc.) — configured via `agent_command` in SHIPLOOP.yml
- The OpenClaw `process` tool for session management

## Pipeline Definition (SHIPLOOP.yml)

Create a `SHIPLOOP.yml` in the project root. This is the single source of truth for the pipeline.

### Schema

```yaml
# SHIPLOOP.yml
project: "Project Name"
repo: /absolute/path/to/project
site: https://production-url.com

# Platform: vercel | netlify | static | custom
platform: vercel

# Branch strategy: direct-to-main | per-segment
branch: direct-to-main

# Verification
verify:
  # Routes to check for HTTP 200
  routes:
    - /
    - /api/health
  # Optional: text or element that MUST appear in response body
  marker: "data-version"
  # Optional: custom health endpoint (checked first if set)
  health_endpoint: /api/health
  # Optional: response header to check (e.g. Vercel deployment ID)
  deploy_header: x-vercel-deployment-url

# Coding agent command (user-configured, no default)
# The command receives the prompt via stdin.
agent_command: "claude --print --permission-mode bypassPermissions"
# Other examples:
#   agent_command: "codex exec --full-auto"
#   agent_command: "opencode --auto"
#   agent_command: "cat > /dev/null && custom-agent run"

# Timeouts (in seconds)
timeouts:
  agent: 900      # 15 minutes — max time for coding agent
  deploy: 300     # 5 minutes — max time waiting for deploy
  verify: 180     # 3 minutes — max time for verification checks

# Preflight commands (all must pass before commit)
preflight:
  build: "npm run build"
  lint: "npm run lint"
  test: "npm run test"

# Files/patterns to NEVER commit (in addition to built-in blocklist)
blocked_patterns:
  - "*.pem"
  - "terraform.tfstate"

# Rollback
rollback:
  last_good_commit: null   # Updated automatically after each successful deploy
  last_good_tag: null       # Updated automatically

# Segments
segments:
  - name: "feature-name"
    status: pending          # pending | running | shipped | failed
    prompt: |
      Your full coding agent prompt here.
      Multi-line YAML block scalar.
    depends_on: []           # Optional: list of segment names that must ship first
    commit: null             # Populated after shipping (git SHA)
    deploy_url: null         # Populated after verification (live URL)
    tag: null                # Git tag for this deploy

  - name: "next-feature"
    status: pending
    prompt: |
      Next prompt here.
    depends_on:
      - "feature-name"      # Won't run until feature-name is shipped
    commit: null
    deploy_url: null
    tag: null
```

### Built-in Blocked Patterns

The ship script ALWAYS rejects these, regardless of `blocked_patterns` config:

```
.env, .env.*, *.key, *.pem, *.p12, *.pfx, *.secret,
id_rsa, id_ed25519, *.keystore, credentials.json,
service-account*.json, token.json, .npmrc (with tokens),
node_modules/, .git/, __pycache__/, .pytest_cache/
```

## Script Templates

This skill includes working script templates in the `scripts/` directory of the skill folder. Copy them to your project's `scripts/` directory and customize:

```bash
# From the skill directory (resolved by the agent):
cp scripts/preflight.sh   <repo>/scripts/preflight.sh
cp scripts/ship.sh         <repo>/scripts/ship.sh
cp scripts/verify-deploy.sh <repo>/scripts/verify-deploy.sh
cp scripts/run-segment.sh  <repo>/scripts/run-segment.sh
chmod +x <repo>/scripts/*.sh
```

Customize the copied scripts for your project (build commands, verify logic, etc.).

## Execution Flow

When asked to "run the ship loop", "keep building", or "build these features":

### 1. Read SHIPLOOP.yml

Parse the YAML. Find the first segment with `status: pending` whose `depends_on` are all `shipped`.

### 2. Update Status

Set the segment's status to `running` in SHIPLOOP.yml.

### 3. Run the Segment

The segment orchestration works as follows. The agent writes the prompt to a temp file (NEVER passes it as a shell argument) and runs the segment script:

```bash
# Write prompt to temp file to avoid shell injection
PROMPT_FILE=$(mktemp /tmp/shiploop-prompt-XXXXXX.txt)
cat > "$PROMPT_FILE" << 'PROMPT_EOF'
<segment prompt content here>
PROMPT_EOF

cd <repo> && bash scripts/run-segment.sh "<segment-name>" "$PROMPT_FILE"
```

Run this as a background `exec` command:

```
exec(command="...", background=true, workdir="<repo>")
```

### 4. Poll Until Complete

Use the OpenClaw `process` tool to wait for completion. This is an agent-level tool call, NOT a shell command:

```
process(action="poll", sessionId="<session-id-from-exec>", timeout=30000)
```

Poll in a loop. Each poll waits up to 30 seconds. Check if the process has exited. If it's still running and the `agent_timeout` has elapsed, kill the process and mark the segment as failed.

### 5. Check Results

After the process exits:
- **Exit code 0**: Segment succeeded. Update SHIPLOOP.yml:
  - Set `status: shipped`
  - Record `commit` (the git SHA from ship.sh output)
  - Record `deploy_url` (the verified URL)
  - Record `tag` (the git tag applied)
  - Update `rollback.last_good_commit` and `rollback.last_good_tag`
- **Non-zero exit**: Segment failed. Set `status: failed`. Do NOT continue to next segment.

### 6. Message the User

Send a concise update after each segment.

### 7. Continue the Chain

If the segment shipped successfully, immediately find the next `pending` segment (checking `depends_on`) and start it. Do NOT wait for the user to ask.

### 8. Repeat

Until all segments are `shipped` or one `fails`.

## Rollback

Every successful deploy is tagged with `shiploop/<segment-name>/<timestamp>`. If a deploy causes issues:

### Automatic Rollback Info

SHIPLOOP.yml tracks `rollback.last_good_commit` and `rollback.last_good_tag`. After any failure, tell the user:

```
Last known good state: <tag> (<commit>)
To rollback: git revert HEAD && git push
Or hard rollback: git reset --hard <last_good_commit> && git push --force
```

### Manual Rollback

```bash
# Revert to last known good deploy
git checkout <last_good_tag>
git push origin HEAD:main --force

# Or revert just the bad commit
git revert <bad_commit> && git push
```

## Branch Strategy

### `direct-to-main` (default)

All commits go straight to main. Fast, but risky. Rollback via git revert or tags.

**Warning**: This means every commit immediately deploys. Only use for projects with good CI/CD and the ability to quickly revert.

### `per-segment`

Each segment gets its own branch: `shiploop/<segment-name>`. After verification, the agent merges to main.

```
shiploop/dark-mode → main (after verify)
shiploop/auth-flow → main (after verify)
```

This is safer but slower. Use for production systems where you want PR-style isolation.

## Crash Recovery

On session start or resume, check for interrupted work:

1. **Read SHIPLOOP.yml** — look for segments with `status: running`
2. **Check if the process is still alive**:
   ```
   process(action="list")
   ```
   Look for a session matching the segment name.
3. **If process is running**: Resume polling it.
4. **If process is NOT found but status is `running`**: The session crashed mid-segment.
   - Mark the segment as `failed`
   - Report to the user: "Segment X was interrupted. The code changes may be partially applied. Review the diff before retrying."
   - Do NOT auto-retry without user approval.

## Platform-Specific Verification

### Vercel

- Check `x-vercel-deployment-url` header for new deployment ID
- Poll until deployment URL changes from previous value
- Verify routes return 200 with new deployment

### Netlify

- Check `x-nf-request-id` header
- Poll deploy API: `https://api.netlify.com/api/v1/sites/<site-id>/deploys?per_page=1`
- Wait for latest deploy status to be `ready`

### Static / GitHub Pages

- Simple HTTP 200 check on all routes
- Check for `marker` text in response body
- Allow extra time (GitHub Pages can take 2-3 minutes)

### Custom

- Uses `health_endpoint` if configured
- Falls back to HTTP 200 + marker check
- Override `verify-deploy.sh` entirely for custom logic

## Critical Rules

### Never Break the Chain

When a segment completes, you MUST immediately:
1. Update SHIPLOOP.yml
2. Message the user
3. Start the next eligible segment (respecting `depends_on`)

Do NOT wait for the user to check in.

### Preflight is Mandatory

Every segment MUST pass `preflight.sh` (build + lint + test) before any files are committed. If preflight fails, the segment fails. No exceptions. No "ship now, fix later."

### Explicit File Staging Only

NEVER use `git add -A` or `git add .`. The ship script stages only files that were actually modified (from `git diff`). A pre-commit check scans staged files against the blocklist and aborts if any sensitive files are detected.

### Prompts via File, Never Shell Arguments

Segment prompts are written to a temp file and passed as a file path. This prevents shell injection from prompt content. The temp file is cleaned up after use.

### Checkpoint Everything

Write status to SHIPLOOP.yml after every state change. If the session restarts, read SHIPLOOP.yml to find where you left off.

### Handle Failures

If a segment fails:
1. Update status to `failed` in SHIPLOOP.yml
2. Include rollback information in the failure message
3. Message the user with the error and what to do
4. Do NOT auto-retry without user approval
5. Do NOT skip to the next segment

## Starting a Ship Loop

When the user describes multiple features to build:

1. Create `SHIPLOOP.yml` with all segments defined
2. Copy and customize the scripts from this skill's `scripts/` directory
3. Ask user to confirm the plan
4. Start running with the first eligible segment

## Resuming a Ship Loop

On session start or when asked about progress:

1. Read `SHIPLOOP.yml`
2. Report status of all segments (with commit SHAs and deploy URLs for shipped ones)
3. Run crash recovery checks for any `running` segments
4. If there are `pending` segments with met dependencies, offer to continue

## Complete Worked Example

### User Request

> "Build these 3 features for my portfolio site"

### Generated SHIPLOOP.yml

```yaml
project: "Portfolio Site"
repo: /home/user/portfolio
site: https://portfolio.vercel.app

platform: vercel
branch: direct-to-main
agent_command: "claude --print --permission-mode bypassPermissions"

verify:
  routes:
    - /
    - /projects
    - /contact
  marker: "data-version"
  deploy_header: x-vercel-deployment-url

timeouts:
  agent: 900
  deploy: 300
  verify: 180

preflight:
  build: "npm run build"
  lint: "npx eslint . --max-warnings 0"
  test: "npm test -- --passWithNoTests"

blocked_patterns: []

rollback:
  last_good_commit: null
  last_good_tag: null

segments:
  - name: "dark-mode"
    status: pending
    prompt: |
      Add dark mode support to the portfolio site.
      - Use CSS custom properties for theming
      - Add a toggle button in the header
      - Respect prefers-color-scheme
      - Persist preference in localStorage
      - Ensure all pages work in both modes
    depends_on: []
    commit: null
    deploy_url: null
    tag: null

  - name: "contact-form"
    status: pending
    prompt: |
      Add a working contact form to /contact.
      - Use a simple form with name, email, message fields
      - Submit to /api/contact serverless function
      - Show success/error states
      - Add basic validation (required fields, email format)
    depends_on: []
    commit: null
    deploy_url: null
    tag: null

  - name: "project-filters"
    status: pending
    prompt: |
      Add filtering to the /projects page.
      - Filter by technology tag (React, Python, etc.)
      - Filter by year
      - URL query params for shareable filter state
      - Animated transitions when filtering
    depends_on:
      - "dark-mode"
    commit: null
    deploy_url: null
    tag: null
```

### Execution Output

```
🚢 Ship loop started: Portfolio Site (3 segments)

🔄 Segment 1/3: dark-mode — running agent...
   ⏱ Agent completed in 4m 22s
   ✅ Preflight passed (build: ok, lint: ok, test: ok)
   📦 Committed: a1b2c3d — "feat: dark mode support"
   🏷 Tagged: shiploop/dark-mode/20260323-001500
   🔍 Verifying deploy...
   ✅ Deploy verified (new deployment: dpl_abc123)
✅ Segment 1/3: dark-mode — shipped and verified

🔄 Segment 2/3: contact-form — running agent...
   ⏱ Agent completed in 6m 15s
   ✅ Preflight passed (build: ok, lint: ok, test: ok)
   📦 Committed: d4e5f6a — "feat: contact form with API endpoint"
   🏷 Tagged: shiploop/contact-form/20260323-002200
   🔍 Verifying deploy...
   ✅ Deploy verified (new deployment: dpl_def456)
✅ Segment 2/3: contact-form — shipped and verified

🔄 Segment 3/3: project-filters — running agent...
   (depends_on: dark-mode ✅)
   ⏱ Agent completed in 5m 48s
   ✅ Preflight passed (build: ok, lint: ok, test: ok)
   📦 Committed: 7g8h9i0 — "feat: project page filters"
   🏷 Tagged: shiploop/project-filters/20260323-003100
   🔍 Verifying deploy...
   ✅ Deploy verified (new deployment: dpl_ghi789)
✅ Segment 3/3: project-filters — shipped and verified

🏁 Ship loop complete! 3/3 segments shipped.
✅ 1. dark-mode       — a1b2c3d — https://portfolio.vercel.app
✅ 2. contact-form    — d4e5f6a — https://portfolio.vercel.app/contact
✅ 3. project-filters — 7g8h9i0 — https://portfolio.vercel.app/projects
All live at https://portfolio.vercel.app
Last good commit: 7g8h9i0 | Tag: shiploop/project-filters/20260323-003100
```

## Status Messages

After each segment:
```
✅ Segment 3/7: Dark mode — shipped (a1b2c3d)
🔄 Starting Segment 4/7: Trip management...
```

On failure:
```
❌ Segment 4/7: Trip management — FAILED (preflight: lint errors)
   Last good: shiploop/dark-mode/20260323-001500 (a1b2c3d)
   Run `git diff` to see uncommitted changes.
   Awaiting your call — retry or skip?
```

After all segments:
```
🏁 Ship loop complete! 7/7 segments shipped.
✅ 1. Display name fix  — a1b2c3d
✅ 2. Dark mode          — d4e5f6a
✅ 3. Chat UX            — 7g8h9i0
...
All live at https://production-url.com
```
