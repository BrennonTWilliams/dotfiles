# ==============================================================================
# glow Markdown Renderer Helpers
# ==============================================================================
# glow's -w/--width flag takes a fixed column count; there is no "auto" or
# percentage mode. When rendering to a TTY, bare `glow` already auto-detects
# terminal width, but when piped to a pager it falls back to a fixed 80.
# These wrappers compute a width from the live terminal size instead.

# True terminal column count via the TIOCGWINSZ ioctl (`stty size`), read from
# /dev/tty so it works even when the wrapper's stdin is a pipe. This matches how
# glow detects width internally. We deliberately avoid $COLUMNS and `tput cols`:
# both trust the shell's COLUMNS value, which can lag the real terminal (stale
# after a resize, or exported small by a parent/multiplexer) and would make glow
# render far narrower than the window. Falls back to COLUMNS then 80 with no tty.
_glow_term_cols() {
    local cols
    cols=${${(s: :)$(stty size </dev/tty 2>/dev/null)}[2]}
    [[ $cols == <1-> ]] || cols=$(tput cols 2>/dev/null)
    [[ $cols == <1-> ]] || cols=${COLUMNS:-80}
    print -r -- "$cols"
}

# Render Markdown wrapped to ~90% of the current terminal width (floored at 40
# so tiny panes stay legible). Passes all args through to glow, so `gloww file.md`,
# `gloww -p file.md`, or piping via stdin all work.
# Usage: gloww README.md   |   some-cmd | gloww
gloww() {
    local w=$(( $(_glow_term_cols) * 9 / 10 ))
    (( w < 40 )) && w=40
    glow -w "$w" "$@"
}

# Render Markdown wrapped to the full terminal width and page it. Useful when
# glow's output would otherwise wrap at the default 80 columns through a pipe.
# Usage: glowp README.md
glowp() {
    glow -w "$(_glow_term_cols)" "$@" | less -r
}
