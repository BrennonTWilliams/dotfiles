# ==============================================================================
# Navigation Functions
# ==============================================================================

# Create directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick find by name pattern
qfind() {
    find . -name "*$1*"
}
