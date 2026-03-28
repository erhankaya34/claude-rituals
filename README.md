# Claude Rituals

Developer rituals for Claude Code. Session management, project setup, context continuity, and parallel tab coordination -- in one plugin.

## The Problem

Long-running projects with Claude Code hit these walls:

1. **Context loss** -- Every new conversation starts from scratch. Yesterday's decisions, gotchas, and progress are gone.
2. **Parallel tab chaos** -- Multiple Claude Code tabs editing the same files cause conflicts, duplicate work, and lost changes.
3. **Discipline decay** -- Commit hygiene, doc freshness, and structured workflows erode over time without enforcement.
4. **Onboarding friction** -- Setting up CLAUDE.md, memory, and context files for a new project is manual and undocumented.

## The Solution: 7 Rituals

| Ritual | What it does | Mutates? |
|--------|-------------|----------|
| `/init` | Detect your stack, generate CLAUDE.md skeleton, set up session tracking | Yes |
| `/session <topic>` | Start work -- sync context, detect conflicts, register tab | Yes |
| `/checkpoint` | Mid-work save -- wip commit + context update | Yes |
| `/endofsession` | Close session -- group commits, update docs, anchor for recap | Yes |
| `/recap` | "Where was I?" -- recover context from previous sessions | Read-only |
| `/status` | Project health dashboard -- git, docs, memory at a glance | Read-only |
| `/handoff` | Generate context transfer document for another developer | Yes |

## Install

### Option A: Claude Code Plugin (recommended)

```
/plugin marketplace add erhankaya34/claude-rituals
/plugin install claude-rituals@erhankaya34
```

Commands are available as `/claude-rituals:init`, `/claude-rituals:session`, etc.

### Option B: Manual (fallback)

```bash
git clone https://github.com/erhankaya34/claude-rituals.git
cd claude-rituals
./install.sh --global    # All projects
./install.sh --project /path/to/project  # Single project
```

Commands are available as `/init`, `/session`, etc. (no namespace prefix).

## Quick Start

```
1. /claude-rituals:init              # Set up your project (one-time)
2. /claude-rituals:session auth flow  # Start working on something
3. ... work ...
4. /claude-rituals:checkpoint         # Save progress mid-work
5. ... more work ...
6. /claude-rituals:endofsession       # Close session, commit, document
7. ... next day ...
8. /claude-rituals:recap              # Pick up where you left off
```

## Rituals in Detail

### /init -- Project Setup

Detects your tech stack from marker files (package.json, Gemfile, pubspec.yaml, go.mod, etc.), analyzes directory structure, and generates:

- **CLAUDE.md** -- Tailored project skeleton with stack-specific conventions
- **.claude/ACTIVE_CONTEXT.md** -- Session tracking file

If your project already has a CLAUDE.md, the skeleton is saved to `.claude/CLAUDE_SKELETON.md` as a merge reference.

Supported stacks: Flutter, Node.js/TypeScript, Python, Ruby/Rails, Go, Rust, Java/Kotlin, PHP, Elixir, C#/.NET, C/C++.

### /session -- Start Work

Syncs context from other tabs, checks for file conflicts, registers your tab:

```
Tab 1 | Branch: main | Topic: auth flow
Active tabs: none
Conflict: none
```

If your last session was over 24 hours ago, it suggests running `/recap` first.

### /checkpoint -- Mid-Work Save

Quick wip commit with context update. Stages files individually (never `git add .`), excludes sensitive files:

```
Checkpoint: 3 files committed. wip: auth middleware done
```

### /endofsession -- Close Session

Groups all changes into logical conventional commits (backend first, then data layer, UI, docs last). Updates project documentation. Writes a session anchor for `/recap`.

Supports `--this` flag for closing a single tab in parallel work -- commits only that tab's files.

### /recap -- Where Was I?

Reads your last session anchor, git log, ACTIVE_CONTEXT, development log, and memory files. Synthesizes into:

```
RECAP | Last session: 2026-03-28 18:30 | 8 commits since then

What was done:
- Added auth middleware and login flow
- Fixed redirect bug on token expiry

What's pending:
- OAuth provider integration
- Password reset flow

Suggested next steps:
- Continue OAuth integration (most dependencies resolved)
```

Read-only. Changes nothing. Works even without `/init` -- falls back to git log.

### /status -- Project Health

One-screen dashboard showing git state, active work, doc freshness, and memory stats:

```
STATUS | Branch: main | 2 uncommitted | 5 ahead of origin

Recent commits:
  abc1234 feat: add login screen
  def5678 fix: token refresh logic
  ...

Doc freshness:
  CLAUDE.md          -- 2 days ago
  README.md          -- 38 days ago (stale)

Memory: 8 files (3 project, 2 feedback, 2 gotcha, 1 user)
```

### /handoff -- Context Transfer

Generates a HANDOFF.md pulling from CLAUDE.md, memory, git history, and development log. Includes a "What I Wish I Knew" section derived from gotcha memories.

Perfect for onboarding a new team member or transferring context to your future self.

## Parallel Tab Workflow

The core value of Claude Rituals is safe parallel development across multiple Claude Code tabs:

1. **Tab 1:** `/session backend refactor` -- registers, no conflicts
2. **Tab 2:** `/session UI polish` -- registers, detects no overlap
3. **Tab 1:** `/checkpoint` -- wip commit for backend work
4. **Tab 2:** `/endofsession --this` -- commits only UI work, leaves backend untouched
5. **Tab 1:** `/endofsession` -- commits backend work, closes session

If tabs overlap on files, `/session` warns and suggests git worktrees for isolation.

## How It Works

### ACTIVE_CONTEXT.md

A shared file at `.claude/ACTIVE_CONTEXT.md` tracking:
- Which tabs are active and what they're working on
- Recently completed work
- Ongoing tasks and warnings

Every `/session` reads it, every `/checkpoint` updates it, every `/endofsession` cleans it up.

### Session Anchor

`/endofsession` writes a timestamp to `.claude/last_session`. Next time you run `/recap`, it knows exactly where you left off. Without it, `/recap` falls back to the last 48 hours of git history.

### Commit Discipline

`/endofsession` enforces:
- Logical grouping (backend, data, UI, docs -- separate commits)
- Conventional commit format (`feat:`, `fix:`, `refactor:`)
- No sensitive files (.env, credentials)
- File-by-file staging (never `git add .`)

## Customization

All rituals are markdown files. Edit them to match your project:

- **Commit style** -- Change conventional commits to your team's format
- **Doc detection** -- Add your project's specific documentation files
- **Grouping rules** -- Adjust commit categories for your stack
- **Stack templates** -- Add or modify templates in `templates/stacks/`

## Upgrading from v1

If you previously used `claude-session-protocol`:

1. Remove old commands: `./install.sh --uninstall` (or manually delete session.md, checkpoint.md, endofsession.md from `~/.claude/commands/`)
2. Install the plugin: `/plugin marketplace add erhankaya34/claude-rituals`
3. Run `/claude-rituals:init` on your existing projects

Your ACTIVE_CONTEXT.md files are compatible -- no migration needed.

## File Structure

```
claude-rituals/
  .claude-plugin/
    plugin.json              Plugin manifest
    marketplace.json         Marketplace definition
  commands/
    init.md                  /claude-rituals:init
    session.md               /claude-rituals:session
    checkpoint.md            /claude-rituals:checkpoint
    endofsession.md          /claude-rituals:endofsession
    recap.md                 /claude-rituals:recap
    status.md                /claude-rituals:status
    handoff.md               /claude-rituals:handoff
  templates/
    ACTIVE_CONTEXT.md        Session tracking template
    CLAUDE_SKELETON.md       Generic CLAUDE.md skeleton
    stacks/                  Stack-specific convention hints
      flutter.md, node.md, python.md, ruby.md,
      go.md, rust.md, java.md
  install.sh                 Fallback installer
  LICENSE                    MIT
```

## Requirements

- Claude Code (CLI, desktop app, web app, or IDE extension)
- Git

## License

MIT
