# ==============================================================================
# Development Abbreviations
# ==============================================================================

abbr -S serve='python3 -m http.server'
abbr -S ports='netstat -tulanp'

# Debug output - redirect stderr and stdout to file while displaying
abbr -gS '2>'='2>&1 | tee debug.log'
abbr -S cpb='cat  | pbcopy'

# AI Tools (--force needed to override /usr/bin/cc)
abbr -S --force --quiet cc='claude --dangerously-skip-permissions'
abbr -S --force ccc='claude --dangerously-skip-permissions -c'
abbr -S --force ccr='claude --dangerously-skip-permissions -r'
abbr -S --force ccrf='claude --dangerously-skip-permissions -r --fork-session'
abbr -S lli='ll-issues'
abbr -S llil='ll-issues list'
abbr -S llile='ll-issues list --group-by epic'
abbr -S llis='ll-issues show'
abbr -S lll='ll-loop'
abbr -S llll='ll-loop list'
abbr -S lllr='ll-loop run'
abbr -S lllra='ll-loop run autodev'
abbr -S llls='ll-loop show'
abbr -S lls='ll-sprint'
abbr -S llsl='ll-sprint list'
abbr -S llss='ll-sprint show'
abbr -S lla='ll-auto'
abbr -S llao='ll-auto --only'
abbr -S llp='ll-parallel'
abbr -S glip='glow "$(ll-issues path )"'
abbr -S zlip='zed "$(ll-issues path )"'
abbr -S zclsj='zed .claude/settings.local.json'

# CLI Tools
abbr -S g='glow'
abbr -S npmrd='npm run dev'
abbr -S npmr='npm run dev'

# Terminal repair
abbr -S kkp='printf "\x1b[<u"'
abbr -S tsize='tput cols; tput lines'
abbr -S clearss="precmd_functions=(); PROMPT='%~ ❯ '; RPROMPT=''; PROMPT_EOL_MARK=''; clear"
abbr -S recent='ll-issues list --status done --sort completed --desc --limit 10'
