# Handoff

Generate a context transfer document for another developer (or your future self in a new environment). Pulls from all available project context to create a comprehensive HANDOFF.md.

**Arguments:** `$ARGUMENTS`

---

## 0. Pre-flight

1. Check if `HANDOFF.md` already exists in the project root
2. If it exists, ask the user: "A previous handoff exists. Overwrite it, or create HANDOFF-<today's date>.md instead?"
3. Wait for user decision before proceeding.
4. If `.claude/ACTIVE_CONTEXT.md` doesn't exist: note it but continue -- use git and filesystem for context

## 1. Gather Sources

Read all available context (skip any that don't exist):

- **CLAUDE.md** -- Project overview, tech stack, conventions, current status
- **ACTIVE_CONTEXT.md** -- Active work, recently completed, ongoing tasks, warnings
- **Git history** -- `git log --oneline -20` for recent activity, `git log --format='%an' | sort -u` for contributors
- **README.md** -- Project description, setup instructions
- **Memory files** -- Gotcha/feedback memories for "What I Wish I Knew" section
- **DEVELOPMENT_LOG.md** -- Recent session notes, key decisions
- **Package/dependency files** -- Tech stack details (package.json, Gemfile, etc.)
- **CI config** -- Build/deploy commands

## 2. Generate Document

Create a structured handoff document with these sections. Omit any section where no relevant information was found:

```markdown
# Project Handoff -- <project name>
Generated: <date>

## Project Overview
<From CLAUDE.md or README.md. Brief description of what the project does,
who it's for, and its current phase.>

## Tech Stack
<Languages, frameworks, key dependencies. From package files and CLAUDE.md.>

## Current State
<What's in progress, what's recently completed, what's pending.
From ACTIVE_CONTEXT.md and recent git history.>

## How to Get Started
<Build commands, environment setup, test commands, dev server.
From README.md, Makefile, CI config, or package.json scripts.>

## What I Wish I Knew
<Derived from gotcha and feedback memory files. Common pitfalls,
non-obvious patterns, things that break in surprising ways.
OMIT THIS SECTION ENTIRELY if no gotcha/feedback memories exist.>

## Key Decisions
<Important architectural, product, or technical decisions and their rationale.
From CLAUDE.md, memory files, and development log.>

## Next Steps
<Prioritized list of what should be worked on next.
From ACTIVE_CONTEXT.md ongoing work and development log.>
```

## 3. Write File

1. Save to project root as `HANDOFF.md` (or `HANDOFF-<date>.md` if user chose not to overwrite)
2. Report: "Handoff document written to <path> (<N> lines)"
3. Suggest: "Review the document and commit it if you want to share it: `git add HANDOFF.md && git commit -m 'docs: add project handoff document'`"

---

## Notes

- Creates one markdown file. Does NOT commit it -- developer decides whether and when to commit.
- Should complete under 30 seconds.
- The quality of the handoff depends on the richness of project context (CLAUDE.md, memory, development log).
- Projects that consistently use `/endofsession` produce better handoffs.
