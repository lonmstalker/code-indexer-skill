#!/usr/bin/env bash
set -euo pipefail

# Code-Indexer Skill Installer
# Installs skill for Claude Code and Codex CLI

SKILL_NAME="code-indexer"
REPO_URL="https://github.com/lonmstalker/code-indexer-skill"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install code-indexer skill for Claude Code and/or Codex CLI.

OPTIONS:
    --claude          Install for Claude Code only
    --codex           Install for Codex CLI only
    --global          Install globally (default)
    --local           Install for current project only
    --uninstall       Remove installed skill
    -h, --help        Show this help

EXAMPLES:
    $0                      # Install globally for both
    $0 --claude --local     # Install for Claude Code in current project
    $0 --codex --global     # Install globally for Codex only
    $0 --uninstall          # Remove skill

EOF
}

# Defaults
INSTALL_CLAUDE=true
INSTALL_CODEX=true
INSTALL_GLOBAL=true
UNINSTALL=false

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --claude)
            INSTALL_CLAUDE=true
            INSTALL_CODEX=false
            shift ;;
        --codex)
            INSTALL_CLAUDE=false
            INSTALL_CODEX=true
            shift ;;
        --global)
            INSTALL_GLOBAL=true
            shift ;;
        --local)
            INSTALL_GLOBAL=false
            shift ;;
        --uninstall)
            UNINSTALL=true
            shift ;;
        -h|--help)
            usage
            exit 0 ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1 ;;
    esac
done

# Determine script location (for local install from repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$SCRIPT_DIR/plugins/code-indexer/skills/code-indexer/SKILL.md"

# Check if running from repo or need to download
if [[ ! -f "$SKILL_SOURCE" ]]; then
    info "Downloading skill from GitHub..."
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    curl -sSL "$REPO_URL/raw/master/plugins/code-indexer/skills/code-indexer/SKILL.md" \
        -o "$TEMP_DIR/SKILL.md"
    SKILL_SOURCE="$TEMP_DIR/SKILL.md"
fi

# Define target directories
if $INSTALL_GLOBAL; then
    CLAUDE_DIR="$HOME/.claude/skills/$SKILL_NAME"
    CODEX_DIR="$HOME/.codex/skills/$SKILL_NAME"
else
    CLAUDE_DIR=".claude/skills/$SKILL_NAME"
    CODEX_DIR=".codex/skills/$SKILL_NAME"
fi

install_skill() {
    local target_dir="$1"
    local name="$2"

    if [[ -d "$target_dir" ]]; then
        warn "$name skill already exists at $target_dir, updating..."
    fi

    mkdir -p "$target_dir"
    cp "$SKILL_SOURCE" "$target_dir/SKILL.md"
    info "$name skill installed to $target_dir"
}

uninstall_skill() {
    local target_dir="$1"
    local name="$2"

    if [[ -d "$target_dir" ]]; then
        rm -rf "$target_dir"
        info "$name skill removed from $target_dir"
    else
        warn "$name skill not found at $target_dir"
    fi
}

# Main logic
if $UNINSTALL; then
    info "Uninstalling code-indexer skill..."
    $INSTALL_CLAUDE && uninstall_skill "$CLAUDE_DIR" "Claude Code"
    $INSTALL_CODEX && uninstall_skill "$CODEX_DIR" "Codex"
    info "Uninstall complete!"
else
    info "Installing code-indexer skill..."
    $INSTALL_CLAUDE && install_skill "$CLAUDE_DIR" "Claude Code"
    $INSTALL_CODEX && install_skill "$CODEX_DIR" "Codex"

    echo ""
    info "Installation complete!"
    echo ""
    echo "Skill triggers: code-indexer, symbols, definition, references, call-graph, outline"
    echo ""

    if $INSTALL_CLAUDE; then
        echo "Claude Code: Skill will activate automatically on triggers"
    fi
    if $INSTALL_CODEX; then
        echo "Codex CLI: Skill will activate automatically on triggers"
    fi
fi
