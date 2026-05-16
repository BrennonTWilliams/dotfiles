#!/usr/bin/env bash

# ==============================================================================
# Tmux Plugin Manager (TPM) Installation Script
# ==============================================================================
# Installs TPM and tmux plugins
# ==============================================================================

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

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
info "  - tmux-sensible          (Sensible defaults)"
info "  - tmux-resurrect         (Save/restore sessions)"
info "  - tmux-continuum         (Auto-save sessions)"
info "  - tmux-cpu               (CPU/RAM status bar widgets)"
info "  - tmux-prefix-highlight  (Visual PREFIX/COPY indicator in status bar)"
info "  - fcsonline/tmux-thumbs  (Hint-mode URL/path picker; requires Rust)"
info "  - tmux-plugins/tmux-open (Copy-mode o opens URLs/files; Ctrl-o opens in \$EDITOR)"
info "  - rickstaa/tmux-notify   (Desktop notification on command finish; prefix+m)"
info ""
info "NOTE: tmux-thumbs has no pre-built ARM64 binary."
info "After 'Prefix + I', build it manually:"
info "  cd ~/.tmux/plugins/tmux-thumbs && cargo build --release"
