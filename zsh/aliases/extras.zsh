# ==============================================================================
# Extra Aliases (Fallback for non-abbr mode)
# ==============================================================================
# These aliases are also defined as abbreviations in abbreviations/*.zsh
# In abbr mode, abbreviations take precedence (they expand on space/enter)
# In alias mode, these provide the same shortcuts without expansion

# Directory listing with tree
alias tre='eza -T'

# Clipboard sync
alias clipboard-sync='uniclip ${UNICLIP_SERVER:-localhost:53168}'

# Mindfulness
alias breath='zenta now --quick'
alias breathe='zenta now'
alias reflect='zenta reflect'

# Task Master
alias tm='task-master'
alias taskmaster='task-master'

# Neovim keybindings help
alias nk='nvim-keys'

# Tmux
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# Starship mode switching
alias sc='starship-compact'
alias ss='starship-standard'
alias sv='starship-verbose'
alias sm='starship-mode'
