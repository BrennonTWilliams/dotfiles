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

# Ensure path resolution functions are available
if ! command -v resolve_platform_path >/dev/null 2>&1; then
    echo "⚠️  Warning: Cross-platform utilities not loaded. Path resolution may not work correctly."
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

# export PATH="$(resolve_platform_path "conda_bin"):$PATH"  # commented out by conda initialize

# Docker CLI completions - use cross-platform path resolution
if command -v resolve_platform_path >/dev/null 2>&1; then
    local docker_completions="$(resolve_platform_path "docker_completions")"
    if [ -d "$docker_completions" ]; then
        fpath=($docker_completions $fpath)
    fi
else
    # Fallback to hardcoded path if cross-platform utilities not available
    if [ -d "$HOME/.docker/completions" ]; then
        fpath=($HOME/.docker/completions $fpath)
    fi
fi

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Initialize completions system (do this only once, at the end of the file)
autoload -Uz compinit
compinit

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# Use cross-platform path resolution for conda
if command -v resolve_platform_path >/dev/null 2>&1; then
    local conda_bin="$(resolve_platform_path "conda_bin")"
    __conda_setup="$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
else
    # Fallback to dynamic paths for backward compatibility
    local conda_bin="${HOME}/miniforge3/bin"
    if [ -d "$conda_bin" ]; then
        __conda_setup="$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    fi
fi
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local conda_profile="$(resolve_platform_path "conda_profile")"
        local conda_bin="$(resolve_platform_path "conda_bin")"
        if [ -f "$conda_profile" ]; then
            . "$conda_profile"
        else
            export PATH="$conda_bin:$PATH"
        fi
    else
        # Fallback to dynamic paths for backward compatibility
        local conda_root="${HOME}/miniforge3"
        local conda_profile="$conda_root/etc/profile.d/conda.sh"
        local conda_bin="$conda_root/bin"
        if [ -f "$conda_profile" ]; then
            . "$conda_profile"
        else
            export PATH="$conda_bin:$PATH"
        fi
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
# Use cross-platform path resolution for Docker completions
if command -v resolve_platform_path >/dev/null 2>&1; then
    local docker_completions="$(resolve_platform_path "docker_completions")"
    fpath=($docker_completions $fpath)
else
    # Fallback to dynamic path for backward compatibility
    fpath=(${HOME}/.docker/completions $fpath)
fi
autoload -Uz compinit
compinit
# End of Docker CLI completions

# ==============================================================================
# PATH Configuration
# ==============================================================================

# Add custom directories to PATH (consolidated from multiple locations)
# Use cross-platform path resolution where available
if command -v resolve_platform_path >/dev/null 2>&1; then
    export PATH="$(resolve_platform_path "uzi"):$PATH"
    export PATH="$(resolve_platform_path "sdd_workshops"):$PATH"
    export PATH="$(resolve_platform_path "npm_global_bin"):$PATH"
else
    # Fallback to dynamic paths for backward compatibility
    export PATH="$HOME/AIProjects/ai-workspaces/uzi:$PATH"
    export PATH="$PATH:$HOME/AIProjects/ai-workspaces/sdd-workshops"
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Common paths that work across platforms
export PATH="$HOME/.local/bin:$PATH"

# Platform-specific paths
case "$(detect_os 2>/dev/null || echo 'unknown')" in
    "macos")
        export PATH="/opt/homebrew/bin:$PATH"
        # Library path for microsandbox (macOS only)
        export DYLD_LIBRARY_PATH="$(resolve_platform_path "local_lib" 2>/dev/null || echo "$HOME/.local/lib"):$DYLD_LIBRARY_PATH"
        ;;
    "linux")
        # Add Linux-specific paths here if needed
        # For example: export PATH="$HOME/.linuxbrew/bin:$PATH"
        ;;
esac

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

# Video Analysis CLI - use cross-platform path resolution
if command -v resolve_platform_path >/dev/null 2>&1; then
    alias video-analysis='$(resolve_platform_path "video_analysis_cli")'
else
    # Fallback to dynamic path for backward compatibility
    alias video-analysis='$HOME/AIProjects/ai-workspaces/sdd-workshops/video-analysis-cli'
fi

# ==============================================================================
# Starship Display Mode Functions
# ==============================================================================

# Switch between Compact, Standard, and Verbose display modes
starship-compact() {
    # Use cross-platform path resolution
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local starship_dir="$(resolve_platform_path "starship_config")"
        local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
    else
        # Fallback to hardcoded paths for backward compatibility
        local starship_dir="$HOME/.config/starship"
        local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
    fi

    # Create symlink to compact configuration
    ln -sf "$dotfiles_dir/modes/compact.toml" "$starship_dir/starship.toml"
    echo "🚀 Starship mode: COMPACT (minimal information)"
    echo "Configuration: $dotfiles_dir/modes/compact.toml"
    exec zsh
}

starship-standard() {
    # Use cross-platform path resolution
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local starship_dir="$(resolve_platform_path "starship_config")"
        local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
    else
        # Fallback to hardcoded paths for backward compatibility
        local starship_dir="$HOME/.config/starship"
        local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
    fi

    # Create symlink to standard configuration
    ln -sf "$dotfiles_dir/modes/standard.toml" "$starship_dir/starship.toml"
    echo "📋 Starship mode: STANDARD (current multi-line layout)"
    echo "Configuration: $dotfiles_dir/modes/standard.toml"
    exec zsh
}

starship-verbose() {
    # Use cross-platform path resolution
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local starship_dir="$(resolve_platform_path "starship_config")"
        local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
    else
        # Fallback to hardcoded paths for backward compatibility
        local starship_dir="$HOME/.config/starship"
        local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
    fi

    # Create symlink to verbose configuration
    ln -sf "$dotfiles_dir/modes/verbose.toml" "$starship_dir/starship.toml"
    echo "📊 Starship mode: VERBOSE (full context with all details)"
    echo "Configuration: $dotfiles_dir/modes/verbose.toml"
    exec zsh
}

# Show current Starship display mode
starship-mode() {
    # Use cross-platform path resolution
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local starship_config="$(resolve_platform_path "starship_config")/starship.toml"
        local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
    else
        # Fallback to hardcoded paths for backward compatibility
        local starship_config="$HOME/.config/starship/starship.toml"
        local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
    fi

    # Check which configuration file is currently symlinked
    if [[ -L "$starship_config" ]]; then
        local target=$(readlink "$starship_config")
        case "$target" in
            *compact.toml)
                echo "🚀 Current mode: COMPACT (minimal information)"
                echo "Active configuration: $target"
                ;;
            *standard.toml)
                echo "📋 Current mode: STANDARD (current multi-line layout)"
                echo "Active configuration: $target"
                ;;
            *verbose.toml)
                echo "📊 Current mode: VERBOSE (full context with all details)"
                echo "Active configuration: $target"
                ;;
            *)
                echo "❓ Unknown mode - custom configuration"
                echo "Active configuration: $target"
                ;;
        esac
    else
        echo "📋 Current mode: STANDARD (using default configuration)"
        echo "Configuration: $starship_config (not a symlink)"
    fi
}

# Quick aliases for mode switching
alias sc=starship-compact
alias ss=starship-standard
alias sv=starship-verbose
alias sm=starship-mode

# Initialize Starship in standard mode if not already configured
if [[ ! -L "$(resolve_platform_path "starship_config" 2>/dev/null || echo "$HOME/.config/starship")/starship.toml" ]]; then
    # Use cross-platform path resolution
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local starship_dir="$(resolve_platform_path "starship_config")"
        local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
    else
        # Fallback to hardcoded paths for backward compatibility
        local starship_dir="$HOME/.config/starship"
        local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
    fi
    ln -sf "$dotfiles_dir/modes/standard.toml" "$starship_dir/starship.toml"
fi

# ==============================================================================
# Starship Prompt Integration
# ==============================================================================

# Starship is the primary prompt system
# Custom prompt functions have been removed for better performance
eval "$(starship init zsh)"
