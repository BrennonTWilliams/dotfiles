# ~/.zshenv: Always sourced, even for non-interactive shells
# This file should contain PATH settings and environment variables
# that need to be available to all shells and GUI applications

# Local user binaries
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew configuration - needs to be early for package availability
# Check common Homebrew locations for both macOS and Linux
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# NVM directory (the functions are lazy-loaded in .zshrc)
export NVM_DIR="$HOME/.nvm"

# Add NVM's current Node.js version bin to PATH for global npm packages
# This makes globally installed packages (like Claude Code) available
# We add this dynamically since the node version may change
if [ -d "$NVM_DIR/versions/node" ]; then
    # Find the currently active or default node version
    NVM_CURRENT_BIN="$NVM_DIR/versions/node/$(ls -t "$NVM_DIR/versions/node" 2>/dev/null | head -1)/bin"
    if [ -d "$NVM_CURRENT_BIN" ]; then
        export PATH="$NVM_CURRENT_BIN:$PATH"
    fi
fi

# Source local environment overrides if they exist
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
