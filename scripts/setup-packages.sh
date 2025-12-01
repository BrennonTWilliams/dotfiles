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

# Platform-specific packages (defined in function to support bash 3.2+)

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
    # Note: homebrew/core and homebrew/cask are now installed by default
    # No longer need to explicitly tap them in modern Homebrew
    info "Homebrew taps are automatically configured"
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
    # Ensure OS is set
    if [ -z "${OS:-}" ]; then
        error "OS variable not set. Run detect_os first."
    fi

    # Return packages based on OS (using case for bash 3.2 compatibility)
    local platform_packages=""
    case "$OS" in
        debian|ubuntu|linuxmint|pop)
            platform_packages="git curl wget vim build-essential stow zsh tmux"
            ;;
        redhat|fedora|rhel|centos|rocky|almalinux)
            platform_packages="git curl wget vim make gcc stow zsh tmux"
            ;;
        arch|manjaro|endeavouros|garuda)
            platform_packages="git curl wget vim base-devel stow zsh tmux"
            ;;
        macos)
            platform_packages="git curl wget vim stow zsh tmux bash"
            ;;
        opensuse-leap|opensuse-tumbleweed)
            platform_packages="git curl wget vim make gcc stow zsh tmux"
            ;;
        void|void-musl)
            platform_packages="git curl wget vim base-devel stow zsh tmux"
            ;;
        alpine)
            platform_packages="git curl wget vim build-base stow zsh tmux"
            ;;
        gentoo)
            platform_packages="git curl wget vim stow zsh tmux"
            ;;
        solus)
            platform_packages="git curl wget vim make gcc stow zsh tmux"
            ;;
        clear-linux-os)
            platform_packages="git curl wget vim stow zsh tmux"
            ;;
        *)
            warn "No packages defined for OS: $OS"
            return 1
            ;;
    esac

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