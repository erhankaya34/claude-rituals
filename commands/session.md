# Session

Start a new work session. Syncs state from other tabs, registers this tab, checks for conflicts.

**Topic:** `$ARGUMENTS`

---

## 0. Pre-flight

1. Check if `.claude/ACTIVE_CONTEXT.md` exists
2. If missing: suggest "Run `/claude-rituals:init` to set up session tracking for this project." Then proceed -- session can still register the tab by creating the file.
3. Check `.claude/last_session` for the last session timestamp
4. If last session was more than 24 hours ago: suggest "It's been a while since your last session. Consider running `/claude-rituals:recap` to review what happened."

## 1. Sync

1. Read `.claude/ACTIVE_CONTEXT.md` in the project root
2. Run `git status` and `git log --oneline -5` to check current state
3. Identify active branch and uncommitted changes
4. Report what other tabs are working on:
   - Active tabs, topics, branches
   - Recently completed work
   - Ongoing work list
5. If no active tabs (clean start): report "Clean start, no active work"

## 2. Conflict Analysis

1. Analyze whether this tab's topic (`$ARGUMENTS`) could overlap files with active tabs
2. Check if multiple tabs are working on the same branch
3. If conflict detected, WARN:
   - Specify which tab and which files might overlap
   - Suggest creating a worktree: `git worktree add ../<project>-<topic> <branch-name>`
   - User decides -- do NOT create automatically
4. If no conflict: report "No conflict, safe to proceed"

## 3. Register

1. Add this tab to the "Active Work" table in `.claude/ACTIVE_CONTEXT.md`:
   - Tab: next available number
   - Branch: current branch
   - Topic: `$ARGUMENTS`
   - Started: date + time (YYYY-MM-DD HH:MM)
2. If `$ARGUMENTS` is empty, ask user: "What will you be working on?"

## 4. Memory Check

- Check memory files for existing info related to this topic (gotchas, feedback, project notes)
- If relevant info found, give brief summary
- If nothing found, SKIP this step (no "nothing found" message)

## 5. Summary

Compact report:
```
Tab N | Branch: <branch> | Topic: <topic>
Active tabs: M (or "none")
Conflict: none (or details)
Related notes: ... (if any)
```

---

## Notes

- This command modifies ONLY `.claude/ACTIVE_CONTEXT.md`
- Does NOT create any commits
- Worktree creation ONLY with user approval
- Should complete within 15 seconds
