# .zshrc - This file is sourced only for interactive shells
# Use this file for settings that should apply when you interact with the shell,
# including prompt setup, aliases, interactive functions, and command completion.

# Aliases
alias tre='eza -T'
alias clipboard-sync='uniclip 192.168.1.24:38687'

# Python environment management
# Note: Using both pyenv and conda can be useful if you use different Python
# environments for different projects. If you primarily use one, consider removing the other.
# Pyenv initialization
# Note: PYENV_ROOT is already set in .zshenv
# if command -v pyenv >/dev/null 2>&1; then
#   eval "$(pyenv init --path)"
#   eval "$(pyenv init -)"
#   if pyenv commands | grep -q virtualenv-init; then
#     eval "$(pyenv virtualenv-init -)"
#   fi
# fi

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

# Add uzi directory to PATH
export PATH="/Users/brennon/AIProjects/ai-workspaces/uzi:$PATH"

# Added by microsandbox installer
export PATH="$HOME/.local/bin:$PATH"
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
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Users/brennon/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# IntelliShell
export INTELLI_HOME="/Users/brennon/Library/Application Support/org.IntelliShell.Intelli-Shell"
# export INTELLI_SEARCH_HOTKEY='^@'
# export INTELLI_VARIABLE_HOTKEY='^l'
# export INTELLI_BOOKMARK_HOTKEY='^b'
# export INTELLI_FIX_HOTKEY='^x'
# export INTELLI_SKIP_ESC_BIND=0
# alias is="intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
eval "$(intelli-shell init zsh)"
