# ==============================================================================
# glow Markdown Renderer Helpers
# ==============================================================================
# glow's -w/--width flag takes a fixed column count; there is no "auto" or
# percentage mode. When rendering to a TTY, bare `glow` already auto-detects
# terminal width, but when piping to a pager it falls back to a fixed 80.
# These wrappers compute a width from the live terminal size instead.

# Render Markdown wrapped to ~90% of the current terminal width, clamped to a
# readable range. Passes all args through to glow, so `gloww file.md`,
# `gloww -p file.md`, or piping via stdin all work.
# Usage: gloww README.md   |   some-cmd | gloww
gloww() {
    local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
    local w=$(( cols * 9 / 10 ))
    (( w > 120 )) && w=120
    (( w < 40 )) && w=40
    glow -w "$w" "$@"
}

# Render Markdown wrapped to the full terminal width and page it. Useful when
# glow's output would otherwise wrap at the default 80 columns through a pipe.
# Usage: glowp README.md
glowp() {
    local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
    glow -w "$cols" "$@" | less -r
}
