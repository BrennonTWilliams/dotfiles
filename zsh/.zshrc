# .zshrc - This file is sourced only for interactive shells
# Use this file for settings that should apply when you interact with the shell,
# including prompt setup, aliases, interactive functions, and command completion.

# Aliases
alias tre='eza -T'
alias clipboard-sync='uniclip 192.168.1.24:38687'

# ==============================================================================
# Enhanced Statusline Configuration for Ghostty
# ==============================================================================

# Function to get git branch and status
git_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
        local status=$(git status --porcelain 2>/dev/null | wc -l)
        if [ $status -eq 0 ]; then
            echo "%F{010}± $branch%f"  # Green for clean
        else
            echo "%F{009}± $branch*$status%f"  # Red for dirty with file count
        fi
    fi
}

# Function to get current working directory (shortened)
short_path() {
    echo "%F{012}%3~%f"  # Blue, max 3 directories deep
}

# Function to get virtual environment info
venv_info() {
    if [[ -n $VIRTUAL_ENV ]]; then
        local venv_name=$(basename $VIRTUAL_ENV)
        echo "%F{014}($venv_name)%f "  # Cyan
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        echo "%F{014}($CONDA_DEFAULT_ENV)%f "  # Cyan
    fi
}

# Function to get memory usage for current shell
memory_info() {
    local mem_usage=$(ps -o rss= -p $$ | awk '{printf "%.1f", $1/1024}')
    echo "%F{014}💾 ${mem_usage}MB%f"  # Cyan memory info
}

# Function to get CPU usage for current shell
cpu_info() {
    local cpu_usage=$(ps -o %cpu= -p $$ | awk '{printf "%.1f", $1}')
    echo "%F{011}⚡ ${cpu_usage}%%f"  # Yellow CPU info
}

# Function to get workspace/project context
workspace_info() {
    # Check for Git repo name
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local repo_name=$(basename $(git rev-parse --show-toplevel))
        echo "%F{013}📁 $repo_name%f"  # Magenta workspace
    # Check for package.json, Cargo.toml, etc.
    elif [[ -f "package.json" ]]; then
        local project_name=$(jq -r .name package.json 2>/dev/null || echo "Node")
        echo "%F{013}📦 $project_name%f"  # Magenta project
    elif [[ -f "Cargo.toml" ]]; then
        local project_name=$(grep '^name = ' Cargo.toml | cut -d'"' -f2 || echo "Rust")
        echo "%F{013}🦀 $project_name%f"  # Magenta project
    elif [[ -f "pyproject.toml" ]]; then
        local project_name=$(grep '^name = ' pyproject.toml | cut -d'"' -f2 || echo "Python")
        echo "%F{013}🐍 $project_name%f"  # Magenta project
    else
        local dir_name=$(basename $(pwd))
        echo "%F{013}📂 $dir_name%f"  # Magenta directory
    fi
}

# Function to get command execution time and handle terminal titles
preexec() {
    __timer_start=$(date +%s.%N)
    # Set terminal title to "directory: command"
    print -Pn "\e]0;%~: $1\a"
}

precmd() {
    if [[ -n $__timer_start ]]; then
        local __timer_end=$(date +%s.%N)
        local __elapsed=$(echo "$__timer_end - $__timer_start" | bc -l 2>/dev/null || echo "0")
        local __elapsed_int=$(echo "$__elapsed" | cut -d. -f1)
        if [[ $__elapsed_int -ge 1 ]]; then
            __timer_info=" %F{011}${__elapsed}s%f"  # Yellow timing info
        else
            __timer_info=""
        fi
        unset __timer_start
    else
        __timer_info=""
    fi

    # Set title to current directory when command finishes
    print -Pn "\e]0;%~\a"

    # Update prompt with all status information
    zle && zle reset-prompt
}

# Enhanced prompt with rich status information
setopt PROMPT_SUBST
PROMPT='
%F{013}┌─[%f$(venv_info)$(short_path)%F{013}]─[%f$(git_status)%F{013}]%f$__timer_info
%F{013}└─❯%f '

# Right-side prompt with timestamp and job count
RPROMPT='%F{008}%D{%H:%M:%S}%f%(1j.%F{009}+ %j%f.)'  # Gray timestamp, red job count

# ==============================================================================
# Tab Block Enhanced Prompt System
# ==============================================================================

# Store original prompt for toggling
ORIGINAL_PROMPT="$PROMPT"
ORIGINAL_RPROMPT="$RPROMPT"

# Enhanced tab prompt with rich visualization
tab_prompt() {
    PROMPT='
%F{013}┌─[%f$(workspace_info)%F{013}]─[%f$(venv_info)$(short_path)%F{013}]─[%f$(git_status)%F{013}]
%F{013}├─[%f$(memory_info)%F{013}]─[%f$(cpu_info)%F{013}]%f$__timer_info
%F{013}└─❯%f '
    RPROMPT='%F{008}%D{%H:%M}%f%(1j.%F{009}+ %j%f.)'  # Shorter time format for tab mode
    echo "🔥 Tab-enhanced prompt activated. Use 'standard_prompt' to return to normal."
}

# Return to standard prompt
standard_prompt() {
    PROMPT="$ORIGINAL_PROMPT"
    RPROMPT="$ORIGINAL_RPROMPT"
    echo "🔧 Standard prompt restored. Use 'tab_prompt' for tab-enhanced view."
}

# Compact tab prompt (minimal)
compact_prompt() {
    PROMPT='$(workspace_info) $(git_status) ❯ '
    RPROMPT=''
    echo "📱 Compact mode activated. Use 'standard_prompt' to return to normal."
}

# Minimal information prompt
minimal_prompt() {
    PROMPT='%F{012}%2~%f ❯ '  # Just directory, no git or extras
    RPROMPT=''
    echo "⚡ Minimal mode activated. Use 'standard_prompt' to return to normal."
}

# Ghostty Terminal Title Integration is now handled in the enhanced statusline above

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

# IntelliShell - DISABLED for Mac reference system to prevent hotkey conflicts
# export INTELLI_HOME="/Users/brennon/Library/Application Support/org.IntelliShell.Intelli-Shell"
# export INTELLI_SEARCH_HOTKEY='^@'
# export INTELLI_VARIABLE_HOTKEY='^l'
# export INTELLI_BOOKMARK_HOTKEY='^b'
# export INTELLI_FIX_HOTKEY='^x'
# export INTELLI_SKIP_ESC_BIND=0
# alias is="intelli-shell"
# export PATH="$INTELLI_HOME/bin:$PATH"
# eval "$(intelli-shell init zsh)"

# Video Analysis CLI
alias video-analysis='/Users/brennon/AIProjects/ai-workspaces/sdd-workshops/video-analysis-cli'
export PATH="$PATH:/Users/brennon/AIProjects/ai-workspaces/sdd-workshops"

# ==============================================================================
# Quick Prompt Reference
# ==============================================================================
#
# Available prompt modes:
# - tab_prompt     : Enhanced tab blocks with workspace, memory, CPU info
# - standard_prompt: Return to original custom prompt
# - compact_prompt : Minimal workspace + git status
# - minimal_prompt : Just directory path
# - starship-enable: Switch to Starship prompt system
# - starship-disable: Return to custom prompt
#
# ==============================================================================
# Starship Prompt Integration
# ==============================================================================

# Toggle between custom prompt and Starship
# Use 'starship-enable' to switch to Starship, 'starship-disable' to return to custom
starship-enable() {
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
        echo "✨ Starship prompt enabled. Use 'starship-disable' to return to custom prompt."
    else
        echo "❌ Starship not found. Install with: brew install starship"
    fi
}

starship-disable() {
    # Reset to custom prompt by re-sourcing this file without Starship
    unset -f precmd 2>/dev/null
    unset -f preexec 2>/dev/null
    source ~/.zshrc
    echo "🔧 Custom prompt restored. Use 'starship-enable' to switch back to Starship."
}

# Uncomment the line below to enable Starship by default
# eval "$(starship init zsh)"
