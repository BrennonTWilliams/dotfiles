# ==============================================================================
# Git Abbreviations
# ==============================================================================
# These expand on Space/Enter to show the full command in history

# --force needed to override ghostscript (gs)
abbr -S --force --quiet gs='git status'
abbr -S ga='git add'
abbr -S gc='git commit'
abbr -S gcm='git commit -m "'
abbr -S gp='git push'
abbr -S gl='git log --oneline --graph --decorate'
abbr -S gd='git diff'
abbr -S gco='git checkout'
abbr -S gcb='git checkout -b'
abbr -S gcob='git checkout -b'
abbr -S gb='git branch'
abbr -S gcl='git clone'
abbr -S gpl='git pull'

# -- Analysis
abbr -S glchurn="git log --after=\"1 year ago\" --name-only --pretty=format: | grep -v '^$' | sort | uniq -c | sort -nr | head -20"
abbr -S glwho="git log --no-merges --pretty=format:%an | sort | uniq -c | sort -nr"
abbr -S glbugs="git log -i -E --grep='fix|bug|broken' --name-only --pretty=format: | grep -v '^$' | sort | uniq -c | sort -nr | head -20"
abbr -S glvel="git log --pretty=format:%ad --date=format:%Y-%m | sort | uniq -c"
abbr -S glfire="git log --after=\"1 year ago\" -i -E --grep='revert|hotfix|emergency|rollback' --oneline"
