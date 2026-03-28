# Checkpoint

Mid-work save point. Creates a wip commit and updates ACTIVE_CONTEXT. Does NOT update docs or memory.

**Description:** `$ARGUMENTS`

---

## 1. Commit

1. List changes with `git status`
2. Stage changed files individually (`git add <file>` -- never `git add .` or `git add -A`)
3. Do NOT commit sensitive files (.env, credentials, secrets, API keys)
4. Commit message:
   - Format: `wip: <short description>`
   - Use `$ARGUMENTS` if provided, otherwise derive from changes
5. If no changes (clean working tree): say "Checkpoint unnecessary, no changes" and stop

## 2. Update ACTIVE_CONTEXT

- Update this tab's row in `.claude/ACTIVE_CONTEXT.md` with last activity time
- Do NOT change anything else

## 3. Report

Single-line summary:
```
Checkpoint: N files committed. wip: <message>
```

---

## Notes

- Does NOT update project docs
- Does NOT update memory
- Does NOT close the session
- Should complete within 10 seconds
