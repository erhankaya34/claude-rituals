---
title: "feat: Claude Rituals v2 -- All-in-One Claude Code Enhancer"
type: feat
status: completed
date: 2026-03-29
origin: docs/brainstorms/2026-03-29-claude-rituals-v2-requirements.md
---

# Claude Rituals v2 -- All-in-One Claude Code Enhancer

## Overview

Transform "claude-session-protocol" (3 session management commands) into "Claude Rituals" -- a native Claude Code plugin with 7 rituals that solve context loss, parallel tab chaos, project discipline decay, and onboarding friction. Distribution via Claude Code plugin marketplace.

## Problem Statement / Motivation

Claude Code starts every conversation from scratch. Long-running projects lose context between sessions, parallel tabs cause conflicts, commit hygiene degrades, and setting up a project for Claude Code is manual busywork. Claude Rituals v1 partially solved parallel tab coordination. v2 expands to be the all-in-one Claude Code power user kit.

(see origin: `docs/brainstorms/2026-03-29-claude-rituals-v2-requirements.md` -- Problem Frame)

## Proposed Solution

7 rituals distributed as a native Claude Code plugin:

| Ritual | Category | Mutates? | Purpose |
|--------|----------|----------|---------|
| `/init` | Setup | Yes (creates files) | Bootstrap project for Claude Code |
| `/session` | Lifecycle | Yes (ACTIVE_CONTEXT) | Start work, sync tabs, detect conflicts |
| `/checkpoint` | Lifecycle | Yes (wip commit) | Mid-work save point |
| `/endofsession` | Lifecycle | Yes (commits, docs) | Close session with structured commits |
| `/recap` | Intelligence | No (read-only) | "Where was I?" context recovery |
| `/status` | Intelligence | No (read-only) | Project health dashboard |
| `/handoff` | Intelligence | Yes (creates HANDOFF.md) | Context transfer document |

## Technical Approach

### Target File Structure

```
claude-rituals/
  .claude-plugin/
    plugin.json                  -- Plugin manifest
    marketplace.json             -- Marketplace definition
  commands/
    init.md                      -- /claude-rituals:init
    session.md                   -- /claude-rituals:session
    checkpoint.md                -- /claude-rituals:checkpoint
    endofsession.md              -- /claude-rituals:endofsession
    recap.md                     -- /claude-rituals:recap
    status.md                    -- /claude-rituals:status
    handoff.md                   -- /claude-rituals:handoff
  templates/
    ACTIVE_CONTEXT.md            -- Starter template
    CLAUDE_SKELETON.md           -- Generic CLAUDE.md skeleton
    stacks/
      flutter.md                 -- Flutter/Dart hints for CLAUDE.md
      node.md                    -- Node.js/TypeScript hints
      python.md                  -- Python hints
      ruby.md                    -- Ruby/Rails hints
      go.md                      -- Go hints
      rust.md                    -- Rust hints
      java.md                    -- Java/Kotlin hints
  install.sh                     -- Fallback installer (all 7 commands)
  LICENSE
  README.md
```

### Plugin Manifest

`.claude-plugin/plugin.json`:
```json
{
  "name": "claude-rituals",
  "version": "2.0.0",
  "description": "Session management, project setup, and context continuity for Claude Code",
  "author": {
    "name": "Erhan Kaya"
  },
  "repository": "https://github.com/erhankaya34/claude-rituals",
  "license": "MIT",
  "keywords": ["session", "workflow", "productivity", "rituals"]
}
```

`.claude-plugin/marketplace.json`:
```json
{
  "name": "claude-rituals-marketplace",
  "owner": {
    "name": "Erhan Kaya"
  },
  "plugins": [
    {
      "name": "claude-rituals",
      "source": ".",
      "description": "Session management, project setup, and context continuity for Claude Code",
      "version": "2.0.0"
    }
  ]
}
```

### Key Design Decisions from SpecFlow Analysis

1. **Drop R11** (see origin: R11): `/init` will NOT copy command files to `.claude/commands/`. Plugin is the single source of truth. Avoids version divergence between local copies and plugin updates. `install.sh` serves non-plugin users who get all 7 commands locally.

2. **Drop R30** (see origin: R30): `/endofsession` will NOT remind about `/status`. Enforcing read-only principle for `/status` and `/recap` is more important than a nag reminder. `/status` is promoted through `/init` output and README instead.

3. **Recap anchor**: `/endofsession` writes `.claude/last_session` timestamp file. `/recap` reads this. Fallback: last 48 hours of git log when file is missing.

4. **/init with existing CLAUDE.md**: Generate skeleton as `.claude/CLAUDE_SKELETON.md` (reference file to merge from), do NOT overwrite existing CLAUDE.md.

5. **Graceful degradation**: All 4 new rituals work at some level even without `/init`. They degrade to git history + filesystem analysis and suggest `/init` in output.

6. **install.sh installs all 7**: No degraded experience for fallback users.

## Implementation Phases

### Phase 1: Plugin Infrastructure & Rebrand

Restructure the repo from a loose collection of files into a proper Claude Code plugin.

**Tasks:**

- [ ] Create `.claude-plugin/plugin.json` with manifest (see schema above)
- [ ] Create `.claude-plugin/marketplace.json` with marketplace definition
- [ ] Move existing `commands/` to plugin root (already in correct location)
- [ ] Rename repo references from "claude-session-protocol" to "claude-rituals"
- [ ] Update `install.sh`:
  - Use glob `cp "$COMMANDS_SRC"/*.md "$target/"` instead of hardcoded 3 files
  - Update banner text and messages to "Claude Rituals"
  - Add `--uninstall` flag (removes command files)
  - Add version echo
- [ ] Remove `templates/claude-md-snippet.md` (replaced by `/init` ritual)
- [ ] Create `templates/CLAUDE_SKELETON.md` -- generic CLAUDE.md skeleton

**Files created/modified:**
- `NEW: .claude-plugin/plugin.json`
- `NEW: .claude-plugin/marketplace.json`
- `MODIFIED: install.sh`
- `DELETED: templates/claude-md-snippet.md`
- `NEW: templates/CLAUDE_SKELETON.md`

**Success criteria:** `plugin.json` is valid. install.sh copies all command files.

---

### Phase 2: /init Ritual

The gateway ritual -- first thing a developer runs. Must be impressive.

**Tasks:**

- [ ] Write `commands/init.md` with these sections:
  - `## 0. Pre-flight Check`: Check if `.claude/ACTIVE_CONTEXT.md` exists. If yes, report "Already initialized" and offer to re-detect stack / regenerate skeleton.
  - `## 1. Stack Detection`: Check for marker files in priority order:

    | Marker File | Stack | Key Sections |
    |-------------|-------|-------------|
    | `pubspec.yaml` | Flutter/Dart | Widget architecture, state mgmt, platform channels |
    | `package.json` | Node.js/TypeScript | Framework (React/Next/Vue/Express), bundler, test runner |
    | `Gemfile` | Ruby/Rails | Rails conventions, ActiveRecord, background jobs |
    | `go.mod` | Go | Package structure, concurrency patterns, error handling |
    | `requirements.txt` / `pyproject.toml` | Python | Framework (Django/Flask/FastAPI), type hints, virtual envs |
    | `Cargo.toml` | Rust | Ownership patterns, unsafe usage, feature flags |
    | `pom.xml` / `build.gradle` | Java/Kotlin | Build tool, dependency injection, project structure |
    | `composer.json` | PHP | Framework (Laravel/Symfony), PSR standards |
    | `mix.exs` | Elixir | OTP patterns, GenServer usage |
    | `*.csproj` / `*.sln` | C# / .NET | Project structure, NuGet packages |

  - `## 2. Directory Analysis`: Scan for `src/`, `lib/`, `app/`, `test/`, `spec/`, `.github/`, `docker-compose.yml`, `Makefile`, etc. Determine project layout pattern.
  - `## 3. Config Scan`: Read `.gitignore` (detect sensitive file patterns), CI config (detect test/deploy commands), existing README (extract project description).
  - `## 4. Generate CLAUDE.md`:
    - If CLAUDE.md does NOT exist: Create CLAUDE.md from `templates/CLAUDE_SKELETON.md` + stack-specific hints from `templates/stacks/<stack>.md`
    - If CLAUDE.md already exists: Generate `.claude/CLAUDE_SKELETON.md` as a reference. Tell developer: "Your project already has a CLAUDE.md. A skeleton with detected stack info was saved to `.claude/CLAUDE_SKELETON.md` -- compare and merge what's useful."
  - `## 5. Create Context Files`: Create `.claude/ACTIVE_CONTEXT.md` from template (skip if exists).
  - `## 6. Summary`: Output what was detected and created. List the 7 available rituals with one-line descriptions. Suggest next steps: "Customize your CLAUDE.md, then run `/claude-rituals:session <topic>` to start working."
  - `## Notes`: Does NOT create commits. Does NOT push to remote. Should complete under 60 seconds.

- [ ] Write `templates/CLAUDE_SKELETON.md` -- generic skeleton with placeholder sections:
  - Project Summary (name, description, tech stack)
  - Code Conventions (detected from stack)
  - Development Process (session management workflow)
  - Current Status (blank, developer fills)
  - File Structure (detected from directory analysis)

- [ ] Write stack hint files in `templates/stacks/`:
  - Each file is a markdown snippet with stack-specific CLAUDE.md sections
  - NOT full CLAUDE.md templates -- just the sections that differ per stack
  - Example: `flutter.md` includes widget composition rules, state management patterns, platform-specific notes
  - Example: `node.md` includes module system (ESM/CJS), framework conventions, test patterns

**Files created:**
- `NEW: commands/init.md`
- `NEW: templates/CLAUDE_SKELETON.md`
- `NEW: templates/stacks/flutter.md`
- `NEW: templates/stacks/node.md`
- `NEW: templates/stacks/python.md`
- `NEW: templates/stacks/ruby.md`
- `NEW: templates/stacks/go.md`
- `NEW: templates/stacks/rust.md`
- `NEW: templates/stacks/java.md`

**Success criteria:** Running `/claude-rituals:init` on a Node.js project creates a CLAUDE.md with Node-specific sections, .claude/ACTIVE_CONTEXT.md, and outputs a clear summary.

---

### Phase 3: /recap Ritual

The highest-value new ritual. Makes returning to a project frictionless.

**Tasks:**

- [ ] Write `commands/recap.md` with these sections:
  - `## 0. Pre-flight`: Check for `.claude/ACTIVE_CONTEXT.md`. If missing, suggest `/init` but continue with whatever is available.
  - `## 1. Determine Last Session`: Read `.claude/last_session` file (written by `/endofsession`). If missing, fall back to scanning the last 48 hours of git log.
  - `## 2. Git Activity`: Run `git log --oneline --since=<last_session>` (or last 48h). Summarize: N commits, key changes, branches touched.
  - `## 3. Context State`: Read ACTIVE_CONTEXT.md -- active work, recently completed, ongoing tasks, warnings.
  - `## 4. Development Log`: If DEVELOPMENT_LOG.md (or similar) exists, read the last session entry. Extract: what was done, gotchas, decisions.
  - `## 5. Memory Scan`: Check memory files for recent entries (modified since last session). Highlight new gotchas, feedback, project notes.
  - `## 6. Synthesis`: Output a structured recap:
    ```
    RECAP | Last session: <date> | <N> commits since then

    What was done:
    - ...

    What's pending:
    - ...

    Suggested next steps:
    - ...

    Warnings:
    - ... (if any)
    ```
  - `## Notes`: Read-only. Does NOT create commits, modify files, or change any state. Should complete under 15 seconds.

**Files created:**
- `NEW: commands/recap.md`

**Success criteria:** A developer returning after a day off runs `/recap` and gets a complete picture of where they left off within 15 seconds.

---

### Phase 4: /status Ritual

Quick project health snapshot -- the "dashboard glance."

**Tasks:**

- [ ] Write `commands/status.md` with these sections:
  - `## 0. Pre-flight`: Same graceful degradation as /recap.
  - `## 1. Git State`: Current branch, uncommitted changes (count), commits ahead/behind remote, last 5 commits (one-line).
  - `## 2. Active Work`: Read ACTIVE_CONTEXT.md -- active tabs table, ongoing work list.
  - `## 3. Doc Freshness`: Check last-modified dates of key docs. Flag docs not updated in 30+ days if repo has recent commits. Check: CLAUDE.md, DEVELOPMENT_LOG.md, architecture docs, README.md.
  - `## 4. Memory Stats`: Count memory files by type (user, feedback, project, reference, gotcha). Flag entries older than 30 days as potentially stale.
  - `## 5. Dashboard Output`:
    ```
    STATUS | Branch: main | 3 uncommitted files | 2 ahead of origin

    Recent commits:
      abc1234 feat: add user auth
      def5678 fix: login redirect
      ...

    Active work:
      Tab 1 | backend refactor | 2h ago
      Tab 2 | UI polish | 45min ago

    Doc freshness:
      CLAUDE.md          -- 3 days ago
      DEVELOPMENT_LOG.md -- 1 day ago
      README.md          -- 45 days ago (stale)

    Memory: 12 files (4 project, 3 feedback, 2 gotcha, 2 reference, 1 user)
    ```
  - `## Notes`: Read-only. Does NOT create commits, modify files, or change any state. Should complete under 10 seconds.

**Files created:**
- `NEW: commands/status.md`

**Success criteria:** Dashboard renders in under 10 seconds and fits on one screen.

---

### Phase 5: /handoff Ritual

Context transfer for another developer (or future self in a new environment).

**Tasks:**

- [ ] Write `commands/handoff.md` with these sections:
  - `## 0. Pre-flight`: Same graceful degradation. Additionally: if `HANDOFF.md` already exists, ask user: "A previous handoff exists. Overwrite or create HANDOFF-<date>.md?"
  - `## 1. Gather Sources`: Read CLAUDE.md (project overview, tech stack, conventions), ACTIVE_CONTEXT.md (current state), git log (recent 20 commits), memory files (gotchas, feedback, project notes).
  - `## 2. Generate Document`: Create a structured HANDOFF.md:
    ```markdown
    # Project Handoff -- <project name>
    Generated: <date>

    ## Project Overview
    [From CLAUDE.md or detected stack]

    ## Tech Stack
    [Languages, frameworks, key dependencies]

    ## Current State
    [What's in progress, what's recently completed, what's pending]

    ## How to Get Started
    [Build commands, env setup, test commands]

    ## What I Wish I Knew
    [Derived from gotcha/feedback memories -- omit section if none exist]

    ## Key Decisions
    [Important architectural/product decisions from memory or CLAUDE.md]

    ## Next Steps
    [Prioritized list from ACTIVE_CONTEXT and development log]
    ```
  - `## 3. Write File`: Save to project root as `HANDOFF.md` (or `HANDOFF-<date>.md` if overwrite declined). Report path and file size.
  - `## Notes`: Creates one file. Does NOT commit it (developer decides). Should complete under 30 seconds.

**Files created:**
- `NEW: commands/handoff.md`

**Success criteria:** HANDOFF.md gives a new developer everything they need to start contributing without reading the entire codebase.

---

### Phase 6: Upgrade Existing Rituals

Adapt v1 commands to work with the v2 ecosystem.

**Tasks:**

- [ ] Update `commands/session.md`:
  - Add `## 0. Pre-flight` section: Check if `.claude/ACTIVE_CONTEXT.md` exists. If not, suggest `/claude-rituals:init`.
  - In `## 1. Sync`: After reading ACTIVE_CONTEXT, check `.claude/last_session`. If last session was >24h ago, suggest: "It's been a while. Consider running `/claude-rituals:recap` first."
  - Keep all existing behavior intact.

- [ ] Update `commands/endofsession.md`:
  - After `## 4. Final Check`, add a new step: Write current timestamp to `.claude/last_session` (simple ISO date string). This anchors `/recap`'s "last session" detection.
  - In `--this` mode: update `.claude/last_session` only if no other active tabs remain.
  - Keep all existing behavior intact.

- [ ] Update `commands/checkpoint.md`:
  - Add `## 0. Pre-flight`: If no `.claude/ACTIVE_CONTEXT.md`, warn but proceed with wip commit (primary value is the commit, not the context update).
  - Keep all existing behavior intact.

**Files modified:**
- `MODIFIED: commands/session.md`
- `MODIFIED: commands/endofsession.md`
- `MODIFIED: commands/checkpoint.md`

**Success criteria:** Existing session lifecycle workflow is unbroken. New pre-flight checks are non-blocking suggestions.

---

### Phase 7: README & Documentation

Complete rebrand and documentation refresh.

**Tasks:**

- [ ] Rewrite `README.md` as "Claude Rituals":
  - Hero section: Name, tagline ("Developer rituals for Claude Code"), one-line description
  - Problem section: 4 pain points (context loss, parallel chaos, discipline decay, onboarding friction)
  - Rituals table: All 7 with one-line descriptions
  - Install section: Plugin marketplace (primary) + install.sh (fallback)
  - Quick start: `/init` -> `/session` -> `/checkpoint` -> `/endofsession` -> `/recap`
  - Detailed usage: Each ritual with example input/output
  - Customization guide
  - v1 Migration section: "If upgrading from claude-session-protocol, remove old commands from ~/.claude/commands/ before installing the plugin."
  - Requirements: Claude Code + Git
  - License: MIT

- [ ] Update `templates/ACTIVE_CONTEXT.md`:
  - Add header comment listing all 7 rituals that touch it
  - Keep structure identical

**Files modified:**
- `REWRITE: README.md`
- `MODIFIED: templates/ACTIVE_CONTEXT.md`

**Success criteria:** README makes a developer want to install Claude Rituals within 30 seconds of reading.

---

## Acceptance Criteria

### Functional Requirements

- [ ] Plugin installs via `/plugin marketplace add` + `/plugin install` (SC4)
- [ ] All 7 commands are accessible as `/claude-rituals:<name>`
- [ ] `/init` detects stack and generates CLAUDE.md skeleton under 60 seconds (SC1)
- [ ] `/recap` provides full session context without manual doc reading (SC2)
- [ ] `/status` renders a compact dashboard in under 10 seconds
- [ ] `/handoff` generates a complete HANDOFF.md
- [ ] `/session` + `/checkpoint` + `/endofsession` prevent parallel tab conflicts (SC3)
- [ ] `install.sh --global` installs all 7 commands as fallback
- [ ] All rituals degrade gracefully when `.claude/` files don't exist

### Non-Functional Requirements

- [ ] Zero runtime dependencies (pure markdown prompts + bash installer)
- [ ] No external API calls (everything local)
- [ ] No project-specific logic (works with any language/framework)
- [ ] No analytics or telemetry

### Quality Gates

- [ ] No DuckIn-specific references anywhere in the repo (grep verified)
- [ ] No hardcoded paths (all paths relative to project root)
- [ ] All commands follow consistent structure (title, description, arguments, numbered sections, notes)
- [ ] README has install + usage examples for all 7 rituals
- [ ] v1 migration path documented

## Dependencies & Prerequisites

- Claude Code plugin system with commands/ support (confirmed)
- GitHub repository renamed to `claude-rituals` (or new repo created)
- Git initialized in target projects

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Plugin system changes breaking format | Low | High | install.sh fallback always works |
| Marketplace adoption is low | Medium | Medium | install.sh + manual copy as alternatives |
| /init stack detection misidentifies | Low | Low | Detection is suggestive, developer customizes |
| /recap shows stale info | Medium | Medium | last_session anchor + 48h fallback |
| Namespace verbosity (`/claude-rituals:session`) | Certain | Low | Acceptable tradeoff for distribution. Users can alias with local commands if needed. |

## Sources & References

### Origin

- **Origin document:** [docs/brainstorms/2026-03-29-claude-rituals-v2-requirements.md](docs/brainstorms/2026-03-29-claude-rituals-v2-requirements.md) -- Key decisions: plugin format over npm, commands over skills, "Claude Rituals" naming, medium-depth /init, read-only /recap and /status.

### Internal References

- Existing v1 commands: `commands/session.md`, `commands/checkpoint.md`, `commands/endofsession.md`
- Template: `templates/ACTIVE_CONTEXT.md`
- Installer: `install.sh`

### External References

- Claude Code Plugin docs: https://code.claude.com/docs/en/plugins.md
- Plugin reference: https://code.claude.com/docs/en/plugins-reference.md
- Marketplace system: https://code.claude.com/docs/en/plugin-marketplaces.md
