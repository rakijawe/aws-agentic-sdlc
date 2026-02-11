---
inclusion: always
---

# Jira Workflow Automation & Role-Based Assignment

This steering file defines the automated workflow for assigning Jira tasks to appropriate teams based on spec-driven development.

## Overview

When Stories/Tasks are created from Spec Mode, they should be automatically routed to the correct team using Jira roles, components, labels, and automation rules.

## Team Structure & Jira Roles

### Define Project Roles
Configure these roles in Jira Project Settings → People:

- **Backend Team** - Java/AWS Lambda developers
- **Frontend Team** - Angular/TypeScript developers
- **DevOps Team** - Infrastructure and deployment engineers
- **QA Team** - Quality assurance and testing specialists

### Role Membership
- Add team members to their respective roles
- Members can belong to multiple roles if needed
- Roles are project-specific

## Component-Based Routing

### Jira Components Setup
Create these components in Project Settings → Components:

#### Backend Components
- `backend-api` - REST API development
- `backend-service` - Business logic layer
- `backend-data` - Database and JPA
- `backend-security` - Authentication/Authorization
- `backend-integration` - External system integration

**Default Assignee**: Backend Team Lead or use Component Lead

#### Frontend Components
- `frontend-ui` - Angular components and pages
- `frontend-forms` - Form handling and validation
- `frontend-routing` - Navigation and routing
- `frontend-state` - State management
- `frontend-styling` - CSS/Material theming

**Default Assignee**: Frontend Team Lead

#### DevOps Components
- `devops-infra` - Infrastructure as code
- `devops-cicd` - Pipeline configuration
- `devops-docker` - Container configuration
- `devops-monitoring` - Logging and monitoring

**Default Assignee**: DevOps Team Lead

#### QA Components
- `qa-testing` - Test case creation
- `qa-automation` - Automated test scripts
- `qa-performance` - Performance testing
- `qa-security` - Security testing

**Default Assignee**: QA Team Lead

#### Cross-Functional Components
- `documentation` - Technical documentation
- `architecture` - Design decisions
- `database-migration` - Schema changes

## Label-Based Classification

### Task Type Labels
Use these labels to classify work type:

#### Backend Labels
- `backend` - General backend work
- `api-development` - REST API creation
- `database-schema` - Database changes
- `business-logic` - Service layer implementation
- `security-impl` - Security features

#### Frontend Labels
- `frontend` - General frontend work
- `ui-component` - Component development
- `form-validation` - Form and validation logic
- `routing` - Navigation implementation
- `styling` - UI/UX styling

#### DevOps Labels
- `devops` - General DevOps work
- `infrastructure` - IaC and provisioning
- `pipeline` - CI/CD configuration
- `deployment` - Release and deployment
- `monitoring` - Observability setup

#### QA Labels
- `qa` - General QA work
- `test-cases` - Manual test creation
- `automation` - Test automation
- `regression` - Regression testing
- `integration-testing` - Integration test suite

#### Priority Labels
- `critical` - Must be done immediately
- `high-priority` - Important work
- `tech-debt` - Technical debt items
- `refactoring` - Code improvement

## Spec Tagging Conventions

### In Spec Files
When creating implementation tasks in spec files, use these tags to indicate team assignment:

```markdown
## Implementation Tasks

### Backend Tasks
<!-- @team:backend @component:backend-api -->
- [ ] Create User authentication endpoint
- [ ] Implement password validation service
- [ ] Add account locking logic

### Frontend Tasks
<!-- @team:frontend @component:frontend-ui -->
- [ ] Create login page component
- [ ] Implement form validation
- [ ] Add error message display

### DevOps Tasks
<!-- @team:devops @component:devops-cicd -->
- [ ] Configure deployment pipeline
- [ ] Set up environment variables
- [ ] Create Docker configuration

### QA Tasks
<!-- @team:qa @component:qa-testing -->
- [ ] Create test cases for login flow
- [ ] Verify validation rules
- [ ] Test account locking behavior
```

### Tag Format
- `@team:<team-name>` - Specifies the responsible team
- `@component:<component-name>` - Maps to Jira component
- `@label:<label-name>` - Additional classification labels
- `@priority:<level>` - Priority indicator

## Jira Automation Rules

### Rule 1: Auto-Assign by Component
**Trigger**: Issue created  
**Condition**: Component is set  
**Action**: Assign to component default assignee or role

```
WHEN: Issue created
IF: Component = "backend-api"
THEN: Assign to role "Backend Team"
```

### Rule 2: Auto-Assign by Label
**Trigger**: Issue created or updated  
**Condition**: Label matches team pattern  
**Action**: Assign to corresponding team role

```
WHEN: Issue created or label added
IF: Label contains "backend"
THEN: 
  - Assign to role "Backend Team"
  - Add component "backend-api" (if not set)
```

### Rule 3: Multi-Component Assignment
**Trigger**: Issue has multiple components  
**Condition**: Components from different teams  
**Action**: Create subtasks for each team

```
WHEN: Issue created
IF: Has components from multiple teams
THEN:
  - Create subtask for each component
  - Assign each subtask to respective team
  - Link subtasks to parent
```

### Rule 4: QA Auto-Assignment on Ready for Testing
**Trigger**: Status changed to "Ready for Testing"  
**Condition**: No QA assignee  
**Action**: Assign to QA team

```
WHEN: Status changed to "Ready for Testing"
IF: Assignee role != "QA Team"
THEN:
  - Add watcher from QA Team
  - Add label "qa-ready"
  - Send notification to QA Team
```

### Rule 5: DevOps Notification on Deployment
**Trigger**: Status changed to "Ready for Deployment"  
**Condition**: Has deployment requirements  
**Action**: Notify DevOps team

```
WHEN: Status changed to "Ready for Deployment"
THEN:
  - Add label "deployment-ready"
  - Assign to role "DevOps Team"
  - Send Slack notification to #devops channel
```

### Rule 6: Auto-Label from Summary Keywords
**Trigger**: Issue created  
**Condition**: Summary contains keywords  
**Action**: Add appropriate labels

```
WHEN: Issue created
IF: Summary contains "API" OR "endpoint" OR "service"
THEN: Add label "backend"

IF: Summary contains "UI" OR "component" OR "page"
THEN: Add label "frontend"

IF: Summary contains "pipeline" OR "deploy" OR "docker"
THEN: Add label "devops"

IF: Summary contains "test" OR "QA" OR "verify"
THEN: Add label "qa"
```

## Workflow States by Team

### Backend Workflow
1. **To Do** → Backend Team picks up
2. **In Progress** → Development ongoing
3. **Code Review** → PR created, peer review
4. **Ready for Testing** → QA Team notified
5. **Done** → Merged and deployed

### Frontend Workflow
1. **To Do** → Frontend Team picks up
2. **In Progress** → Component development
3. **Code Review** → PR created, peer review
4. **Ready for Testing** → QA Team notified
5. **Done** → Merged and deployed

### DevOps Workflow
1. **To Do** → DevOps Team picks up
2. **In Progress** → Infrastructure work
3. **Review** → Configuration review
4. **Testing** → Validate in staging
5. **Done** → Applied to production

### QA Workflow
1. **To Do** → QA Team picks up
2. **In Progress** → Test execution
3. **Blocked** → Issues found, reassign to dev
4. **Verified** → Tests passed
5. **Done** → Sign-off complete

## Integration with Spec Mode

### When Creating Tasks from Specs

1. **Parse Spec File** - Extract task metadata from tags
2. **Create Jira Issue** - Use Jira API or integration
3. **Set Component** - Based on `@component` tag
4. **Add Labels** - Based on `@label` and `@team` tags
5. **Set Priority** - Based on `@priority` tag
6. **Trigger Automation** - Let Jira rules handle assignment

### Example Spec-to-Jira Mapping

```markdown
<!-- @team:backend @component:backend-security @label:api-development @priority:high -->
- [ ] Implement JWT token generation
```

Maps to Jira Issue:
- **Component**: backend-security
- **Labels**: backend, api-development, high-priority
- **Assignee**: Backend Team (via automation)
- **Priority**: High

## Best Practices

### For Spec Authors
- Always include `@team` tag for clear ownership
- Use `@component` to ensure proper routing
- Add `@priority` for critical items
- Keep task descriptions clear and actionable

### For Team Leads
- Review component default assignees regularly
- Monitor unassigned issues in team backlog
- Ensure automation rules are working correctly
- Update role memberships as team changes

### For Developers
- Check component assignment when picking up work
- Add yourself as watcher on related components
- Update labels if task scope changes
- Link related issues across teams

### For QA Team
- Monitor "Ready for Testing" status
- Use qa-ready label for filtering
- Create test subtasks for complex features
- Link test cases to implementation tasks

## Monitoring & Reporting

### Dashboards to Create

1. **Team Workload Dashboard**
   - Issues by component
   - Issues by team role
   - Burndown by team

2. **Assignment Health Dashboard**
   - Unassigned issues by component
   - Issues missing components
   - Issues with multiple teams

3. **Workflow Efficiency Dashboard**
   - Time in each status by team
   - Blocked issues by team
   - Cycle time by component

### JQL Queries for Monitoring

```jql
# Unassigned backend tasks
project = REXX AND component = backend-api AND assignee is EMPTY

# Frontend tasks ready for testing
project = REXX AND label = frontend AND status = "Ready for Testing"

# DevOps tasks in progress
project = REXX AND component in (devops-infra, devops-cicd) AND status = "In Progress"

# QA backlog
project = REXX AND component = qa-testing AND status = "To Do"

# Cross-team issues
project = REXX AND component in (backend-api, frontend-ui) AND status != Done
```

## Troubleshooting

### Issue: Tasks Not Auto-Assigning
- Verify component is set correctly
- Check automation rule is enabled
- Confirm role membership is current
- Review rule execution logs

### Issue: Wrong Team Assigned
- Update component default assignee
- Correct the component selection
- Adjust automation rule conditions
- Add missing labels

### Issue: Multiple Teams on One Task
- Consider splitting into subtasks
- Use parent-child relationship
- Assign primary team to parent
- Create subtasks for other teams

## Implementation Checklist

- [ ] Create project roles in Jira
- [ ] Add team members to roles
- [ ] Create all components with default assignees
- [ ] Set up automation rules (6 rules minimum)
- [ ] Create label taxonomy
- [ ] Document spec tagging conventions
- [ ] Create team dashboards
- [ ] Train teams on workflow
- [ ] Test automation with sample issues
- [ ] Monitor and refine rules
