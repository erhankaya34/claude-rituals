#!/bin/bash
# Claude Rituals -- Fallback Installer
# For users who prefer manual installation over the plugin marketplace.
# Copies all ritual commands to your Claude Code project or user config.
#
# Preferred installation: /plugin marketplace add erhankaya34/claude-rituals
#                         /plugin install claude-rituals@erhankaya34

set -e

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"

usage() {
    echo "Claude Rituals v$VERSION -- Fallback Installer"
    echo ""
    echo "Usage: ./install.sh [--global | --project <path> | --uninstall]"
    echo ""
    echo "  --global          Install to ~/.claude/commands/ (available in all projects)"
    echo "  --project <path>  Install to <path>/.claude/commands/ (project-specific)"
    echo "  --uninstall       Remove ritual commands from ~/.claude/commands/"
    echo ""
    echo "If no flag is given, installs to current directory's .claude/commands/"
    echo ""
    echo "Preferred: Install as a Claude Code plugin instead:"
    echo "  /plugin marketplace add erhankaya34/claude-rituals"
    echo "  /plugin install claude-rituals@erhankaya34"
}

COMMANDS=(
    "init.md"
    "session.md"
    "checkpoint.md"
    "endofsession.md"
    "recap.md"
    "status.md"
    "handoff.md"
)

install_commands() {
    local target="$1"
    mkdir -p "$target"

    local count=0
    for cmd in "${COMMANDS[@]}"; do
        if [ -f "$COMMANDS_SRC/$cmd" ]; then
            cp "$COMMANDS_SRC/$cmd" "$target/$cmd"
            count=$((count + 1))
        fi
    done

    echo "Installed $count commands to $target"
}

uninstall_commands() {
    local target="$HOME/.claude/commands"

    local count=0
    for cmd in "${COMMANDS[@]}"; do
        if [ -f "$target/$cmd" ]; then
            rm "$target/$cmd"
            count=$((count + 1))
        fi
    done

    echo "Removed $count commands from $target"
}

install_context_template() {
    local project_root="$1"
    local ctx_dir="$project_root/.claude"
    local ctx_file="$ctx_dir/ACTIVE_CONTEXT.md"

    if [ -f "$ctx_file" ]; then
        echo "ACTIVE_CONTEXT.md already exists at $ctx_file -- skipping"
        return
    fi

    mkdir -p "$ctx_dir"
    cp "$SCRIPT_DIR/templates/ACTIVE_CONTEXT.md" "$ctx_file"
    echo "Created $ctx_file"
}

case "${1:-}" in
    --global)
        install_commands "$HOME/.claude/commands"
        echo ""
        echo "Commands installed globally. Available in any project as:"
        echo "  /init, /session, /checkpoint, /endofsession, /recap, /status, /handoff"
        echo ""
        echo "Run with --project in each project to create ACTIVE_CONTEXT.md"
        ;;
    --project)
        if [ -z "${2:-}" ]; then
            echo "Error: --project requires a path"
            usage
            exit 1
        fi
        PROJECT_ROOT="$2"
        install_commands "$PROJECT_ROOT/.claude/commands"
        install_context_template "$PROJECT_ROOT"
        echo ""
        echo "Done. Run /init to generate a CLAUDE.md skeleton for your project."
        ;;
    --uninstall)
        uninstall_commands
        ;;
    --help|-h)
        usage
        ;;
    --version|-v)
        echo "Claude Rituals v$VERSION"
        ;;
    *)
        PROJECT_ROOT="$(pwd)"
        install_commands "$PROJECT_ROOT/.claude/commands"
        install_context_template "$PROJECT_ROOT"
        echo ""
        echo "Done. Run /init to generate a CLAUDE.md skeleton for your project."
        ;;
esac
