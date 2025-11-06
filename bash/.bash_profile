# .bash_profile - Bash login shell configuration
# This file is sourced for login shells

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# Cross-platform conda initialization using path resolution system

# Source cross-platform utilities if available
if [[ -f ~/.zsh_cross_platform ]]; then
    # Use bash compatibility mode for zsh functions
    source ~/.zsh_cross_platform 2>/dev/null || true
fi

# Initialize conda with cross-platform path resolution
initialize_conda() {
    # Try to use cross-platform path resolution if available
    if command -v resolve_platform_path >/dev/null 2>&1; then
        local conda_bin="$(resolve_platform_path "conda_bin")"
        local conda_profile="$(resolve_platform_path "conda_profile")"

        if [[ -f "$conda_bin/conda" ]]; then
            eval "$("$conda_bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
        elif [[ -f "$conda_profile" ]]; then
            . "$conda_profile"
        fi
    else
        # Fallback: traditional path detection
        if command -v conda >/dev/null 2>&1; then
            # Try to find conda installation
            if [[ -f "$HOME/miniforge3/bin/conda" ]]; then
                eval "$($HOME/miniforge3/bin/conda 'shell.bash' 'hook' 2> /dev/null)"
            elif [[ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]]; then
                . "$HOME/miniforge3/etc/profile.d/conda.sh"
            elif [[ -f "/opt/homebrew/Caskroom/miniforge/base/bin/conda" ]]; then
                eval "$(/opt/homebrew/Caskroom/miniforge/base/bin/conda 'shell.bash' 'hook' 2> /dev/null)"
            elif [[ -f "/opt/homebrew/bin/conda" ]]; then
                eval "$(/opt/homebrew/bin/conda 'shell.bash' 'hook' 2> /dev/null)"
            else
                # Fallback: add conda to PATH if found elsewhere
                export PATH="$(dirname $(which conda))/../bin:$PATH"
            fi
        else
            echo "conda not found - please install or update paths in .bash_profile"
        fi
    fi
}

# Initialize conda
initialize_conda

# IntelliShell (optional - macOS-only shell enhancement)
# Cross-platform alternative: Use Starship prompt (recommended) or custom shell functions
# Note: IntelliShell is macOS-only and not recommended for cross-platform setups

# Cross-platform shell enhancement alternatives
if command -v resolve_platform_path >/dev/null 2>&1; then
    # Use platform detection for shell enhancements
    case "$(detect_os)" in
        "macos")
            # macOS-specific shell enhancements can be added here
            # IntelliShell path (if you still want to use it on macOS):
            if [[ -d "$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell" ]]; then
                export INTELLI_HOME="$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell"
                export PATH="$INTELLI_HOME/bin:$PATH"
                # eval "$(intelli-shell init bash)"  # Uncomment if IntelliShell is installed
            fi
            ;;
        "linux")
            # Linux-specific shell enhancements
            # For example, you could add Linux-specific tools here
            # None needed - Starship provides cross-platform prompt functionality
            ;;
    esac
else
    # Fallback: Traditional IntelliShell setup (macOS only)
    if [[ -d "$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell" ]]; then
        export INTELLI_HOME="$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell"
        export PATH="$INTELLI_HOME/bin:$PATH"
        # eval "$(intelli-shell init bash)"  # Uncomment if IntelliShell is installed
    fi
fi

# Recommendation: Use Starship prompt for cross-platform shell enhancement
# Starship is already configured in .zshrc and provides better functionality
# than IntelliShell with full Linux/macOS compatibility.

# Source .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Load local overrides
if [ -f "$HOME/.bash_profile.local" ]; then
    source "$HOME/.bash_profile.local"
fi