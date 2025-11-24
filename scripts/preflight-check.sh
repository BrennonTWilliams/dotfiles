#!/usr/bin/env bash

# ==============================================================================
# Pre-flight Dependency Check
# ==============================================================================
# Validates system prerequisites before installation
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Dependency Definitions
# ==============================================================================

# Critical dependencies (installation will fail without these)
declare -a CRITICAL_DEPS=(
    "git:Git version control"
    "stow:GNU Stow symlink manager"
    "curl:cURL download tool"
)

# Optional dependencies (enhance experience but not required)
declare -a OPTIONAL_DEPS=(
    "delta:Delta diff viewer"
    "fzf:Fuzzy finder for interactive selection"
    "zsh:Z Shell"
)

# ==============================================================================
# Dependency Checking Functions
# ==============================================================================

# Check if command exists and get version
check_command() {
    local cmd="$1"
    local description="$2"

    if command -v "$cmd" &> /dev/null; then
        local version=$(get_installed_version "$cmd")
        echo "installed:$version"
        return 0
    else
        echo "missing:$description"
        return 1
    fi
}

# Check Homebrew installation
check_homebrew() {
    local brew_paths=(
        "/opt/homebrew/bin/brew"  # Apple Silicon
        "/usr/local/bin/brew"      # Intel
        "$(command -v brew 2>/dev/null || true)"
    )

    for brew_path in "${brew_paths[@]}"; do
        if [ -n "$brew_path" ] && [ -x "$brew_path" ]; then
            local version=$("$brew_path" --version 2>/dev/null | head -1 | awk '{print $2}')
            echo "installed:$version:$brew_path"
            return 0
        fi
    done

    echo "missing:Homebrew is required for package management on macOS"
    return 1
}

# Check disk space
check_disk_space() {
    local required_gb=2
    local available_gb

    if [ "$OS" = "macos" ]; then
        available_gb=$(df -g "$HOME" | tail -1 | awk '{print $4}')
    else
        available_gb=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
    fi

    if [ "$available_gb" -ge "$required_gb" ]; then
        echo "sufficient:${available_gb}GB available"
        return 0
    else
        echo "insufficient:${available_gb}GB available, need ${required_gb}GB"
        return 1
    fi
}

# Check internet connectivity
check_internet() {
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null 2>&1 || \
       ping -c 1 -W 2 github.com &> /dev/null 2>&1; then
        echo "active"
        return 0
    else
        echo "inactive"
        return 1
    fi
}

# ==============================================================================
# Installation Functions
# ==============================================================================

# Install Homebrew on macOS
install_homebrew() {
    section "Installing Homebrew"

    info "This may take 5-10 minutes. Please wait..."
    echo

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Add to PATH
        if [ -x "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        success "Homebrew installed successfully"
        return 0
    else
        error "Failed to install Homebrew"
        return 1
    fi
}

# Install a package using the system package manager
install_dependency() {
    local package="$1"
    local description="$2"

    info "Installing $package ($description)..."

    case "$PKG_MANAGER" in
        brew)
            if brew install "$package" 2>&1; then
                success "$package installed successfully"
                return 0
            fi
            ;;
        apt)
            if sudo apt update && sudo apt install -y "$package" 2>&1; then
                success "$package installed successfully"
                return 0
            fi
            ;;
        dnf|yum)
            if sudo "$PKG_MANAGER" install -y "$package" 2>&1; then
                success "$package installed successfully"
                return 0
            fi
            ;;
        pacman)
            if sudo pacman -S --noconfirm "$package" 2>&1; then
                success "$package installed successfully"
                return 0
            fi
            ;;
        *)
            warn "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    error "Failed to install $package"
    return 1
}

# ==============================================================================
# Main Pre-flight Check
# ==============================================================================

run_preflight_check() {
    local interactive="${1:-true}"  # If false, just report and exit

    section "PRE-FLIGHT DEPENDENCY CHECK"

    echo "Checking system prerequisites..."
    echo

    detect_os

    local -a critical_missing=()
    local -a optional_missing=()
    local pkg_mgr_missing=false

    # Check core dependencies
    echo "[Core Dependencies]"
    for dep_info in "${CRITICAL_DEPS[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        local result=$(check_command "$dep" "$desc")

        if [[ "$result" == installed:* ]]; then
            local version="${result#installed:}"
            echo "✓ $dep ($version) - installed"
        else
            echo "✗ $dep - NOT FOUND"
            critical_missing+=("$dep:$desc")
        fi
    done
    echo

    # Check package manager
    echo "[Package Manager]"
    if [ "$OS" = "macos" ]; then
        local brew_result=$(check_homebrew)
        if [[ "$brew_result" == installed:* ]]; then
            IFS=':' read -r status version path <<< "$brew_result"
            echo "✓ Homebrew ($version) - installed"
        else
            local reason="${brew_result#missing:}"
            echo "⚠ Homebrew - not installed (required for macOS)"
            echo "  Install with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            pkg_mgr_missing=true
        fi
    else
        echo "✓ $PKG_MANAGER - available"
    fi
    echo

    # Check optional dependencies
    echo "[Optional Tools]"
    for dep_info in "${OPTIONAL_DEPS[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        local result=$(check_command "$dep" "$desc")

        if [[ "$result" == installed:* ]]; then
            local version="${result#installed:}"
            echo "✓ $dep ($version) - installed"
        else
            echo "⬡ $dep - not found ($desc)"
            optional_missing+=("$dep:$desc")
        fi
    done
    echo

    # Check system requirements
    echo "[System Requirements]"

    local disk_result=$(check_disk_space)
    if [[ "$disk_result" == sufficient:* ]]; then
        echo "✓ Disk space: ${disk_result#sufficient:}"
    else
        echo "✗ Disk space: ${disk_result#insufficient:}"
    fi

    local net_result=$(check_internet)
    if [ "$net_result" = "active" ]; then
        echo "✓ Internet connection: active"
    else
        echo "⚠ Internet connection: not detected"
    fi

    echo "✓ Shell: $SHELL"
    echo

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Handle missing dependencies
    if [ ${#critical_missing[@]} -gt 0 ] || [ "$pkg_mgr_missing" = true ]; then
        warn "MISSING DEPENDENCIES DETECTED"
        echo
        echo "The following required dependencies are missing:"

        if [ "$pkg_mgr_missing" = true ]; then
            echo "  • homebrew (required for package management on macOS)"
        fi

        for dep_info in "${critical_missing[@]}"; do
            IFS=':' read -r dep desc <<< "$dep_info"
            echo "  • $dep ($desc)"
        done
        echo

        if [ "$interactive" = true ]; then
            prompt_install_dependencies
            return $?
        else
            return 1
        fi
    else
        success "All prerequisites satisfied"
        return 0
    fi
}

# Prompt user to install missing dependencies
prompt_install_dependencies() {
    echo "Would you like to install missing dependencies now?"
    echo
    echo "  1. Install all missing dependencies (recommended)"
    echo "  2. Install only critical dependencies"
    echo "  3. Show manual installation instructions"
    echo "  4. Continue anyway (not recommended - may fail)"
    echo "  5. Exit"
    echo

    read -p "Enter choice (1-5) [default: 1]: " choice
    choice=${choice:-1}

    case "$choice" in
        1)
            install_missing_dependencies "all"
            ;;
        2)
            install_missing_dependencies "critical"
            ;;
        3)
            show_manual_instructions
            return 1
            ;;
        4)
            warn "Continuing without all dependencies - installation may fail"
            return 0
            ;;
        5)
            info "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid choice"
            return 1
            ;;
    esac
}

# Install missing dependencies
install_missing_dependencies() {
    local scope="${1:-all}"  # all or critical

    section "INSTALLING DEPENDENCIES"

    local install_count=0
    local total_to_install=0

    # Count dependencies to install
    if [ "$pkg_mgr_missing" = true ]; then
        ((total_to_install++)) || true
    fi
    total_to_install=$((total_to_install + ${#critical_missing[@]}))

    if [ "$scope" = "all" ]; then
        total_to_install=$((total_to_install + ${#optional_missing[@]}))
    fi

    # Install package manager if missing
    if [ "$pkg_mgr_missing" = true ]; then
        ((install_count++)) || true
        echo "[$install_count/$total_to_install] Installing Homebrew..."
        if ! install_homebrew; then
            error "Failed to install Homebrew - cannot continue"
        fi
        # Re-detect after Homebrew installation
        detect_os
    fi

    # Install critical dependencies
    for dep_info in "${critical_missing[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        ((install_count++)) || true
        echo "[$install_count/$total_to_install] Installing $dep..."
        install_dependency "$dep" "$desc" || warn "Failed to install $dep"
    done

    # Install optional dependencies if requested
    if [ "$scope" = "all" ]; then
        for dep_info in "${optional_missing[@]}"; do
            IFS=':' read -r dep desc <<< "$dep_info"
            ((install_count++)) || true
            echo "[$install_count/$total_to_install] Installing $dep..."
            install_dependency "$dep" "$desc" || warn "Failed to install $dep (optional)"
        done
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    success "Dependencies installation completed"
    echo
    info "Re-running pre-flight check..."
    echo

    # Re-run check
    run_preflight_check_silent
}

# Silent check (just returns status)
run_preflight_check_silent() {
    local all_present=true

    for dep_info in "${CRITICAL_DEPS[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        if ! command -v "$dep" &> /dev/null; then
            all_present=false
            echo "✗ $dep - still missing"
        else
            local version=$(get_installed_version "$dep")
            echo "✓ $dep ($version) - installed"
        fi
    done

    if [ "$OS" = "macos" ]; then
        if ! command -v brew &> /dev/null; then
            all_present=false
            echo "✗ Homebrew - still missing"
        else
            local version=$(brew --version 2>/dev/null | head -1 | awk '{print $2}')
            echo "✓ Homebrew ($version) - installed"
        fi
    fi

    echo

    if [ "$all_present" = true ]; then
        success "All prerequisites satisfied. Proceeding with installation..."
        return 0
    else
        error "Some dependencies are still missing"
        return 1
    fi
}

# Show manual installation instructions
show_manual_instructions() {
    section "MANUAL INSTALLATION INSTRUCTIONS"

    echo "To install missing dependencies manually:"
    echo

    if [ "$pkg_mgr_missing" = true ]; then
        cat << 'EOF'
▸ Homebrew (Package Manager)
  Platform: macOS
  Command:
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  After installation, add to PATH:
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

EOF
    fi

    for dep_info in "${critical_missing[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        echo "▸ $dep ($desc)"
        echo "  Platform: $OS"
        echo "  Command: $PKG_MANAGER install $dep"
        echo
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "After installing dependencies, re-run this script:"
    echo "  ./install-new.sh --all"
    echo
    echo "Or check dependencies only:"
    echo "  ./install-new.sh --check-deps"
    echo
}

# ==============================================================================
# Main Entry Point
# ==============================================================================

main() {
    run_preflight_check "${1:-true}"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
