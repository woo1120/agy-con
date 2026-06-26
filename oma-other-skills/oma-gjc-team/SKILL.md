---
name: oma-gjc-team
description: "Multi-agent parallel execution with tmux-based worker coordination, task claiming, worktree isolation, and completion evidence. Forked from @gajae-code/coding-agent team skill, adapted for OMA runtime."
argument-hint: "[--workers N] [--worktree] <task description or plan reference>"
level: 4

source: "forked from upstream team skill and rebranded for GJC"
---

# Team (Multi-Agent Parallel Execution)

Team is the parallel multi-agent execution workflow. It spawns multiple GJC worker agents in separate tmux panes, distributes tasks via a claim-based protocol, optionally isolates each worker in a git worktree, and collects structured completion evidence. A leader agent coordinates the lifecycle.

## Usage

```
/skill:oma-gjc-team "implement the 5 tasks from the ralplan output"
```

## Flags

- `--workers N`: Number of parallel workers to spawn (default: 3, max: 20)
- `--worktree`: Enable git worktree isolation per worker for branch-safe parallel edits

## Core Architecture

### Roles

| Role | Responsibility |
|---|---|
| **Leader** | Creates task plan, spawns workers, monitors progress, handles integration |
| **Worker** | Claims tasks, executes in isolation, reports evidence, heartbeats |

### Phases

| Phase | Description |
|---|---|
| `starting` | Leader initializing, spawning workers |
| `running` | Workers actively executing tasks |
| `awaiting_integration` | All tasks done, waiting for merge/review |
| `complete` | All work integrated and verified |
| `failed` | Unrecoverable failure |
| `cancelled` | Manually cancelled |

### Task Lifecycle

```
pending → in_progress → completed
    ↓         ↓
  blocked   failed
```

### Worker Lifecycle

```
starting → ready → working → draining → stopped
                      ↓
                    failed
```

## Behavior

### 1. Task Planning

When invoked:
1. Decompose the objective into discrete tasks with `id`, `subject`, `title`, `objective`, `description`
2. Identify task dependencies (`depends_on`, `blocked_by`)
3. Optionally assign lanes and required roles
4. Write initial task state

### 2. Worker Spawning

For each worker (up to `--workers N`):
1. Create a tmux pane with the GJC team profile
2. If `--worktree` enabled, create an isolated git worktree per worker
3. Set worker status to `starting` → `ready`
4. Begin heartbeat monitoring

### 3. Task Claiming Protocol

Workers claim tasks via a lease-based protocol:
- Worker requests a `pending` task with no unresolved `blocked_by`
- Leader assigns a claim with `owner`, `token`, and `leased_until`
- Worker holds the lease while executing; heartbeats extend it
- On completion, worker submits structured evidence

### 4. Completion Evidence

Each completed task requires structured evidence:

```json
{
  "summary": "What was done",
  "items": [
    {
      "kind": "command",
      "status": "passed",
      "summary": "Tests pass",
      "command": "npm test",
      "output": "42 tests passed"
    },
    {
      "kind": "artifact",
      "status": "verified",
      "summary": "Component created",
      "artifact": "src/components/Auth.tsx"
    }
  ],
  "files": ["src/components/Auth.tsx", "src/hooks/useAuth.ts"],
  "recorded_by": "worker-1",
  "recorded_at": "2026-01-01T00:00:00Z"
}
```

Evidence item kinds:
- `command`: Shell command execution with output
- `inspection`: Code review or manual check
- `artifact`: File or resource created/modified

Evidence statuses: `passed`, `failed`, `not_run`, `verified`, `rejected`

### 5. Integration Phase

After all tasks complete:
1. Leader enters `awaiting_integration` phase
2. If worktrees were used, merge branches back
3. Run integration tests
4. Resolve any merge conflicts
5. Transition to `complete`

### 6. Shutdown Modes

| Mode | Behavior |
|---|---|
| `graceful` | Wait for in-progress tasks, then stop |
| `force` | Stop all workers immediately |
| `abort` | Kill all workers, mark tasks failed |

## Worktree Isolation

When `--worktree` is enabled:
- Each worker gets an isolated git worktree
- Workers can make commits without conflicting
- Leader handles merge-back during integration
- Worktree paths are tracked in worker state

## Pre-Execution Gate

Team inherits the ralplan pre-execution gate. Underspecified prompts like "team improve the app" are redirected to ralplan for consensus planning before execution begins. See `oma-gjc-ralplan` for gate details.

### Good vs Bad Prompts

**Passes the gate** (specific enough):
- `team fix the null check in src/hooks/bridge.ts:326`
- `team implement issue #42`
- `team add validation to function processKeywordDetector`

**Gated → redirected to ralplan** (needs scoping):
- `team fix this`
- `team build the app`
- `team improve performance`

**Bypass**: Prefix with `force:` or `!`

## Integration with Other Skills

- **ralplan**: Creates the plan that team executes
- **ultragoal**: Tracks team progress at the goal level
- **deep-interview**: Clarifies requirements before team execution

## Environment Variables

| Variable | Purpose |
|---|---|
| `GJC_TEAM_WORKER_CLI` | Override CLI used for worker agents |
| `GJC_TEAM_WORKER_CLI_MAP` | Per-worker CLI override map |
