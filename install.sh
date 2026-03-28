#!/bin/bash
# Claude Session Protocol -- Installer
# Copies session management commands to your Claude Code project or user config.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"

usage() {
    echo "Usage: ./install.sh [--global | --project <path>]"
    echo ""
    echo "  --global          Install to ~/.claude/commands/ (available in all projects)"
    echo "  --project <path>  Install to <path>/.claude/commands/ (project-specific)"
    echo ""
    echo "If no flag is given, installs to current directory's .claude/commands/"
}

install_commands() {
    local target="$1"
    mkdir -p "$target"

    cp "$COMMANDS_SRC/session.md" "$target/session.md"
    cp "$COMMANDS_SRC/checkpoint.md" "$target/checkpoint.md"
    cp "$COMMANDS_SRC/endofsession.md" "$target/endofsession.md"

    echo "Installed 3 commands to $target"
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
        echo "Commands installed globally. Use /session, /checkpoint, /endofsession in any project."
        echo "Note: Run this script with --project in each project to create ACTIVE_CONTEXT.md"
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
        echo "Done. Add the parallel work protocol to your CLAUDE.md:"
        echo "  cat templates/claude-md-snippet.md"
        ;;
    --help|-h)
        usage
        ;;
    *)
        # Default: install to current directory
        PROJECT_ROOT="$(pwd)"
        install_commands "$PROJECT_ROOT/.claude/commands"
        install_context_template "$PROJECT_ROOT"
        echo ""
        echo "Done. Add the parallel work protocol to your CLAUDE.md:"
        echo "  cat $SCRIPT_DIR/templates/claude-md-snippet.md"
        ;;
esac
