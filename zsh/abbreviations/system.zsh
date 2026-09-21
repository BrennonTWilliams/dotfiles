# ==============================================================================
# System Abbreviations
# ==============================================================================

abbr -S h='history'
abbr -S c='clear'

# Neovim keybindings help
abbr -S nk='nvim-keys'

# Task Master
abbr -S tm='task-master'
abbr -S taskmaster='task-master'

# Eza tree view
abbr -S tre='eza -T'
# Directory tree views
abbr -S tredir='eza -T -D --git-ignore'

# ls
abbr -S lsa='ls -a'

# Mindfulness
abbr -S breath='zenta now --quick'
abbr -S breathe='zenta now'
abbr -S reflect='zenta reflect'

# Starship mode switching (whole-word only — no `-S` so these don't
# collide with `sc` in `escape`/`desc`, `ss` in netstat, etc.)
abbr sc='starship-compact'
abbr ss='starship-standard'
abbr sv='starship-verbose'
abbr st='starship-terminal'
abbr sm='starship-mode'
abbr sg='starship-gruvbox-rainbow'
abbr sgl='starship-gruvbox-light'

# Theme mode toggle (light/dark — Ghostty, tmux, Starship)
abbr -S tt='toggle-theme'

# System monitors toggle (tmux CPU/RAM, starship memory)
abbr -S tsm='toggle-sys-monitors'
