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

# Font configurations (Nerd Font variants for terminal compatibility)
FONTS_TO_INSTALL=(
    "IosevkaTerm Nerd Font"
    "JetBrains Mono Nerd Font"
    "Fira Code Nerd Font"
)

# Nerd Fonts GitHub release version
NERD_FONTS_VERSION="v3.3.0"

# ==============================================================================
# Font Installation Functions
# ==============================================================================

install_fonts() {
    section "Installing Fonts"

    if [ "$OS" = "macos" ]; then
        install_fonts_macos
    else
        install_fonts_linux
    fi
}

install_fonts_macos() {
    local font_dir="$HOME/Library/Fonts"

    if ! command_exists brew; then
        warn "Homebrew not found - skipping font installation"
        warn "Install fonts manually or install Homebrew first"
        return 1
    fi

    mkdir -p "$font_dir"

    for font in "${FONTS_TO_INSTALL[@]}"; do
        info "Installing font: $font"

        local cask_name=""
        case "$font" in
            "IosevkaTerm Nerd Font")
                cask_name="font-iosevka-term-nerd-font"
                ;;
            "JetBrains Mono Nerd Font")
                cask_name="font-jetbrains-mono-nerd-font"
                ;;
            "Fira Code Nerd Font")
                cask_name="font-fira-code-nerd-font"
                ;;
            *)
                warn "Unknown font: $font - skipping"
                continue
                ;;
        esac

        if brew list --cask "$cask_name" &>/dev/null; then
            info "$font already installed"
        else
            if brew install --cask "$cask_name"; then
                success "Installed $font"
            else
                warn "Failed to install $font"
            fi
        fi
    done

    success "Font installation completed"
}

install_fonts_linux() {
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # Map display names to Nerd Fonts release archive names
    for font in "${FONTS_TO_INSTALL[@]}"; do
        local archive_name=""
        case "$font" in
            "IosevkaTerm Nerd Font")
                archive_name="IosevkaTerm"
                ;;
            "JetBrains Mono Nerd Font")
                archive_name="JetBrainsMono"
                ;;
            "Fira Code Nerd Font")
                archive_name="FiraCode"
                ;;
            *)
                warn "Unknown font: $font - skipping"
                continue
                ;;
        esac

        # Skip if any .ttf files for this font already exist
        if ls "$font_dir"/${archive_name}*.ttf &>/dev/null; then
            info "$font already installed"
            continue
        fi

        info "Installing font: $font"
        local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${archive_name}.tar.xz"
        local tmp_dir
        tmp_dir=$(mktemp -d)

        if curl -fsSL "$url" -o "$tmp_dir/${archive_name}.tar.xz"; then
            tar -xf "$tmp_dir/${archive_name}.tar.xz" -C "$font_dir" --wildcards '*.ttf' 2>/dev/null || \
                tar -xf "$tmp_dir/${archive_name}.tar.xz" -C "$font_dir"
            success "Installed $font"
        else
            warn "Failed to download $font"
        fi

        rm -rf "$tmp_dir"
    done

    # Rebuild font cache
    if command_exists fc-cache; then
        info "Rebuilding font cache..."
        fc-cache -f "$font_dir"
    fi

    success "Font installation completed"
}

# ==============================================================================
# Shell Setup Functions
# ==============================================================================

setup_zsh() {
    section "Setting up Zsh"

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

setup_zsh_abbr() {
    section "Setting up zsh-abbr"

    local abbr_dir="${ZDOTDIR:-$HOME}/.zsh-abbr"

    # Check if already available via Homebrew
    if [ -f "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-abbr/zsh-abbr.zsh" ] || \
       [ -f "/usr/local/share/zsh-abbr/zsh-abbr.zsh" ] || \
       [ -f "/home/linuxbrew/.linuxbrew/share/zsh-abbr/zsh-abbr.zsh" ]; then
        info "zsh-abbr already installed via Homebrew"
        return 0
    fi

    # Check if already cloned
    if [ -f "$abbr_dir/zsh-abbr.zsh" ]; then
        info "zsh-abbr already installed at $abbr_dir"
        return 0
    fi

    # Clone with submodules (zsh-job-queue dependency)
    info "Installing zsh-abbr from source..."
    if git clone --recurse-submodules https://github.com/olets/zsh-abbr.git "$abbr_dir"; then
        success "zsh-abbr installed to $abbr_dir"
    else
        warn "Failed to clone zsh-abbr"
        return 1
    fi
}

setup_starship() {
    section "Setting up Starship Prompt"

    if ! command_exists starship; then
        info "Installing Starship prompt..."
        if [ "$PKG_MANAGER" = "brew" ]; then
            brew install starship
        elif command_exists curl; then
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
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

    if ! command_exists tmux; then
        warn "Tmux not found, please install it first"
        return 1
    fi

    # Detect the prefix from the tmux config
    local prefix="Ctrl-b"
    if [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ] && grep -q 'prefix.*C-a' "$DOTFILES_DIR/tmux/.tmux.conf"; then
        prefix="Ctrl-a"
    fi

    info "Tmux configuration will be installed by stow"
    info "Remember to install tmux plugins: Prefix + I ($prefix + Shift-i)"
}

setup_ghostty() {
    section "Setting up Ghostty Terminal"

    if [ "$OS" = "macos" ]; then
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
    setup_zsh_abbr
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
