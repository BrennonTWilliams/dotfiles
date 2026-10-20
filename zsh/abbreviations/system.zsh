# ==============================================================================
# System Abbreviations
# ==============================================================================

abbr -S h='history'
abbr -S c='clear; tmux clear-history 2>/dev/null'

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

# Starship mode switching. Regular abbreviations (session or user scope)
# only expand as a whole command word; `-S` = session scope, which keeps them
# out of zsh-abbr's cross-shell job queue and shared user-abbreviations file.
abbr -S sc='starship-compact'
abbr -S ss='starship-standard'
abbr -S sv='starship-verbose'
abbr -S st='starship-terminal'
abbr -S sm='starship-mode'
abbr -S sg='starship-gruvbox-rainbow'
abbr -S sgl='starship-gruvbox-light'

# Theme mode toggle (light/dark — Ghostty, tmux, Starship)
abbr -S tt='toggle-theme'

# System monitors toggle (tmux CPU/RAM, starship memory)
abbr -S tsm='toggle-sys-monitors'

# Tailscale VPN
abbr -S tsup='tailscale up'
abbr -S tsdown='tailscale down'
abbr -S tss='tailscale status'
