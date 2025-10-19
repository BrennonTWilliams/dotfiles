# Custom Aliases
# Place your custom aliases here

# ============================================
# Directory Navigation
# ============================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ============================================
# File Operations
# ============================================
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'

# ============================================
# Git Shortcuts (complement to git plugin)
# ============================================
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ============================================
# System Shortcuts
# ============================================
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias h='history'
alias c='clear'

# ============================================
# Tmux Shortcuts
# ============================================
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# ============================================
# Utility Functions
# ============================================
# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick find
qfind() {
  find . -name "*$1*"
}

# Extract based on extension (complements extract plugin)
# The extract plugin should handle most cases, but this is a backup

# ============================================
# Development
# ============================================
alias serve='python3 -m http.server'
alias ports='netstat -tulanp'

# ============================================
# Safety Nets
# ============================================
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
