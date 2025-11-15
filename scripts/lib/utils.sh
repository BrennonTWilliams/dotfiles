#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Installation Utilities
# ==============================================================================
# Common utility functions used across all installation scripts
# ==============================================================================

set -euo pipefail

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

# Detect operating system and Linux distribution with enhanced support
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Enhanced Linux distribution detection
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS="$ID"
            case "$ID" in
                ubuntu|debian|linuxmint|pop)
                    PKG_MANAGER="apt"
                    ;;
                fedora|rhel|centos|rocky|almalinux)
                    PKG_MANAGER="dnf"
                    # Older systems might use yum
                    if command -v yum >/dev/null 2>&1 && ! command -v dnf >/dev/null 2>&1; then
                        PKG_MANAGER="yum"
                    fi
                    ;;
                arch|manjaro|endeavouros|garuda)
                    PKG_MANAGER="pacman"
                    ;;
                opensuse-leap|opensuse-tumbleweed)
                    PKG_MANAGER="zypper"
                    ;;
                void|void-musl)
                    PKG_MANAGER="xbps"
                    ;;
                alpine)
                    PKG_MANAGER="apk"
                    ;;
                gentoo)
                    PKG_MANAGER="emerge"
                    ;;
                solus)
                    PKG_MANAGER="eopkg"
                    ;;
                clear-linux-os)
                    PKG_MANAGER="swupd"
                    ;;
                *)
                    # Fallback detection methods
                    if [ -f /etc/debian_version ]; then
                        OS="debian"
                        PKG_MANAGER="apt"
                    elif [ -f /etc/redhat-release ]; then
                        OS="redhat"
                        PKG_MANAGER="dnf"
                        if command -v yum >/dev/null 2>&1 && ! command -v dnf >/dev/null 2>&1; then
                            PKG_MANAGER="yum"
                        fi
                    elif [ -f /etc/arch-release ]; then
                        OS="arch"
                        PKG_MANAGER="pacman"
                    elif command -v apt >/dev/null 2>&1; then
                        OS="debian"
                        PKG_MANAGER="apt"
                    elif command -v dnf >/dev/null 2>&1; then
                        OS="redhat"
                        PKG_MANAGER="dnf"
                    elif command -v pacman >/dev/null 2>&1; then
                        OS="arch"
                        PKG_MANAGER="pacman"
                    else
                        OS="linux"
                        PKG_MANAGER="unknown"
                    fi
                    ;;
            esac
        else
            # Legacy detection methods for older systems
            if [ -f /etc/debian_version ]; then
                OS="debian"
                PKG_MANAGER="apt"
            elif [ -f /etc/redhat-release ]; then
                OS="redhat"
                PKG_MANAGER="dnf"
                if command -v yum >/dev/null 2>&1 && ! command -v dnf >/dev/null 2>&1; then
                    PKG_MANAGER="yum"
                fi
            elif [ -f /etc/arch-release ]; then
                OS="arch"
                PKG_MANAGER="pacman"
            else
                OS="linux"
                PKG_MANAGER="unknown"
            fi
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

# Get detailed system information for debugging
get_system_info() {
    detect_os
    echo "OS: $OS"
    echo "Package Manager: $PKG_MANAGER"
    echo "OSTYPE: $OSTYPE"

    if [[ "$OS" != "macos" ]]; then
        if command -v lsb_release >/dev/null 2>&1; then
            echo "Distribution: $(lsb_release -d -s)"
            echo "Release: $(lsb_release -r -s)"
            echo "Codename: $(lsb_release -c -s)"
        fi

        if [ -f /etc/os-release ]; then
            echo "Pretty Name: $PRETTY_NAME"
            echo "Version: $VERSION"
            echo "Version ID: $VERSION_ID"
        fi
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

# Check if package is available in zypper (openSUSE)
check_zypper_package_availability() {
    local pkg="$1"
    if zypper search -i "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in zypper repositories"
        return 1
    fi
}

# Check if package is available in xbps (Void Linux)
check_xbps_package_availability() {
    local pkg="$1"
    if xbps-query -R "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in xbps repositories"
        return 1
    fi
}

# Check if package is available in apk (Alpine Linux)
check_apk_package_availability() {
    local pkg="$1"
    if apk info "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in apk repositories"
        return 1
    fi
}

# Check if package is available in emerge (Gentoo)
check_emerge_package_availability() {
    local pkg="$1"
    if emerge --search "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in Gentoo repositories"
        return 1
    fi
}

# Check if package is available in eopkg (Solus)
check_eopkg_package_availability() {
    local pkg="$1"
    if eopkg info "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in Solus repositories"
        return 1
    fi
}

# Check if package is available in swupd (Clear Linux)
check_swupd_package_availability() {
    local pkg="$1"
    if swupd bundle-info "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in Clear Linux bundles"
        return 1
    fi
}

# Generic package availability check that works with detected package manager
check_package_availability() {
    local pkg="$1"
    local manager="${PKG_MANAGER:-unknown}"

    case "$manager" in
        apt)
            check_apt_package_availability "$pkg"
            ;;
        dnf|yum)
            check_dnf_package_availability "$pkg"
            ;;
        pacman)
            check_pacman_package_availability "$pkg"
            ;;
        zypper)
            check_zypper_package_availability "$pkg"
            ;;
        xbps)
            check_xbps_package_availability "$pkg"
            ;;
        apk)
            check_apk_package_availability "$pkg"
            ;;
        emerge)
            check_emerge_package_availability "$pkg"
            ;;
        eopkg)
            check_eopkg_package_availability "$pkg"
            ;;
        swupd)
            check_swupd_package_availability "$pkg"
            ;;
        brew)
            # Homebrew packages are typically available if brew search finds them
            if brew search "$pkg" | grep -q "^$pkg\$"; then
                return 0
            else
                warn "Package '$pkg' not found in Homebrew"
                return 1
            fi
            ;;
        *)
            warn "Unknown package manager: $manager. Cannot check availability of '$pkg'"
            return 1
            ;;
    esac
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
    local current_dir
    current_dir="$(pwd)" || return 1
    if stow -d "$current_dir" -t "$target_dir" "$package"; then
        success "Stowed $package"
    else
        error "Failed to stow $package"
    fi
}