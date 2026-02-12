# Status Tracking Guide

This guide explains how to use the status tracking system for the User Authentication, Registration, and Profile Management System.

---

## 📚 Status Tracking Files

### 1. `.kiro/steering/project-status.md`
**Purpose**: Comprehensive project status and progress tracking  
**Inclusion**: Always included in context  
**Update Frequency**: After each task completion

**Contains**:
- Current project state and phase
- Completed tasks with details
- Pending tasks
- Progress metrics by phase and component
- Sprint goals and milestones
- Quality metrics
- Architecture decisions
- Known issues
- Reference documents

**When to Update**:
- After completing any task or sub-task
- When starting a new phase
- When making important decisions
- When encountering blockers
- At the end of each sprint

---

### 2. `.kiro/steering/task-tracking.md`
**Purpose**: Quick reference checklist for all tasks  
**Inclusion**: Always included in context  
**Update Frequency**: After each sub-task completion

**Contains**:
- Quick status overview with progress bars
- Complete checklist of all tasks and sub-tasks
- Progress by component
- Current focus and priorities
- Task status legend
- Velocity tracking
- Quick commands

**When to Update**:
- After completing any sub-task
- When starting a new task
- When updating progress percentages

---

### 3. `.kiro/steering/daily-status-template.md`
**Purpose**: Template for daily status updates  
**Inclusion**: Manual (use when needed)  
**Update Frequency**: Daily (optional)

**Contains**:
- Daily summary template
- Completed tasks today
- In-progress tasks
- Blockers and issues
- Progress metrics
- Tomorrow's plan
- Learnings and notes
- Code changes
- Testing status
- Time breakdown

**When to Use**:
- For daily standup reports
- For tracking daily progress
- For personal work logs
- For team status updates

---

### 4. `.kiro/specs/tasks.md`
**Purpose**: Detailed implementation tasks with requirements mapping  
**Update Method**: Use `taskStatus` tool  
**Update Frequency**: After each sub-task completion

**Contains**:
- All 21 main tasks
- All sub-tasks with detailed descriptions
- Requirement mappings
- Team assignments
- Figma references
- Property-based test specifications

**When to Update**:
- Use the `taskStatus` tool to mark tasks as:
  - `not_started`
  - `queued`
  - `in_progress`
  - `completed`

---

### 5. `COMPLETED_TASKS.md`
**Purpose**: Historical record of completed work  
**Update Frequency**: After each task completion

**Contains**:
- List of completed tasks with dates
- What was done for each task
- Files created/modified
- Next steps for each task
- Summary of project structure setup

**When to Update**:
- After completing any task
- When reaching milestones
- At the end of each phase

---

## 🔄 Update Workflow

### When Completing a Sub-task

1. **Update tasks.md** (using taskStatus tool):
   ```bash
   # Mark task as in progress
   taskStatus(task="1.2 Define RDS PostgreSQL instance", status="in_progress")
   
   # Mark task as completed
   taskStatus(task="1.2 Define RDS PostgreSQL instance", status="completed")
   ```

2. **Update task-tracking.md**:
   - Change `[ ]` to `[x]` for the completed sub-task
   - Update progress percentages
   - Update progress bars
   - Update "Last Updated" timestamp

3. **Update project-status.md**:
   - Move task from "Pending" to "Completed" section
   - Add details about what was done
   - Update progress metrics
   - Update phase progress
   - Update "Last Updated" timestamp

4. **Update COMPLETED_TASKS.md**:
   - Add entry for the completed task
   - Include date, description, files created
   - Add any important notes

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "Complete Task 1.2: Define RDS PostgreSQL instance"
   ```

---

### When Starting a New Task

1. **Update tasks.md**:
   ```bash
   taskStatus(task="1.2 Define RDS PostgreSQL instance", status="in_progress")
   ```

2. **Update task-tracking.md**:
   - Change `[ ]` to `[~]` for in-progress tasks (optional)
   - Update "Current Focus" section

3. **Update project-status.md**:
   - Update "Current Status" section
   - Update "Current Sprint Goals"
   - Update "Next Actions"

---

### Daily Status Update (Optional)

1. **Copy daily-status-template.md**:
   ```bash
   cp .kiro/steering/daily-status-template.md .kiro/steering/daily-status-2024-01-15.md
   ```

2. **Fill in the template**:
   - Update date and day
   - List completed tasks
   - List in-progress tasks
   - Note any blockers
   - Plan tomorrow's work

3. **Archive or delete**:
   - Keep for records or delete after updating main status files

---

## 📊 Progress Tracking

### How to Calculate Progress

#### Task Progress
```
Task Progress = (Completed Sub-tasks / Total Sub-tasks) × 100%

Example:
Task 1 has 7 sub-tasks, 1 completed
Progress = (1 / 7) × 100% = 14%
```

#### Phase Progress
```
Phase Progress = (Completed Tasks / Total Tasks in Phase) × 100%

Example:
Phase 1 has 4 tasks, 0 completed (but 2 sub-tasks done)
Progress = Weighted average of task progress ≈ 10%
```

#### Overall Progress
```
Overall Progress = (Completed Sub-tasks / Total Sub-tasks) × 100%

Example:
2 sub-tasks completed out of ~100 total
Progress = (2 / 100) × 100% ≈ 2%

Or use weighted by main tasks:
2 sub-tasks from 21 main tasks ≈ 9.5%
```

---

## 🎯 Status Indicators

### Task Status
- ✅ **Complete** - Task is done and verified
- 🟡 **In Progress** - Task is currently being worked on
- ⏭️ **Not Started** - Task has not been started
- 🚫 **Blocked** - Task is blocked by dependencies or issues
- ⭐ **Optional** - Task is optional and can be skipped

### Progress Bars
```
[██████████] 100% - Complete
[█████░░░░░]  50% - Half done
[██░░░░░░░░]  20% - Started
[░░░░░░░░░░]   0% - Not started
```

### Phase Status
- ✅ **Complete** - All tasks in phase done
- 🟡 **In Progress** - Some tasks in phase done
- ⏭️ **Not Started** - No tasks in phase started
- 🚫 **Blocked** - Phase is blocked

---

## 📝 Best Practices

### 1. Update Frequently
- Update status files after each sub-task completion
- Don't wait until end of day or week
- Keep status current and accurate

### 2. Be Specific
- Include details about what was done
- List files created/modified
- Note any challenges or decisions

### 3. Track Time
- Estimate time for tasks
- Track actual time spent
- Use for future planning

### 4. Document Blockers
- Note blockers immediately
- Include impact and action items
- Update when resolved

### 5. Celebrate Wins
- Note achievements and milestones
- Track progress visually
- Share successes with team

---

## 🔍 Quick Reference Commands

### View Status Files
```bash
# View comprehensive status
cat .kiro/steering/project-status.md

# View task checklist
cat .kiro/steering/task-tracking.md

# View completed tasks
cat COMPLETED_TASKS.md

# View all tasks
cat .kiro/specs/tasks.md
```

### Update Task Status
```bash
# In Kiro, use taskStatus tool:
taskStatus(
  taskFilePath=".kiro/specs/tasks.md",
  task="1.2 Define RDS PostgreSQL instance",
  status="completed"
)
```

### Search for Tasks
```bash
# Find specific task
grep "Task 1.2" .kiro/specs/tasks.md

# Find completed tasks
grep "\[x\]" .kiro/steering/task-tracking.md

# Find in-progress tasks
grep "\[~\]" .kiro/steering/task-tracking.md
```

---

## 📈 Reporting

### Weekly Status Report
Use information from:
1. `project-status.md` - Overall progress and metrics
2. `task-tracking.md` - Completed tasks checklist
3. `COMPLETED_TASKS.md` - Detailed work done

### Sprint Review
Use information from:
1. `project-status.md` - Sprint goals and achievements
2. `task-tracking.md` - Velocity tracking
3. Daily status files (if created)

### Stakeholder Updates
Use information from:
1. `project-status.md` - High-level status and milestones
2. `README.md` - Project overview
3. `COMPLETED_TASKS.md` - Recent accomplishments

---

## 🎯 Current Status Summary

### Files Created
- ✅ `.kiro/steering/project-status.md` - Comprehensive status tracking
- ✅ `.kiro/steering/task-tracking.md` - Quick task checklist
- ✅ `.kiro/steering/daily-status-template.md` - Daily update template
- ✅ `COMPLETED_TASKS.md` - Historical record
- ✅ `STATUS_TRACKING_GUIDE.md` - This guide

### How to Use
1. **Always check** `project-status.md` for current state
2. **Update** `task-tracking.md` after each sub-task
3. **Use** `daily-status-template.md` for daily logs (optional)
4. **Maintain** `COMPLETED_TASKS.md` for history
5. **Follow** this guide for consistency

---

## 🚀 Getting Started

### First Time Setup
1. Read this guide
2. Review `project-status.md` to understand current state
3. Review `task-tracking.md` to see task checklist
4. Review `tasks.md` to see detailed tasks

### Daily Workflow
1. Check `project-status.md` for current focus
2. Work on tasks
3. Update `task-tracking.md` as you complete sub-tasks
4. Update `project-status.md` with details
5. Use `taskStatus` tool to update `tasks.md`
6. Commit changes

### Weekly Workflow
1. Review progress in `project-status.md`
2. Update sprint goals if needed
3. Review velocity and adjust estimates
4. Plan next week's work
5. Update documentation

---

**Status**: ✅ Status tracking system complete and ready to use  
**Last Updated**: Current Session  
**Next Review**: After completing first task
