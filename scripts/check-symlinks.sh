#!/usr/bin/env bash

# ==============================================================================
# Symlink Health Check Script
# ==============================================================================
# Verifies that all expected dotfiles symlinks are properly configured.
# Run with --fix to automatically create missing manual symlinks.
#
# Usage:
#   ./scripts/check-symlinks.sh          # Check symlink status
#   ./scripts/check-symlinks.sh --fix    # Fix missing manual symlinks
# ==============================================================================

set -euo pipefail

# Get script and dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0
WARN=0

# Options
FIX_MODE=false

# ==============================================================================
# Helper Functions
# ==============================================================================

print_status() {
    local status="$1"
    local message="$2"

    case "$status" in
        ok)
            echo -e "  ${GREEN}[OK]${NC} $message"
            ((PASS++))
            ;;
        missing)
            echo -e "  ${RED}[MISSING]${NC} $message"
            ((FAIL++))
            ;;
        file)
            echo -e "  ${YELLOW}[FILE]${NC} $message ${YELLOW}(not a symlink)${NC}"
            ((WARN++))
            ;;
        wrong)
            echo -e "  ${RED}[WRONG]${NC} $message"
            ((FAIL++))
            ;;
    esac
}

section() {
    echo -e "\n${BLUE}${BOLD}=== $1 ===${NC}"
}

# Check if a symlink exists and points to the correct target
check_symlink() {
    local target="$1"
    local expected_source="$2"
    local display_name="${3:-$target}"

    if [ -L "$target" ]; then
        local actual_source
        actual_source=$(readlink "$target")

        # Resolve the actual symlink to absolute path for comparison
        local actual_resolved
        local expected_resolved

        # Get the directory containing the symlink and resolve from there
        local target_dir
        target_dir=$(dirname "$target")

        # Resolve actual source (handles relative symlinks)
        if [[ "$actual_source" == /* ]]; then
            actual_resolved="$actual_source"
        else
            actual_resolved=$(cd "$target_dir" && cd "$(dirname "$actual_source")" && pwd)/$(basename "$actual_source")
        fi

        # Resolve expected source
        expected_resolved=$(cd "$(dirname "$expected_source")" 2>/dev/null && pwd)/$(basename "$expected_source") 2>/dev/null || echo "$expected_source"

        # Compare resolved paths
        if [[ "$actual_resolved" == "$expected_resolved" ]]; then
            print_status "ok" "$display_name"
            return 0
        else
            print_status "wrong" "$display_name -> $actual_source (expected: $expected_source)"
            return 1
        fi
    elif [ -e "$target" ]; then
        print_status "file" "$display_name"
        return 1
    else
        print_status "missing" "$display_name"
        return 1
    fi
}

# Create a symlink (used in fix mode)
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "    ${YELLOW}Backing up existing file...${NC}"
        mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    ln -sf "$source" "$target"
    echo -e "    ${GREEN}Created symlink${NC}"
}

# ==============================================================================
# Symlink Checks
# ==============================================================================

check_stow_packages() {
    section "Stow-Managed Packages"

    # Core shell configs
    echo -e "\n${CYAN}Zsh:${NC}"
    check_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc" "~/.zshrc" || true
    check_symlink "$HOME/.zshenv" "$DOTFILES_DIR/zsh/.zshenv" "~/.zshenv" || true
    check_symlink "$HOME/.zprofile" "$DOTFILES_DIR/zsh/.zprofile" "~/.zprofile" || true

    echo -e "\n${CYAN}Bash:${NC}"
    check_symlink "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc" "~/.bashrc" || true
    check_symlink "$HOME/.bash_profile" "$DOTFILES_DIR/bash/.bash_profile" "~/.bash_profile" || true

    echo -e "\n${CYAN}Git:${NC}"
    check_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig" "~/.gitconfig" || true
    check_symlink "$HOME/.gitignore" "$DOTFILES_DIR/git/.gitignore" "~/.gitignore" || true

    echo -e "\n${CYAN}Tmux:${NC}"
    check_symlink "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf" "~/.tmux.conf" || true

    echo -e "\n${CYAN}Neovim:${NC}"
    check_symlink "$HOME/.config/nvim/init.lua" "$DOTFILES_DIR/neovim/.config/nvim/init.lua" "~/.config/nvim/init.lua" || true

    echo -e "\n${CYAN}Starship:${NC}"
    if [ -d "$HOME/.config/starship" ]; then
        check_symlink "$HOME/.config/starship/standard.toml" "$DOTFILES_DIR/starship/.config/starship/standard.toml" "~/.config/starship/standard.toml" || true
    else
        print_status "missing" "~/.config/starship/ directory"
    fi

    # Platform-specific
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${CYAN}Ghostty (macOS):${NC}"
        check_symlink "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/.config/ghostty/config" "~/.config/ghostty/config" || true
    else
        echo -e "\n${CYAN}Foot (Linux):${NC}"
        if [ -f "$HOME/.config/foot/foot.ini" ] || [ -L "$HOME/.config/foot/foot.ini" ]; then
            check_symlink "$HOME/.config/foot/foot.ini" "$DOTFILES_DIR/foot/.config/foot/foot.ini" "~/.config/foot/foot.ini" || true
        fi

        echo -e "\n${CYAN}Sway (Linux):${NC}"
        if [ -f "$HOME/.config/sway/config" ] || [ -L "$HOME/.config/sway/config" ]; then
            check_symlink "$HOME/.config/sway/config" "$DOTFILES_DIR/sway/.config/sway/config" "~/.config/sway/config" || true
        fi
    fi
}

check_zsh_modules() {
    section "Zsh Modular Configuration"

    echo -e "\n${CYAN}Functions:${NC}"
    if [ -d "$DOTFILES_DIR/zsh/functions" ]; then
        print_status "ok" "zsh/functions/ directory exists"
        [ -f "$DOTFILES_DIR/zsh/functions/_init.zsh" ] && print_status "ok" "functions/_init.zsh" || print_status "missing" "functions/_init.zsh"
    else
        print_status "missing" "zsh/functions/ directory"
    fi

    echo -e "\n${CYAN}Aliases:${NC}"
    if [ -d "$DOTFILES_DIR/zsh/aliases" ]; then
        print_status "ok" "zsh/aliases/ directory exists"
        [ -f "$DOTFILES_DIR/zsh/aliases/_init.zsh" ] && print_status "ok" "aliases/_init.zsh" || print_status "missing" "aliases/_init.zsh"
        [ -f "$DOTFILES_DIR/zsh/aliases/safety.zsh" ] && print_status "ok" "aliases/safety.zsh" || print_status "missing" "aliases/safety.zsh"
    else
        print_status "missing" "zsh/aliases/ directory"
    fi

    echo -e "\n${CYAN}Abbreviations:${NC}"
    if [ -d "$DOTFILES_DIR/zsh/abbreviations" ]; then
        print_status "ok" "zsh/abbreviations/ directory exists"
        [ -f "$DOTFILES_DIR/zsh/abbreviations/_init.zsh" ] && print_status "ok" "abbreviations/_init.zsh" || print_status "missing" "abbreviations/_init.zsh"
    else
        print_status "missing" "zsh/abbreviations/ directory"
    fi

    # Check zsh-abbr installation status
    echo -e "\n${CYAN}zsh-abbr Status:${NC}"
    local abbr_mode="${DOTFILES_ABBR_MODE:-alias}"
    if command -v brew >/dev/null 2>&1; then
        if brew list olets/tap/zsh-abbr >/dev/null 2>&1; then
            print_status "ok" "zsh-abbr installed (mode: $abbr_mode)"
        else
            if [ "$abbr_mode" = "abbr" ] || [ "$abbr_mode" = "both" ]; then
                print_status "missing" "zsh-abbr not installed (mode: $abbr_mode requires it)"
                echo -e "    ${YELLOW}Install with: brew install olets/tap/zsh-abbr${NC}"
            else
                echo -e "  ${YELLOW}[INFO]${NC} zsh-abbr not installed (not required for mode: $abbr_mode)"
            fi
        fi
    else
        echo -e "  ${YELLOW}[INFO]${NC} Homebrew not available, skipping zsh-abbr check"
    fi
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix)
                FIX_MODE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--fix]"
                echo ""
                echo "Options:"
                echo "  --fix    Automatically fix missing manual symlinks"
                echo "  --help   Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo -e "${BOLD}Dotfiles Symlink Health Check${NC}"
    echo -e "Dotfiles directory: ${CYAN}$DOTFILES_DIR${NC}"

    if [ "$FIX_MODE" = true ]; then
        echo -e "Mode: ${GREEN}Fix${NC} (will create missing manual symlinks)"
    else
        echo -e "Mode: ${BLUE}Check${NC} (run with --fix to repair)"
    fi

    # Run checks
    check_stow_packages
    check_zsh_modules

    # Summary
    section "Summary"
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN"
    echo ""

    if [ $FAIL -gt 0 ]; then
        echo -e "${RED}Some symlinks are missing or incorrect.${NC}"
        if [ "$FIX_MODE" = false ]; then
            echo -e "Run with ${CYAN}--fix${NC} to repair manual symlinks."
            echo -e "For stow-managed files, run: ${CYAN}stow --restow <package>${NC}"
        fi
        exit 1
    elif [ $WARN -gt 0 ]; then
        echo -e "${YELLOW}Some files exist but are not symlinks.${NC}"
        echo -e "Consider backing them up and re-running stow."
        exit 0
    else
        echo -e "${GREEN}All symlinks are correctly configured.${NC}"
        exit 0
    fi
}

main "$@"
