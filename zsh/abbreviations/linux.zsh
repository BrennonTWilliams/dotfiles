# ==============================================================================
# Linux-Specific Abbreviations
# ==============================================================================
# Only loaded on Linux systems

[[ "$OSTYPE" == "darwin"* ]] && return 0

# Package management (Debian/Ubuntu)
abbr -S update='sudo apt update && sudo apt upgrade -y'
abbr -S cleanup='sudo apt autoremove -y && sudo apt autoclean'
