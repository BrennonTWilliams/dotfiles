# ==============================================================================
# Bash Interactive Shell Configuration
# ==============================================================================

# Added by microsandbox installer
export PATH="$HOME/.local/bin:$PATH"

# macOS-only library path
case "$(uname -s)" in
    Darwin*) export DYLD_LIBRARY_PATH="$HOME/.local/lib:$DYLD_LIBRARY_PATH" ;;
esac

# ==============================================================================
# History Settings
# ==============================================================================
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend 2>/dev/null

# ==============================================================================
# Shell Options
# ==============================================================================
shopt -s checkwinsize 2>/dev/null
shopt -s globstar 2>/dev/null

# ==============================================================================
# Bash Completion
# ==============================================================================
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
elif [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# ==============================================================================
# Starship Prompt
# ==============================================================================
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ==============================================================================
# Terminal Integrations
# ==============================================================================
# Kiro shell integration (with command check)
if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
    kiro_path="$(kiro --locate-shell-integration-path bash 2>/dev/null)"
    [[ -f "$kiro_path" ]] && . "$kiro_path"
    unset kiro_path
fi

# ==============================================================================
# Local Overrides
# ==============================================================================
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
