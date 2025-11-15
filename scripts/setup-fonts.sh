#!/usr/bin/env bash

# ==============================================================================
# Nerd Fonts Installation Script
# ==============================================================================
# Downloads and installs IosevkaTerm Nerd Font and other popular fonts
# ==============================================================================

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

FONT_DIR="$HOME/.local/share/fonts"
NERD_FONTS_VERSION="v3.3.0"

# Create fonts directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Function to download and install a Nerd Font
install_nerd_font() {
    local font_name="$1"
    local font_dir="$FONT_DIR/NerdFonts"

    mkdir -p "$font_dir"

    if ls "$font_dir"/*"$font_name"*.ttf 1> /dev/null 2>&1; then
        info "$font_name already installed"
        return
    fi

    info "Downloading $font_name Nerd Font..."

    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/${font_name}.zip"
    local temp_file="/tmp/${font_name}.zip"

    curl -fLo "$temp_file" "$url"

    info "Installing $font_name..."
    unzip -o "$temp_file" -d "$font_dir" "*.ttf" 2>/dev/null || true

    rm -f "$temp_file"
    info "$font_name installed successfully"
}

section "Installing Nerd Fonts"

# Install primary font (used in your config)
install_nerd_font "IosevkaTerm"

# Optional: Install additional popular fonts
read -p "Install additional fonts? (FiraCode, JetBrainsMono, Hack) (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_nerd_font "FiraCode"
    install_nerd_font "JetBrainsMono"
    install_nerd_font "Hack"
fi

# Refresh font cache
section "Refreshing Font Cache"
info "Updating font cache..."
fc-cache -fv "$FONT_DIR" > /dev/null 2>&1

info ""
info "Font installation complete!"
info "Installed fonts are located in: $FONT_DIR"
info ""
info "To verify installation, run: fc-list | grep -i iosevka"
