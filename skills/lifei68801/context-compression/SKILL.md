---
name: context-compression
version: 3.9.7
description: "Manage OpenClaw session context with automatic truncation and memory preservation. Prevents context overflow errors. Features: token-based session trimming, AI fact extraction, preference lifecycle management. Use when: (1) context window exceeds limit (2) setting up memory hierarchy (3) managing user preferences with expiry. Triggers on: compression config, memory management, context overflow."
license: MIT-0
author: lifei68801
metadata:
  openclaw:
    requires:
      bins: ["bash", "jq", "sed", "grep", "head", "tail", "wc", "mkdir", "date", "tr", "cut"]
    permissions:
      - "file:read:~/.openclaw/agents/main/sessions/*.jsonl"
      - "file:write:~/.openclaw/agents/main/sessions/*.jsonl"
      - "file:read:~/.openclaw/workspace/memory/*.md"
      - "file:write:~/.openclaw/workspace/memory/*.md"
      - "file:write:~/.openclaw/workspace/MEMORY.md"
    behavior:
      modifiesLocalFiles: true
      description: "Local file operations for session trimming and memory storage. Uses built-in system tools (bash, jq, sed). No external network activity from scripts. Optional AI fact extraction uses local OpenClaw installation."
---

# Context Compression - Complete Solution v3.9

A comprehensive context management system that ensures:
1. **Never exceeds model context limit**
2. **Remembers all previous conversations** through hierarchical memory
3. **AI-powered intelligent fact extraction** with categorization

---

## 🆕 What's New in v3.9.5

### Preferences Lifecycle Management
- **New script**: `check-preferences-expiry.sh` - Automatically expires short-term and mid-term preferences
- **Layered structure**: Preferences now categorized as 长期 (permanent), 中期 (1-4 weeks), 短期 (1-7 days)
- **Expiry tracking**: Daily cron checks and removes expired preferences
- **Usage**: Tag preferences with `@YYYY-MM-DD` to track age, e.g. `- 今天不想运动 @2026-03-12`

### Usage Pattern
```markdown
#### ⏰ 短期偏好 (1-7天)
- 今天不想运动 @2026-03-12
- 这周专注写论文 @2026-03-10

#### 🔄 中期偏好 (1-4周)
- 这个月要早起 @2026-03-01

#### 📍 长期偏好 (永久)
- 沟通风格：女友风格
```

The cron job will automatically remove expired entries based on age.

---

## 🆕 What's New in v3.9.4

### Documentation Cleanup
- Improved documentation clarity
- Updated technical references
- No functional changes

### What's New in v3.9.2

### Critical Fix: Active Sessions Now Get Fact Extraction
- **Fixed**: Active sessions (with .lock files) were completely skipped, never extracting facts
- **Now**: Even active sessions have their high-priority content extracted to MEMORY.md
- **Impact**: No more memory loss during long sessions

### What's New in v3.9.1

### Case-Insensitive Keyword Matching
- **Fixed**: Priority keywords now match regardless of case (IMPORTANT, Important, important)
- **Added**: Common case variants for all English keywords
- **Improved**: Better bilingual support for global users

### What's New in v3.9.0

### Critical Fix: Fact Extraction Now Works!
- **Fixed**: priority-first strategy was skipping fact extraction entirely
- **Now**: All strategies (priority-first, time-decay, token-only) extract facts before truncating
- **Configurable**: Priority keywords can now be loaded from config file
- **Bilingual**: Default keywords include both Chinese and English for global users

### Enhanced Error Handling
- **Retry mechanism**: Extraction operations retry up to 2 times on failure
- **Pending queue**: Failed extractions are saved for later retry
- **Better logging**: Clear v8 tags in logs to track new behavior

### What's New in v3.8.3

### Maintenance Update
- Removed obsolete backup files
- All core functionality remains intact via `truncate-sessions-safe.sh`
- Improved documentation

### What's New in v3.8.0

### AI-Powered Fact Extraction
- **New script**: `extract-facts-enhanced.sh` - Uses local AI to extract structured facts
- **No more simple keyword matching** - AI understands context and extracts truly important information
- **Automatic workflow**: Truncation triggers → Detect high-value content → AI extracts facts → Write to MEMORY.md → Then truncate
- **Categorized output**: Facts are tagged as [偏好], [决策], [任务], [时间], [关系], [重要]

### How It Works
```
Session grows → Approaches token limit → Truncation script runs
    ↓
Detect high-value keywords (重要, 决定, TODO, etc.)
    ↓
AI extracts structured facts → Write to MEMORY.md
    ↓
Then perform truncation
```

### v3.6.3 Changes
- Security Scanner Fix: No credential scanning
- Scripts only detect user preferences, decisions, and tasks

### Memory Persistence Safeguards (v3.6)
- **Session end hook v2.0**: Detects unsaved important content, generates alerts
- **Mid-session check**: Periodic scan for keywords that should be saved
- **Alert file system**: `.session-alert` file when memory may be stale
- **Freshness tracking**: Monitors daily note update frequency

### Integration with AGENTS.md
- Hooks now output structured data for AI to read
- Recommendation system: `SAVE_NOW` when important content detected
- Automatic keyword detection: 重要/决定/记住/TODO/偏好

---

## 🆕 What's New in v3.5

### Enhanced Fact Extraction
- **6 category detection**: preferences, decisions, tasks, important, time, relationships
- **Structured storage**: facts stored in TSV files for easy querying
- **Automatic sync**: facts automatically merged into MEMORY.md

### Smart Summaries
- **Intelligent compression**: extracts headers, tasks, important items
- **Fact integration**: includes extracted facts from all categories
- **Statistics**: shows completion rates and key metrics

### Session Hooks
- **Session start hook**: auto-loads context and checks memory health
- **Session end hook**: forces save of critical information

---

## ⚠️ How It Works

**Local file operations only:**
- Reads session files from `~/.openclaw/agents/main/sessions/*.jsonl`
- Truncates large sessions to prevent context overflow
- Writes extracted facts to `MEMORY.md` and daily notes
- Uses standard system tools (bash, jq, sed, grep)

**Optional AI feature:**
- Fact extraction uses your local OpenClaw installation
- No external services or network connections from the scripts themselves
- All data stays on your machine

**What gets extracted:**
- User preferences (喜欢/偏好/讨厌)
- Important decisions (决定/确定)
- Task status (待办/TODO/完成)
- Time references (明天/下周)
- Contact references (同事/朋友/客户)

---

## 🚀 Quick Start: Interactive Setup

When this skill is first loaded, **proactively guide the user through configuration**:

### Step 0: Check Existing Configuration

```bash
# Check if already configured
cat ~/.openclaw/workspace/.context-compression-config.json 2>/dev/null
```

If already configured, ask: "Existing configuration detected. Reconfigure?"

### Step 1: Ask Configuration Questions (One at a Time)

**Question 1: Context Preservation**
> "How much context should be preserved for each new session? (1 token ≈ 3-4 Chinese characters)"
> - Default (40000 tokens) → Recommended, balances history retention with context safety
> - Conservative (60000 tokens) → Keeps more history
> - Aggressive (20000 tokens) → Minimizes context
> - Custom → Enter token count (10000-100000)

**Question 2: Truncation Frequency**
> "How often should context be truncated to prevent overflow?"
> - Every 10 minutes (Default) → Recommended
> - Every 30 minutes → Low frequency
> - Every hour → Lowest frequency
> - Custom → Enter minutes

**Question 3: Skip Active Sessions**
> "Should active sessions be skipped during truncation to prevent corruption of sessions being written?"
> - Yes (Default) → Recommended, prevents data corruption
> - No → May truncate sessions currently being written to

**Question 4: Daily Summary Generation**
> "Should daily session summaries be generated automatically?"
> - Yes → Generate compressed summaries from daily notes every 4 hours
> - No (Default) → Rely on real-time memory writes

### Step 2: Save Configuration

Create config file and update scripts:

```bash
# Save configuration
cat > ~/.openclaw/workspace/.context-compression-config.json << 'EOF'
{
  "version": "2.3",
  "maxTokens": <user_choice>,
  "frequencyMinutes": <user_choice>,
  "skipActive": <user_choice>,
  "enableSummaries": <user_choice>,
  "strategy": "priority-first",
  "priorityKeywords": [
    "重要", "决定", "记住", "TODO", "偏好",
    "important", "remember", "must", "deadline", "decision"
  ],
  "preserveUserMessages": true,
  "configuredAt": "$(date -Iseconds)"
}
EOF
```

**Priority Keywords**: Content matching these keywords will be extracted before truncation.
- Default includes both Chinese and English keywords
- Customize based on your language preference
- Use regex patterns (e.g., `"周[一二三四五六日]"` for weekdays)

### Step 3: Configure Periodic Tasks

The setup wizard will guide you through optional periodic task configuration.

### Step 4: Update Script Parameters

Update `truncate-sessions-safe.sh` with user config:

```bash
# Create config env file for the script
cat > ~/.openclaw/workspace/skills/context-compression/scripts/.config << 'EOF'
export MAX_TOKENS=<user_max_tokens>
export SKIP_ACTIVE=<user_skip_active>
EOF
```

### Step 5: Confirm Configuration

Tell user:
```
✅ Configuration complete!

Truncation settings:
- Token limit: X tokens (~Y Chinese characters)
- Check frequency: Every Z minutes
- Skip active sessions: Yes/No

Next steps:
1. Real-time memory writes ensure continuity
2. System will auto-truncate session files
3. Run check-context-health.sh to check status
```

---

## 🎯 Design Goals

| Goal | Solution |
|------|----------|
| Never exceed context limit | Pre-load truncation + context window management |
| Remember history | Hierarchical memory: short window + compressed summaries |
| Reliable | No dependency on agent context for critical operations |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Context Assembly Pipeline                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Total Context Budget: 80k tokens                                          │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ L4: Long-term Memory (MEMORY.md)                    ~5k tokens      │   │
│  │     - User preferences, important decisions, key facts              │   │
│  │     - Loaded first, always present                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ L3: Compressed Summaries (memory/summaries/)        ~10k tokens     │   │
│  │     - Daily summaries of older conversations                        │   │
│  │     - Compressed but semantically complete                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ L2: Short-term Window (recent sessions)             ~25k tokens     │   │
│  │     - Last N sessions, full conversation history                    │   │
│  │     - Loaded from session files directly                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ L1: Current Session                                  ~40k tokens     │   │
│  │     - Active conversation, full detail                              │   │
│  │     - Real-time writing to memory                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Reserved for system: ~10k tokens                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Implementation

### Part 1: System-Level Session Truncation

**Problem**: Truncation must happen BEFORE context is loaded.

**Solution**: Background process that runs independently.

```bash
# Key parameters:
MAX_TOKENS=40000       # Keep last 40000 tokens per session
SKIP_ACTIVE=true       # Don't truncate sessions with .lock files
```

**Setup**:
The skill automatically configures periodic session maintenance during initial setup.

---

### Part 2: Session Startup Sequence

**Every session must execute this sequence BEFORE loading full context:**

```
Step 1: Read MEMORY.md (long-term memory)
Step 2: Read memory/YYYY-MM-DD.md (today + yesterday notes)
Step 3: Load recent session files (limited by window size)
Step 4: Assemble context within budget
Step 5: Begin conversation
```

**Implementation in AGENTS.md**:
```markdown
## Every Session

1. Read MEMORY.md — long-term memory
2. Read memory/YYYY-MM-DD.md (today + yesterday)
3. Session files are auto-truncated by system cron
4. Begin conversation
5. **Real-time memory writing**: Important info → write to memory files immediately
```

---

### Part 3: Real-Time Memory Writing

**Critical**: Memory must be written during conversation, not after.

```
During Conversation:
│
├─→ User mentions preference → IMMEDIATELY update MEMORY.md
├─→ Important decision made → IMMEDIATELY update MEMORY.md
├─→ Task completed → IMMEDIATELY write to daily notes
└─→ Key information learned → IMMEDIATELY update relevant file
```

**Why immediate?**
- Session may be truncated at any time
- Summaries are unreliable (fail when context exceeded)
- Only guaranteed way to preserve memory

---

### Part 4: Hierarchical Memory Structure

#### L4: Long-term Memory (MEMORY.md)

```markdown
# MEMORY.md

## User Profile
- Name: ...
- Preferences: ...
- Goals: ...

## Important Decisions
- [Date] Decision: ...

## Key Information
- ...
```

**Update trigger**: Immediately when important info is mentioned.

#### L3: Daily Summaries (memory/summaries/YYYY-MM-DD.md)

```markdown
# Summary - YYYY-MM-DD

## Key Events
1. Event 1: ...
2. Event 2: ...

## Decisions
- Decision 1

## Tasks
- ✅ Completed: ...
- 🔄 In Progress: ...

## Tokens: ~500 (compressed from ~10k original)
```

**Generation**: Run daily via cron (but don't depend on it for critical memory).

#### L2: Recent Sessions (session files)

- Last 2000 lines per session
- Auto-truncated by system cron
- Full conversation detail for recent history

#### L1: Current Session

- Active conversation
- Write to memory files in real-time

---

## 📊 Context Budget Management

### Token Allocation

| Layer | Budget | Source |
|-------|--------|--------|
| System messages | ~10k | OpenClaw internal |
| Long-term memory (L4) | ~5k | MEMORY.md |
| Daily summaries (L3) | ~10k | memory/summaries/*.md |
| Recent sessions (L2) | ~25k | Session files (limited) |
| Current session (L1) | ~30k | Active conversation |
| **Total** | ~80k | |

### Overflow Handling

```
If context > 80k tokens:
│
├─→ Step 1: Skip older summaries (L3)
├─→ Step 2: Reduce recent sessions window (L2)
├─→ Step 3: Compress current session (handled by OpenClaw safeguard mode)
└─→ Always preserve: L4 (MEMORY.md) + L1 (current session)
```

---

## 🚀 Scripts

### 1. truncate-sessions-safe.sh

Safe truncation that preserves JSONL integrity.

```bash
#!/bin/bash
# Truncates session files to last N lines
# Preserves JSONL line integrity
# Skips active sessions (with .lock files)
```

### 2. generate-daily-summary.sh

Generates compressed summary from daily notes (not from session context).

```bash
#!/bin/bash
# Reads memory/YYYY-MM-DD.md
# Compresses to ~500 tokens
# Writes to memory/summaries/YYYY-MM-DD.md
```

### 3. check-context-health.sh

Reports current context status.

```bash
#!/bin/bash
# Reports:
# - Total session file sizes
# - Memory file sizes
# - Estimated context usage
# - Recommendations
```

### 4. session-start-hook.sh

Loads context and checks memory health at session start.

```bash
#!/bin/bash
# Checks MEMORY.md exists
# Creates today's daily note if missing
# Outputs context summary for AI
```

### 5. session-end-hook.sh (v2.0)

Detects unsaved content and generates alerts.

```bash
#!/bin/bash
# Checks MEMORY.md has today's updates
# Checks daily note freshness
# Detects potential unsaved important content
# Generates .session-alert if needed
```

### 6. mid-session-check.sh (NEW)

Periodic check for important content that should be saved.

```bash
#!/bin/bash
# Scans current session for keywords (重要/决定/TODO/偏好)
# Checks daily note freshness
# Outputs JSON recommendation: SAVE_NOW or OK
```

---

## ⚙️ Configuration

### openclaw.json

```json
{
  "agents": {
    "defaults": {
      "contextTokens": 80000,
      "compaction": {
        "mode": "safeguard",
        "reserveTokens": 25000,
        "reserveTokensFloor": 30000,
        "keepRecentTokens": 10000,
        "maxHistoryShare": 0.5
      }
    }
  }
}
```

### Periodic Tasks

Session maintenance runs automatically. Check skill logs at `~/.openclaw/logs/truncation.log` for status.

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Truncation script is executable: `ls -la scripts/truncate-sessions-safe.sh`
- [ ] Memory directories exist: `ls -la memory/ memory/summaries/`
- [ ] MEMORY.md exists and is up to date
- [ ] AGENTS.md has real-time memory writing rules

---

## 🔍 Troubleshooting

### Context Still Exceeded

1. Check truncation is running: `cat /root/.openclaw/logs/truncation.log`
2. Reduce MAX_LINES in truncation script
3. Reduce contextTokens in openclaw.json

### Memory Not Persisting

1. Check AGENTS.md has real-time writing rules
2. Verify memory files are being updated: `ls -la memory/`
3. Ensure important info is written immediately, not at end of session

### Summaries Not Generated

1. Check daily notes exist: `ls -la memory/YYYY-MM-DD.md`
2. Run summary script manually to test
3. Check cron logs: `grep CRON /var/log/syslog`

---

## 📚 References

- [OpenClaw Compaction Docs](https://docs.openclaw.ai)
- [Hierarchical Memory Architecture](references/memory-architecture.md)
- [Token Estimation Guide](references/token-estimation.md)
