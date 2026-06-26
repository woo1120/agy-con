---
name: oma-gjc-ultragoal
description: "Durable goal ledger with per-goal quality gates and completion verification. Forked from @gajae-code/coding-agent ultragoal skill, adapted for OMA runtime."
argument-hint: "<goal objective description>"
level: 4

source: "forked from upstream ultragoal skill and rebranded for GJC"
---

# Ultragoal (Durable Goal Ledger)

Ultragoal is the persistent goal-tracking workflow. It decomposes a high-level objective into discrete goals, tracks each through a state machine (`pending → active → complete/failed/blocked/superseded`), and enforces per-goal quality gates with cryptographic completion verification receipts. Goals persist across session interruptions via durable `.gjc/ultragoal/` state on disk.

## Usage

```
/skill:oma-gjc-ultragoal "build the authentication module with OAuth2 support"
```

## Core Concepts

### Goal Modes

- **aggregate**: Single GJC objective covering all goals. One final receipt covers the entire plan.
- **per-story**: Each goal gets its own completion receipt with independent quality gate verification.

### Goal Statuses

| Status | Meaning |
|---|---|
| `pending` | Not yet started |
| `active` | Currently being worked on |
| `complete` | Finished and verified |
| `failed` | Attempted but failed |
| `blocked` | Waiting on external dependency |
| `review_blocked` | Needs human review before proceeding |
| `superseded` | Replaced by a newer goal |

### Durable State

State is persisted in the `.gjc/ultragoal/` directory:

```
.gjc/ultragoal/
├── brief.json     # Plan metadata (objective, mode, timestamps)
├── goals.json     # Goal array with status, evidence, verification
└── ledger.jsonl   # Append-only event log for auditability
```

## Behavior

### 1. Plan Creation

When invoked with an objective:
1. Decompose the objective into discrete, testable goals
2. Assign each goal a unique ID, title, and objective description
3. Set initial status to `pending`
4. Write the plan to `.gjc/ultragoal/brief.json` and `.gjc/ultragoal/goals.json`
5. Initialize the ledger at `.gjc/ultragoal/ledger.jsonl`

### 2. Goal Execution

For each schedulable goal (status ∈ {`pending`, `active`, `failed`}):
1. Transition to `active` and log the event
2. Execute the goal's objective
3. Collect evidence (command outputs, test results, artifacts)
4. Evidence must meet minimum substantive thresholds:
   - At least 5 words
   - At least 32 characters

### 3. Completion Verification

Each goal completion requires a cryptographic receipt:
- `qualityGateHash`: Hash of the quality criteria used
- `gjcGoalSnapshotHash`: Hash of the goal state at checkpoint time
- `planGeneration`: Hash of the full plan for drift detection
- Basis fields linking to the ledger state before checkpoint

### 4. Guard System

The ultragoal guard (`ultragoal-guard.ts`) prevents premature completion claims:

| Guard State | Meaning |
|---|---|
| `inactive` | No ultragoal plan exists |
| `unrelated_goal` | Current objective doesn't match any plan goal |
| `active_verified_complete` | Goal completed with valid receipt |
| `active_missing_receipt` | Goal claims complete but has no receipt |
| `active_stale_receipt` | Receipt exists but plan has changed since |
| `active_missing_final_receipt` | Per-story goals done but no aggregate receipt |
| `active_dirty_quality_gate` | Receipt hash doesn't match current quality criteria |
| `active_review_blocked_unrecorded` | Review needed but not logged |
| `unreadable_fail_closed` | State files corrupted; fail closed for safety |

### 5. Snapshot Validation

Goal snapshots have temporal bounds:
- Maximum age: 10 minutes
- Maximum future skew: 1 minute

Snapshots outside these bounds are rejected to prevent replay attacks on completion claims.

## Execution Policy

- Goals execute sequentially unless explicitly marked as parallelizable
- Failed goals can be retried (status returns to `active`)
- Superseded goals are excluded from completion calculations
- The plan is considered complete only when ALL non-superseded goals have valid completion receipts
- All state transitions are logged to the append-only ledger

## Integration with Other Skills

- **ralplan**: Use ralplan to create the initial plan, then ultragoal to track execution
- **team**: Use team for parallel execution of independent ultragoal goals
- **deep-interview**: Use deep-interview to clarify vague objectives before creating an ultragoal plan

## Planning/Execution Boundary

Ultragoal is both a planning and execution tracker. It creates the goal structure (planning) and monitors progress through quality-gated completion (execution). The quality gate system ensures that no goal is marked complete without verifiable evidence.
