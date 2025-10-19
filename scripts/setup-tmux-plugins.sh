#!/usr/bin/env bash

# ==============================================================================
# Tmux Plugin Manager (TPM) Installation Script
# ==============================================================================
# Installs TPM and tmux plugins
# ==============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Install TPM if not already installed
if [ ! -d "$TPM_DIR" ]; then
    info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    info "TPM installed successfully"
else
    info "TPM already installed"
fi

info ""
info "Tmux Plugin Manager setup complete!"
info ""
info "To install tmux plugins:"
info "  1. Start tmux: tmux"
info "  2. Press: Prefix + I (Ctrl-a + Shift-i)"
info ""
info "Configured plugins:"
info "  - tmux-sensible        (Sensible defaults)"
info "  - tmux-yank           (Better clipboard)"
info "  - tmux-resurrect      (Save/restore sessions)"
info "  - tmux-continuum      (Auto-save sessions)"
