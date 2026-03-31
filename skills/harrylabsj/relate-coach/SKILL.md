---
name: relationship-coach
description: Relationship Coach — Provides self-help tools for communication skills, relationship maintenance, conflict resolution, and boundary setting. Includes non-violent communication, active listening, conflict management, and interpersonal skills. Note: this tool does not provide marriage counseling, emotional therapy, or act as a substitute for personal social interaction; when professional help is needed, users are referred appropriately.
---

# Relationship Coach

> ⚠️ **MVP / Skeleton Version**: This skill is a minimal viable skeleton. Core features are under development.

---

## Planned Features

- [ ] Non-Violent Communication (NVC) templates
- [ ] Active listening exercises
- [ ] Conflict resolution frameworks
- [ ] Boundary setting guides
- [ ] Relationship maintenance tips
- [ ] Social anxiety self-help
- [ ] Workplace communication skills
- [ ] Intimate relationship communication basics

## Usage Scenarios (Under Development)

This skill activates when the user mentions things like:

- "Can't communicate"
- "Relationships are exhausting"
- "Don't know how to express myself"
- "relationship"
- "interpersonal"
- "can't say no"

## What This Skill Does NOT Provide

This skill does **NOT** provide:
- Marriage counseling or couples therapy
- Dating / matchmaking advice
- Getting an ex-partner back
- Acting as a substitute for the user's own social interactions
- Psychological diagnosis or treatment

If a user needs these specialized services, they should be directed to a qualified professional.

## Safety Boundaries (Under Development)

- Detection and referral for out-of-scope content
- High-risk content detection
- Professional disclaimer

---

## Development Status

### Current Progress
- ✅ Directory structure created
- ✅ skill.json skeleton
- ✅ SKILL.md framework
- ⏳ Core modules under development

### Development Priorities
1. Communication skill template library
2. Non-violent communication guide
3. Common scenario response scripts
4. Boundary identification and setting guide
5. Testing and validation

---

## Architecture

```
relate-coach/
├── SKILL.md              # This file
├── skill.json            # Metadata
└── scripts/
    ├── handler.py        # Main handler
    └── boundary_checker.py
```
