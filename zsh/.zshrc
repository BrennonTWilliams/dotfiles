# .zshrc - This file is sourced only for interactive shells
# Use this file for settings that should apply when you interact with the shell,
# including prompt setup, aliases, interactive functions, and command completion.

# ==============================================================================
# Cross-Platform Integration
# ==============================================================================

# Source cross-platform utilities
if [[ -f ~/.zsh_cross_platform ]]; then
    source ~/.zsh_cross_platform
fi

# Aliases
alias tre='eza -T'
alias clipboard-sync='uniclip 192.168.1.24:38687'

# ==============================================================================
# Starship Prompt Configuration
# ==============================================================================
# Custom prompt functions removed - using Starship instead
# Starship provides better performance, maintainability, and features

# ==============================================================================
# Terminal Title Management
# ==============================================================================

# Set terminal title for current command and directory
preexec() {
    # Set terminal title to "directory: command"
    print -Pn "\e]0;%~: $1\a"
}

precmd() {
    # Set title to current directory when command finishes
    print -Pn "\e]0;%~\a"
}

# Python environment management
# Using conda for Python environment management

# export PATH="$HOME/miniforge3/bin:$PATH"  # commented out by conda initialize

# Docker CLI completions
if [ -d "$HOME/.docker/completions" ]; then
  fpath=($HOME/.docker/completions $fpath)
fi

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Initialize completions system (do this only once, at the end of the file)
autoload -Uz compinit
compinit

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/brennon/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/brennon/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/brennon/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/brennon/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/brennon/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# ==============================================================================
# PATH Configuration
# ==============================================================================

# Add custom directories to PATH (consolidated from multiple locations)
export PATH="/Users/brennon/AIProjects/ai-workspaces/uzi:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:/Users/brennon/AIProjects/ai-workspaces/sdd-workshops"

# Library path for microsandbox
export DYLD_LIBRARY_PATH="$HOME/.local/lib:$DYLD_LIBRARY_PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# z - jump around
. ~/.local/share/z/z.sh

alias breath='zenta now --quick'
alias breathe='zenta now'
alias reflect='zenta reflect'

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"





# Task Master aliases added on 8/16/2025
alias tm='task-master'
alias taskmaster='task-master'

# IntelliShell integration removed - using Starship prompt instead

# Video Analysis CLI
alias video-analysis='/Users/brennon/AIProjects/ai-workspaces/sdd-workshops/video-analysis-cli'

# ==============================================================================
# Starship Prompt Integration
# ==============================================================================

# Starship is the primary prompt system
# Custom prompt functions have been removed for better performance
eval "$(starship init zsh)"
