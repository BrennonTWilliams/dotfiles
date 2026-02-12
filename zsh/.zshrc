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
    echo "[!] Warning: Cross-platform utilities not loaded. Path resolution may not work correctly."
fi

# ==============================================================================
# Custom Logo Display (Opt-in)
# ==============================================================================
# Display custom CLI logo for interactive shells
# To enable: run `logo-toggle` (creates ~/.config/brenentech/.logo_enabled)
if [[ -f ~/.config/brenentech/logo.sh ]]; then
    source ~/.config/brenentech/logo.sh
fi

# ==============================================================================
# Modular Shell Configuration
# ==============================================================================
# Toggle via DOTFILES_ABBR_MODE environment variable:
#   abbr   - zsh-abbr abbreviations (default, requires: brew install olets/tap/zsh-abbr)
#   alias  - Traditional aliases only (fallback if zsh-abbr not installed)
#
# Set in ~/.zshenv.local: export DOTFILES_ABBR_MODE="alias"

# Resolve DOTFILES_ZSH from symlink (${0:A:h} doesn't work for sourced files)
if [[ -L ~/.zshrc ]]; then
    DOTFILES_ZSH="$HOME/$(dirname "$(readlink ~/.zshrc)")"
else
    DOTFILES_ZSH="${0:A:h}"
fi

# Load functions (always - these are shell functions like mkcd, nvim-keys, etc.)
[[ -f "$DOTFILES_ZSH/functions/_init.zsh" ]] && source "$DOTFILES_ZSH/functions/_init.zsh"

# Load safety aliases (always - rm -i, cp -i, mv -i should not expand)
[[ -f "$DOTFILES_ZSH/aliases/_init.zsh" ]] && source "$DOTFILES_ZSH/aliases/_init.zsh"

# Load abbreviations (default mode)
if [[ "${DOTFILES_ABBR_MODE:-abbr}" == "abbr" ]]; then
    [[ -f "$DOTFILES_ZSH/abbreviations/_init.zsh" ]] && source "$DOTFILES_ZSH/abbreviations/_init.zsh"
fi

# Load aliases if mode is "alias" (fallback when zsh-abbr not installed)
if [[ "${DOTFILES_ABBR_MODE:-abbr}" == "alias" ]]; then
    [[ -f "$DOTFILES_ZSH/aliases/extras.zsh" ]] && source "$DOTFILES_ZSH/aliases/extras.zsh"
fi

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
# Lazy-loading saves 100-200ms on shell startup by deferring conda init until first use

__conda_lazy_init() {
    unfunction conda 2>/dev/null

    # Resolve conda paths (with fallback)
    local conda_bin
    if command -v resolve_platform_path >/dev/null 2>&1; then
        conda_bin="$(resolve_platform_path "conda_bin")"
    else
        conda_bin="${HOME}/miniforge3/bin"
    fi

    [[ ! -d "$conda_bin" ]] && return 1

    # Try shell hook first, then profile.d, then just PATH
    local __conda_setup
    __conda_setup="$("$conda_bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"

    if [[ $? -eq 0 ]]; then
        eval "$__conda_setup"
    elif [[ -f "${conda_bin%/bin}/etc/profile.d/conda.sh" ]]; then
        . "${conda_bin%/bin}/etc/profile.d/conda.sh"
    else
        export PATH="$conda_bin:$PATH"
    fi

    unfunction __conda_lazy_init 2>/dev/null
}

conda() {
    __conda_lazy_init
    conda "$@"
}

# Add conda bin to PATH for tools that need it before lazy-init
{
    local conda_bin
    if command -v resolve_platform_path >/dev/null 2>&1; then
        conda_bin="$(resolve_platform_path "conda_bin")"
    else
        conda_bin="${HOME}/miniforge3/bin"
    fi
    [[ -d "$conda_bin" ]] && export PATH="$conda_bin:$PATH"
}
# <<< conda initialize (lazy-loaded) <<<

# ==============================================================================
# Completion System Configuration
# ==============================================================================

# Add local site-functions to fpath (for stow-managed completions like ghostty)
fpath=(${HOME}/.local/share/zsh/site-functions $fpath)

# Docker CLI completions (added by Docker Desktop)
if command -v resolve_platform_path >/dev/null 2>&1; then
    local docker_completions="$(resolve_platform_path "docker_completions")"
    fpath=($docker_completions $fpath)
else
    fpath=(${HOME}/.docker/completions $fpath)
fi

autoload -Uz compinit
compinit

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
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# >>> zoxide - smarter cd command >>>
# Modern replacement for z/autojump - tracks directory usage by frecency
# Usage: z <partial-path>  - jump to best match
#        zi <partial-path> - interactive selection with fzf
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
# <<< zoxide <<<

# ==============================================================================
# BRENENTECH Logo Functions
# ==============================================================================

# Toggle logo display on/off (persistent)
logo-toggle() {
    local state_file="$HOME/.config/brenentech/.logo_enabled"

    if [[ -f "$state_file" ]]; then
        rm "$state_file"
        echo "▸ BRENENTECH logo disabled (will not show on next login)"
    else
        touch "$state_file"
        echo "▸ BRENENTECH logo enabled (will show on next login)"
    fi
}

# Display logo manually (bypasses state check)
logo-show() {
    local logo_script="$HOME/.config/brenentech/logo.sh"

    if [[ -f "$logo_script" ]]; then
        # Temporarily create state file if it doesn't exist
        local state_file="$HOME/.config/brenentech/.logo_enabled"
        local had_state=false
        [[ -f "$state_file" ]] && had_state=true

        # Ensure state file exists for display
        touch "$state_file"

        # Source the logo script
        source "$logo_script"

        # Restore original state
        if ! $had_state; then
            rm "$state_file"
        fi
    else
        echo "[x] Logo script not found at: $logo_script"
    fi
}

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




# IntelliShell integration removed - using Starship prompt instead

# ==============================================================================
# Starship Display Mode Functions
# ==============================================================================

# Cache starship paths once (avoids repeated resolve_platform_path calls)
if command -v resolve_platform_path >/dev/null 2>&1; then
    typeset -g _STARSHIP_CONFIG_DIR="$(resolve_platform_path "starship_config")"
    typeset -g _DOTFILES_STARSHIP_DIR="$(resolve_platform_path "dotfiles")/starship"
else
    typeset -g _STARSHIP_CONFIG_DIR="$HOME/.config/starship"
    typeset -g _DOTFILES_STARSHIP_DIR="$HOME/.dotfiles/starship"
fi

# Helper to switch starship mode
_starship_set_mode() {
    local mode="$1" label="$2" symbol="$3"
    ln -sf "$_DOTFILES_STARSHIP_DIR/.config/starship/${mode}.toml" "$_STARSHIP_CONFIG_DIR/starship.toml"
    echo "[$symbol] Starship mode: $label"
    echo "Configuration: $_DOTFILES_STARSHIP_DIR/.config/starship/${mode}.toml"
    exec zsh
}

starship-compact()              { _starship_set_mode "compact"              "COMPACT (minimal information)" ">"; }
starship-standard()             { _starship_set_mode "standard"             "STANDARD (current multi-line layout)" "="; }
starship-verbose()              { _starship_set_mode "verbose"              "VERBOSE (full context with all details)" "+"; }
starship-gruvbox-light()        { _starship_set_mode "gruvbox-rainbow-light" "GRUVBOX RAINBOW LIGHT" "*"; }
starship-gruvbox-rainbow()      { _starship_set_mode "gruvbox-rainbow"       "GRUVBOX RAINBOW (dark)" "#"; }

# Show current Starship display mode
starship-mode() {
    local config_file="$_STARSHIP_CONFIG_DIR/starship.toml"

    if [[ -L "$config_file" ]]; then
        local target=$(readlink "$config_file")
        case "$target" in
            *compact.toml)              echo "[>] Current mode: COMPACT (minimal information)" ;;
            *standard.toml)             echo "[=] Current mode: STANDARD (current multi-line layout)" ;;
            *verbose.toml)              echo "[+] Current mode: VERBOSE (full context with all details)" ;;
            *gruvbox-rainbow-light.toml) echo "[*] Current mode: GRUVBOX RAINBOW LIGHT" ;;
            *gruvbox-rainbow.toml)      echo "[#] Current mode: GRUVBOX RAINBOW (dark)" ;;
            *)                          echo "[?] Unknown mode - custom configuration" ;;
        esac
        echo "Active configuration: $target"
    else
        echo "[=] Current mode: STANDARD (using default configuration)"
        echo "Configuration: $config_file (not a symlink)"
    fi
}

# Initialize Starship in standard mode if not already configured
[[ ! -d "$_STARSHIP_CONFIG_DIR" ]] && mkdir -p "$_STARSHIP_CONFIG_DIR"
[[ ! -L "$_STARSHIP_CONFIG_DIR/starship.toml" ]] && \
    ln -sf "$_DOTFILES_STARSHIP_DIR/.config/starship/standard.toml" "$_STARSHIP_CONFIG_DIR/starship.toml"

# ==============================================================================
# Theme Mode (dark/light toggle)
# ==============================================================================
# State file: ~/.config/theme-mode (contains "dark" or "light")

# Detect macOS appearance on startup
_detect_theme_mode() {
    local style
    style="$(defaults read -g AppleInterfaceStyle 2>/dev/null)"
    if [[ "$style" == "Dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Initialize THEME_MODE from state file or macOS appearance
if [[ -f ~/.config/theme-mode ]]; then
    export THEME_MODE="$(<~/.config/theme-mode)"
else
    export THEME_MODE="$(_detect_theme_mode)"
fi

# Central theme toggle function
toggle-theme() {
    local current="${THEME_MODE:-dark}"
    local new_mode

    if [[ "$current" == "dark" ]]; then
        new_mode="light"
    else
        new_mode="dark"
    fi

    # Persist the mode
    echo "$new_mode" > ~/.config/theme-mode
    export THEME_MODE="$new_mode"

    # Switch Ghostty theme (write to config.local which ghostty auto-reloads)
    local ghostty_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
    if [[ -d "$ghostty_config_dir" ]]; then
        if [[ "$new_mode" == "light" ]]; then
            echo "theme = gruvbox-light-custom" > "$ghostty_config_dir/config.local"
        else
            echo "theme = gruvbox-dark-custom" > "$ghostty_config_dir/config.local"
        fi
    fi

    # Switch Starship config
    if [[ "$new_mode" == "light" ]]; then
        ln -sf "$_DOTFILES_STARSHIP_DIR/.config/starship/gruvbox-rainbow-light.toml" "$_STARSHIP_CONFIG_DIR/starship.toml"
    else
        ln -sf "$_DOTFILES_STARSHIP_DIR/.config/starship/gruvbox-rainbow.toml" "$_STARSHIP_CONFIG_DIR/starship.toml"
    fi

    # Reload tmux if running inside a tmux session
    if [[ -n "$TMUX" ]]; then
        tmux source-file ~/.tmux.conf 2>/dev/null
    fi

    echo "[~] Theme switched to: $new_mode"
    echo "    Restart shell (exec zsh) for full effect"
}

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

# ==============================================================================
# Local Overrides
# ==============================================================================
# Source machine-specific configuration last to allow overriding any setting
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
export PATH="$PATH:$(go env GOPATH)/bin"
export NODE_OPTIONS="--max-old-space-size=8192"
