# ==============================================================================
# Terminal / Tab Title Functions
# ==============================================================================
# OSC 2 helpers for setting terminal tab/window titles.
# Works in Ghostty, WezTerm, iTerm2, and any VTE-compatible terminal.
#
# MANUAL_TAB_TITLE: when non-empty, suppresses the auto-title precmd/preexec
# hooks in .zshrc so the manual title persists across commands.

# Pin the current tab/window title via OSC 2. Persists until tab-title-reset.
# Usage: tab-title my-task
tab-title() {
    MANUAL_TAB_TITLE="${1}"
    print -Pn "\e]2;${1}\a"
}

# Clear the pinned title and restore automatic directory/command titles.
tab-title-reset() {
    MANUAL_TAB_TITLE=""
}
