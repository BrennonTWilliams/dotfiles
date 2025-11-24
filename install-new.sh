#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Bootstrap Installation Script (Modular)
# ==============================================================================
# This script installs dotfiles using GNU Stow for symlink management.
# It provides safe backups, platform detection, and selective installation.
#
# Usage:
#   ./install-new.sh                   # Interactive installation
#   ./install-new.sh --all             # Install all components
#   ./install-new.sh --packages        # Install system packages only
#   ./install-new.sh --terminal        # Setup terminal only
#   ./install-new.sh --dotfiles        # Install dotfiles only
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities and libraries
source "$SCRIPT_DIR/scripts/lib/utils.sh"
source "$SCRIPT_DIR/scripts/lib/conflict-resolution.sh"

# ==============================================================================
# Configuration
# ==============================================================================

DOTFILES_DIR="$SCRIPT_DIR"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_CREATED=false

# Preview mode settings
PREVIEW_MODE=false
DRY_RUN=false
VERBOSE=false

# Conflict resolution settings
INTERACTIVE_MODE=true
AUTO_RESOLVE_STRATEGY=""

# Export for use in sourced scripts
export DOTFILES_DIR
export PREVIEW_MODE
export DRY_RUN
export VERBOSE
export INTERACTIVE_MODE
export AUTO_RESOLVE_STRATEGY

# ==============================================================================
# Dotfiles Installation Functions
# ==============================================================================

get_available_packages() {
    local packages=()
    for dir in */; do
        if [ -d "$dir" ] && [ -f "$dir/.stowrc" ] || [ -f "$dir/.*" ]; then
            packages+=("${dir%/}")
        fi
    done
    echo "${packages[@]}"
}

# Export for use in preview.sh
export -f get_available_packages

install_dotfiles() {
    section "Installing Dotfiles"

    local packages=($(get_available_packages))
    local available_packages="${packages[*]}"

    if [ -z "$available_packages" ]; then
        warn "No packages found to install"
        return 1
    fi

    info "Available packages: $available_packages"

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Install each package with conflict resolution
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            # Resolve conflicts before stowing
            if ! resolve_package_conflicts "$package" "$HOME" "$BACKUP_DIR"; then
                warn "Conflict resolution incomplete for $package"
                if [ "$AUTO_RESOLVE_STRATEGY" = "fail-on-conflict" ]; then
                    error "Aborting installation due to conflicts"
                fi
            fi

            # Stow the package
            stow_package "$package" "$HOME" "$BACKUP_DIR"
        fi
    done

    success "Dotfiles installation completed"
}

create_local_configs() {
    section "Creating Local Configurations"

    # Create local configuration files if they don't exist
    local local_configs=(
        "$HOME/.zshrc.local"
        "$HOME/.zshenv.local"
        "$HOME/.bashrc.local"
        "$HOME/.bash_profile.local"
        "$HOME/.tmux.local"
        "$HOME/.gitconfig.local"
        "$HOME/.npmrc.local"
    )

    for config in "${local_configs[@]}"; do
        if [ ! -f "$config" ]; then
            info "Creating $config"
            touch "$config"
        else
            info "$config already exists"
        fi
    done

    success "Local configurations created"
}

# ==============================================================================
# Preview Mode Functions
# ==============================================================================

run_preview_mode() {
    local mode="${1:-all}"

    # Source preview library
    source "$SCRIPT_DIR/scripts/lib/preview.sh"

    # Detect OS first
    detect_os

    # Display preview header
    preview_header

    # Run appropriate preview based on mode
    case "$mode" in
        all)
            preview_packages
            preview_dotfiles
            preview_shell_setup
            ;;
        packages)
            preview_packages
            ;;
        dotfiles)
            preview_dotfiles
            ;;
        terminal)
            preview_shell_setup
            ;;
    esac

    # Display conflict resolution mode info
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo ""
        info "Conflict Resolution: ${BOLD}Interactive mode${NC} (will prompt for conflicts)"
    elif [ -n "$AUTO_RESOLVE_STRATEGY" ]; then
        echo ""
        info "Conflict Resolution: ${BOLD}Auto-resolve${NC} (strategy: $AUTO_RESOLVE_STRATEGY)"
    fi

    # Display summary
    preview_summary
}

# ==============================================================================
# Main Installation Functions
# ==============================================================================

install_packages_only() {
    "$SCRIPT_DIR/scripts/setup-packages.sh"
}

setup_terminal_only() {
    "$SCRIPT_DIR/scripts/setup-terminal.sh"
}

install_all() {
    section "Complete Installation"

    # Run pre-flight dependency check
    if ! "$SCRIPT_DIR/scripts/preflight-check.sh" true; then
        error "Pre-flight check failed. Please resolve dependencies first."
    fi

    # Install system packages
    install_packages_only

    # Install dotfiles
    install_dotfiles

    # Create local configs
    create_local_configs

    # Setup new configurations (git, vscode, npm)
    if [ -f "$SCRIPT_DIR/scripts/setup-new-configs.sh" ]; then
        "$SCRIPT_DIR/scripts/setup-new-configs.sh"
    else
        warn "New configuration setup script not found"
    fi

    # Setup terminal
    setup_terminal_only

    # Post-installation steps
    post_install
}

post_install() {
    section "Post-Installation Steps"

    # Run health check
    if [ -f "$SCRIPT_DIR/scripts/health-check.sh" ]; then
        echo
        info "Running post-installation health check..."
        "$SCRIPT_DIR/scripts/health-check.sh"
        echo
    fi

    echo
    success "Installation completed successfully!"
    echo
    echo -e "${CYAN}Next steps:${NC}"

    # Platform-specific instructions
    case "$OS" in
        "macos")
            cat << 'EOF'
1. Restart your terminal or run: source ~/.zshrc
2. Install tmux plugins: Prefix + I (Ctrl-a + Shift-i)
3. Configure Ghostty terminal as needed
EOF
            ;;
        "linux"|"debian"|"redhat"|"arch")
            cat << 'EOF'
1. Restart your terminal or run: source ~/.zshrc
2. Install tmux plugins: Prefix + I (Ctrl-b + Shift-i)
3. Configure your terminal emulator as needed
EOF
            ;;
    esac

    if [ "$BACKUP_CREATED" = true ]; then
        echo -e "${CYAN}Backup Location:${NC}"
        echo "  Your old dotfiles are backed up at: $BACKUP_DIR"
        echo
    fi

    echo -e "${CYAN}Customization:${NC}"
    echo "  - Edit ~/.zshrc.local for zsh customizations"
    echo "  - Edit ~/.tmux.local for tmux customizations"
    echo "  - Edit ~/.gitconfig.local for git customizations"
    echo
}

# ==============================================================================
# Argument Parsing and Main Function
# ==============================================================================

print_banner() {
    cat << 'EOF'
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/

Modular Bootstrap Installation Script
EOF
    echo
}

show_usage() {
    cat << EOF
Usage: $0 [OPTION]

Options:
  --all          Install all components (packages + dotfiles + terminal)
  --packages     Install system packages only
  --terminal     Setup terminal and shell only
  --dotfiles     Install dotfiles only
  --check-deps   Check system dependencies without installing
  --preview      Preview installation without making changes (dry-run)
  --dry-run      Alias for --preview
  --verbose      Show detailed output (use with --preview for full details)
  --help         Show this help message

Conflict Resolution:
  --interactive            Interactive conflict resolution (default)
  --no-interactive         Disable interactive prompts
  --auto-resolve=STRATEGY  Automatically resolve conflicts using strategy:
      keep-existing        Skip conflicting dotfiles, keep existing
      overwrite            Backup existing, install new dotfiles
      backup-all           Rename existing to .orig, install new
      fail-on-conflict     Abort installation on any conflict

Preview Mode:
  --preview --all        Preview complete installation
  --preview --packages   Preview package installations
  --preview --dotfiles   Preview dotfile symlinks
  --preview --terminal   Preview terminal/shell setup

Examples:
  $0 --all                              # Full interactive installation
  $0 --dotfiles --auto-resolve=overwrite  # Auto-overwrite conflicts
  $0 --all --no-interactive --auto-resolve=keep-existing  # Non-interactive
  $0 --preview --all --verbose          # Detailed preview

If no option is provided, interactive mode will be launched.
EOF
}

interactive_mode() {
    section "Interactive Installation Mode"

    echo "Select components to install:"
    echo "1) All components"
    echo "2) System packages only"
    echo "3) Terminal setup only"
    echo "4) Dotfiles only"
    echo "5) Exit"
    echo

    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            install_all
            ;;
        2)
            install_packages_only
            ;;
        3)
            setup_terminal_only
            ;;
        4)
            install_dotfiles
            create_local_configs
            ;;
        5)
            info "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

main() {
    print_banner

    # Parse all arguments
    local action=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --preview|--dry-run)
                PREVIEW_MODE=true
                DRY_RUN=true
                export PREVIEW_MODE
                export DRY_RUN
                shift
                ;;
            --verbose)
                VERBOSE=true
                export VERBOSE
                shift
                ;;
            --interactive)
                INTERACTIVE_MODE=true
                export INTERACTIVE_MODE
                shift
                ;;
            --no-interactive)
                INTERACTIVE_MODE=false
                export INTERACTIVE_MODE
                shift
                ;;
            --auto-resolve=*)
                AUTO_RESOLVE_STRATEGY="${1#*=}"
                INTERACTIVE_MODE=false
                export AUTO_RESOLVE_STRATEGY
                export INTERACTIVE_MODE

                # Validate strategy
                case "$AUTO_RESOLVE_STRATEGY" in
                    keep-existing|overwrite|backup-all|fail-on-conflict)
                        ;;
                    *)
                        error "Invalid auto-resolve strategy: $AUTO_RESOLVE_STRATEGY"
                        ;;
                esac
                shift
                ;;
            --all|--packages|--terminal|--dotfiles|--check-deps)
                action="$1"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            "")
                shift
                ;;
            *)
                error "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done

    # If no action specified and not in preview mode, run interactive mode
    if [ -z "$action" ] && [ "$PREVIEW_MODE" = false ]; then
        interactive_mode
        return
    fi

    # Default action is --all if only preview/verbose flags are set
    if [ -z "$action" ]; then
        action="--all"
    fi

    # Execute preview or installation based on mode
    if [ "$PREVIEW_MODE" = true ]; then
        case "$action" in
            --all)
                run_preview_mode "all"
                ;;
            --packages)
                run_preview_mode "packages"
                ;;
            --terminal)
                run_preview_mode "terminal"
                ;;
            --dotfiles)
                run_preview_mode "dotfiles"
                ;;
            --check-deps)
                "$SCRIPT_DIR/scripts/preflight-check.sh" false
                ;;
        esac
    else
        case "$action" in
            --all)
                install_all
                ;;
            --packages)
                install_packages_only
                ;;
            --terminal)
                setup_terminal_only
                ;;
            --dotfiles)
                install_dotfiles
                create_local_configs
                ;;
            --check-deps)
                "$SCRIPT_DIR/scripts/preflight-check.sh" true
                exit $?
                ;;
        esac
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi