# ~/.zshenv: Always sourced, even for non-interactive shells
# This file should contain PATH settings and environment variables
# that need to be available to all shells and GUI applications

# Claude Code - needs to be in PATH early for GUI apps
export PATH="$HOME/.npm-global/bin:$PATH"

# Homebrew configuration - also needs to be early
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# NVM directory (the functions are lazy-loaded in .zshrc)
export NVM_DIR="$HOME/.nvm"

# Source local environment overrides if they exist
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
