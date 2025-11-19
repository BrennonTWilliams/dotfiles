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
# Clipboard sync - uses UNICLIP_SERVER environment variable
# Set UNICLIP_SERVER in ~/.zshenv or ~/.zshrc.local (e.g., export UNICLIP_SERVER="192.168.1.24:38687")
alias clipboard-sync='uniclip ${UNICLIP_SERVER:-localhost:53168}'

# ==============================================================================
# Starship Prompt Configuration
# ==============================================================================
# Custom prompt functions removed - using Starship instead
# Starship provides better performance, maintainability, and features

# ==============================================================================
# Terminal Title Management
# ==============================================================================

# Set terminal title for current command and directory
# Using add-zsh-hook to avoid conflicts with Starship and other prompt systems
autoload -Uz add-zsh-hook

# Function to set title before command execution
_set_title_preexec() {
    # Set terminal title to "directory: command"
    print -Pn "\e]0;%~: $1\a"
}

# Function to set title after command completion
_set_title_precmd() {
    # Set title to current directory when command finishes
    print -Pn "\e]0;%~\a"
}

# Register hooks (allows multiple functions to use precmd/preexec)
add-zsh-hook preexec _set_title_preexec
add-zsh-hook precmd _set_title_precmd

# Python environment management
# Using conda for Python environment management

# export PATH="$(resolve_platform_path "conda_bin"):$PATH"  # commented out by conda initialize

# ==============================================================================
# VSCode Shell Integration (Optimized)
# ==============================================================================
# Performance: 10-30ms baseline, optimized to <5ms with caching
# Only loads when running in VSCode terminal ($TERM_PROGRAM == "vscode")
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Cache directory for shell integration paths
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    local vscode_cache="$cache_dir/vscode_integration_path"
    local vscode_integration=""

    # Try to load from cache first (avoids spawning 'code' process)
    if [[ -f "$vscode_cache" && -r "$vscode_cache" ]]; then
        vscode_integration="$(<"$vscode_cache")"
        # Verify cached path is still valid
        if [[ ! -f "$vscode_integration" ]]; then
            vscode_integration=""
            rm -f "$vscode_cache" 2>/dev/null
        fi
    fi

    # If cache miss or invalid, fetch and cache the path
    if [[ -z "$vscode_integration" ]] && command -v code >/dev/null 2>&1; then
        vscode_integration="$(code --locate-shell-integration-path zsh 2>/dev/null)"
        if [[ -n "$vscode_integration" && -f "$vscode_integration" ]]; then
            mkdir -p "$cache_dir" 2>/dev/null
            echo "$vscode_integration" > "$vscode_cache" 2>/dev/null
        fi
    fi

    # Source the integration if available
    [[ -n "$vscode_integration" && -f "$vscode_integration" ]] && . "$vscode_integration"

    unset vscode_integration vscode_cache cache_dir
fi

# >>> conda initialize (lazy-loaded) >>>
# !! Lazy-loading wrapper for conda - saves 100-200ms on shell startup !!
# Conda will be initialized only when first used
#
# This replaces the standard synchronous conda init that runs on every shell startup.
# Instead, we create a placeholder function that initializes conda on first use.

# Initialize conda when first used
__conda_lazy_init() {
    # Remove the placeholder function to avoid recursion
    unfunction conda 2>/dev/null

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

    # Clean up the lazy init function
    unfunction __conda_lazy_init
}

# Create a placeholder conda function that initializes on first use
conda() {
    __conda_lazy_init
    # Call the real conda command with all arguments
    conda "$@"
}

# Ensure conda bin is in PATH for other tools that might need it
if command -v resolve_platform_path >/dev/null 2>&1; then
    local conda_bin="$(resolve_platform_path "conda_bin")"
    export PATH="$conda_bin:$PATH"
else
    # Fallback to dynamic paths for backward compatibility
    local conda_bin="${HOME}/miniforge3/bin"
    if [ -d "$conda_bin" ]; then
        export PATH="$conda_bin:$PATH"
    fi
fi
# <<< conda initialize (lazy-loaded) <<<

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
# NOTE: Standard PATH additions (Homebrew, NPM, .local/bin, Pyenv) are now in .zshenv
# Only application-specific paths are added here

# Platform-specific configuration (non-PATH)
case "$(detect_os 2>/dev/null || echo 'unknown')" in
    "macos")
        # Library path for microsandbox (macOS only)
        export DYLD_LIBRARY_PATH="$(resolve_platform_path "local_lib" 2>/dev/null || echo "$HOME/.local/lib"):$DYLD_LIBRARY_PATH"
        ;;
    "linux")
        # Add Linux-specific configuration here if needed
        ;;
esac

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# >>> z - jump around (lazy-loaded) >>>
# !! Lazy-loading wrapper for z - saves 5-15ms on shell startup !!
# Z will be initialized only when first used
#
# This replaces the standard synchronous z init that runs on every shell startup.
# Instead, we create a placeholder function that initializes z on first use.

# Initialize z when first used
__z_lazy_init() {
    # Remove the placeholder function to avoid recursion
    unfunction z 2>/dev/null

    # Source the z script
    if [[ -f ~/.local/share/z/z.sh ]]; then
        . ~/.local/share/z/z.sh
    else
        echo "Warning: z.sh not found at ~/.local/share/z/z.sh"
        return 1
    fi

    # Clean up the lazy init function
    unfunction __z_lazy_init
}

# Create a placeholder z function that initializes on first use
z() {
    __z_lazy_init
    # Call the real z command with all arguments
    z "$@"
}
# <<< z - jump around (lazy-loaded) <<<

alias breath='zenta now --quick'
alias breathe='zenta now'
alias reflect='zenta reflect'

# ==============================================================================
# Kiro Shell Integration (Optimized)
# ==============================================================================
# Performance: 10-30ms baseline, optimized to <5ms with caching
# Only loads when running in Kiro terminal ($TERM_PROGRAM == "kiro")
if [[ "$TERM_PROGRAM" == "kiro" ]]; then
    # Cache directory for shell integration paths
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    local kiro_cache="$cache_dir/kiro_integration_path"
    local kiro_integration=""

    # Try to load from cache first (avoids spawning 'kiro' process)
    if [[ -f "$kiro_cache" && -r "$kiro_cache" ]]; then
        kiro_integration="$(<"$kiro_cache")"
        # Verify cached path is still valid
        if [[ ! -f "$kiro_integration" ]]; then
            kiro_integration=""
            rm -f "$kiro_cache" 2>/dev/null
        fi
    fi

    # If cache miss or invalid, fetch and cache the path
    if [[ -z "$kiro_integration" ]] && command -v kiro >/dev/null 2>&1; then
        kiro_integration="$(kiro --locate-shell-integration-path zsh 2>/dev/null)"
        if [[ -n "$kiro_integration" && -f "$kiro_integration" ]]; then
            mkdir -p "$cache_dir" 2>/dev/null
            echo "$kiro_integration" > "$kiro_cache" 2>/dev/null
        fi
    fi

    # Source the integration if available
    [[ -n "$kiro_integration" && -f "$kiro_integration" ]] && . "$kiro_integration"

    unset kiro_integration kiro_cache cache_dir
fi





# Task Master aliases added on 8/16/2025
alias tm='task-master'
alias taskmaster='task-master'

# IntelliShell integration removed - using Starship prompt instead

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
        local dotfiles_dir="$HOME/.dotfiles/starship"
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
        local dotfiles_dir="$HOME/.dotfiles/starship"
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
        local dotfiles_dir="$HOME/.dotfiles/starship"
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
        local dotfiles_dir="$HOME/.dotfiles/starship"
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
        local dotfiles_dir="$HOME/.dotfiles/starship"
    fi
    ln -sf "$dotfiles_dir/modes/standard.toml" "$starship_dir/starship.toml"
fi

# ==============================================================================
# Starship Prompt Integration
# ==============================================================================

# Starship is the primary prompt system
# Custom prompt functions have been removed for better performance

# Clear any existing prompt configurations to prevent conflicts
unset PROMPT
unset RPROMPT
unset PROMPT_COMMAND

# Initialize Starship
eval "$(starship init zsh)"
