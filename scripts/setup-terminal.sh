#!/usr/bin/env bash

# ==============================================================================
# Terminal Setup Script
# ==============================================================================
# Handles terminal configuration, fonts, and shell setup
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Configuration
# ==============================================================================

# Font configurations
FONT_DIR="$HOME/Library/Fonts"
FONTS_TO_INSTALL=(
    "JetBrains Mono"
    "Fira Code"
    "Source Code Pro"
)

# ==============================================================================
# Font Installation Functions (macOS)
# ==============================================================================

install_fonts() {
    if [ "$OS" != "macos" ]; then
        info "Font installation only supported on macOS"
        return 0
    fi

    section "Installing Fonts"

    # Create font directory if it doesn't exist
    mkdir -p "$FONT_DIR"

    for font in "${FONTS_TO_INSTALL[@]}"; do
        info "Installing font: $font"

        # This is a placeholder - actual font installation would be handled
        # by downloading from trusted sources or using Homebrew casks
        warn "Font installation for $font not implemented - please install manually"
    done

    success "Font installation completed"
}

# ==============================================================================
# Shell Setup Functions
# ==============================================================================

setup_zsh() {
    section "Setting up Zsh"

    # Check if zsh is installed
    if ! command_exists zsh; then
        warn "Zsh not found, skipping zsh setup"
        return 1
    fi

    # Change default shell to zsh if not already
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        success "Default shell changed to zsh"
    else
        info "Zsh is already the default shell"
    fi

}

setup_starship() {
    section "Setting up Starship Prompt"

    # Install starship if not present
    if ! command_exists starship; then
        info "Installing Starship prompt..."
        if [ "$PKG_MANAGER" = "brew" ]; then
            brew install starship
        else
            warn "Please install Starship manually: https://starship.rs/#installation"
        fi
    else
        info "Starship already installed"
    fi

    # Create starship config directory
    local starship_config_dir="$HOME/.config/starship"
    mkdir -p "$starship_config_dir"

    # Copy starship config if it exists in dotfiles
    if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
        info "Installing Starship configuration..."
        backup_if_exists "$starship_config_dir/starship.toml" "$HOME/.dotfiles_backup"
        cp "$DOTFILES_DIR/starship/starship.toml" "$starship_config_dir/"
        success "Starship configuration installed"
    fi
}

# ==============================================================================
# Terminal Configuration
# ==============================================================================

setup_tmux() {
    section "Setting up Tmux"

    # Check if tmux is installed
    if ! command_exists tmux; then
        warn "Tmux not found, please install it first"
        return 1
    fi

    info "Tmux configuration will be installed by stow"
    info "Remember to install tmux plugins: Prefix + I (Ctrl-a + Shift-i)"
}

setup_ghostty() {
    section "Setting up Ghostty Terminal"

    if [ "$OS" = "macos" ]; then
        # Create Ghostty config directory
        local ghostty_config_dir="$HOME/.config/ghostty"
        mkdir -p "$ghostty_config_dir"

        if [ -d "$DOTFILES_DIR/ghostty" ]; then
            info "Ghostty configuration will be installed by stow"
        else
            warn "Ghostty configuration not found in dotfiles"
        fi
    else
        info "Ghostty setup only applicable to macOS"
    fi
}

# ==============================================================================
# Main Function
# ==============================================================================

main() {
    section "Terminal Setup"

    # Change to dotfiles directory
    cd "$DOTFILES_DIR"

    # Setup components
    setup_zsh
    setup_starship
    setup_tmux
    setup_ghostty
    install_fonts

    success "Terminal setup completed successfully"
    echo
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. If using tmux, install plugins with: Prefix + I"
    echo "3. Customize your terminal appearance as needed"
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi