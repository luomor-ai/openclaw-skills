---
name: scenario-planning
description: >
  Use this skill whenever a project manager, strategist, or team lead wants to think ahead, stress-test a plan, prepare for uncertainty, or ask "what if" questions about a project or initiative. Trigger when the user mentions any of: scenario planning, what-if analysis, contingency planning, strategic flexibility, planning for uncertainty, future-proofing a project, risk-proofing, preparing for disruption, adaptive planning, or building resilience into a roadmap. Also trigger when someone says things like "how do we prepare if X happens", "what should we do if things change", "we need a Plan B", "we're worried about unknowns", or "how do we stay agile if the landscape shifts". This skill is software-agnostic and works for any industry, project type, or team size — from product sprints to megaprojects. It guides the agent through a structured, repeatable scenario planning process grounded in structured project management practices — moving the project manager from reactive to proactively prepared.
---

# Scenario Planning Skill

## What This Skill Does

Scenario Planning is a strategic management practice that prepares a team to navigate uncertainty by developing multiple coherent, plausible futures and defining adaptive responses to each. It is fundamentally different from traditional risk management:

| Traditional Risk Management | Scenario Planning |
|---|---|
| Identifies specific events and mitigates them | Reshapes the entire strategy around a changing landscape |
| One most-probable future | Multiple equally plausible futures |
| Reactive: respond when risk occurs | Proactive: prepare before uncertainty resolves |
| Puzzle-solving by deduction | Mystery-navigating by induction and narrative |

**Foundation:** This skill is grounded in established strategic planning, project schedule management, and corporate strategy in turbulent markets.

**Core shift:** From *"if X happens, we'll do Y"* → to *"if the world looks like THIS, here is how we lead."*

---

## Foundational Concepts

Before beginning, the agent must understand these foundations:

### The Three Schools of Scenario Planning
There are three distinct methodological schools. The agent must select the right school for the project's context:

| School | Approach | Best For | Data Source | Output |
|--------|----------|----------|-------------|--------|
| **Intuitive Logic ** | Qualitative; narrative-driven | Long-term strategy, organizational change, high uncertainty | Internal team + external experts in facilitated sessions | Plausible narrative scenarios, no probabilities |
| **La Prospective ** | Mixed qualitative + quantitative | Medium-term; public/private sector strategy | Structural analysis + stakeholder interviews | Descriptive or normative scenarios with actor behavior modeling |
| **Probabilistic Modified Trends ** | Quantitative; model-driven | Short-to-medium term; measurable risk factors | Time series data + expert probability estimates | Scenarios with probabilities attached; sensitivity analysis |

**Default for most project contexts:** ILM — it is the most accessible, requires no specialized software, works from facilitated conversation, and is proven for organizational decision-making.

**When to use LP or PMT:** If the project has rich historical data, quantifiable risk factors, or is a megaproject with financial modeling requirements, layer in PMT or LP elements (see `references/school-selection-guide.md`).

### The Synthesized Definition of a Scenario
A scenario must satisfy six criteria :
1. **Future-oriented** — it describes a state that does not yet exist
2. **Externally referenced** — it is shaped by forces outside the organization's full control
3. **Narrative form** — it reads as a story, not a list of variables
4. **Plausible** — it could credibly happen given current conditions
5. **Part of a differentiated set** — scenarios must be meaningfully different from each other, not variations on a theme
6. **Internally consistent** — all elements within the scenario must reinforce each other logically

### Risk vs. Uncertainty: A Critical Distinction
- **Risk** — divergences where probability and impact can be estimated (known unknowns). Managed by traditional risk management.
- **Uncertainty** — conditions where probability and impact are unknown or unknowable. Managed by scenario planning.
- **Radical uncertainty** — complex environments where things are non-linear; small input changes cause large output changes (megaprojects, digital disruption, geopolitical shifts). Requires scenario narratives, not point forecasts.

**The Optimist vs. Skeptic trap :** An Optimist closes down options quickly — picking one future and committing. If wrong, rework is expensive. A Skeptic holds multiple options open, uses scenarios as parallel paths, and converges only as uncertainty resolves. This skill follows the Skeptic's approach.

### The Causal Chain Principle
Risks do not exist in isolation — they form causal chains. A war in a distant region → oil price increases → transportation costs rise → supplier prices rise → project budget pressure. Identify where in the causal chain a risk factor sits. Work with **proximate causes** that are close enough to your project to translate into financial and operational plans.

---

## Guiding Principles

These are established core principles:

1. **Plausibility over pessimism** — Scenarios are not best/worst case. They are internally consistent alternative worlds . Avoid optimistic/pessimistic framing — it introduces bias toward wishful or fear-based thinking.
2. **Narrative over numbers** — Scenarios work because they connect with decision-makers' mental models through storytelling . A vivid scenario story is more actionable than a probability table.
3. **Dialogue is indispensable** — Scenarios built only by one person are not scenarios; they are predictions. The process of building them together is where the strategic value is created.
4. **Scenarios without strategies are useless** — Every scenario must conclude with: "And therefore, we do this." 
5. **Early warning systems are mandatory** — Scenarios must be connected to observable signal indicators and monitored continuously. Without this, they become documents, not tools .
6. **Top management commitment is a success factor** — Without executive engagement, scenario planning becomes a one-off exercise and dies.
7. **Scale the approach to uncertainty level** — Short-term projects with measurable uncertainties → lean toward PMT methods. Long-term, complex, qualitative uncertainty → lean toward ILM .
8. **Megaprojects require additional governance** — For large, complex, or long-duration projects: use principal-steward (not principal-agent) governance structures; innovation must be protected; alliance contracting may be warranted .

---

## The Scenario Planning Process

The agent works through these phases. They are designed to be sequential but the agent must remain flexible — users may enter at any phase or need only a subset.

---

### PHASE 0 — SCHOOL SELECTION & SCOPE CALIBRATION

**Goal:** Select the right methodological approach and calibrate depth before beginning.

**This phase is mandatory.** Starting with the wrong school wastes time and produces poor scenarios.

**Agent actions:**
- Ask the user to describe the project in 3–4 sentences.
- Assess against these calibration questions:
  - What is the planning horizon? (Short: <1 year / Medium: 1–3 years / Long: 3+ years)
  - How quantifiable are the key uncertainties? (Measurable with data vs. qualitative and judgment-based)
  - Is this a standard project or a megaproject (large budget, multiple years, complex stakeholder web, non-linear outcomes)?
  - What is the team's scenario planning experience? (First time vs. practiced)
  - Is top management committed to acting on outputs? (Critical success factor)

- Based on answers, recommend a school:
  - Short horizon + quantifiable risks → **PMT elements** (sensitivity analysis, probability trees)
  - Medium/long horizon + strategic uncertainty → **ILM** (facilitated narrative scenarios)
  - Megaproject or complex infrastructure → **a specialized scenario planning framework** for megaprojects; consider principal-steward governance framing
  - Hybrid situations → **LP** (structural analysis + qualitative narratives)

- Also determine depth: Full engagement (all 7 phases) or Focused engagement (Phases 1–4 only for smaller projects).

**Output of Phase 0:**
- School selection with rationale.
- Engagement scope (full or focused).
- A note on whether megaproject governance considerations apply.

---

### PHASE 1 — PROJECT SCOPING & STRATEGIC CONTEXT

**Goal:** Understand the project, its strategic objectives, and the forces shaping its environment.

**Agent actions:**
- Gather: project goal, current phase, timeline, team, budget range, key deliverables, success criteria.
- Identify the project's **Key Focal Issue** — the single most important strategic question the scenario planning is designed to answer. (e.g., "What is the right delivery strategy given regulatory uncertainty?")
- Conduct a **PESTLE scan** of the external environment (Political, Economic, Social, Technological, Legal, Environmental) — this is standard across all three schools.
- Identify **internal forces**: team capacity, budget constraints, leadership stability, stakeholder alignment.
- Identify key stakeholders and decision-makers, including their risk tolerance.
- Note the project's position on the certainty spectrum: Are uncertainties resolvable  or radical (true uncertainty)?

**Crucial note:** The quality of this phase determines everything. The quality and extent of information gathered in the scanning phase directly determines scenario reliability. Poor scoping produces unrepresentative scenarios.

**Output of Phase 1:**
- Project Context Summary (2–3 paragraphs).
- Key Focal Issue statement.
- PESTLE scan (brief — forces relevant to this project only).
- Stakeholder map with decision authority.

---

### PHASE 2 — DRIVING FORCES & UNCERTAINTY MAPPING

**Goal:** Identify, rank, and select the forces that will define which scenario unfolds.

**This is the most intellectually demanding phase.** Identifying the top 2 critical uncertainties is the hinge of the entire exercise.

**Agent actions:**

**Step 1 — Generate Driving Forces:**
- Brainstorm all forces (from PESTLE scan + internal forces) that could materially affect the Key Focal Issue.
- Aim for 20–50 forces before filtering (aim for around 50 for a thorough review).
- Group similar forces. Eliminate duplicates.

**Step 2 — Assess each force on two dimensions:**
- **Impact** on the project (High / Medium / Low)
- **Uncertainty** of the force's future direction (High / Medium / Low)

Use a **Risk Assessment Matrix**: multiply probability of occurrence (1–5 scale) × severity of impact (1–5 scale). Forces scoring above 10 are key risks/uncertainties.

**Step 3 — Map to the 2×2 grid:**
```
                    HIGH IMPACT          LOW IMPACT
HIGH UNCERTAINTY  [ SCENARIO DRIVERS ] [ WILD CARDS     ]
LOW  UNCERTAINTY  [ CRITICAL FACTORS ] [ BACKGROUND NOISE]
```

- **Scenario Drivers** (high impact + high uncertainty): These become the axes of scenario construction. Limit to TOP 2 for the scenario matrix.
- **Critical Factors** (high impact + low uncertainty): These are constraints. Treat via traditional risk management, not scenarios.
- **Wild Cards** (low impact + high uncertainty): Document. Monitor. Do not build scenarios around them.
- **Background Noise**: Discard.

**Step 4 — Causal Chain Analysis :**
For each Scenario Driver, trace its causal chain:
- What is the root cause of this force?
- What intermediate events connect root cause to project impact?
- At which point in the chain does your project feel it?
- Work with the **proximate** variable — the one closest to project impact that can still be monitored.

**Step 5 — Sensitivity Analysis (for quantifiable forces):**
If forces are quantifiable, apply sensitivity analysis: test what a 10% change in each variable does to key project performance indicators (budget, timeline, revenue, scope). Forces where a 10% change produces >50% change in performance are your highest-priority Scenario Drivers .

**Output of Phase 2:**
- Driving Forces Register: all forces scored by impact and uncertainty.
- Uncertainty Map (2×2 grid populated).
- Top 2 **Scenario Drivers** confirmed and described.
- Causal chain narrative for each Scenario Driver.
- (If applicable) Sensitivity analysis results.

---

### PHASE 3 — SCENARIO CONSTRUCTION

**Goal:** Build 3–4 distinct, plausible, internally consistent scenarios that represent the genuine range of futures.

**Core rules:**
- **Plausible, not just possible** — Scenarios represent coherent futures, not random what-ifs .
- **Internally consistent** — Every element within a scenario must be logically compatible. Test this explicitly.
- **Meaningfully different** — Not variations on a theme. Scenarios should challenge conventional wisdom .
- **Narrative form** — Each scenario must be a story written in present tense, as if it has already happened .
- **No probabilities in ILM** — If using the Intuitive Logic school, do not attach probabilities. All scenarios are equally plausible. (PMT school may attach probabilities — see `references/school-selection-guide.md`.)
- **Avoid Best/Worst framing** — This introduces optimism bias and overconfidence .

**The 2×2 Scenario Matrix method (ILM — default):**
Take the top 2 Scenario Drivers. Place one on each axis (Low ↔ High). The four quadrants generate 4 scenarios:

```
                    DRIVER B: LOW         DRIVER B: HIGH
DRIVER A: HIGH   [  Scenario 3       ] [ Scenario 4        ]
DRIVER A: LOW    [  Scenario 1       ] [ Scenario 2        ]
```

Each quadrant represents a distinct world. Name them descriptively, not evaluatively.

**For each scenario, document:**
1. **Name** — Descriptive, memorable, non-judgmental (e.g., "The Regulated Platform", "The Open Market", not "Bad Outcome")
2. **News Headline** — A vivid, future-written headline as if reporting from that world 
3. **Narrative** — 2–4 sentences in present tense describing what this world looks like. Make it specific to the project context.
4. **Triggering Conditions** — What sequence of events would bring this scenario into existence?
5. **Impact on Project** — Scope, timeline, budget, team, stakeholders, key dependencies
6. **Strategic Response** — The adapted project strategy in this scenario
7. **Key Decisions Required** — What decisions must be made, by whom, by when
8. **Early Warning Indicators** — Specific, observable, monitorable signals that this scenario is beginning to unfold (required)

**For 3-scenario sets (alternative — used when one driver dominates):**
Use Pessimistic / Baseline / Optimistic framing — but rename them descriptively. This approach is appropriate when:
- Only one clear Scenario Driver exists
- The project has quantifiable financial variables (useful for financial planning)
- The team is new to scenario planning and needs a simpler entry point

**Scenario consistency check:**
Before finalizing, run a consistency test: for each pair of assumptions within a scenario, ask "Can these two things co-exist in the same world?" If no, revise. (This is the Consistency Matrix approach.)

**Output of Phase 3:**
- Scenario Library: 3–4 fully documented scenarios.
- Consistency check confirmation for each scenario.
- Named, narrativized, and differentiated set ready for stress testing.

→ See `references/scenario-templates.md` for full templates, naming conventions, and narrative writing guidance.

---

### PHASE 4 — STRATEGY STRESS TESTING & GAP ANALYSIS

**Goal:** Test the current project plan against each scenario to find vulnerabilities, gaps, and pivot points.

**Crucial basis:** This is called the "Gap Analysis" — identifying the Planning Gap between strategic goals and what each scenario actually produces. This is not optional. Scenarios that are not tested against the current plan have no operational value.

**Agent actions:**

**Step 1 — Financial/Performance Gap Analysis:**
For each scenario, evaluate what the project's key performance indicators look like:
- What does scope/output look like in this scenario?
- What does timeline look like?
- What does budget/cost look like?
- Does the project still achieve its strategic objectives?

Calculate or estimate the **Planning Gap** — the difference between planned targets and what each scenario produces.

**Step 2 — Strategy Stress Test Matrix:**
Build the matrix:

| Plan Element | Baseline | Scenario 2 | Scenario 3 | Scenario 4 |
|---|---|---|---|---|
| Milestone 1 | ✅ Stable | ⚠️ At Risk | 🔴 Must Change | ✅ Stable |
| Budget | ✅ Stable | 🔴 Must Change | ⚠️ At Risk | ➕ Opportunity |
| (etc.) | | | | |

Ratings: ✅ Stable / ⚠️ At Risk / 🔴 Must Change / ➕ Opportunity

**Step 3 — Identify strategic response types:**
- **Robust strategies** — work reasonably well across all scenarios. Prioritize these.
- **Scenario-specific strategies** — only work in one scenario. Use with caution; activate only when that scenario is confirmed.
- **No-regret moves** — improve outcomes in every scenario. Execute immediately regardless of which scenario emerges.
- **Hedging moves** — moderate between scenarios; slightly suboptimal in each but protect against downside.

**Step 4 — Pre-authorized Decision Gates:**
For each decision that would need to be made quickly under scenario activation, pre-authorize it now:
- What is the decision?
- What are the options?
- Who is authorized to decide?
- What information is needed?
- What is the default if signals are ambiguous?

**Note on megaprojects :** For complex projects, the Skeptic's approach applies: do not close down options too early. Keep parallel paths open. Innovation requires space — conventional project management's control emphasis is counterproductive under radical uncertainty.

**Output of Phase 4:**
- Planning Gap analysis per scenario.
- Strategy Stress Test Matrix.
- No-Regret Moves list (execute now).
- Pre-authorized Decision Gates register.
- Identification of robust vs. scenario-specific strategies.

→ See `references/stress-test-matrix.md` for templates.

---

### PHASE 5 — ADAPTIVE ROADMAP WITH DECISION GATES

**Goal:** Embed scenario intelligence into the actual project roadmap, creating a living, adaptive plan.

**Key concept — the Skeptic's roadmap :**
Unlike the Optimist who commits early and hopes, the Skeptic builds a roadmap that keeps options open, reduces optionality deliberately at pre-defined Decision Gates as evidence accumulates, and treats the roadmap as a learning artifact, not a fixed plan.

**Agent actions:**
- Map the project timeline and identify **3–5 natural Decision Gates** tied to real milestones (not arbitrary dates).
- At each Decision Gate, pre-define:
  - **Signal review** — which early warning indicators are evaluated here?
  - **Decision** — what path choice is made based on signals?
  - **Authority** — who decides (PM / Sponsor / Steering Committee)?
  - **Paths** — what does the project look like if we stay vs. pivot?
  - **Default** — what happens if signals are ambiguous? (Always define a default — ambiguity paralysis is a known failure mode)

- Define **Scenario Activation Thresholds**: the specific, observable conditions that, when confirmed, trigger a formal pivot to a non-baseline scenario strategy. These must be concrete — not "if things look bad" but "if [specific observable event] occurs by [date/milestone]."

- For megaprojects: build in **innovation checkpoints** where the team is explicitly permitted to explore alternative delivery approaches, not just monitor progress .

**Output of Phase 5:**
- Adaptive Roadmap: timeline annotated with Decision Gates and scenario-linked paths.
- Scenario Activation Criteria document.
- (For megaprojects) Innovation Checkpoint schedule.

---

### PHASE 6 — STAKEHOLDER COMMUNICATION & INTERNALIZATION

**Goal:** Ensure scenarios live in the minds of decision-makers, not just in documents.

**Core basis:** The single most important outcome of scenario planning exercises is often increased organizational dialogue and tool adoption — not the document produced. Leadership commitment and dialogue are the primary influencing factors in scenario planning success.

**Transparency principle:** Scenarios must be communicated as plausible, alternative hypotheses — not predictions. This framing reduces resistance and opens genuine strategic conversation.

**Agent actions:**
- Tailor communication to three audiences:
  - **Executive Sponsors:** Strategic implications, no-regret moves, Decision Gate authority, escalation thresholds. Keep to 1–2 pages.
  - **Project Core Team:** Their role as signal detectors; scenario-specific workstream implications; what to watch for.
  - **External Stakeholders/Clients:** Communicate adaptive nature of the plan; do not share internal scenario detail unless necessary.

- Draft an **Executive Summary** covering:
  - Why scenario planning was conducted (the Key Focal Issue)
  - The 2 Critical Uncertainties identified
  - The 3–4 scenarios (headline + 2-sentence narrative each)
  - No-regret moves already underway
  - Decision Gate governance structure

- Develop a **communication rhythm** — scenarios need to be re-visited in meetings, not filed away.

**Output of Phase 6:**
- Stakeholder Communication Plan.
- Executive Summary (1–2 pages).
- Team Briefing document.

→ See `references/stakeholder-communication.md` for templates and framing language.

---

### PHASE 7 — MONITORING, GOVERNANCE & LESSONS LEARNED

**Goal:** Make the scenario plan operational — a living, monitored, updated system, not a document.

**Core basis:** Scenario planning is only effective when it is "conceived as a continuous and steady process." A scenario plan that is not monitored produces no value. After a project, lessons learned must capture which scenario actually unfolded and why — this organizational learning is underutilized.

**Agent actions:**
- Define the **Signal Monitoring Cadence** (recommended: weekly during execution).
- Define the **Scenario Review Cadence** (recommended: at each major milestone or monthly).
- Define the **Escalation Protocol**: who is notified and in what sequence when a Scenario Activation Threshold is crossed.
- Assign the **Scenario Plan Owner** — one named person responsible for keeping the plan current.

- Governance structure:
  ```
  Signal Review     → PM / Team Lead        → Weekly
  Decision Gate     → PM + Sponsor          → At milestone
  Scenario Activation → PM → Sponsor → Steering Committee → As triggered
  Full Plan Refresh → PM + Core Team        → Monthly or at major milestone
  Early Warning System → Signal Owner       → Continuous
  ```

- **Lessons Learned :**
  - Which scenario actually unfolded? Why?
  - Which early warning indicators were accurate? Which were misleading?
  - Were the Decision Gates triggered at the right moments?
  - What would be done differently in the scenario construction?
  - What can future projects learn?

**Output of Phase 7:**
- Scenario Governance Document.
- Signal Monitoring Dashboard .
-  Lessons Learned: Scenario Retrospective.

---

## Project Scale Guidance

| Project Scale | Recommended Approach |
|---|---|
| **Small project** (<6 months, 1–5 people) | Phases 1–4 only. 3 scenarios. ILM school. 1-page output. |
| **Medium project** (6–18 months, 5–20 people) | Phases 1–6. 3–4 scenarios. ILM or LP. Full deliverables set. |
| **Large project** (18+ months, 20+ people) | All 7 phases. 4 scenarios. ILM with PMT elements. Full governance structure. |
| **Megaproject** (multi-year, multi-org, >$100M) | All 7 phases. A tailored complex scenario framework. Principal-steward governance framing. Innovation checkpoints. Alliance-contracting considerations. |

---

## Summary of Deliverables

| # | Deliverable | Phase | School |
|---|---|---|---|
| 0 | School Selection & Scope Calibration | 0 | All |
| 1 | Project Context Summary + Key Focal Issue | 1 | All |
| 2 | Driving Forces Register + Uncertainty Map | 2 | All |
| 3 | Causal Chain Analysis | 2 | All |
| 4 | Sensitivity Analysis (if quantifiable) | 2 | PMT/LP |
| 5 | Scenario Library (3–4 scenarios) | 3 | All |
| 6 | Consistency Check per Scenario | 3 | All |
| 7 | Planning Gap Analysis | 4 | All |
| 8 | Strategy Stress Test Matrix | 4 | All |
| 9 | No-Regret Moves + Pre-authorized Decision Gates | 4 | All |
| 10 | Adaptive Roadmap with Decision Gates | 5 | All |
| 11 | Scenario Activation Criteria | 5 | All |
| 12 | Executive Summary + Stakeholder Communication Plan | 6 | All |
| 13 | Scenario Governance Document + Signal Dashboard | 7 | All |
| 14 | Lessons Learned: Scenario Retrospective | 7  | All |

---

## Agent Behavior Guidelines

- **School selection first.** Never begin building scenarios without selecting the appropriate methodological school (Phase 0). Wrong school = wasted effort.
- **Ask, don't assume.** Generic scenarios are useless. Context is everything.
- **Co-create, don't dictate.** The evidence is clear: the dialogue process is where value is created, not the document.
- **Narrative over numbers.** Push for vivid, concrete scenario stories. Abstract scenarios do not influence decisions.
- **Tie everything to decisions.** Every scenario must answer: "And therefore, what do we do?"
- **Demand early warning indicators.** Scenarios without observable signals cannot be activated. This is non-negotiable .
- **Scale appropriately.** Use the project scale guidance table. Not every project needs all 14 deliverables.
- **Flag megaproject conditions.** If the project is large, complex, or non-linear, raise governance considerations proactively.
- **Stay software-agnostic.** All outputs are format-neutral.

---

## Quick-Start Mode

For users who want rapid orientation:

1. "Tell me about your project: what it is, its current phase, and what's at stake if it goes wrong."
2. "What are the 2–3 forces outside your control that worry you most?"
3. "If those forces shifted significantly in different directions, what would each version of the world look like for this project?"

From these three answers, draft a preliminary Uncertainty Map and 2×2 scenario matrix, then invite the user to refine from there. Label the approach (ILM quick-start) so the user knows what methodology they're in.
