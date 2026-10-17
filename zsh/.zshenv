# .zshenv - This file is sourced for all shells (interactive, non-interactive, login)
# Place all environment variables here to ensure they're available everywhere
#
# ==============================================================================
# PATH Configuration (Consolidated from .zprofile and .zshrc)
# ==============================================================================
# All PATH modifications are centralized in _dotfiles_setup_path so they can be
# re-applied from .zprofile: on macOS, /etc/zprofile runs path_helper AFTER this
# file and moves the system dirs ahead of Homebrew. Re-running this function
# puts our dirs back in front.

# Keep PATH/FPATH entries unique (first occurrence wins), so re-running the
# setup or nesting shells never piles up duplicates.
typeset -U path fpath

_dotfiles_setup_path() {
    # Homebrew - must be early as other tools may depend on it
    if [[ -x /opt/homebrew/bin/brew ]]; then
        # Apple Silicon: static equivalent of `brew shellenv` (saves a fork)
        export HOMEBREW_PREFIX=/opt/homebrew
        export HOMEBREW_CELLAR=/opt/homebrew/Cellar
        export HOMEBREW_REPOSITORY=/opt/homebrew
        path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
        fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
        [[ :${INFOPATH:-}: == *:/opt/homebrew/share/info:* ]] || \
            export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
    elif [[ -x /usr/local/bin/brew ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        # Linuxbrew
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif (( $+commands[brew] )); then
        eval "$(brew shellenv)"
    fi

    # Pyenv, JetBrains Toolbox, npm globals, kimi-code, user binaries.
    # Prepended in order, so the last existing entry ends up first
    # (~/.local/bin wins).
    export PYENV_ROOT="$HOME/.pyenv"
    local d
    for d in \
        "$PYENV_ROOT/bin" \
        "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" \
        "$HOME/.npm-global/bin" \
        "$HOME/.kimi-code/bin" \
        "$HOME/.local/bin"
    do
        [[ -d $d ]] && path=("$d" $path)
    done

    # Appended (lowest priority)
    [[ -d /Applications/Obsidian.app/Contents/MacOS ]] && path+=(/Applications/Obsidian.app/Contents/MacOS)
    [[ -d ${GOPATH:-$HOME/go}/bin ]] && path+=("${GOPATH:-$HOME/go}/bin")

    export PATH
}
_dotfiles_setup_path

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Machine-specific environment overrides (e.g. DOTFILES_ABBR_MODE)
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
