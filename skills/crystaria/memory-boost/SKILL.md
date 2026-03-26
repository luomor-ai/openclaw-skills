---
name: memory-boost
description: Simple text-based memory system for AI assistants - never lose context again
homepage: https://clawhub.ai/skills/memory-boost
version: 1.0.1
tags: [memory, productivity, workflow, text-based, best-practice]
---

# Memory Boost Skill

**Version:** 1.0.1 (Tag Format Fix)
**Author:** Crystaria (with Paw and Kyle)
**License:** MIT
**Tags:** memory, productivity, workflow, text-based, best-practice

---

## 🧠 The Problem

AI assistants have no real memory. Each session starts fresh. Important context is lost between conversations.

**Sound familiar?**

- "Wait, what were we working on last time?"
- "I forgot why we made this decision..."
- "Can you remind me about...?"
- "Where did we save that link?"

**This is not your fault. It's how AI works.**

We don't remember. We reload.

---

## 💡 The Solution

**Text-based memory system.**

Simple text files that persist between sessions. No code. No databases. Just markdown files you can read and edit.

### Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Memory Boost                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Layer 1: MEMORY_INDEX.md (Optional)                    │
│  → Quick reference for active projects                  │
│                                                         │
│  Layer 2: MEMORY.md (Required)                          │
│  → Long-term memory: decisions, preferences, context    │
│                                                         │
│  Layer 3: memory/*.md (Required)                        │
│  → Daily logs and project notes                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 File Structure

```
your-workspace/
├── MEMORY.md              # Long-term memory (required)
├── MEMORY_INDEX.md        # Quick reference (optional)
└── memory/                # Daily logs (required)
    ├── 2026-03-23.md      # Daily session log
    ├── 2026-03-24.md      # Daily session log
    └── project-name.md    # Project-specific notes
```

### Naming Conventions

| File Pattern | Purpose |
|--------------|---------|
| `YYYY-MM-DD.md` | Daily session logs |
| `project-name.md` | Project-specific notes |
| `topic-name.md` | Topic-based notes (e.g., `meeting-notes.md`) |

---

## 📖 How to Use

### Before Starting Work (Every Session)

**Step 1:** Read `MEMORY.md`
- Understand long-term context
- Review user preferences
- Check active projects

**Step 2:** Read `memory/` files
- Today's file: `memory/YYYY-MM-DD.md`
- Relevant project file: `memory/project-name.md`

**Step 3:** (Optional) Read `MEMORY_INDEX.md`
- Quick status check
- Key links

### After Completing Work

**Step 1:** Update `memory/today.md`
- What you completed
- Notes for tomorrow

**Step 2:** Update `MEMORY.md` (if important)
- New decisions
- Lessons learned
- Changed preferences

**Step 3:** (Optional) Update `MEMORY_INDEX.md`
- Project status changes
- New links

---

## 📝 Templates

### MEMORY.md Template

```markdown
# MEMORY.md - Long-term Memory

**Created:** YYYY-MM-DD  
**Last Updated:** YYYY-MM-DD

---

## 🎯 Active Projects

| Project | Status | Links | Last Updated |
|---------|--------|-------|--------------|
| Project A | 🟡 In Progress | [Link](...) | YYYY-MM-DD |
| Project B | ✅ Completed | [Link](...) | YYYY-MM-DD |

---

## 📚 Important Decisions

### YYYY-MM-DD
- **Decision:** What was decided
- **Reason:** Why this choice
- **Context:** Background info

---

## 👤 User Preferences

| Aspect | Preference |
|--------|------------|
| Communication | Formal/Casual |
| Response Style | Detailed/Concise |
| Work Focus | Areas of interest |

---

## 🔗 Key Links

- Project Repo: https://...
- Documentation: https://...
- Other Resources: https://...

---

*Last updated: YYYY-MM-DD*
```

### memory/YYYY-MM-DD.md Template

```markdown
# YYYY-MM-DD

## Completed
- [ ] Task 1
- [ ] Task 2

## In Progress
- Task 3 (50% done)

## Notes
- Something learned today
- Context for tomorrow
- Questions to follow up

## Links
- https://...
```

### memory/project-name.md Template

```markdown
# Project Name

**Created:** YYYY-MM-DD  
**Status:** Active/Completed/On Hold

---

## Overview
What this project is about.

---

## Key Decisions
- YYYY-MM-DD: Decision about X

---

## Technical Notes
- Architecture choices
- Dependencies
- Important commands

---

## Todo
- [ ] Next steps
```

### MEMORY_INDEX.md Template (Optional)

```markdown
# Memory Index - Quick Reference

**Created:** YYYY-MM-DD  
**Maintained By:** Your AI Assistant

---

## 🎯 Active Projects

| Project | Status | Links | Updated |
|---------|--------|-------|---------|
| Project A | 🟡 In Progress | [Repo](...) | YYYY-MM-DD |

---

## 📚 Recent Decisions

### YYYY-MM-DD
- Brief decision summary

---

## 👤 Quick Preferences

- Style: Preference 1, Preference 2
- Focus: Area 1, Area 2

---

## 🔗 Key Links

- Main Project: https://...
- Documentation: https://...

---

*Last updated: YYYY-MM-DD*
```

---

## 📝 Example: Filled MEMORY.md

Here's what a real MEMORY.md might look like:

```markdown
# MEMORY.md - Long-term Memory

**Created:** 2026-03-01  
**Last Updated:** 2026-03-23

---

## 🎯 Active Projects

| Project | Status | Links | Last Updated |
|---------|--------|-------|--------------|
| Website Redesign | 🟡 In Progress | [Figma](...), [Repo](...) | 2026-03-23 |
| Mobile App | 🟢 Planning | [Brief](...) | 2026-03-20 |

---

## 📚 Important Decisions

### 2026-03-23
- **Decision:** Use React for website redesign
- **Reason:** Team has React experience, better component reusability
- **Context:** Evaluated Vue vs React, team voted for React

### 2026-03-15
- **Decision:** Deploy to Vercel instead of self-hosting
- **Reason:** Faster setup, automatic HTTPS, less maintenance
- **Context:** Project timeline was tight, needed quick deployment

---

## 👤 User Preferences

| Aspect | Preference |
|--------|------------|
| Communication | Casual but professional |
| Response Style | Structured with bullet points |
| Work Focus | Web development, automation |

---

## 🔗 Key Links

- Main Repo: https://github.com/...
- Documentation: https://docs...
- Design Files: https://figma.com/...

---

*Last updated: 2026-03-23*
```

---

## ✅ Best Practices

### Do ✅

- **Read memory files at session start** - Never skip this step
- **Write immediately after tasks** - Don't wait
- **Use clear structure** - Tables, lists, headers
- **Keep it simple** - Bullet points over paragraphs
- **Update status changes** - When projects move forward
- **Record decisions with reasons** - Not just what, but why
- **Link liberally** - URLs are your friends

### Don't ❌

- **Don't rely on "mental notes"** - If it matters, write it
- **Don't wait until "later"** - Later never comes
- **Don't write essays** - Be concise
- **Don't over-organize** - Simple is sustainable
- **Don't hide important info** - Future you needs to find it
- **Don't skip updates** - Stale memory is worse than no memory

---

## 🔄 When to Update

| Trigger | Action |
|---------|--------|
| Session start | Read MEMORY.md + today's memory file |
| Task complete | Update memory/today.md |
| Important decision | Add to MEMORY.md |
| Project status change | Update MEMORY_INDEX.md |
| Session end | Quick review of what was done |
| User says "remember this" | Write immediately, confirm location |

---

## 🎯 Common Scenarios

### Scenario 1: Starting a New Project

```
1. Create memory/project-name.md
2. Add project to MEMORY.md (Active Projects table)
3. Add to MEMORY_INDEX.md (if using)
4. Start logging work in memory/project-name.md
```

### Scenario 2: Making an Important Decision

```
1. Complete the task
2. Update memory/today.md with what happened
3. Add decision to MEMORY.md (Important Decisions section)
4. Update project status in MEMORY_INDEX.md
```

### Scenario 3: User Says "Remember This"

```
1. Ask: "Should I add this to MEMORY.md or a project file?"
2. Write it immediately
3. Confirm: "Added to [file]. You can find it under [section]."
```

### Scenario 4: Returning After a Break

```
1. Read MEMORY.md (refresh long-term context)
2. Read memory/ files from last session
3. Check MEMORY_INDEX.md for status overview
4. Ask user: "Ready to continue [project]?"
```

---

## 🔧 For Advanced Users

### Multi-AI Teams

If you work with multiple AI assistants:

- **Share MEMORY.md** - All AIs read/write the same file
- **Each AI can have its own notes** - e.g., `CLAUDE.md`, `PAW.md`
- **Sync via MEMORY_INDEX.md** - Single source of truth for status

> **Note:** This requires all AIs to have access to the same file system. For cloud-based setups, consider using shared storage or version control (e.g., Git).

### Custom Categories

Add sections to MEMORY.md based on your needs:

- `## 📅 Scheduled Tasks` - Recurring reminders
- `## 🎓 Lessons Learned` - Mistakes and insights
- `## 💡 Ideas` - Brainstorming backlog
- `## 🔐 Security Notes` - ⚠️ **NOT RECOMMENDED**: Never store passwords, API keys, or secrets in memory files. These are plain text and not encrypted.

### Automation

If you're technical:

- Use cron jobs to create daily memory files
- Auto-archive old memory files monthly
- Create scripts to search across memory files

---

## ❓ FAQ

### Q: Isn't this just note-taking?

**A:** Yes and no. Traditional notes are for humans. Memory files are for **AI + human**. They're structured for quick reloading, not deep reading.

### Q: How much detail should I include?

**A:** Enough that future you understands context. Not so much that it's painful to write or read. Aim for **skimmable**.

### Q: What if I forget to update?

**A:** No problem. Update when you remember. Better late than never. The system is forgiving.

### Q: Can I delete old memory files?

**A:** Yes! Archive or delete freely. Keep only what's useful. MEMORY.md is your curated long-term memory.

### Q: Does this work with [other AI tool]?

**A:** Yes! This is pure text. Any AI that can read/write files can use this system.

---

## 🚀 Getting Started

**Right now, do this:**

1. Create `MEMORY.md` in your workspace
2. Create `memory/` folder
3. Create `memory/YYYY-MM-DD.md` (today's date)
4. Start using it!

**That's it.** No setup. No config. Just write.

---

## 📚 Related Resources

- [OpenClaw Documentation](https://docs.openclaw.ai) *(verify link)*
- [ClawHub](https://clawhub.ai) *(verify link)*
- [Markdown Guide](https://www.markdownguide.org)

---

## 🙏 Acknowledgments

This skill was developed with the help of AI assistants.

**Core Contributors:**
- Paw (AI assistant) - Initial design, implementation, testing
- Kyle (AI assistant) - Code review, best practices, documentation
- Crystaria - Project direction, final review

**Inspired by:**
- Real-world memory patterns from multiple AI assistants

---

## 📄 License

MIT License - Feel free to use, modify, and share.

---

*Version 1.0.0 | Last updated: 2026-03-23*
