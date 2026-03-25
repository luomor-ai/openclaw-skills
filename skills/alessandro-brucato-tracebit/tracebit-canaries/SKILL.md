---
name: tracebit-canaries
description: >
  End-to-end Tracebit security canary deployment and autonomous threat response
  for AI agents. Deploys decoy canary tokens (fake credentials that alert on use),
  monitors for alerts via Gmail heartbeat polling, and runs read-only incident
  investigation with human notification. All sensitive operations (canary deployment,
  canary rotation) require explicit human confirmation. Tracebit Community Edition
  is free.
metadata:
  openclaw:
    emoji: "🐦"
    homepage: https://github.com/tracebit-com/tracebit-community-cli
    primaryEnv: TRACEBIT_API_TOKEN
    requires:
      bins:
        - gog
        - curl
        - jq
        - python3
      env:
        - TRACEBIT_API_TOKEN
      config:
        - plugins.messaging
        - plugins.gog.accounts
    permissions:
      - gmail:read (via gog — read-only search for Tracebit alert emails; requires user's pre-authorized Gmail OAuth)
      - messaging:send (via plugins.messaging — sends notifications to user's own channel only)
    keywords:
      - security
      - canary-tokens
      - honeytokens
      - prompt-injection-detection
      - incident-response
      - deception
      - agent-security
  creator:
    org: Tracebit
    source: https://github.com/tracebit-com/tracebit-community-cli
  safety:
    posture: human-gated-deployment
    red_lines:
      - no-autonomous-writes-to-credential-locations
      - no-credential-exfiltration
      - no-messages-to-external-recipients
      - no-remediation-without-human-approval
    runtime_constraints:
      all-access-requires-upfront-user-consent: true
      canary-deployment-requires-human-confirmation: true
      canary-rotation-requires-human-acknowledgement: true
      credential-files-written-only-by-cli-not-skill: true
      gmail-access-read-only: true
      gmail-access-requires-user-consent: true
      notifications-to-user-channel-only: true
      signup-password-never-in-conversation-output: true
---

# Tracebit Canaries Skill

## What This Skill Does

End-to-end security canary coverage — from signup to autonomous incident response. You (the agent) perform the mechanical steps (form filling, CLI commands, config edits). Ask the human for confirmation before any operation that writes to sensitive locations or takes remediation actions.

The Tracebit CLI runs a background daemon that auto-refreshes credentials — true "set and forget." When a canary fires, the heartbeat inbox check detects the alert email, then immediately notifies the human, investigates, and reports.

Tracebit Community Edition is free at https://community.tracebit.com

---

## Security & Transparency

This skill is user-initiated and runs under user supervision. The user can interrupt or cancel at any step.

**Prerequisite**: `gog` must be installed and authenticated with the user's Gmail before activation.

**What the skill itself writes to disk:**
- `memory/security-incidents.md` — append-only incident log (only on alert)
- `HEARTBEAT.md` — appends canary check block
- `/tmp/tracebit-credentials-*.txt` — temporary signup password (600 perms, deleted after use)

**What the Tracebit CLI writes (with human confirmation):**
The `tracebit deploy` command places decoy canary tokens in standard credential locations. The skill asks the human for explicit approval before running this command. The CLI is open-source ([source](https://github.com/tracebit-com/tracebit-community-cli)) — see its documentation for the exact file locations and behavior.

**What it reads** — all read-only:
- Gmail inbox via `gog` (Tracebit emails only; `gog` pre-authorized by user)
- `memory/` files (during incident investigation, to check recent activity)

**External endpoints** — only two:
- `community.tracebit.com` (account and canary management)
- `github.com/tracebit-com/tracebit-community-cli` (one-time CLI download, SHA256-verified)

**Background process**: the Tracebit CLI daemon refreshes canary token expiry — no other network calls or file access. Fully removable (see "Local Footprint & Full Removal").

**Key constraints**:
- **Canary deployment requires explicit human confirmation** — the agent explains what the CLI will do and waits for approval before running `tracebit deploy`
- The skill itself never writes to credential locations — it delegates to the open-source Tracebit CLI
- Notifications go only to the user's own messaging channel — never to external recipients
- Canary rotation requires human acknowledgement — the agent does not remediate autonomously
- The signup password is never shown in conversation output — written to a temp file only
- Everything installed is fully reversible (see "Local Footprint & Full Removal")

---

## Execution Principles

**The human activates this skill, supervises the process, and can interrupt or cancel at any step.** The agent's role is to handle the mechanical steps (form filling, CLI commands, config edits) so the human doesn't have to do them manually — not to bypass oversight.

- **Browser steps**: use the OpenClaw browser tool — do not require or assume a system browser
- **CLI steps**: run via exec
- **Config changes**: use gateway tools programmatically
- **Ask the human when needed**: 2FA codes, CAPTCHAs, or any step that fails unexpectedly
- **Never suppress errors or skip steps silently** — always report what happened so the human can make informed decisions

---

## Definition of Done

**You are NOT done until every item below is checked. Do not report success to the human until all 6 are complete.**

```
[ ] Step 1: Tracebit account created and dashboard confirmed in browser
[ ] Step 2: CLI installed and `tracebit --version` returns a version number
[ ] Step 3: CLI authenticated — `tracebit auth status` prints credentials are valid
[ ] Step 4: All 5 canary types deployed — `tracebit show` shows all 5 active
[ ] Step 5: `tracebit show` confirms all canaries active
[ ] Step 6: Heartbeat canary check block added to HEARTBEAT.md
```

A satisfying intermediate result (e.g. `tracebit show` showing 5 active canaries) is **not** completion. The alert detection pipeline (Step 6) is what makes canaries useful. Canaries that fire but notify no one provide no protection.

---

## End-to-End Setup

**Before starting, confirm consent with the human:**

```
This skill needs the following access to set up and monitor canary tokens:

1. Gmail (read-only) — to retrieve the Tracebit signup confirmation code
   and to check for canary alert emails during each heartbeat (~30 min).
   Uses your pre-authorized gog account. No emails are sent, deleted, or modified.

2. Messaging — to send canary alert notifications to you via your configured
   OpenClaw messaging channel. No messages are sent to anyone else.

3. Tracebit CLI — to deploy decoy canary tokens (with your confirmation at
   that step) and manage your Tracebit account.

May I proceed with this access? (yes/no)
```

**Do NOT proceed until the human confirms.** If they decline, stop and report the skill as not activated.

---

### Step 1: Sign Up

**You do this using the browser tool** — not any system-installed browser.

```
1. Get the Gmail address: gog auth list
2. Generate a strong random password (20+ chars, mixed case, digits, symbols):
   python3 -c "import secrets, string; chars = string.ascii_letters + string.digits + '!@#\$%^&*'; print(''.join(secrets.choice(chars) for _ in range(24)))"
   Do NOT display the password in conversation output or logs.
   Write it to a temporary file with restricted permissions:
   TMPFILE=$(mktemp /tmp/tracebit-credentials-XXXXXX.txt) && chmod 600 "$TMPFILE"
   echo "Tracebit password: <PASSWORD>" > "$TMPFILE"
   Remember the file path for the completion report.
3. Use the browser tool to navigate to: https://community.tracebit.com
4. Take a snapshot to see the page
5. Click "Sign up with email" (NOT "Sign in with Google" — email signup avoids OAuth loops)
6. Enter the Gmail address and the generated password
7. Submit — you will be redirected to a "Confirm your account" page asking for a code
8. Retrieve the code from Gmail:
   gog gmail search 'from:tracebit newer_than:5m' --account YOUR@gmail.com --max 3
   Then read the latest message to get the code.
   ⚠️ If gog returns an error: do NOT attempt gog auth add or any OAuth flow — gog is already
   configured. Instead, use the browser tool: navigate to https://mail.google.com (already
   logged in from the signup flow) and find the confirmation email there.
9. Enter the code in the browser and confirm
10. Take a snapshot — confirm the Tracebit "Welcome" onboarding dashboard has loaded
```

**Password handoff**: the password was written to a temporary file during Step 1. In your completion report, tell the user:
1. The password is in the temp file (provide the path)
2. Open the file, copy the password, and log into https://community.tracebit.com
3. Go to Settings → Change Password and set a personal password
4. Delete the temp file: `rm <path>` (or it will be cleaned up on next reboot)

**Error cases:**
- **Email already registered**: go directly to Step 3, log in with email credentials
- **CAPTCHA on the form**: take a screenshot, read the text yourself, type it in. Only ask the human if you cannot read it.
- **Confirmation code not arriving**: in the browser tool, check the Gmail spam folder, wait 60s, then click "Resend code" on the Tracebit page

---

### Step 2: Install the CLI

**You do this via exec.**

```bash
bash scripts/install-tracebit.sh
```

Verify:
```bash
tracebit --version
```

If the script fails, install manually from https://github.com/tracebit-com/tracebit-community-cli/releases/latest:
- **Linux**: download `install-tracebit-linux` and run `bash install-tracebit-linux`
- **macOS arm64**: download `install-tracebit-osx-arm.pkg` and run `sudo installer -pkg install-tracebit-osx-arm.pkg -target /`
- **macOS x64**: download `install-tracebit-osx-x64.pkg` and run `sudo installer -pkg install-tracebit-osx-x64.pkg -target /`

---

### Step 3: Authenticate the CLI

**You do this. Do NOT check what browser is installed on the machine — it is irrelevant. Use the OpenClaw browser tool for all web steps.**

The `tracebit auth` command starts a local HTTP listener on `localhost:5442`, prints a login URL, and waits. You open that URL in the browser tool, authorize, and the OAuth callback delivers the token directly to the waiting process.

```bash
# Run tracebit auth in background so the local listener stays alive
tracebit auth > /tmp/tracebit-auth.log 2>&1 &
TRACEBIT_PID=$!
sleep 3
cat /tmp/tracebit-auth.log
```

The output contains:
```
Opening https://community.tracebit.com/cli-login in your browser
Waiting for authorization...
```

Then:
1. Use the **browser tool** to open `https://community.tracebit.com/cli-login`
2. You will see "Do you wish to authorize the Tracebit CLI?" — click **Authorise**
3. The page redirects to `localhost:5442/callback` — the CLI receives the token automatically
4. The log will show: `Successfully logged into Tracebit`

Verify:
```bash
tracebit auth status
# Should print: Tracebit credentials are valid
```

#### Fallback: API token (if the OAuth callback fails)

1. Use the browser tool to open `https://community.tracebit.com`
2. Sign in, then navigate to Settings → API Keys → Create new token
3. Copy the token value
4. Run `tracebit auth --token` and provide the token when prompted

---

### Step 4: Deploy All Canaries

**⚠️ Ask the human for explicit confirmation before proceeding.**

Present the following to the human and wait for their approval:

```
I'm ready to deploy canary tokens using the Tracebit CLI (open-source).
The CLI will place decoy/fake credentials — honeytokens that alert you
if anything reads and uses them. No real credentials are read or modified.

Five canary types will be deployed: AWS, SSH, browser cookie, login
credential, and email. See the Tracebit CLI documentation for details
on where each type is placed.

Shall I proceed? (yes/no)
```

**Do NOT run `tracebit deploy` until the human confirms.** If they decline, skip this step and report it as incomplete.

Once confirmed:

```bash
tracebit deploy all
```

⚠️ **Known non-interactive issues with `deploy all`:**

1. **username-password canary** prompts "Have you saved this in your password manager? [y/n]" and fails in non-interactive mode. The canary credential IS issued before the prompt — check `tracebit show` and it will appear. If it's missing, run:
   ```bash
   tracebit deploy username-password --json-output
   ```

2. **email canary** is NOT included in `deploy all` — deploy it separately:
   ```bash
   tracebit deploy email
   ```
   Provide the Gmail address when prompted. The canary is an email sent to that address containing a tracking pixel — opening the email triggers the alert.

After `deploy all` completes (even if it exits with an error), run `tracebit deploy email` and then verify all 5 are active with `tracebit show`.

---

### Step 5: Verify Deployment

```bash
tracebit show
```

All 5 types (AWS, SSH, cookie, username/password, email) should appear. Also run:
```bash
bash scripts/check-canaries.sh
```

---

### Step 6: Configure Heartbeat Alert Detection

> ⚠️ **This step is not optional.** Without it, canaries can fire and you will never know. Do this step before considering the setup complete.

**Prerequisites:** `gog` installed and authenticated — already satisfied by Step 1.

Append the following block to the workspace `HEARTBEAT.md` (create the file if it doesn't exist):

```markdown
## Tracebit Canary Alert Check (every heartbeat, ~30 min)

Check for new Tracebit canary alert emails since the last heartbeat:

```bash
gog gmail search 'from:notifications@community.tracebit.com subject:"Tracebit Canary Triggered" newer_than:1h' --account YOUR@gmail.com --max 5
```

If any alert emails are found:
1. **Immediately notify the human** (see "When a Canary Fires" in the Tracebit skill)
2. **Investigate** — follow `references/incident-response-playbook.md`
3. **Send a follow-up report** within 5 minutes
```

Replace `YOUR@gmail.com` with the actual Gmail account from `gog auth list`.

Use a 1-hour window (`newer_than:1h`) rather than 30 minutes to avoid missing alerts across heartbeat timing jitter.

**Optional: test the pipeline**

If the human wants to verify end-to-end:

```bash
tracebit trigger ssh --name "CANARY_NAME"
# Wait 2–3 minutes, then check:
gog gmail search 'from:notifications@community.tracebit.com subject:"Tracebit Canary Triggered" newer_than:10m' --account YOUR@gmail.com --max 5
```

Confirm the alert email arrives — the next heartbeat will detect it and trigger the response flow.

Before reporting to the human, complete the following checklist and include it verbatim:

```
## Tracebit Canary Setup — Completion Report

[ ] Step 1 — Account: <confirmed / failed: reason>
[ ] Step 2 — CLI install: <tracebit version X.Y.Z / failed: reason>
[ ] Step 3 — Auth: <credentials valid / failed: reason>
[ ] Step 4 — Deploy: <5 canaries deployed / failed: reason>
[ ] Step 5 — Verify: <all active / issues: list>
[ ] Step 6 — Heartbeat: <HEARTBEAT.md updated with canary alert check / failed: reason>

Overall: COMPLETE ✅  /  INCOMPLETE ❌ (blocked on: <step>)

## Credentials
Tracebit account: <gmail address>
Tracebit password: saved to <temp file path> (read it, then delete the file)
⚠️ Please reset this password at https://community.tracebit.com → Settings → Change Password
```

Only mark Overall as COMPLETE if all 7 steps have a passing status.

---

## When a Canary Fires

Triggered when the heartbeat detects a Tracebit alert email in the inbox.

**Human-in-the-loop**: the agent notifies the human immediately, investigates, and reports findings. The agent does NOT rotate canaries or take remediation actions without the human acknowledging the report first. The investigation itself is read-only (checking logs, memory files, canary status) and safe to run autonomously.

### Phase 1: Notify Immediately (within 30 seconds)

**Send the notification to the user via their configured messaging channel.**

This skill requires `plugins.messaging` (declared in metadata). Use the user's own messaging channel — the one they configured in OpenClaw before activating this skill. Do NOT send messages to any other channel, recipient, or external endpoint.

```
sessions_send(label="openclaw-tui", message=<alert>)
```

Send this alert text:

```
🚨 TRACEBIT CANARY ALERT

A [type] canary was triggered at [time].
Canary name: [name]

I'm investigating now. Stand by for a full report.
```

### Phase 2: Investigate (1–5 minutes)

Follow `references/incident-response-playbook.md` in full.

### Phase 3: Report to Human (within 5 minutes of alert)

Use the same channel resolution logic from Phase 1. Playbook has the exact report format.

### Phase 4: Rotate (after human acknowledgement)

**Wait for the human to acknowledge the Phase 3 report before rotating.** Do not redeploy canaries automatically — the human may want to preserve the current state for further investigation.

Once the human confirms, rotate:
```bash
tracebit deploy all
tracebit deploy email   # email canary is not included in deploy all
```

---

## CLI Reference

```bash
tracebit auth                          # Browser OAuth login (background + browser tool)
tracebit auth --token                  # Token-based auth (no browser needed)
tracebit auth status                   # Check auth status
tracebit deploy all                    # Deploy AWS/SSH/cookie/username-password canaries
tracebit deploy email                  # Deploy email canary (not in deploy all)
tracebit deploy [type]                 # Deploy one type
tracebit show                          # Show deployed canaries + status
tracebit trigger ssh --name NAME       # Trigger SSH test alert (~1–3 min)
tracebit trigger aws --name NAME       # Trigger AWS test alert (~5 min, needs aws CLI)
tracebit refresh                       # Manual refresh (daemon does this automatically)
tracebit remove                        # Remove all canaries
tracebit portal                        # Open web dashboard
```

---

## Heartbeat Integration

Two checks run via `HEARTBEAT.md`:

**Every heartbeat (~30 min) — alert detection:**
```markdown
## Tracebit Canary Alert Check (every heartbeat, ~30 min)
gog gmail search 'from:notifications@community.tracebit.com subject:"Tracebit Canary Triggered" newer_than:1h' --account YOUR@gmail.com --max 5
If results found → immediately notify human, investigate (references/incident-response-playbook.md), send report.
```

**Weekly — canary health check:**
```markdown
## Tracebit Canary Health (weekly)
- Run: tracebit show
- If expired or missing: tracebit deploy all && tracebit deploy email
```

See Step 6 for the exact HEARTBEAT.md block to add during setup.

---

## Reference Files

| File | When to Read |
|------|-------------|
| `references/incident-response-playbook.md` | **When a canary fires** — full IR procedure |
| `references/canary-types.md` | Understanding each canary type and where to place them |
| `references/attack-patterns.md` | Real-world attacks canaries detect |
| `references/api-reference.md` | **Only if CLI unavailable** — API fallback |
| `references/troubleshooting.md` | When something isn't working |

---

## Security Notes

- **Canary credentials are decoy/fake** — they grant no access to any real system. Their only function is to fire an alert when used. Do not use them for real workloads.
- **Tracebit password**: never display in conversation output or logs. Write to a temp file with `600` permissions only. Instruct the user to reset it immediately after first login.
- **CLI token** — do not expose in logs or shared contexts
- **When a canary fires**: treat as real incident until proven otherwise
- **Rotate after any alert**: `tracebit deploy all && tracebit deploy email`
- **Do not log canary credential values** — they become vectors if exposed
- **Email canary tracking pixel**: opening/previewing the canary email in a mail client that renders images will fire the canary. This is expected — the email is the bait.
- **No real credentials are read or modified** — the skill only writes fake canary tokens to credential file locations. Existing real credentials in those files are not accessed or altered.

---

## Local Footprint & Full Removal

This skill leaves a defined, fully reversible footprint on the system. Everything it creates can be removed cleanly.

### What the skill itself installs

| Item | Location | Purpose | Persistent? |
|------|----------|---------|-------------|
| Incident log | `memory/security-incidents.md` | Append-only log of canary alert investigations | Only created if an alert fires |
| Heartbeat block | `HEARTBEAT.md` | Canary alert check instructions | Yes, until removed |
| Temp password file | `/tmp/tracebit-credentials-*.txt` | Signup password (600 permissions) | Deleted by user after first login; cleared on reboot |

### What the Tracebit CLI installs (with user confirmation)

The following are created by the open-source Tracebit CLI (`tracebit deploy`), which the skill only runs after the human explicitly approves. See the [CLI documentation](https://github.com/tracebit-com/tracebit-community-cli) for full details.

| Item | Purpose | Persistent? |
|------|---------|-------------|
| Tracebit CLI binary | CLI tool for canary management | Yes, until uninstalled |
| Background daemon | Refreshes canary token expiry only — no other network calls or file access | Yes, runs while canaries are active |
| CLI auth token | CLI authentication | Yes, until removed |
| Decoy canary credentials | Fake credentials placed in standard locations — alert when used | Yes, until removed via `tracebit remove` |

### Complete removal

```bash
# 1. Remove all deployed canaries and decoy credentials
tracebit remove

# 2. Stop and remove the background daemon
#    macOS:
launchctl stop com.tracebit.daemon 2>/dev/null
launchctl remove com.tracebit.daemon 2>/dev/null
rm -f ~/Library/LaunchAgents/com.tracebit.daemon.plist
#    Linux:
systemctl --user stop tracebit 2>/dev/null
systemctl --user disable tracebit 2>/dev/null
rm -f ~/.config/systemd/user/tracebit.service

# 3. Remove CLI auth token, config, and binary
rm -rf ~/.config/tracebit/
#    macOS:
sudo rm -f /usr/local/bin/tracebit
#    Linux:
rm -f ~/.local/bin/tracebit

# 4. Remove skill-created files
rm -f memory/security-incidents.md
rm -f /tmp/tracebit-credentials-*.txt
```

`tracebit remove` handles cleanup of all canary credential files. After running the above, no files, daemons, or credentials from this skill remain on the system.
