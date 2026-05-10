# ==============================================================================
# Terminal / Tab Title Functions
# ==============================================================================
# OSC 2 helpers for setting terminal tab/window titles.
# Works in Ghostty, WezTerm, iTerm2, and any VTE-compatible terminal.
#
# MANUAL_TAB_TITLE: when non-empty, suppresses the auto-title preexec/precmd
# hooks so a pinned title persists across commands.

# Pin the current tab/window title via OSC 2. Persists until tab-title-reset.
# Usage: tab-title my-task
tab-title() {
    MANUAL_TAB_TITLE="${1}"
    print -n "\e]2;${1}\a"
}

# Clear the pinned title and restore automatic directory/command titles.
tab-title-reset() {
    MANUAL_TAB_TITLE=""
}

# ==============================================================================
# Auto Tab Title (OSC 2, preexec/precmd hooks)
# ==============================================================================
# Sends a Nerd Font process icon + short cwd as the tab/window title via OSC 2.
# Process → glyph map lives in scripts/lib/process-icons.tsv (single source of
# truth; also read by scripts/process-icon for tmux's window-status-format).

typeset -gA _TAB_ICONS=()
_TAB_ICON_DEFAULT=''

# Load the map once at shell startup. Anonymous function keeps `tsv`/`name`/
# `glyph` out of the global namespace; ${(%):-%x} resolves to this file's path
# so we can find the repo root regardless of how zsh was invoked.
() {
    local tsv="${${(%):-%x}:A:h:h:h}/scripts/lib/process-icons.tsv"
    [[ -r $tsv ]] || return
    local name glyph
    while IFS=$'\t' read -r name glyph; do
        [[ -z $name || $name == \#* ]] && continue
        if [[ $name == _default ]]; then
            _TAB_ICON_DEFAULT=$glyph
        else
            _TAB_ICONS[$name]=$glyph
        fi
    done < $tsv
}

# Emits OSC 2 with icon + short cwd. No subshells — runs on every prompt.
# Shows last 2 path components; substitutes $HOME with ~.
_tab_title_emit() {
  local icon="${_TAB_ICONS[$1]:-$_TAB_ICON_DEFAULT}"
  local cwd="${PWD/#$HOME/~}"
  local -a parts=("${(@s:/:)cwd}")
  local short
  if (( $#parts <= 2 )); then
    short="$cwd"
  else
    short="${parts[-2]}/${parts[-1]}"
  fi
  print -n "\e]2;${icon} ${short}\a"
}

# Called before a command runs — icon derives from the executable name.
_tab_title_preexec() {
  [[ -n "$MANUAL_TAB_TITLE" ]] && return
  _tab_title_emit "${${1%% *}:t}"
}

# Called after a command completes — idle terminal icon + cwd.
_tab_title_precmd() {
  [[ -n "$MANUAL_TAB_TITLE" ]] && return
  _tab_title_emit ""
}
