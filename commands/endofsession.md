# End of Session Protocol

Signals the end of a work session. Groups changes into logical commits, updates project documentation, and updates memory.

**Arguments:** `$ARGUMENTS`

---

## 0. Mode Detection

Check if `$ARGUMENTS` contains `--this`.

### `--this` mode (Tab-Scoped Session End)
When working in parallel tabs, this mode commits and documents **only the work done in this tab**. Does not touch other tabs' changes.

**Scope determination:**
1. Identify which files were worked on in this conversation (from conversation history, tool usage)
2. List all changes with `git status`
3. Commit **only files worked on in this tab** -- leave others unstaged
4. If unsure about a file (could have been touched by multiple tabs), ask the user
5. In docs updates, write **only about this tab's work**

**ACTIVE_CONTEXT.md update:**
- Remove this tab's row from "Active Work" table
- Add to "Recently Completed" list
- Do NOT touch other tabs' rows

### Normal mode (full session close)
If no `--this`, apply all steps below normally (covers all changes).
In normal mode also: reset ACTIVE_CONTEXT.md (mark all tabs completed, clear "Active Work" table).

---

## 1. Group and Commit Changes

### Analysis
- Review all changes with `git status` and `git diff --stat` (`--this` mode: only this tab's files)
- List untracked, modified, and deleted files
- Identify sensitive files (`.env`, credentials, secrets) and exclude from commits
- **If wip commits exist:** Check `git log --oneline` for `wip:` commits. Organize them into logical groups. Do NOT use interactive rebase -- create new commits or amend the last wip

### Grouping Rules
- Split changes into **logical units** -- as incremental as possible
- Typical groups:
  - **Backend:** Migrations, API routes, server-side logic, database changes
  - **Data layer:** Models, repositories, services, serializers
  - **State management:** State classes, providers, stores, reducers
  - **UI:** Screens, components, widgets, styles, templates
  - **Config/infra:** Package files, lock files, generated files, CI config
  - **Docs:** Project documentation updates
- Each group = one commit
- If a group is too large, split further

### Commit Message Format
- Use **conventional commits**: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, etc.
- Messages in English
- Short summary (imperative mood, max 72 characters)
- Add body with details if needed
- Write like a normal developer -- natural and technical

### Commit Order
1. Backend/infra changes first
2. Then data layer
3. Then UI
4. Docs last

---

## 2. Update Project Documentation

This step is critical -- the next session's smooth start depends on it.

> **`--this` mode:** Only update docs relevant to this tab's work. Do not update session numbers or general status lines -- leave those for full `/endofsession`.

### Detect and Update
1. Check which documentation files exist in the project root (common: CLAUDE.md, README.md, DEVELOPMENT_LOG.md, CHANGELOG.md, architecture docs)
2. For each relevant doc, update only sections affected by this session's work:
   - **Main project doc** (CLAUDE.md or similar): Update status counters, version numbers, feature lists
   - **Development log** (if exists): Add session entry with what was done, gotchas, decisions
   - **Architecture docs** (if exists and changed): Update schemas, API docs, component structure
   - **Changelog** (if exists): Add entries for user-facing changes
3. **Only update relevant files** -- if backend wasn't touched, skip backend docs

### What to Document (IMPORTANT)
Always document these in detail:
- **Abandoned approaches:** Why abandoned? What replaced it? Should it not be retried?
- **Bugs and solutions:** Gotchas that could recur in future sessions
- **Architectural decisions:** Why X was chosen over Y, with rationale
- **Workarounds:** Temporary solutions and why they're temporary
- **Discovered limitations:** API limits, platform constraints, etc.

### ACTIVE_CONTEXT.md
- Normal mode: Clear "Active Work" table, consolidate "Ongoing Work"
- Update "Recently Completed" list
- Update "Warnings / Notes" section

---

## 3. Update Memory

> **`--this` mode:** Only update memory related to this tab's topic.

- Update Project Status in memory
- If new patterns/gotchas discovered, add to relevant memory files
- If file structure changed significantly, update
- Keep memory index under 200 lines

---

## 4. Final Check

- Verify nothing was missed with `git status`
- If uncommittable files remain (screenshots, .env, tmp), inform user
- Show commit history with `git log --oneline -10`
- Give brief summary: how many commits, what was updated

> **`--this` mode:** Unstaged files from other tabs are expected. Report as "X files belong to other tabs, left untouched."

---

## Notes

- If no changes (clean working tree): just state this, don't create empty commits
- Commit all docs updates as a separate commit (`docs: update project docs with session N notes`)
- If wip commits exist, they should be organized before session close (see Section 1)
- Give user a brief "session summary" when done
