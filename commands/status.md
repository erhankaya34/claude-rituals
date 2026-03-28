# Status

Project health dashboard. Shows git state, active work, documentation freshness, and memory stats at a glance. Read-only -- changes nothing.

---

## 0. Pre-flight

1. Check if `.claude/ACTIVE_CONTEXT.md` exists
2. If missing: note it in the output but continue with available information
3. Check if this is a git repository (`git rev-parse --git-dir`). If not: report "Not a git repository" and stop.

## 1. Git State

Gather and display:
- Current branch name
- Uncommitted changes: count of modified, staged, and untracked files
- Remote sync: commits ahead/behind remote (if remote exists)
- Last 5 commits: `git log --oneline -5`

## 2. Active Work

1. Read `.claude/ACTIVE_CONTEXT.md` (if exists)
2. Display:
   - Active tabs table (if any tabs are registered)
   - Ongoing work items
   - Recently completed items (last 3-5)
3. If ACTIVE_CONTEXT.md doesn't exist: display "No session tracking -- run /claude-rituals:init to enable"

## 3. Doc Freshness

Check last-modified dates for these files (skip any that don't exist):
- `CLAUDE.md`
- `README.md`
- `DEVELOPMENT_LOG.md`
- `CHANGELOG.md`
- Architecture/design docs (check `docs/` directory for `.md` files)

For each file found:
- Show relative time since last modification ("3 days ago", "2 months ago")
- Flag as **(stale)** if not modified in 30+ days AND the repo has commits within that period

## 4. Memory Stats

1. Check for Claude memory files (in project memory directory or `.claude/memory/`)
2. If found, count files by type based on frontmatter (`type: user`, `type: feedback`, etc.)
3. Flag entries with modification dates older than 30 days as potentially stale
4. If no memory directory: display "No memory files"

## 5. Dashboard Output

Combine all sections into a compact, scannable dashboard:

```
STATUS | Branch: <branch> | <N> uncommitted | <N> ahead of origin

Recent commits:
  <hash> <message>
  <hash> <message>
  <hash> <message>
  <hash> <message>
  <hash> <message>

Active work:
  <tab table or "no active sessions">

Doc freshness:
  CLAUDE.md            -- <relative time>
  README.md            -- <relative time>
  DEVELOPMENT_LOG.md   -- <relative time> (stale)

Memory: <N> files (<breakdown by type>)
```

Keep it to one screen. No verbose explanations -- data only.

---

## Notes

- Read-only. Does NOT create commits, modify files, or change any state.
- Should complete under 10 seconds.
- Degrades gracefully -- shows whatever information is available.
- Useful as a quick check at any point during development.
