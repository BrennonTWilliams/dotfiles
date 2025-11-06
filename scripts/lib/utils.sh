#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Installation Utilities
# ==============================================================================
# Common utility functions used across all installation scripts
# ==============================================================================

# Error handling and debugging
trap 'echo "Error occurred at line $LINENO. Command: $BASH_COMMAND"' ERR

# Enable debug mode if environment variable is set
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
    echo "Debug mode enabled"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==============================================================================
# Logging Functions
# ==============================================================================

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

section() {
    echo -e "\n${BLUE}${BOLD}===${NC} ${BOLD}$1${NC} ${BLUE}${BOLD}===${NC}\n"
}

success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

# ==============================================================================
# System Detection Functions
# ==============================================================================

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            OS="debian"
            PKG_MANAGER="apt"
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
            PKG_MANAGER="dnf"
        elif [ -f /etc/arch-release ]; then
            OS="arch"
            PKG_MANAGER="pacman"
        else
            OS="linux"
            PKG_MANAGER="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

# ==============================================================================
# File Management Functions
# ==============================================================================

# Backup file if it exists
backup_if_exists() {
    local file="$1"
    local backup_dir="$2"

    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$backup_dir"
        local backup_path="$backup_dir/$(basename "$file").backup"

        if [ -e "$backup_path" ]; then
            local counter=1
            while [ -e "$backup_path.$counter" ]; do
                ((counter++))
            done
            backup_path="$backup_path.$counter"
        fi

        cp -R "$file" "$backup_path"
        echo "Backed up: $file -> $backup_path"
        return 0
    fi
    return 1
}

# ==============================================================================
# Package Management Functions
# ==============================================================================

# Check if package is available in apt
check_apt_package_availability() {
    local pkg="$1"
    if apt-cache show "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in apt repositories"
        return 1
    fi
}

# Check if package is available in dnf
check_dnf_package_availability() {
    local pkg="$1"
    if dnf info "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in dnf repositories"
        return 1
    fi
}

# Check if package is available in pacman
check_pacman_package_availability() {
    local pkg="$1"
    if pacman -Si "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in pacman repositories"
        return 1
    fi
}

# ==============================================================================
# Validation Functions
# ==============================================================================

# Check prerequisites
check_prerequisites() {
    section "Checking Prerequisites"

    # Check for required commands
    local required_commands=("stow")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            error "Required command '$cmd' not found. Please install it first."
        fi
    done

    # Check if we're in the right directory
    if [ ! -d "zsh" ] || [ ! -d "tmux" ]; then
        error "Dotfiles directories not found. Please run this script from the dotfiles root directory."
    fi

    # Detect OS
    detect_os
    info "Detected OS: $OS"
    info "Package manager: $PKG_MANAGER"

    success "Prerequisites check passed"
}

# ==============================================================================
# Stow Management Functions
# ==============================================================================

# Stow a package with proper error handling
stow_package() {
    local package="$1"
    local target_dir="${2:-$HOME}"
    local backup_dir="$3"

    info "Stowing $package..."

    # Create backup directory if needed
    if [ -n "$backup_dir" ]; then
        export BACKUP_CREATED=true

        # Check for conflicting files and back them up
        find "$package" -type f -not -path '*/\.*' | while read -r file; do
            local target_file="$target_dir/${file#$package/}"
            backup_if_exists "$target_file" "$backup_dir"
        done
    fi

    # Stow the package
    if stow -d "$(pwd)" -t "$target_dir" "$package"; then
        success "Stowed $package"
    else
        error "Failed to stow $package"
    fi
}