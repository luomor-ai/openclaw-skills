---
name: task-manager
description: Task management tool based on Eisenhower Matrix + P0-P2 priority system. Uses four quadrants for strategic prioritization at macro level, and P0/P1/P2 for fine-grained sorting at micro level. Supports task creation, completion, archiving, cross-quadrant adjustment, future list management, and delegation list management.
---

# Task Manager - Three-Level Priority System

This skill provides **three-level** standardized task list management:
- **Execution Layer**: Eisenhower Four Quadrants (personal tasks)
- **Future Layer**: Maybe List (ideas that may or may not be done)
- **Management Layer**: Delegation List (tasks delegated to team members, periodic review)

## 📊 Three-Level Management System

### 🔷 Execution Layer: Eisenhower Four Quadrants

| Quadrant | Characteristic | Strategy | Typical Scenarios |
|----------|-----------------|----------|-------------------|
| 🔥 **Q1** | Important + Urgent | **Do Immediately** | Deadlines passed, blocking others, hard deadlines |
| 💼 **Q2** | Important + Not Urgent | **Plan & Schedule** | OKRs, team building, strategic tasks |
| ⚡ **Q3** | Not Important + Urgent | **Batch Process** | Daily maintenance, tech fixes, delegatable |
| 🧘 **Q4** | Not Important + Not Urgent | **Postpone/Delete** | Exploratory research, learning tasks, optional features |

### 🔶 Micro Layer: P0/P1/P2 Three-Tier Sorting

Refine priority within the **same quadrant** using three tiers:

- **🔴 P0**: Must do today (hard deadline or blocking others)
- **🟡 P1**: Complete within this week (near-term high priority)
- **🟢 P2**: Within this month/quarter (important but not urgent)

**Why only three tiers?**
- Simplified decision-making: too many tiers cause indecision
- Core scenarios covered: urgent/near-term/long-term is enough
- Lower maintenance cost: less frequent adjustments

### 🌱 Future Layer: Maybe List

Collects all "**may do later**" ideas and inspirations, temporarily not placed in quadrants:

- **Applicable Scenarios**:
  - Ideas not mature enough, need more information
  - Timing not right, waiting for the right opportunity
  - Low interest, temporarily set aside but reluctant to delete
  - Need further research to judge importance/urgency

- **Management Principles**:
  - ✅ Quick capture to avoid forgetting
  - ✅ Regular review (weekly/monthly)
  - ✅ Move to quadrants or delete
  - ❌ Don't pile up too many (keep <20)

**Note**: Maybe List = Future List, for storing ideas that are temporarily uncertain whether to do, or timing is not yet mature.

### 👑 Management Layer: Delegation List

Used for **managing tasks delegated to subordinates**, periodic review of progress and quality:

- **Applicable Scenarios**:
  - Assign tasks to team members
  - Track project progress and quality
  - Regular review of completion status
  - Evaluate subordinate capability and growth

- **Management Principles**:
  - ✅ **Clear owner and deadline**
  - ✅ **Regular review** (weekly/bi-weekly)
  - ✅ **Track progress and quality**
  - ✅ **Timely feedback and guidance**
  - ❌ **Don't micromanage** (give autonomy)
  - ❌ **Don't pile up too many** (keep <15)

## 🎯 Usage Principles

### 1. **Determine Level First, Then Priority**
```markdown
Step 1: Judge task type → Determine level (Execution/Future/Management)
Step 2: If execution task → Determine quadrant position
Step 3: Compare urgency within same quadrant → Assign P0/P1/P2
```

**Examples**:
- "Hiring" → Personal execution → **Q1** → Must do today → **P0**
- "AI Business Scenario Discovery" → Personal execution → **Q2** → This week focus → **P1**
- "Process Lark messages" → Personal execution → **Q3** → Batch on schedule → **P1**
- "Code Agent Research" → Personal execution → **Q4** → Tabled → **P2**
- "Let Xiao Wang take responsibility for Project X" → Delegation → **Delegation List** → Review next week
- "Research AI Painting" → Uncertain → **Maybe List** → Pending evaluation

### 2. **Level > Quadrant > Number**
- Prioritize **task level** (Execution/Future/Management)
- Within Execution Layer, prioritize **quadrant distribution**
- Within same quadrant, P0/P1/P2 used for **specific execution order**

### 3. **Dynamic Adjustment**
- Tasks may **flow across levels** (e.g., Maybe List → Quadrants)
- Tasks may **flow across quadrants** (e.g., Q2 → Q1)
- P0/P1/P2 can be adjusted **within same quadrant**
- Regular review to optimize distribution

### 4. **Maybe List Rotation Mechanism**
```markdown
New Idea → Maybe List (quick record)
↓
Regular Review (weekly/monthly)
↓
Decision → Move to Quadrant / Delete / Keep Pending
```

**Review Criteria**:
- **Important + Urgent** → Q1
- **Important + Not Urgent** → Q2
- **Not Important + Urgent** → Q3
- **Not Important + Not Urgent** → Q4 or Delete

### 5. **Delegation List Rotation Mechanism**
```markdown
Delegated Task → Delegation List (record owner + deadline)
↓
Regular Review (weekly/bi-weekly)
↓
Decision → Mark Complete / Extend / Re-delegate / Remove
```

**Review Criteria**:
- **Completed** → Archive and summarize
- **In Progress** → Check progress, provide guidance
- **At Risk** → Help resolve difficulties or adjust deadline
- **Poor Quality** → Feedback improvement or re-delegate

## 📁 Task File Structure

- **Main Task List**: `tasks/tasks.md` - Grouped by quadrants, sorted by P0/P1/P2 within each (personal execution)
- **Future List**: `tasks/maybe.md` - Collect uncertain ideas and inspirations
- **Delegation List**: `tasks/delegation.md` - Record delegated tasks, periodic review
- **Archive File**: `tasks/archived.md` - Store completed/deleted task history

## 🔄 Operation Flow

### Add Task

#### Scenario A: Clear Task (Direct to Quadrant)

##### Step 1: Determine Quadrant (Macro)
Ask:
- **Is it important?** (valuable for business/team/personal growth)
- **Is it urgent?** (has deadline/blocking others/expired)

→ Determine quadrant position

##### Step 2: Assign P0/P1/P2 (Micro)
Compare within **same quadrant**:
- Must do today? → **P0**
- Complete this week? → **P1**
- Within this month/quarter? → **P2**

##### Step 3: Add Task
See [references/task-add.md](references/task-add.md)

#### Scenario B: Uncertain Idea (Go to Maybe List)

When:
- Idea not mature enough, need more information
- Timing not right, waiting for opportunity
- Low interest, temporarily set aside but reluctant to delete
- Need further research to judge importance/urgency

**Add to Maybe List Format**:
```markdown
### [Category]

#### X. Task Name【Tag】
- [ ] **Status**: Pending Evaluation
- [ ] **Description**: Brief description
- [ ] **Created**: YYYY-MM-DD
- [ ] **Notes**: Why in Maybe List (e.g., "waiting for more info", "timing not right")
```

#### Scenario C: Delegated Task (Go to Delegation List)

When assigning task to team member:

**Add to Delegation List Format**:
```markdown
### [Project/Team]

#### X. Task Name【Tag】
- [ ] **Status**: In Progress / Completed / Extended / Re-delegated
- [ ] **Owner**: @Name
- [ ] **Description**: Brief description
- [ ] **Deadline**: YYYY-MM-DD
- [ ] **Created**: YYYY-MM-DD
- [ ] **Last Review**: YYYY-MM-DD
- [ ] **Next Review**: YYYY-MM-DD
- [ ] **Notes**: Progress notes, feedback, guidance
```

**Delegation Principles**:
- ✅ **Clear owner and expected outcome**
- ✅ **Set reasonable deadline**
- ✅ **Provide necessary resources and support**
- ✅ **Regular review of progress and quality**
- ❌ **Don't micromanage** (excessive intervention)
- ❌ **Don't give vague instructions** (causing misunderstanding)

### Move from Maybe List to Quadrant

**When to move?**
- After gaining more information, can judge importance/urgency
- Timing is right, need to start action
- Found it's actually important, need re-evaluation

**Operation Steps**:
1. Read `tasks/maybe.md`
2. Judge which quadrant it should enter
3. Add to corresponding quadrant per normal process
4. Delete from Maybe List

### Move from Delegation List to Quadrant

**When to move?**
- Task requires your personal execution (no longer delegated)
- Task becomes urgent and important, need intervention
- Subordinate cannot complete, need to take over

**Operation Steps**:
1. Read `tasks/delegation.md`
2. Judge if personal execution is needed
3. Add to corresponding quadrant per normal process
4. Remove from Delegation List

### Complete Task

See [references/task-complete.md](references/task-complete.md)

**Post-completion reflection**:
- If Q1 task: Why did it become urgent? Can we plan ahead?
- If Q2 task: Is it progressing as planned? Need adjustment?
- If Q3 task: Can it be automated or delegated?
- If Q4 task: Is it really not needed?

**Delegated task completion reflection**:
- How did the subordinate perform? Any growth?
- Any areas for improvement?
- Need to provide more training or support?
- Can delegate more similar tasks?

### Adjust Priority

#### Cross-Level Adjustment (Strategic)
When task **nature or priority** changes:
- **Upgrade**: Maybe List → Quadrants (timing is right)
- **Downgrade**: Quadrants → Maybe List (no longer urgent)
- **Transfer**: Quadrants → Delegation List (decide to delegate)
- **Transfer**: Delegation List → Quadrants (need personal execution)

#### Cross-Quadrant Adjustment (Tactical)
When task **importance or urgency** changes:
- **Upgrade**: Q2 → Q1 (new deadline appears)
- **Downgrade**: Q1 → Q2 (found early warning mechanism)
- **Transfer**: Q3 → Q4 (no longer urgent)

#### Same-Quadrant Adjustment (Tactical)
Only adjust P0/P1/P2 **within same quadrant**:
- P1 → P0 (deadline moved up)
- P2 → P1 (client pushing for progress)
- P1 → P2 (time relaxed)

## 📈 Ideal Distribution Reference

Healthy task distribution should be:

| File | Recommended Count | Description |
|------|------------------|-------------|
| 🔥 Q1 | 3-5 | Too many indicates insufficient planning |
| 💼 Q2 | 8-12 | Core area for strategic investment |
| ⚡ Q3 | 5-10 | Can gradually optimize automation |
| 🧘 Q4 | <10 | Regular cleanup |
| 🌱 Maybe List | <20 | Regular review, avoid piling up |
| 👑 Delegation List | <15 | Regular review, avoid out of control |

**Healthy Signs**:
- ✅ Q1 ≤ 5
- ✅ Q2 takes largest proportion
- ✅ Q4 regularly cleaned
- ✅ Maybe List regularly reviewed and cleared
- ✅ Delegation List regularly reviewed and archived
- ❌ Q1 explosive growth (need stronger planning)
- ❌ Delegation List exceeds 15 (need simplification or authorization)

## 🗓️ Time Rhythm Suggestions

### Daily Check
- **Q1**: What must be completed today?
- **Q2**: What to focus on this week?
- **Q3**: What can be batch processed?
- **Q4**: What can be deleted?

### Weekly Review
- Are there too many Q1 tasks? (Strengthen planning)
- How are Q2 tasks progressing? (Enough strategic investment?)
- Can Q3 tasks be automated?
- Does Q4 need cleanup?
- **Maybe List**: Review tasks that can move to quadrants
- **Delegation List**:
  - Review all delegated task progress
  - Check for延期风险
  - Provide necessary guidance and feedback
  - Mark completed tasks

### Monthly Optimization
- Archive and analyze completed Q1 tasks
- Convert Q2 tasks to specific action plans
- Evaluate Q3 batch processing efficiency
- Clean up invalid Q4 tasks
- **Maybe List**: Clear or significantly reduce (at least review once)
- **Delegation List**:
  - Evaluate overall subordinate performance
  - Summarize success experiences and issues
  - Adjust authorization strategy and communication style
  - Archive completed tasks

## ⚠️ Notes

- **Sequential numbers**: Start from 1, no duplicates, no gaps
- **Level before quadrant**: Three levels are main structure, quadrants are execution layer organization
- **Archive after completion**: Don't just mark complete
- **Update timestamp after each operation**
- **Regular Q4 cleanup**: Avoid task buildup
- **Control Q1 count**: Reflect on planning if exceeds 5
- **Maybe List is not trash bin**: Regular review, either move to quadrants or delete
- **Maybe List max 20**: Otherwise loses meaning
- **Delegation List is not hands-off**: Regular review, ensure task quality and progress
- **Delegation List max 15**: Otherwise difficult to manage effectively
- **Delegation is not abandonment**: Maintain focus while giving autonomy

## 📋 Statistics Templates

### Main Task List Statistics
```markdown
## 📊 Statistics

| Quadrant | Count | Task Numbers | Strategy |
|----------|-------|--------------|----------|
| 🔥 Q1 | X | 1-X | Do Immediately |
| 💼 Q2 | Y | X+1-X+Y | Plan & Schedule |
| ⚡ Q3 | Z | ... | Batch Process |
| 🧘 Q4 | W | ... | Postpone/Delete |
| **Total** | N | - | - |
```

### Maybe List Statistics
```markdown
## 📊 Maybe List Statistics

| Item | Count | Description |
|------|-------|-------------|
| Total Tasks | M | - |
| Pending Evaluation | M | All |
| Average Stay Time | X Weeks | Review if >4 weeks |
```

### Delegation List Statistics
```markdown
## 📊 Delegation List Statistics

| Item | Count | Description |
|------|-------|-------------|
| Total Tasks | D | - |
| In Progress | D1 | Need continuous attention |
| Completed | D2 | Completed this month/week |
| At Risk | D3 | Need intervention |
| Average Completion Rate | X% | Overall subordinate performance |
| Average Review Cycle | X Days | Review frequency appropriate? |
```

---

*Version: 5.0 (Added comprehensive task merge and split mechanism)*
*Last Updated: 2026-03-25*
