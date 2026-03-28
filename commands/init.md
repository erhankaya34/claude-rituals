# Init

Bootstrap a project for Claude Code. Detects your tech stack, generates a CLAUDE.md skeleton, and sets up session management context files.

**Arguments:** `$ARGUMENTS`

---

## 0. Pre-flight Check

1. Check if `.claude/ACTIVE_CONTEXT.md` already exists in the project root
2. If it exists:
   - Report: "This project is already initialized."
   - Offer: "Re-detect stack and regenerate skeleton? (This will not overwrite your existing CLAUDE.md)"
   - If user declines, stop here
3. If `$ARGUMENTS` contains `--force`, skip the check and proceed

## 1. Stack Detection

Check the project root for these marker files. Detect ALL present (monorepo support):

| Marker File | Stack | What to Extract |
|-------------|-------|----------------|
| `pubspec.yaml` | Flutter/Dart | Dependencies, SDK version |
| `package.json` | Node.js/TypeScript | Framework (check for react, next, vue, express, etc.), test runner, bundler |
| `Gemfile` | Ruby/Rails | Rails version, key gems, Ruby version |
| `go.mod` | Go | Module path, Go version |
| `requirements.txt` or `pyproject.toml` | Python | Framework (django, flask, fastapi), Python version |
| `Cargo.toml` | Rust | Edition, key dependencies |
| `pom.xml` or `build.gradle` or `build.gradle.kts` | Java/Kotlin | Build tool, framework (Spring, Android) |
| `composer.json` | PHP | Framework (laravel, symfony) |
| `mix.exs` | Elixir | OTP app type, key deps |
| `*.csproj` or `*.sln` | C# / .NET | Target framework, project type |
| `Makefile` or `CMakeLists.txt` | C/C++ | Build system |

If no marker file found: report "No recognized stack detected" and generate a generic CLAUDE.md skeleton.

If multiple marker files found (monorepo): list all detected stacks.

## 2. Directory Analysis

Scan the project for structural patterns:

- **Source directories:** `src/`, `lib/`, `app/`, `pkg/`, `internal/`, `cmd/`
- **Test directories:** `test/`, `tests/`, `spec/`, `__tests__/`, `test_*`
- **Config directories:** `.github/`, `.gitlab-ci.yml`, `.circleci/`, `Dockerfile`, `docker-compose.yml`
- **Documentation:** `docs/`, `README.md`, `CHANGELOG.md`
- **Environment:** `.env.example`, `.env.sample`

Build a summary of the project layout pattern (e.g., "Standard Rails app with app/ structure" or "Monorepo with packages/ workspace").

## 3. Config Scan

Read these files (if they exist) for additional context:

- `.gitignore` -- Identify sensitive file patterns and what's excluded
- CI config (`.github/workflows/*.yml`, `.gitlab-ci.yml`, etc.) -- Extract test commands, deploy targets
- `README.md` -- Extract project name and description (first heading and paragraph)
- `Makefile` -- Extract available targets (common commands)

## 4. Generate CLAUDE.md

### If CLAUDE.md does NOT exist:

1. Read `templates/CLAUDE_SKELETON.md` from the plugin directory (use `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE_SKELETON.md`)
2. Fill in placeholders with detected information:
   - `{{PROJECT_NAME}}` -- from README.md heading or directory name
   - `{{DESCRIPTION}}` -- from README.md first paragraph or "TODO: Add project description"
   - `{{STACK}}`, `{{LANGUAGE}}`, `{{FRAMEWORK}}` -- from stack detection
   - `{{STACK_CONVENTIONS}}` -- read the matching `templates/stacks/<stack>.md` hint file and insert its content
   - `{{FILE_STRUCTURE}}` -- from directory analysis (top 2 levels)
   - `{{DATE}}` -- current date
   - `{{DECISION}}`, `{{RATIONALE}}` -- leave as placeholder rows
3. Write the filled skeleton to `CLAUDE.md` in the project root
4. Report: "Created CLAUDE.md -- review and customize it for your project."

### If CLAUDE.md already exists:

1. Generate the same skeleton as above
2. Write it to `.claude/CLAUDE_SKELETON.md` (NOT to project root)
3. Report: "Your project already has a CLAUDE.md. A skeleton with detected stack info was saved to `.claude/CLAUDE_SKELETON.md` -- compare and merge what's useful."

## 5. Create Context Files

1. Create `.claude/ACTIVE_CONTEXT.md` from `${CLAUDE_PLUGIN_ROOT}/templates/ACTIVE_CONTEXT.md` (skip if exists)
2. Create `.claude/` directory if it doesn't exist

## 6. Summary

Output a structured summary:

```
INIT COMPLETE

Detected stack: <stack(s)>
Project layout: <layout pattern>

Files created:
  CLAUDE.md              (or .claude/CLAUDE_SKELETON.md if existing)
  .claude/ACTIVE_CONTEXT.md

Available rituals:
  /claude-rituals:session <topic>    Start a work session
  /claude-rituals:checkpoint         Mid-work save point
  /claude-rituals:endofsession       Close session with structured commits
  /claude-rituals:recap              Review where you left off
  /claude-rituals:status             Project health dashboard
  /claude-rituals:handoff            Generate context transfer document

Next steps:
  1. Review and customize CLAUDE.md for your project
  2. Run /claude-rituals:session <topic> to start working
```

---

## Notes

- Does NOT create any git commits
- Does NOT push to remote
- Does NOT overwrite existing CLAUDE.md (generates .claude/CLAUDE_SKELETON.md instead)
- Does NOT overwrite existing ACTIVE_CONTEXT.md
- Should complete under 60 seconds
- Stack detection is suggestive, not prescriptive -- developer customizes the generated files
