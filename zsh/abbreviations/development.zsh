# ==============================================================================
# Development Abbreviations
# ==============================================================================

abbr -S serve='python3 -m http.server'
abbr -S ports='netstat -tulanp'

# Debug output - redirect stderr and stdout to file while displaying
abbr -gS '2>'='2>&1 | tee debug.log'

# AI Tools (--force needed to override /usr/bin/cc)
abbr -S --force --quiet cc='claude --dangerously-skip-permissions'
abbr -S --force ccc='claude --dangerously-skip-permissions -c'
abbr -S --force ccr='claude --dangerously-skip-permissions -r'
abbr -S lli='ll-issues'
abbr -S lll='ll-loop'
abbr -S lls='ll-sprint'
abbr -S lla='ll-auto'
abbr -S llp='ll-parallel'

# CLI Tools
abbr -S g='glow'
abbr -S npmrd='npm run dev'
abbr -S npmr='npm run dev'

# Terminal repair
abbr -S kkp='printf "\x1b[<u"'
