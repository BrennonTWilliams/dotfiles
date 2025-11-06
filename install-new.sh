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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/scripts/lib/utils.sh"

# ==============================================================================
# Configuration
# ==============================================================================

DOTFILES_DIR="$SCRIPT_DIR"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_CREATED=false

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

    # Install each package
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
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
        "$HOME/.tmux.local"
        "$HOME/.gitconfig.local"
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

    # Install system packages
    install_packages_only

    # Install dotfiles
    install_dotfiles

    # Create local configs
    create_local_configs

    # Setup terminal
    setup_terminal_only

    # Post-installation steps
    post_install
}

post_install() {
    section "Post-Installation Steps"

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
  --help         Show this help message

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

    # Parse arguments
    case "${1:-}" in
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
        --help|-h)
            show_usage
            exit 0
            ;;
        "")
            interactive_mode
            ;;
        *)
            error "Unknown option: $1. Use --help for usage information."
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi