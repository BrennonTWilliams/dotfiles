# ==============================================================================
# Development Abbreviations
# ==============================================================================

abbr -S serve='python3 -m http.server'
abbr -S ports='netstat -tulanp'

# Debug output - redirect stderr and stdout to file while displaying
abbr -gS '2>'='2>&1 | tee debug.log'

# AI Tools (--force needed to override /usr/bin/cc)
abbr -S --force --quiet cc='claude --dangerously-skip-permissions'
