#!/usr/bin/env bash

# ==============================================================================
# Package Installation Script
# ==============================================================================
# Handles installation of platform-specific packages for dotfiles setup
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Configuration
# ==============================================================================

# Platform-specific packages
declare -A PACKAGES=(
    ["debian"]="git curl wget vim build-essential stow zsh tmux"
    ["redhat"]="git curl wget vim make gcc stow zsh tmux"
    ["arch"]="git curl wget vim base-devel stow zsh tmux"
    ["macos"]="git curl wget vim stow zsh tmux"
    ["opensuse-leap"]="git curl wget vim make gcc stow zsh tmux"
    ["opensuse-tumbleweed"]="git curl wget vim make gcc stow zsh tmux"
    ["void"]="git curl wget vim base-devel stow zsh tmux"
    ["void-musl"]="git curl wget vim base-devel stow zsh tmux"
    ["alpine"]="git curl wget vim build-base stow zsh tmux"
    ["gentoo"]="git curl wget vim stow zsh tmux"
    ["solus"]="git curl wget vim make gcc stow zsh tmux"
    ["clear-linux-os"]="git curl wget vim stow zsh tmux"
)

# ==============================================================================
# macOS Package Management
# ==============================================================================

# Check if package is available via Homebrew
check_brew_package_availability() {
    local pkg="$1"
    if brew info "$pkg" &> /dev/null; then
        return 0
    else
        warn "Package '$pkg' not found in Homebrew"
        return 1
    fi
}

# Install required Homebrew taps
install_required_taps() {
    info "Checking required Homebrew taps..."

    local taps=(
        "homebrew/core"
        "homebrew/cask"
    )

    for tap in "${taps[@]}"; do
        if ! brew tap | grep -q "$tap"; then
            info "Adding tap: $tap"
            brew tap "$tap"
        fi
    done
}

# Install package using appropriate package manager
install_package() {
    local package="$1"

    case "$PKG_MANAGER" in
        "apt")
            if check_apt_package_availability "$package"; then
                info "Installing $package with apt..."
                sudo apt update && sudo apt install -y "$package"
            fi
            ;;
        "dnf")
            if check_dnf_package_availability "$package"; then
                info "Installing $package with dnf..."
                sudo dnf install -y "$package"
            fi
            ;;
        "pacman")
            if check_pacman_package_availability "$package"; then
                info "Installing $package with pacman..."
                sudo pacman -S --noconfirm "$package"
            fi
            ;;
        "brew")
            if check_brew_package_availability "$package"; then
                info "Installing $package with brew..."
                brew install "$package"
            fi
            ;;
        "zypper")
            if check_zypper_package_availability "$package"; then
                info "Installing $package with zypper..."
                sudo zypper install -y "$package"
            fi
            ;;
        "xbps")
            if check_xbps_package_availability "$package"; then
                info "Installing $package with xbps..."
                sudo xbps-install -y "$package"
            fi
            ;;
        "apk")
            if check_apk_package_availability "$package"; then
                info "Installing $package with apk..."
                sudo apk add --no-cache "$package"
            fi
            ;;
        "emerge")
            if check_emerge_package_availability "$package"; then
                info "Installing $package with emerge..."
                sudo emerge "$package"
            fi
            ;;
        "eopkg")
            if check_eopkg_package_availability "$package"; then
                info "Installing $package with eopkg..."
                sudo eopkg install -y "$package"
            fi
            ;;
        "swupd")
            if check_swupd_package_availability "$package"; then
                info "Installing $package with swupd..."
                sudo swupd bundle-add "$package"
            fi
            ;;
        *)
            warn "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# ==============================================================================
# Installation Functions
# ==============================================================================

# Get available packages for current platform
get_platform_packages() {
    local platform_packages="${PACKAGES[$OS]}"

    if [ -z "$platform_packages" ]; then
        warn "No packages defined for OS: $OS"
        return 1
    fi

    echo "$platform_packages"
}

# Install platform packages
install_platform_packages() {
    section "Installing Platform Packages"

    local packages
    packages=$(get_platform_packages)

    if [ $? -eq 0 ] && [ -n "$packages" ]; then
        info "Packages to install: $packages"

        # Special handling for macOS
        if [ "$OS" = "macos" ]; then
            install_required_taps
        fi

        # Install packages
        for package in $packages; do
            install_package "$package"
        done

        success "Platform packages installation completed"
    else
        warn "No packages to install for $OS"
    fi
}

# ==============================================================================
# Main Function
# ==============================================================================

main() {
    section "Package Installation"

    # Change to dotfiles directory
    cd "$DOTFILES_DIR" || exit 1

    # Check prerequisites
    check_prerequisites

    # Install packages
    install_platform_packages

    success "Package installation completed successfully"
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi