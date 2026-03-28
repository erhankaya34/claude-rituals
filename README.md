# Claude Session Protocol

Session management for Claude Code. Track parallel tabs, checkpoint work-in-progress, and close sessions with structured commits and documentation updates.

## The Problem

Long-running projects with Claude Code quickly hit these issues:

- **Context loss between sessions** -- Claude starts fresh each conversation, previous work context is gone
- **Parallel tab conflicts** -- Multiple Claude Code tabs editing the same files cause merge chaos
- **Messy commits** -- Undisciplined wip commits pile up without logical grouping
- **Documentation drift** -- Project docs fall behind the code

## What This Does

Three slash commands that create a disciplined workflow:

| Command | When | What it does |
|---------|------|-------------|
| `/session <topic>` | Start of work | Syncs context, detects conflicts, registers tab |
| `/checkpoint` | During work | Quick wip commit + context update |
| `/endofsession` | End of work | Groups commits, updates docs, updates memory |

### Parallel Tab Support

The protocol tracks active Claude Code tabs via `.claude/ACTIVE_CONTEXT.md`. When you start a new tab, `/session` warns if another tab is working on overlapping files and suggests git worktrees for isolation.

Close a single tab with `/endofsession --this` (commits only that tab's work) or close everything with `/endofsession`.

## Install

### Option A: Global (all projects)

```bash
git clone https://github.com/erhankaya/claude-session-protocol.git
cd claude-session-protocol
./install.sh --global
```

Commands are now available as `/session`, `/checkpoint`, `/endofsession` in every project.

Then, in each project where you want parallel tab tracking:

```bash
mkdir -p .claude
cp templates/ACTIVE_CONTEXT.md .claude/ACTIVE_CONTEXT.md
```

### Option B: Single project

```bash
git clone https://github.com/erhankaya/claude-session-protocol.git
cd claude-session-protocol
./install.sh --project /path/to/your/project
```

### Option C: Manual

Copy the three files from `commands/` into your project's `.claude/commands/` directory:

```bash
cp commands/*.md /path/to/your/project/.claude/commands/
cp templates/ACTIVE_CONTEXT.md /path/to/your/project/.claude/
```

## Setup

After installing, add the parallel work protocol to your project's `CLAUDE.md`. A ready-to-copy snippet is in `templates/claude-md-snippet.md`.

## Usage

### Starting a session

```
/session implement auth flow
```

Output:
```
Tab 1 | Branch: main | Topic: implement auth flow
Active tabs: none
Conflict: none
```

### Mid-work checkpoint

```
/checkpoint auth middleware done
```

Output:
```
Checkpoint: 3 files committed. wip: auth middleware done
```

### Closing a single tab (parallel work)

```
/endofsession --this
```

Commits only files you worked on in this tab. Other tabs' unstaged changes are left untouched.

### Closing the full session

```
/endofsession
```

Groups all wip commits into logical conventional commits, updates project docs, updates memory, gives a session summary.

## How It Works

### ACTIVE_CONTEXT.md

A shared file at `.claude/ACTIVE_CONTEXT.md` that tracks:
- Which tabs are active and what they're working on
- Recently completed work
- Ongoing tasks
- Warnings (pending deploys, risky state, etc.)

This file is the "shared brain" between parallel tabs. Each `/session` reads it, each `/checkpoint` updates it, each `/endofsession` cleans it up.

### Commit Discipline

`/endofsession` enforces:
- Logical grouping (backend, data layer, UI, docs -- separate commits)
- Conventional commit format (`feat:`, `fix:`, `refactor:`, etc.)
- No sensitive files committed (.env, credentials)
- File-by-file staging (never `git add .`)

### Documentation Updates

`/endofsession` automatically detects project docs (CLAUDE.md, DEVELOPMENT_LOG.md, architecture docs, etc.) and updates relevant sections. It documents gotchas, abandoned approaches, and architectural decisions so future sessions start with full context.

## File Structure

```
claude-session-protocol/
  commands/
    session.md          -- /session slash command
    checkpoint.md       -- /checkpoint slash command
    endofsession.md     -- /endofsession slash command
  templates/
    ACTIVE_CONTEXT.md   -- Starter template for tab tracking
    claude-md-snippet.md -- Copy-paste block for your CLAUDE.md
  install.sh            -- Installer script
  LICENSE               -- MIT
  README.md
```

## Customization

The commands are plain markdown files -- edit them to match your project's conventions:

- **Commit message style**: Change conventional commits to your team's format
- **Doc files**: Add your project's specific documentation files to the endofsession detection list
- **Grouping rules**: Adjust commit grouping categories for your stack
- **Language**: Commands are in English but can be translated

## Requirements

- Claude Code (CLI, desktop app, or IDE extension)
- Git

## License

MIT
