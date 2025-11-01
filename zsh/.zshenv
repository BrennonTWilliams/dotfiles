# .zshenv - This file is sourced for all shells (interactive, non-interactive, login)
# Place all environment variables here to ensure they're available everywhere

# Basic PATH setup
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# JetBrains Toolbox
JETBRAINS_PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
if [ -d "$JETBRAINS_PATH" ]; then
    PATH="$JETBRAINS_PATH:$PATH"
fi

# Pyenv configuration
PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
    PATH="$PYENV_ROOT/bin:$PATH"
fi

export PATH
