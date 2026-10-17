# .zprofile - This file is sourced only for login shells
# Use this file for commands and settings that should run on login,
# but not every time a new shell is opened.
#
# The standard load order is: .zshenv → /etc/zprofile → .zprofile → .zshrc
# .zprofile is loaded only in login shells, not for every new terminal.
#
# NOTE: PATH modifications live in .zshenv (_dotfiles_setup_path)

# ==============================================================================
# Restore PATH order after path_helper
# ==============================================================================
# macOS /etc/zprofile runs path_helper, which moves /usr/bin, /bin, etc. ahead
# of Homebrew and our user dirs. Re-apply our PATH setup so they win again.
if [[ "$OSTYPE" == darwin* ]] && (( $+functions[_dotfiles_setup_path] )); then
    _dotfiles_setup_path
fi

# ==============================================================================
# BRENENTECH Logo Display
# ==============================================================================
# Logo display lives in .zshrc (runs for all interactive shells, not just login)

# Python Environment Setup
# Configure pyenv if installed (PATH already set in .zshenv).
# --no-rehash skips a ~75ms `pyenv rehash` on every login shell; run
# `pyenv rehash` yourself after installing a Python or a package with scripts.
if (( $+commands[pyenv] )); then
    eval "$(pyenv init - --no-rehash zsh)"
fi

# SSH Agent for Dev Containers / Linux sessions
# macOS provides SSH_AUTH_SOCK via launchd, so this only runs elsewhere.
# `ssh-add -l` exits 2 when it cannot reach an agent.
_dotfiles_agent_unreachable() {
    [[ -z "$SSH_AUTH_SOCK" ]] && return 0
    ssh-add -l >/dev/null 2>&1
    (( $? == 2 ))
}
if [[ "$OSTYPE" != darwin* ]] && (( $+commands[ssh-agent] )) && _dotfiles_agent_unreachable; then
    # Ensure .ssh directory exists
    if [[ ! -d "$HOME/.ssh" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    # Reuse the agent from a previous login if it is still alive
    [[ -f "$HOME/.ssh/ssh-agent" ]] && eval "$(<"$HOME/.ssh/ssh-agent")" >/dev/null

    if _dotfiles_agent_unreachable; then
        # Launch a new agent and remember how to reach it
        (umask 077; ssh-agent -s >| "$HOME/.ssh/ssh-agent")
        eval "$(<"$HOME/.ssh/ssh-agent")" >/dev/null
        # Load keys only when a terminal is attached (ssh-add may prompt for
        # a passphrase) and only if keys exist
        if [[ -t 0 ]] && ls "$HOME/.ssh"/id_* >/dev/null 2>&1; then
            ssh-add >/dev/null 2>&1
        fi
    fi
fi
unfunction _dotfiles_agent_unreachable 2>/dev/null

# Load local overrides
if [[ -f "$HOME/.zprofile.local" ]]; then
    source "$HOME/.zprofile.local"
fi
