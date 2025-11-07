#!/usr/bin/env bash

# ==============================================================================
# NVM (Node Version Manager) Installation Script
# ==============================================================================
# Installs NVM for managing multiple Node.js versions
# ==============================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

NVM_VERSION="v0.40.3"

if [ ! -d "$HOME/.nvm" ]; then
    info "Installing NVM $NVM_VERSION..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    info "NVM installed successfully"
    info "Installing latest LTS version of Node.js..."
    nvm install --lts
    nvm use --lts

    info "Node.js version: $(node --version)"
    info "npm version: $(npm --version)"
else
    info "NVM already installed"
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    info "Current Node.js version: $(node --version 2>/dev/null || echo 'Not installed')"
fi

info ""
info "NVM setup complete!"
info "Your shell configs already have NVM lazy-loading configured."
info ""
info "Usage:"
info "  nvm install --lts    # Install latest LTS"
info "  nvm install 18       # Install Node.js 18.x"
info "  nvm use 18           # Switch to Node.js 18.x"
info "  nvm ls               # List installed versions"
