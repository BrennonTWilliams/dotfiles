#!/usr/bin/env bash

# ==============================================================================
# Python Environment Setup Script
# ==============================================================================
# Installs pip and pipx with proper PATH configuration
# Works on Debian/Ubuntu-based systems including Raspberry Pi OS
# ==============================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

# Initialize OS detection using utils.sh
detect_os

# Install pip using system package manager or ensurepip
install_pip() {
    info "Installing pip..."

    case "$PKG_MANAGER" in
        apt)
            info "Using apt to install pip..."
            sudo apt-get update -qq

            # Try to install python3-pip package
            if sudo apt-get install -y python3-pip python3-venv 2>&1 | grep -q "unable to locate\|E:"; then
                warn "apt installation had issues, trying ensurepip fallback..."
                install_pip_fallback
            else
                success "pip installed via apt"
            fi
            ;;
        dnf)
            sudo dnf install -y python3-pip python3-virtualenv
            ;;
        pacman)
            sudo pacman -S --noconfirm python-pip
            ;;
        brew)
            # On macOS, pip comes with Python from Homebrew
            if ! command_exists python3; then
                brew install python3
            fi
            ;;
        *)
            error "Unknown package manager. Trying ensurepip fallback..."
            # shellcheck disable=SC2317
            install_pip_fallback
            ;;
    esac
}

# Fallback method using ensurepip
install_pip_fallback() {
    info "Using Python's built-in ensurepip..."

    # Try ensurepip
    if python3 -m ensurepip --user --default-pip 2>/dev/null; then
        success "pip installed via ensurepip"
    else
        warn "ensurepip not available, trying get-pip.py..."
        # Last resort: download get-pip.py
        curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        python3 /tmp/get-pip.py --user
        rm /tmp/get-pip.py
        success "pip installed via get-pip.py"
    fi

    # Upgrade pip to latest version
    python3 -m pip install --user --upgrade pip
}

# Install pipx
install_pipx() {
    info "Installing pipx..."

    # Ensure ~/.local/bin exists
    mkdir -p "$HOME/.local/bin"

    # On Debian/Ubuntu, try to install via apt first
    if [ "$PKG_MANAGER" = "apt" ]; then
        if sudo apt-get install -y pipx 2>/dev/null; then
            success "pipx installed via apt"
            # Ensure path is set up
            pipx ensurepath 2>/dev/null || true
            return 0
        else
            info "pipx not available via apt, installing via pip..."
        fi
    fi

    # Install pipx using pip with --user flag and --break-system-packages if needed
    if python3 -m pip install --user pipx 2>/dev/null; then
        success "pipx installed via pip"
    else
        # On systems with PEP 668 (externally-managed-environment), use --break-system-packages
        # This is safe for --user installations
        python3 -m pip install --user --break-system-packages pipx
        success "pipx installed via pip (with --break-system-packages)"
    fi

    # Ensure pipx path is set up
    python3 -m pipx ensurepath 2>/dev/null || true

    success "pipx setup complete"
}

# Main installation
main() {
    echo -e "${BLUE}=== Python Environment Setup ===${NC}\n"

    detect_os
    info "Detected OS: $OS (Package Manager: $PKG_MANAGER)"
    echo

    # Check Python version
    if ! command_exists python3; then
        error "Python 3 is not installed. Please install Python 3 first."
    fi

    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    info "Python version: $PYTHON_VERSION"
    echo

    # Install pip if not present
    if ! python3 -m pip --version &> /dev/null; then
        warn "pip is not installed"
        install_pip
    else
        PIP_VERSION=$(python3 -m pip --version | awk '{print $2}')
        success "pip is already installed (version $PIP_VERSION)"
    fi

    echo

    # Install pipx if not present
    if ! command_exists pipx; then
        warn "pipx is not installed"
        install_pipx
    else
        PIPX_VERSION=$(pipx --version 2>&1 || echo "unknown")
        success "pipx is already installed (version $PIPX_VERSION)"
    fi

    echo
    echo -e "${BLUE}=== Path Configuration ===${NC}\n"

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        warn "~/.local/bin is not in your PATH"
        info "Your shell configuration files will be updated to include it"
        info "You may need to restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    else
        success "~/.local/bin is in your PATH"
    fi

    # Create pip/pip3 symlinks in ~/.local/bin if they don't exist
    if ! command_exists pip; then
        info "Creating pip symlink in ~/.local/bin..."
        cat > "$HOME/.local/bin/pip" << 'PIPEOF'
#!/usr/bin/env bash
exec python3 -m pip "$@"
PIPEOF
        chmod +x "$HOME/.local/bin/pip"
        success "Created pip command"
    fi

    if ! command_exists pip3; then
        info "Creating pip3 symlink in ~/.local/bin..."
        cat > "$HOME/.local/bin/pip3" << 'PIP3EOF'
#!/usr/bin/env bash
exec python3 -m pip "$@"
PIP3EOF
        chmod +x "$HOME/.local/bin/pip3"
        success "Created pip3 command"
    fi

    echo
    echo -e "${GREEN}=== Python Setup Complete! ===${NC}\n"

    info "Installed tools:"
    echo "  pip:  $(python3 -m pip --version 2>&1 | head -1)"
    if command_exists pipx; then
        echo "  pipx: $(pipx --version 2>&1)"
    else
        echo "  pipx: Installed - restart shell to use"
    fi

    echo
    info "Usage examples:"
    echo "  pip install --user <package>   # Install Python package for user"
    echo "  pipx install <package>          # Install Python CLI tool in isolated environment"
    echo "  pipx list                       # List installed pipx applications"

    echo
    info "Common packages to install with pipx:"
    echo "  pipx install ruff               # Fast Python linter"
    echo "  pipx install black              # Python code formatter"
    echo "  pipx install poetry             # Python dependency manager"
    echo "  pipx install httpie             # User-friendly HTTP client"

    echo
    warn "IMPORTANT: Restart your shell or run 'source ~/.zshrc' for pip/pipx commands to work"
    echo
}

main "$@"
