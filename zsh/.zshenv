# .zshenv - This file is sourced for all shells (interactive, non-interactive, login)
# Place all environment variables here to ensure they're available everywhere
#
# ==============================================================================
# PATH Configuration (Consolidated from .zprofile and .zshrc)
# ==============================================================================
# All PATH modifications are centralized here to prevent duplication and
# ensure consistent environment across all shell types (login, interactive, etc.)

# Homebrew setup - must be early as other tools may depend on it
# Check for both Apple Silicon and Intel locations
if [ -x "/opt/homebrew/bin/brew" ]; then
  # Apple Silicon Mac
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
elif command -v brew >/dev/null 2>&1; then
  # If brew is in PATH but not in the standard locations
  eval "$(brew shellenv)"
fi

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
    PATH="$PYENV_ROOT/bin:$PATH"
fi

# NPM Global Packages Path
# Add npm global packages to PATH if the directory exists
if [ -d "$HOME/.npm-global" ]; then
    PATH="$HOME/.npm-global/bin:$PATH"
fi

# User local binaries
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# JetBrains Toolbox (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    JETBRAINS_PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    if [ -d "$JETBRAINS_PATH" ]; then
        PATH="$JETBRAINS_PATH:$PATH"
    fi
fi

export PATH
