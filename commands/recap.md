# Recap

Recover context from your previous session. Shows what was done, what's pending, and suggests next steps. Read-only -- changes nothing.

**Arguments:** `$ARGUMENTS`

---

## 0. Pre-flight

1. Check if `.claude/ACTIVE_CONTEXT.md` exists
2. If missing: report "No ACTIVE_CONTEXT.md found. Consider running `/claude-rituals:init` to set up session tracking."
3. Continue regardless -- use whatever information is available (git log, filesystem)

## 1. Determine Last Session

1. Check for `.claude/last_session` file (written by `/endofsession`)
2. If found: read the ISO timestamp. This is the "last session" anchor.
3. If NOT found: fall back to 48 hours ago as the anchor. Report: "No session history found -- showing last 48 hours of activity."

## 2. Git Activity

1. Run `git log --oneline --since=<anchor_timestamp>` (or last 48h if no anchor)
2. Summarize:
   - Total number of commits since last session
   - Key changes (group by conventional commit type: feat, fix, refactor, etc.)
   - Branches touched (if not just the current branch)
3. If no commits since anchor: report "No git activity since last session."

## 3. Context State

1. Read `.claude/ACTIVE_CONTEXT.md` (if exists)
2. Extract and report:
   - **Active work:** Any tabs still registered (they may be stale if sessions weren't closed cleanly)
   - **Recently completed:** Last completed items
   - **Ongoing work:** Pending tasks
   - **Warnings:** Any flagged issues
3. If ACTIVE_CONTEXT.md doesn't exist or is empty: skip this section silently

## 4. Development Log

1. Check for `DEVELOPMENT_LOG.md` (or `CHANGELOG.md`, `docs/log.md`) in the project
2. If found: read the last session entry (last `### Session` or `### v` heading)
3. Extract: what was done, gotchas noted, decisions made
4. If not found: skip this section silently

## 5. Memory Scan

1. Check for memory files in the project's Claude memory directory
2. Look for files modified since the last session anchor
3. If recent entries found: highlight new gotchas, feedback, or project notes
4. If no memory directory or no recent entries: skip this section silently

## 6. Synthesis

Output a structured recap. Only include sections that have content -- omit empty sections entirely:

```
RECAP | Last session: <date/time> | <N> commits since then

What was done:
- <commit summaries and development log highlights>

What's pending:
- <from ACTIVE_CONTEXT ongoing work and recently active tabs>

Suggested next steps:
- <prioritized based on context -- what makes sense to work on next>

Warnings:
- <from ACTIVE_CONTEXT warnings, stale docs, unresolved issues>
```

If `$ARGUMENTS` contains a topic keyword, filter and prioritize information related to that topic.

---

## Notes

- Read-only. Does NOT create commits, modify files, or change any state.
- Should complete under 15 seconds.
- Degrades gracefully -- works with just git log if no other context files exist.
- The more consistently `/endofsession` is used, the better recaps become.
