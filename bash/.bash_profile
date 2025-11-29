# .bash_profile - Bash login shell configuration
# This file is sourced for login shells

# ==============================================================================
# Conda Initialize (Lazy-Loaded)
# ==============================================================================
# Lazy-loading saves 100-200ms on shell startup

__conda_lazy_init() {
    unset -f conda 2>/dev/null

    # Resolve conda paths (with fallback)
    local conda_bin="${HOME}/miniforge3/bin"
    [[ ! -d "$conda_bin" ]] && return 1

    # Try shell hook first, then profile.d, then just PATH
    local __conda_setup
    __conda_setup="$("$conda_bin/conda" 'shell.bash' 'hook' 2>/dev/null)"

    if [[ $? -eq 0 ]]; then
        eval "$__conda_setup"
    elif [[ -f "${HOME}/miniforge3/etc/profile.d/conda.sh" ]]; then
        . "${HOME}/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$conda_bin:$PATH"
    fi

    unset -f __conda_lazy_init 2>/dev/null
}

conda() {
    __conda_lazy_init
    conda "$@"
}

# Add conda bin to PATH for tools that need it before lazy-init
[[ -d "${HOME}/miniforge3/bin" ]] && export PATH="${HOME}/miniforge3/bin:$PATH"

# ==============================================================================
# Platform-Specific Enhancements (macOS)
# ==============================================================================
# IntelliShell is macOS-only; Starship (configured in .bashrc) is preferred
if [[ -d "$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell" ]]; then
    export INTELLI_HOME="$HOME/Library/Application Support/org.IntelliShell.Intelli-Shell"
    export PATH="$INTELLI_HOME/bin:$PATH"
    # eval "$(intelli-shell init bash)"  # Uncomment if IntelliShell is installed
fi

# ==============================================================================
# Source .bashrc (interactive settings)
# ==============================================================================
# Source .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Load local overrides
if [ -f "$HOME/.bash_profile.local" ]; then
    source "$HOME/.bash_profile.local"
fi