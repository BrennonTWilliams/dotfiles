#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Bootstrap Installation Script
# ==============================================================================
# This script installs dotfiles using GNU Stow for symlink management.
# It provides safe backups, platform detection, and selective installation.
#
# Usage:
#   ./install.sh                    # Interactive installation (packages + setup)
#   ./install.sh --all              # Install all packages + run all setup scripts
#   ./install.sh --all --no-setup   # Install all packages, skip setup scripts
#   ./install.sh zsh tmux           # Install only specified packages (interactive setup)
#
# Options:
#   --all         Install all packages without prompting
#   --no-setup    Skip running setup scripts (fonts, oh-my-zsh, nvm, tmux)
#   --setup-only  Only run setup scripts, skip package installation
# ==============================================================================

set -e

# ==============================================================================
# Configuration
# ==============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_CREATED=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==============================================================================
# Helper Functions
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

# Install package based on detected OS
install_package() {
    local package="$1"

    info "Installing $package..."

    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -qq && sudo apt-get install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        *)
            warn "Unknown package manager. Please install $package manually."
            return 1
            ;;
    esac
}

# Backup a file or directory if it exists and is not a symlink
backup_if_exists() {
    local target="$1"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        if [ "$BACKUP_CREATED" = false ]; then
            mkdir -p "$BACKUP_DIR"
            BACKUP_CREATED=true
            info "Created backup directory: $BACKUP_DIR"
        fi

        local filename=$(basename "$target")
        cp -r "$target" "$BACKUP_DIR/$filename"
        info "Backed up: $filename"
    fi
}

# ==============================================================================
# Installation Steps
# ==============================================================================

# Check prerequisites
check_prerequisites() {
    section "Checking Prerequisites"

    detect_os
    info "Detected OS: $OS (Package Manager: $PKG_MANAGER)"

    local missing=()

    # Check for required commands
    if ! command_exists git; then
        missing+=("git")
    fi

    if ! command_exists stow; then
        missing+=("stow")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing required packages: ${missing[*]}"

        if [ -t 0 ]; then
            # Interactive mode
            read -p "Install missing packages? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                for pkg in "${missing[@]}"; do
                    install_package "$pkg"
                done
            else
                error "Cannot proceed without required packages"
            fi
        else
            error "Cannot proceed without required packages: ${missing[*]}"
        fi
    else
        success "All prerequisites satisfied"
    fi
}

# Backup existing dotfiles
backup_existing() {
    section "Backing Up Existing Configuration"

    # Files to check and backup
    local files=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.bash_logout"
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.zshenv.local"
        "$HOME/.zshrc.local"
        "$HOME/.bashrc.local"
        "$HOME/.zprofile"
        "$HOME/.tmux.conf"
        "$HOME/.vimrc"
        "$HOME/.config/sway"
        "$HOME/.config/sway/config.local"
        "$HOME/.config/foot"
        "$HOME/.oh-my-zsh/custom/aliases.zsh"
    )

    local backed_up=0

    for file in "${files[@]}"; do
        if [ -e "$file" ] && [ ! -L "$file" ]; then
            backup_if_exists "$file"
            ((backed_up++))
        fi
    done

    if [ $backed_up -eq 0 ]; then
        info "No existing dotfiles to backup"
    else
        success "Backed up $backed_up items to $BACKUP_DIR"
    fi
}

# Get list of available packages
get_available_packages() {
    local packages=()

    for dir in "$DOTFILES_DIR"/*/; do
        if [ -d "$dir" ]; then
            local pkg=$(basename "$dir")
            # Exclude non-package directories
            if [ "$pkg" != "scripts" ] && [ "$pkg" != ".git" ]; then
                packages+=("$pkg")
            fi
        fi
    done

    echo "${packages[@]}"
}

# Install a single package using Stow
stow_package() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"

    if [ ! -d "$package_dir" ]; then
        warn "Package '$package' not found"
        return 1
    fi

    info "Installing $package..."

    # Change to dotfiles directory
    cd "$DOTFILES_DIR"

    # Use stow to create symlinks
    # -R = restow (remove and reinstall)
    # -v = verbose
    # -t = target directory (home)
    if stow -R -t "$HOME" "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
        success "Installed $package"
        return 0
    else
        error "Failed to install $package"
        return 1
    fi
}

# Install dotfiles
install_dotfiles() {
    section "Installing Dotfiles"

    local packages=()

    # Parse command line arguments
    if [ "$1" = "--all" ]; then
        # Install all packages
        packages=($(get_available_packages))
        info "Installing all packages: ${packages[*]}"
    elif [ $# -gt 0 ]; then
        # Install specific packages from arguments
        packages=("$@")
        info "Installing specified packages: ${packages[*]}"
    else
        # Interactive selection
        local available_packages=($(get_available_packages))

        echo -e "${CYAN}Available packages:${NC}"
        for pkg in "${available_packages[@]}"; do
            echo "  - $pkg"
        done
        echo

        for pkg in "${available_packages[@]}"; do
            read -p "Install $pkg? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                packages+=("$pkg")
            fi
        done
    fi

    # Install selected packages
    if [ ${#packages[@]} -eq 0 ]; then
        warn "No packages selected for installation"
        return
    fi

    local installed=0
    local failed=0

    for pkg in "${packages[@]}"; do
        if stow_package "$pkg"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    echo
    success "Installed $installed packages"
    [ $failed -gt 0 ] && warn "$failed packages failed to install"
}

# Create local configuration files
create_local_configs() {
    section "Creating Local Configuration Files"

    info "Creating machine-specific configuration files..."

    # Create local config files if they don't exist
    touch "$HOME/.zshenv.local"
    touch "$HOME/.zshrc.local"
    touch "$HOME/.bashrc.local"

    # Create Sway local config
    mkdir -p "$HOME/.config/sway"
    if [ ! -f "$HOME/.config/sway/config.local" ]; then
        cat > "$HOME/.config/sway/config.local" << 'EOF'
# Machine-specific Sway configuration
# This file is not tracked in version control
#
# Example configurations:
# output HDMI-A-1 scale 2.0
# output DP-1 resolution 1920x1080
EOF
        info "Created ~/.config/sway/config.local"
    fi

    success "Local configuration files ready"
    info "Edit these files for machine-specific settings:"
    echo "  - ~/.zshenv.local"
    echo "  - ~/.zshrc.local"
    echo "  - ~/.bashrc.local"
    echo "  - ~/.config/sway/config.local"
}

# Run setup scripts
run_setup_scripts() {
    section "Running Setup Scripts"

    local scripts_dir="$DOTFILES_DIR/scripts"
    local run_mode="$1"  # "all", "interactive", or "skip"

    # Available setup scripts
    local setup_scripts=(
        "setup-python.sh:Install pip and pipx (Python package managers)"
        "setup-ohmyzsh.sh:Install Oh My Zsh with plugins"
        "setup-nvm.sh:Install NVM (Node Version Manager)"
        "setup-fonts.sh:Install Nerd Fonts"
        "setup-tmux-plugins.sh:Install Tmux Plugin Manager"
    )

    local scripts_to_run=()

    case "$run_mode" in
        all)
            info "Running all setup scripts..."
            for script_info in "${setup_scripts[@]}"; do
                scripts_to_run+=("${script_info%%:*}")
            done
            ;;
        interactive)
            echo -e "${CYAN}Available setup scripts:${NC}"
            for script_info in "${setup_scripts[@]}"; do
                local script_name="${script_info%%:*}"
                local description="${script_info#*:}"
                echo "  - $description"
            done
            echo

            for script_info in "${setup_scripts[@]}"; do
                local script_name="${script_info%%:*}"
                local description="${script_info#*:}"
                read -p "Run $description? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    scripts_to_run+=("$script_name")
                fi
            done
            ;;
        skip)
            info "Skipping setup scripts"
            return 0
            ;;
        *)
            warn "Unknown run mode: $run_mode"
            return 1
            ;;
    esac

    # Run selected scripts
    if [ ${#scripts_to_run[@]} -eq 0 ]; then
        info "No setup scripts selected"
        return 0
    fi

    local successful=0
    local failed=0

    for script in "${scripts_to_run[@]}"; do
        local script_path="$scripts_dir/$script"

        if [ ! -f "$script_path" ]; then
            warn "Script not found: $script"
            ((failed++))
            continue
        fi

        if [ ! -x "$script_path" ]; then
            warn "Script not executable: $script"
            chmod +x "$script_path"
        fi

        info "Running $script..."
        echo

        if "$script_path"; then
            ((successful++))
            success "Completed $script"
        else
            ((failed++))
            warn "Failed to run $script"
        fi
        echo
    done

    echo
    success "Ran $successful setup scripts successfully"
    [ $failed -gt 0 ] && warn "$failed setup scripts failed"
}

# Show post-installation instructions
post_install() {
    section "Post-Installation"

    local setup_ran="$1"

    cat << 'EOF'

Configuration installed successfully!

Next Steps:

1. Review and edit local configuration files:
   - ~/.zshenv.local
   - ~/.zshrc.local
   - ~/.bashrc.local
   - ~/.config/sway/config.local

2. Reload your shell:
   - exec $SHELL
   or restart your terminal

EOF

    if [ "$setup_ran" != "true" ]; then
        cat << 'EOF'
3. Install additional dependencies (if not already done):
   - Run: ./scripts/setup-python.sh      (Install pip and pipx)
   - Run: ./scripts/setup-ohmyzsh.sh     (Install Oh My Zsh)
   - Run: ./scripts/setup-nvm.sh         (Install NVM)
   - Run: ./scripts/setup-fonts.sh       (Install Nerd Fonts)
   - Run: ./scripts/setup-tmux-plugins.sh (Install Tmux plugins)

   Or run: ./install.sh --setup-only

EOF
    else
        cat << 'EOF'
3. If using tmux, install plugins:
   - Open tmux and press: Prefix + I (Ctrl-a + Shift-i)

EOF
    fi

    if [ "$BACKUP_CREATED" = true ]; then
        echo -e "${CYAN}Backup Location:${NC}"
        echo "  Your old dotfiles are backed up at: $BACKUP_DIR"
        echo
    fi

    success "Installation complete!"
}

# ==============================================================================
# Main
# ==============================================================================

print_banner() {
    cat << 'EOF'
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/

Bootstrap Installation Script
EOF
    echo
}

main() {
    print_banner

    # Parse arguments
    local install_all=false
    local no_setup=false
    local setup_only=false
    local package_args=()

    for arg in "$@"; do
        case "$arg" in
            --all)
                install_all=true
                ;;
            --no-setup)
                no_setup=true
                ;;
            --setup-only)
                setup_only=true
                ;;
            *)
                package_args+=("$arg")
                ;;
        esac
    done

    # Determine setup mode
    local setup_mode="interactive"
    if [ "$no_setup" = true ]; then
        setup_mode="skip"
    elif [ "$install_all" = true ]; then
        setup_mode="all"
    fi

    # Run installation steps
    if [ "$setup_only" = false ]; then
        check_prerequisites
        backup_existing

        if [ "$install_all" = true ]; then
            install_dotfiles --all
        else
            install_dotfiles "${package_args[@]}"
        fi

        create_local_configs
    fi

    # Run setup scripts
    local setup_ran=false
    if [ "$setup_mode" != "skip" ]; then
        run_setup_scripts "$setup_mode"
        setup_ran=true
    fi

    # Show post-installation instructions (skip if setup-only)
    if [ "$setup_only" = false ]; then
        post_install "$setup_ran"
    else
        success "Setup scripts completed!"
    fi
}

# Run main function with all arguments
main "$@"
