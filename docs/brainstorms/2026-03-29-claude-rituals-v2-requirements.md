---
date: 2026-03-29
topic: claude-rituals-v2
---

# Claude Rituals v2 -- All-in-One Claude Code Enhancer

## Problem Frame

Claude Code starts every conversation from scratch. Long-running projects suffer from:

1. **Context loss between sessions** -- Claude has no memory of what happened yesterday unless the developer manually maintains CLAUDE.md, memory files, and development logs. Most don't.
2. **Parallel tab chaos** -- Multiple Claude Code tabs editing the same codebase cause merge conflicts, duplicate work, and lost changes. No built-in coordination exists.
3. **Project discipline decay** -- Commit hygiene, documentation freshness, and structured session management require manual effort that erodes over time.
4. **Onboarding friction** -- Setting up a project for Claude Code (CLAUDE.md, memory, context files) is manual and undocumented. Each developer reinvents the wheel.

Claude Rituals v1 solved #2 and partially #3 with 3 commands (session/checkpoint/endofsession). v2 expands to solve all 4 problems with 7 rituals distributed as a native Claude Code plugin.

## Requirements

### Core: Rebrand and Plugin Format
- R1. Rename from "claude-session-protocol" to "claude-rituals"
- R2. Restructure as a native Claude Code plugin with `.claude-plugin/plugin.json` manifest
- R3. All rituals live in `commands/` directory, invoked as `/claude-rituals:<command>`
- R4. Maintain `install.sh` as fallback for users who prefer manual installation to `~/.claude/commands/`
- R5. Publish as a GitHub-based plugin marketplace so users install with `/plugin marketplace add` + `/plugin install`

### Ritual: /init (Project Setup)
- R6. Detect project stack from marker files (pubspec.yaml, package.json, Gemfile, go.mod, requirements.txt, Cargo.toml, pom.xml, etc.)
- R7. Analyze directory structure (src/, lib/, app/, test/ etc.) to understand project layout
- R8. Scan existing config (.gitignore, CI files, existing README) for additional context
- R9. Generate a CLAUDE.md skeleton tailored to the detected stack -- sections for project summary, tech stack, code conventions, development process, current status
- R10. Create `.claude/ACTIVE_CONTEXT.md` from template
- R11. Create `.claude/commands/` with the 3 session lifecycle commands (session, checkpoint, endofsession) so they work without the plugin namespace too
- R12. Output a summary of what was detected and created, with next steps for the developer to customize

### Ritual: /recap (Where Was I?)
- R13. Read git log since last session close (detect from commit messages or ACTIVE_CONTEXT timestamps)
- R14. Read ACTIVE_CONTEXT.md for pending work, recently completed items, warnings
- R15. Read DEVELOPMENT_LOG.md or equivalent if it exists for session notes
- R16. Scan memory files for recent entries
- R17. Synthesize into a structured "recap" output: what was done, what's pending, suggested next steps
- R18. Should be fast (under 15 seconds) -- read-only, no mutations

### Ritual: /status (Project Health Dashboard)
- R19. Git state: current branch, uncommitted changes, commits ahead/behind remote, recent commits (last 5)
- R20. Active work: read ACTIVE_CONTEXT.md for active tabs and ongoing work
- R21. Doc freshness: check last-modified dates of key docs (CLAUDE.md, architecture docs, development log)
- R22. Memory stats: count memory files by type, flag stale entries (older than 30 days)
- R23. Output as a structured dashboard -- compact, scannable, single-screen

### Ritual: /handoff (Context Transfer)
- R24. Generate a structured handoff document: project overview, tech stack, current state, critical gotchas, next steps
- R25. Pull from: CLAUDE.md, ACTIVE_CONTEXT.md, recent git history, memory files
- R26. Output as a markdown file in the project (e.g., `HANDOFF.md`) that can be shared
- R27. Include "what I wish I knew when I started" section derived from gotcha/feedback memories

### Existing Rituals: Upgrade
- R28. Upgrade /session, /checkpoint, /endofsession from v1 to work with the new /init-generated structure
- R29. /session should suggest `/claude-rituals:recap` if context seems stale (e.g., last activity > 24h ago)
- R30. /endofsession should remind about `/claude-rituals:status` if it hasn't been run recently

## Success Criteria

- SC1. A developer with zero Claude Code experience runs `/claude-rituals:init` on an existing project and gets a working CLAUDE.md + session management setup in under 60 seconds
- SC2. A returning developer runs `/claude-rituals:recap` and has full context of where they left off without reading any docs manually
- SC3. Parallel tab work (2+ tabs) produces zero merge conflicts when using /session + /checkpoint + /endofsession
- SC4. The plugin installs with 2 commands: marketplace add + plugin install

## Scope Boundaries

- No MCP servers or runtime dependencies -- rituals are pure markdown prompts
- No project-specific logic -- rituals must work with any language/framework
- No external API calls -- everything is local (git, filesystem, memory)
- /init generates a skeleton CLAUDE.md, not a complete one -- developer customizes it
- /handoff generates a snapshot document, not a live sync
- No analytics/telemetry collection

## Key Decisions

- **Plugin format over npm/curl**: Native Claude Code plugin is the most integrated distribution. install.sh kept as fallback.
- **Commands over Skills**: Commands are user-invoked (explicit), skills are agent-invoked (implicit). Session management should be deliberate, not automatic. Commands are the right choice.
- **"Claude Rituals" naming**: Developer rituals metaphor -- each command is a ritual in the development workflow. Memorable, distinct, non-generic.
- **/init medium depth**: Stack detection + directory structure analysis. Deep enough to generate useful skeletons, not so deep that it's slow or error-prone. No dependency tree analysis.
- **Read-only /recap and /status**: These rituals never mutate state. They observe and report. Mutations happen only in /session, /checkpoint, /endofsession.

## Dependencies / Assumptions

- Claude Code plugin system supports commands/ directory in plugins (confirmed via docs)
- Plugin marketplace is GitHub-based -- no npm registry needed
- Users have git initialized in their projects
- ACTIVE_CONTEXT.md location is `.claude/ACTIVE_CONTEXT.md` (project root)

## Outstanding Questions

### Deferred to Planning
- [Affects R3][Technical] Exact plugin.json schema and marketplace.json structure -- verify against current Claude Code docs
- [Affects R6-R8][Needs research] Full list of stack marker files and what CLAUDE.md sections each stack needs
- [Affects R9][Technical] CLAUDE.md skeleton templates per stack -- how many variants, how much is shared vs stack-specific
- [Affects R13][Technical] How to reliably detect "last session" -- commit message patterns, timestamps, or ACTIVE_CONTEXT entries
- [Affects R26][Technical] /handoff output format -- single HANDOFF.md or stdout? Should it overwrite or append?

## Next Steps

All blocking questions resolved. Ready for planning.

-> `/ce:plan` for structured implementation planning
