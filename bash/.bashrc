# ==============================================================================
# Bash Interactive Shell Configuration
# ==============================================================================

# Added by microsandbox installer
export PATH="$HOME/.local/bin:$PATH"

# macOS-only library path
# Note: DYLD_LIBRARY_PATH is stripped by SIP for system binaries in /usr/bin, /bin, etc.
# This only affects user-installed programs not protected by SIP
case "$(uname -s)" in
    Darwin*) [[ -d "$HOME/.local/lib" ]] && export DYLD_LIBRARY_PATH="$HOME/.local/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}" ;;
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
# Safety Aliases
# ==============================================================================
alias cp='cp -i'

# ==============================================================================
# Homebrew PATH (macOS)
# ==============================================================================
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ==============================================================================
# Bash Completion
# ==============================================================================
# Check Homebrew paths first on macOS, then fall back to Linux paths
if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
elif [[ -r /usr/local/etc/profile.d/bash_completion.sh ]]; then
    . /usr/local/etc/profile.d/bash_completion.sh
elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
fi

# ==============================================================================
# Starship Prompt
# ==============================================================================
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ==============================================================================
# Zoxide - Smarter cd Command
# ==============================================================================
# Modern replacement for z/autojump - tracks directory usage by frecency
# Usage: z <partial-path>  - jump to best match
#        zi <partial-path> - interactive selection with fzf
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
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
. "$HOME/.cargo/env"
