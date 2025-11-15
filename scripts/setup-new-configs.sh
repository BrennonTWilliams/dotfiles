#!/usr/bin/env bash

# ==============================================================================
# New Dotfiles Configuration Setup Script
# ==============================================================================
# This script sets up the new configuration packages (git, vscode, npm)
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Git Configuration Setup
# ==============================================================================

setup_git_config() {
    section "Setting up Git Configuration"

    local gitconfig="$HOME/.gitconfig"
    local gitconfig_template="$SCRIPT_DIR/../git/.gitconfig"

    if [ -f "$gitconfig_template" ]; then
        if [ ! -f "$gitconfig" ] || [ ! -s "$gitconfig" ]; then
            info "Setting up Git configuration"
            cp "$gitconfig_template" "$gitconfig"

            warn "Remember to update your Git user information:"
            warn "  git config --global user.name 'Your Name'"
            warn "  git config --global user.email 'your.email@example.com'"
        else
            info "Git configuration already exists"
        fi

        # Create local config if it doesn't exist
        if [ ! -f "$HOME/.gitconfig.local" ]; then
            info "Creating local Git configuration file"
            cat > "$HOME/.gitconfig.local" << 'EOF'
# Local Git configuration
# Add machine-specific settings here

[user]
    # Override personal information if needed
    # name = Your Actual Name
    # email = your.actual.email@example.com

[credential]
    # macOS keychain
    helper = osxkeychain

    # Linux (uncomment if needed)
    # helper = manager

# Work-specific configurations
# [github]
#     user = your-work-username
EOF
        fi
    else
        warn "Git configuration template not found"
    fi

    success "Git configuration setup completed"
}

# ==============================================================================
# VS Code Setup
# ==============================================================================

setup_vscode() {
    section "Setting up VS Code"

    if command_exists code; then
        info "VS Code found - installing extensions"

        local extensions_file="$SCRIPT_DIR/../vscode/extensions.txt"
        if [ -f "$extensions_file" ]; then
            # Install extensions
            while IFS= read -r extension; do
                # Skip comments and empty lines, and trim whitespace
                if [[ ! "$extension" =~ ^[[:space:]]*# ]] && [[ -n "${extension// }" ]]; then
                    # Remove comments after extension names and trim whitespace
                    extension=$(echo "$extension" | cut -d'#' -f1 | xargs)
                    if [[ -n "$extension" ]]; then
                        info "Installing extension: $extension"
                        code --install-extension "$extension" --force
                    fi
                fi
            done < "$extensions_file"

            success "VS Code extensions installed"
        else
            warn "VS Code extensions file not found"
        fi

        # Ensure VS Code settings directory exists and setup symlinks
        local vscode_config_dir="$HOME/.config/Code/User"
        local vscode_stow_dir="$HOME/.vscode"

        # Create the VS Code config directory if it doesn't exist
        if [ ! -d "$vscode_config_dir" ]; then
            mkdir -p "$vscode_config_dir"
            info "Created VS Code config directory: $vscode_config_dir"
        fi

        # Create the stow target directory if it doesn't exist
        if [ ! -d "$vscode_stow_dir" ]; then
            mkdir -p "$vscode_stow_dir"
            info "Created VS Code stow directory: $vscode_stow_dir"
        fi

        # Symlink individual files to the correct VS Code config location
        local vscode_files=("settings.json" "keybindings.json")
        for file in "${vscode_files[@]}"; do
            local source_file="$SCRIPT_DIR/../vscode/$file"
            local target_file="$vscode_config_dir/$file"

            if [ -f "$source_file" ]; then
                if [ -L "$target_file" ]; then
                    # Remove existing symlink
                    unlink "$target_file"
                elif [ -f "$target_file" ]; then
                    # Backup existing file
                    mv "$target_file" "$target_file.backup.$(date +%Y%m%d_%H%M%S)"
                fi

                # Create new symlink
                ln -s "$source_file" "$target_file"
                info "Linked $file to VS Code configuration"
            fi
        done

        info "VS Code configuration files linked successfully"
    else
        warn "VS Code not found - skipping extension installation"
        warn "Install VS Code first: https://code.visualstudio.com/"
    fi

    success "VS Code setup completed"
}

# ==============================================================================
# NPM Setup
# ==============================================================================

setup_npm() {
    section "Setting up NPM Configuration"

    if command_exists npm; then
        info "NPM found - configuring global packages"

        # Create npm global directory if it doesn't exist
        local npm_global="$HOME/.npm-global"
        if [ ! -d "$npm_global" ]; then
            mkdir -p "$npm_global"
            info "Created NPM global directory: $npm_global"
        fi

        # Check if npm global path is in PATH
        if [[ ":$PATH:" != *":$npm_global/bin:"* ]]; then
            warn "Adding NPM global directory to PATH"
            warn "Add this to your shell profile:"
            warn "  export PATH=\"$npm_global/bin:\$PATH\""
        fi

        # Install essential global packages
        local essential_packages=(
            "npm"
            "typescript"
            "nodemon"
            "eslint"
            "prettier"
        )

        info "Installing essential NPM packages:"
        for package in "${essential_packages[@]}"; do
            info "Installing $package globally"
            npm install -g "$package"
        done

        # Offer to install additional packages
        local packages_file="$SCRIPT_DIR/../npm/global-packages.txt"
        if [ -f "$packages_file" ]; then
            echo
            warn "Additional global packages are available in global-packages.txt"
            warn "Install them with: xargs -a $packages_file npm install -g"
        fi

        # Create local NPM config if it doesn't exist
        if [ ! -f "$HOME/.npmrc.local" ]; then
            info "Creating local NPM configuration file"
            cat > "$HOME/.npmrc.local" << 'EOF'
# Local NPM configuration
# Add machine-specific settings here

# Company registry (uncomment if needed)
# @yourcompany:registry=https://npm.yourcompany.com

# Authentication tokens (never commit this file)
# //registry.npmjs.org/:_authToken=your_token_here

# Proxy settings (uncomment if needed)
# proxy=http://proxy.company.com:8080
# https-proxy=http://proxy.company.com:8080
EOF
        fi

    else
        warn "NPM not found - skipping NPM configuration"
        warn "Install Node.js first: https://nodejs.org/"
    fi

    success "NPM setup completed"
}

# ==============================================================================
# Shell Configuration Setup
# ==============================================================================

setup_shell_configs() {
    section "Setting up Shell Configurations"

    # Create local shell config files if they don't exist
    local shell_configs=(
        "$HOME/.bash_profile.local"
        "$HOME/.bashrc.local"
        "$HOME/.zshenv.local"
        "$HOME/.zshrc.local"
    )

    for config in "${shell_configs[@]}"; do
        if [ ! -f "$config" ]; then
            info "Creating $config"
            touch "$config"
        else
            info "$config already exists"
        fi
    done

    success "Shell configuration setup completed"
}

# ==============================================================================
# Main Function
# ==============================================================================

main() {
    info "Starting new dotfiles configuration setup"

    setup_git_config
    setup_vscode
    setup_npm
    setup_shell_configs

    section "Setup Complete"
    success "New dotfiles configuration setup completed!"
    echo
    warn "Remember to:"
    warn "1. Update your Git user information: git config --global user.name/email"
    warn "2. Add ~/.npm-global/bin to your PATH if not already present"
    warn "3. Reload your shell: exec \$SHELL"
    warn "4. Check the README files in each configuration directory"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi