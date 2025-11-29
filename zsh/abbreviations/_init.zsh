# ==============================================================================
# zsh-abbr Abbreviations Loader
# ==============================================================================
# Toggle via DOTFILES_ABBR_MODE environment variable:
#   alias  - Traditional aliases only (default, backward compatible)
#   abbr   - Abbreviations only (requires zsh-abbr)
#   both   - Both systems active (for transition testing)
#
# Set in ~/.zshenv.local: export DOTFILES_ABBR_MODE="abbr"

: "${DOTFILES_ABBR_MODE:=alias}"

# Skip abbreviations if mode is "alias" only
[[ "$DOTFILES_ABBR_MODE" == "alias" ]] && return 0

# ==============================================================================
# Detect and Load zsh-abbr
# ==============================================================================

local abbr_path=""

# Check Homebrew paths (macOS Apple Silicon)
if [[ -f "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-abbr/zsh-abbr.zsh"
# Check Homebrew paths (macOS Intel)
elif [[ -f "/usr/local/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="/usr/local/share/zsh-abbr/zsh-abbr.zsh"
# Check Linuxbrew path
elif [[ -f "/home/linuxbrew/.linuxbrew/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="/home/linuxbrew/.linuxbrew/share/zsh-abbr/zsh-abbr.zsh"
# Check manual installation
elif [[ -f "${ZDOTDIR:-$HOME}/.zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="${ZDOTDIR:-$HOME}/.zsh-abbr/zsh-abbr.zsh"
fi

# Exit gracefully if zsh-abbr not found
if [[ -z "$abbr_path" ]]; then
    echo "[dotfiles] zsh-abbr not found. Install with: brew install olets/tap/zsh-abbr"
    echo "[dotfiles] Falling back to traditional aliases"
    return 0
fi

# Load zsh-abbr
source "$abbr_path"

# ==============================================================================
# Load Abbreviation Category Files
# ==============================================================================

local abbr_dir="${0:A:h}"

for file in "$abbr_dir"/*.zsh; do
    # Skip this init file
    [[ "${file:t}" == "_init.zsh" ]] && continue
    # Source category file
    [[ -f "$file" ]] && source "$file"
done

unset abbr_path abbr_dir
