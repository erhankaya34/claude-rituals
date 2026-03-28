# Parallel Work Protocol (CLAUDE.md snippet)

> Copy this section into your project's CLAUDE.md to enable session tracking.

---

## Parallel Work Protocol

This project may be developed across multiple parallel Claude Code tabs. Tab coordination uses three slash commands:

- **`/session <topic>`**: Start work in a new tab (sync + register + conflict check)
- **`/checkpoint`**: Mid-work save (wip commit + context update)
- **`/endofsession --this`**: Close single tab (commit + document only this tab's work)
- **`/endofsession`**: Close full session (all tabs, full documentation update)

### Auto-Checkpoint
When a subtask is completed, automatically checkpoint:
- Stage and commit only related files: `git add <file>` + `git commit -m "wip: <description>"`
- Update `.claude/ACTIVE_CONTEXT.md` with current progress
- Do NOT update docs or memory -- those happen at `/endofsession`
- Do this without asking, just give a 1-line summary
- At `/endofsession`, wip commits are organized into logical groups
