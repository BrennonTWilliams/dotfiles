#!/usr/bin/env bash

# ==============================================================================
# ⚠️  DEPRECATED - Please use install-new.sh instead
# ==============================================================================
# This script has been superseded by install-new.sh which provides:
# - Modular installation system
# - Better platform detection
# - Interactive component selection
# - Smaller codebase (7.4 KB vs 31 KB)
#
# Run: ./install-new.sh
# ==============================================================================

# ==============================================================================
# Dotfiles Bootstrap Installation Script (LEGACY)
# ==============================================================================
# This script installs dotfiles using GNU Stow for symlink management.
# It provides safe backups, platform detection, and selective installation.
#
# Usage:
#   ./install.sh                    # Interactive installation (packages + setup)
#   ./install.sh --all              # Install all packages + run all setup scripts
#   ./install.sh --all --no-setup   # Install all packages, skip setup scripts
#   ./install.sh --packages         # Install platform-specific packages only
#   ./install.sh zsh tmux           # Install only specified packages (interactive setup)
#   ./install.sh --all --reference-mac  # Install all packages safe for Mac reference systems
#   ./install.sh --development      # Complete development environment setup (all packages + setup + dev tools)
#
# Options:
#   --all         Install all packages without prompting
#   --no-setup    Skip running setup scripts (fonts, oh-my-zsh, nvm, tmux)
#   --setup-only  Only run setup scripts, skip package installation
#   --packages    Install platform-specific system packages only
#   --reference-mac Skip packages that modify hotkeys (for Mac reference systems)
#   --development Complete development environment setup (combines --all --packages)
# ==============================================================================

set -euo pipefail

# Error handling and debugging
trap 'echo "Error occurred at line $LINENO. Command: $BASH_COMMAND"' ERR

# Enable debug mode if environment variable is set
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
    echo "Debug mode enabled"
fi

# ==============================================================================
# Configuration
# ==============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_CREATED=false
REFERENCE_MAC=false

# Source utility functions
source "$DOTFILES_DIR/scripts/lib/utils.sh"

# ==============================================================================
# Helper Functions
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

# Check if a Homebrew package exists before installation
check_brew_package_availability() {
    local package="$1"

    if [[ "$PKG_MANAGER" != "brew" ]]; then
        return 0  # Skip check for non-brew systems
    fi

    # Special handling for sketchybar - check if tap is already added
    if [[ "$package" == "sketchybar" ]]; then
        return 0  # We'll handle sketchybar specially
    fi

    # Check if package exists using brew search
    if brew search "$package" 2>/dev/null | grep -q "^$package$"; then
        return 0  # Package exists
    else
        return 1  # Package not found
    fi
}

# Install required taps for specific packages
install_required_taps() {
    local package="$1"

    if [[ "$PKG_MANAGER" != "brew" ]]; then
        return 0  # Only applies to Homebrew
    fi

    case "$package" in
        sketchybar)
            # Check if tap is already added
            if ! brew tap | grep -q "FelixKratz/formulae"; then
                info "Adding FelixKratz/formulae tap for sketchybar..."
                brew tap FelixKratz/formulae
            else
                info "FelixKratz/formulae tap already exists"
            fi
            ;;
    esac
}

# Install package based on detected OS
install_package() {
    local package="$1"

    # Skip Linux-only packages on macOS
    if [[ "$OS" == "macos" ]]; then
        case "$package" in
            sway|swaybg|swayidle|swaylock|waybar|foot|wmenu|mako-notifier|wlsunset)
                warn "Skipping Linux-only package: $package"
                return 0
                ;;
        esac
    fi

    # Special handling for sketchybar on macOS
    if [[ "$OS" == "macos" && "$package" == "sketchybar" ]]; then
        info "Installing sketchybar with special tap handling..."

        # Install required tap first
        if ! install_required_taps "$package"; then
            error "Failed to install required tap for $package"
            return 1
        fi

        # Now install sketchybar from the tap
        if brew install sketchybar; then
            success "Successfully installed sketchybar"
            return 0
        else
            error "Failed to install sketchybar"
            return 1
        fi
    fi

    # Check package availability for Homebrew
    if ! check_brew_package_availability "$package"; then
        warn "Package '$package' not found in Homebrew repository. Skipping..."
        return 1
    fi

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

# Enhanced cross-platform command validation
validate_platform_commands() {
    local missing=()
    local optional_missing=()

    # Core cross-platform commands
    local core_commands=(
        "git:Version control"
        "curl:HTTP client"
        "zsh:Shell (optional but recommended)"
        "tmux:Terminal multiplexer (optional but recommended)"
    )

    for cmd_info in "${core_commands[@]}"; do
        local cmd="${cmd_info%:*}"
        local description="${cmd_info#*:}"

        if ! command_exists "$cmd"; then
            if [[ "$description" == *"optional"* ]]; then
                optional_missing+=("$cmd ($description)")
            else
                missing+=("$cmd ($description)")
            fi
        fi
    done

    # Platform-specific commands
    if [[ "$OS" == "macos" ]]; then
        local macos_commands=(
            "pbcopy:macOS clipboard (paste)"
            "pbpaste:macOS clipboard (copy)"
        )

        for cmd_info in "${macos_commands[@]}"; do
            local cmd="${cmd_info%:*}"
            local description="${cmd_info#*:}"

            if ! command_exists "$cmd"; then
                optional_missing+=("$cmd ($description)")
            fi
        done

    elif [[ "$OS" == "linux" ]]; then
        local linux_commands=(
            "xclip:X11 clipboard (optional, for X11 environments)"
        )

        for cmd_info in "${linux_commands[@]}"; do
            local cmd="${cmd_info%:*}"
            local description="${cmd_info#*:}"

            if ! command_exists "$cmd"; then
                optional_missing+=("$cmd ($description)")
            fi
        done
    fi

    # Display results
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing required commands:"
        for cmd in "${missing[@]}"; do
            echo "  - $cmd"
        done
        return 1
    fi

    if [ ${#optional_missing[@]} -gt 0 ]; then
        info "Missing optional commands (installation will continue):"
        for cmd in "${optional_missing[@]}"; do
            echo "  - $cmd"
        done
    fi

    return 0
}

# Check prerequisites
check_prerequisites() {
    section "Checking Prerequisites"

    detect_os
    info "Detected OS: $OS (Package Manager: $PKG_MANAGER)"

    local missing=()

    # Check for required installation tools
    if ! command_exists stow; then
        missing+=("stow")
    fi

    # Enhanced cross-platform command validation
    if ! validate_platform_commands; then
        error "Cannot proceed without required commands"
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
        "$HOME/.profile"
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
        "$HOME/.config/ghostty"
        "$HOME/.oh-my-zsh/custom/aliases.zsh"
    )

    local backed_up=0

    for file in "${files[@]}"; do
        if [ -e "$file" ] && [ ! -L "$file" ]; then
            backup_if_exists "$file"
            backed_up=$((backed_up + 1))
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

# Get platform-specific package list
get_platform_packages() {
    local packages_file=""

    # Detect OS and choose appropriate package file
    detect_os
    case "$OS" in
        "macos")
            if [ "$REFERENCE_MAC" = true ]; then
                packages_file="$DOTFILES_DIR/packages-macos-reference.txt"
                info "Using reference Mac package list (hotkey-safe)"
            else
                packages_file="$DOTFILES_DIR/packages-macos.txt"
            fi
            ;;
        *)
            packages_file="$DOTFILES_DIR/packages-linux.txt"
            ;;
    esac

    if [ -f "$packages_file" ]; then
        # Return packages from the file, filtering out comments and empty lines
        # Extract only the package name (first word) from each non-comment line
        grep -v '^#' "$packages_file" | grep -v '^$' | grep -v '^[[:space:]]*$' | awk '{print $1}'
    else
        warn "No package file found for OS: $OS"
        return 1
    fi
}

# Linux package availability validation functions
check_apt_package_availability() {
    local package="$1"
    apt-cache show "$package" &>/dev/null
}

check_dnf_package_availability() {
    local package="$1"
    dnf info "$package" &>/dev/null
}

check_pacman_package_availability() {
    local package="$1"
    # Corrected pacman validation: try -Si first, then -Ss
    pacman -Si "$package" &>/dev/null || pacman -Ss "^${package}$" &>/dev/null
}

# Filter packages for Mac reference systems (exclude hotkey-affecting packages)
filter_reference_mac_packages() {
    local packages=("$@")
    local filtered_packages=()

    # Packages that modify hotkeys and should be excluded on Mac reference systems
    local hotkey_packages=(
        "rectangle"      # Window manager with system-wide hotkeys
        "sketchybar"     # Status bar that may register hotkeys
    )

    for package in "${packages[@]}"; do
        # Skip empty lines and comments
        if [ -z "$package" ] || [[ "$package" =~ ^# ]]; then
            continue
        fi

        # Check if package should be excluded for Mac reference systems
        local should_exclude=false
        for hotkey_pkg in "${hotkey_packages[@]}"; do
            if [[ "$package" == "$hotkey_pkg" ]]; then
                warn "Reference Mac mode: Skipping hotkey-affecting package: $package"
                should_exclude=true
                break
            fi
        done

        if [ "$should_exclude" = false ]; then
            filtered_packages+=("$package")
        fi
    done

    printf '%s\n' "${filtered_packages[@]}"
}

# Pre-validate packages and handle special requirements
pre_validate_packages() {
    local packages=("$@")
    local valid_packages=()
    local special_packages=()

    detect_os

    # Apply reference Mac filtering if enabled
    if [ "$REFERENCE_MAC" = true ] && [[ "$OS" == "macos" ]]; then
        info "Reference Mac mode: Filtering out hotkey-affecting packages..."
        packages=($(filter_reference_mac_packages "${packages[@]}"))
    fi

    for package in "${packages[@]}"; do
        # Skip empty lines and comments
        if [ -z "$package" ] || [[ "$package" =~ ^# ]]; then
            continue
        fi

        # Check for packages requiring special handling
        if [[ "$OS" == "macos" && "$package" == "sketchybar" ]]; then
            special_packages+=("$package")
            valid_packages+=("$package")
            continue
        fi

        # Skip Linux-only packages on macOS
        if [[ "$OS" == "macos" ]]; then
            case "$package" in
                sway|swaybg|swayidle|swaylock|waybar|foot|wmenu|mako-notifier|wlsunset)
                    warn "Skipping Linux-only package: $package"
                    continue
                    ;;
            esac
        fi

        # Enhanced package availability validation
        if [[ "$PKG_MANAGER" == "brew" ]]; then
            if check_brew_package_availability "$package"; then
                valid_packages+=("$package")
            else
                warn "Package '$package' not available in Homebrew, skipping..."
            fi
        elif [[ "$PKG_MANAGER" == "apt" ]]; then
            if check_apt_package_availability "$package"; then
                valid_packages+=("$package")
            else
                warn "Package '$package' not available in apt repositories, skipping..."
            fi
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            if check_dnf_package_availability "$package"; then
                valid_packages+=("$package")
            else
                warn "Package '$package' not available in dnf repositories, skipping..."
            fi
        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            if check_pacman_package_availability "$package"; then
                valid_packages+=("$package")
            else
                warn "Package '$package' not available in pacman repositories, skipping..."
            fi
        else
            # For other package managers, assume packages are valid
            valid_packages+=("$package")
        fi
    done

    # Echo results back to caller
    printf '%s\n' "${valid_packages[@]}"
}

# Install platform-specific packages from package files
install_platform_packages() {
    section "Installing Platform-Specific Packages"

    local packages=()
    while IFS= read -r package; do
        # Skip empty lines
        if [ -n "$package" ]; then
            packages+=("$package")
        fi
    done < <(get_platform_packages)

    if [ ${#packages[@]} -eq 0 ]; then
        warn "No packages found for platform: $OS"
        return 0
    fi

    info "Found ${#packages[@]} packages for $OS: ${packages[*]}"

    # Pre-validate packages and filter out invalid ones
    local valid_packages=()
    while IFS= read -r package; do
        if [ -n "$package" ]; then
            valid_packages+=("$package")
        fi
    done < <(pre_validate_packages "${packages[@]}")

    if [ ${#valid_packages[@]} -eq 0 ]; then
        warn "No valid packages found after validation"
        return 0
    fi

    info "Installing ${#valid_packages[@]} validated packages for $OS: ${valid_packages[*]}"

    local installed=0
    local failed=0

    for package in "${valid_packages[@]}"; do
        if install_package "$package"; then
            installed=$((installed + 1))
        else
            failed=$((failed + 1))
        fi
    done

    echo
    success "Platform package installation complete"
    info "Installed: $installed, Failed: $failed"
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
    cd "$DOTFILES_DIR" || return 1

    # First, try a dry run to detect conflicts
    local conflicts
    conflicts=$(stow -n -t "$HOME" "$package" 2>&1 | grep -i "conflict\|would cause conflicts" || true)

    if [ -n "$conflicts" ]; then
        warn "Conflicts detected for $package:"
        echo "$conflicts"

        # Try to adopt existing files (move them under stow's control)
        info "Attempting to adopt existing files..."
        local adopt_output
        if adopt_output=$(stow --adopt -t "$HOME" "$package" 2>&1); then
            if [ -n "$adopt_output" ]; then
                echo "$adopt_output" | grep -v "BUG in find_stowed_path" || true
            fi
            success "Installed $package (adopted existing files)"
            return 0
        else
            # If adoption fails, try with --override
            warn "Adoption failed, trying with --override..."
            local override_output
            if override_output=$(stow --override='.*' -t "$HOME" "$package" 2>&1); then
                if [ -n "$override_output" ]; then
                    echo "$override_output" | grep -v "BUG in find_stowed_path" || true
                fi
                success "Installed $package (overridden)"
                return 0
            else
                error "Failed to install $package due to unresolved conflicts"
                echo "Conflicts:"
                echo "$conflicts"
                return 1
            fi
        fi
    else
        # No conflicts, proceed with normal installation
        local stow_output
        if stow_output=$(stow -R -t "$HOME" "$package" 2>&1); then
            # Filter out known bug messages and show success
            if [ -n "$stow_output" ]; then
                echo "$stow_output" | grep -v "BUG in find_stowed_path" || true
            fi
            success "Installed $package"
            return 0
        else
            error "Failed to install $package"
            echo "Stow error:"
            echo "$stow_output"
            return 1
        fi
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
            installed=$((installed + 1))
        else
            failed=$((failed + 1))
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
            failed=$((failed + 1))
            continue
        fi

        if [ ! -x "$script_path" ]; then
            warn "Script not executable: $script"
            chmod +x "$script_path"
        fi

        info "Running $script..."
        echo

        if "$script_path"; then
            successful=$((successful + 1))
            success "Completed $script"
        else
            failed=$((failed + 1))
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
    # Get version from VERSION file if it exists
    local version="unknown"
    if [ -f "$DOTFILES_DIR/VERSION" ]; then
        version=$(cat "$DOTFILES_DIR/VERSION" | tr -d '[:space:]')
    fi

    cat << 'EOF'
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/

Bootstrap Installation Script
EOF
    echo -e "${CYAN}Version:${NC} $version"
    echo
}

main() {
    print_banner

    # ==============================================================================
    # DEPRECATION WARNING
    # ==============================================================================
    echo ""
    echo -e "${YELLOW}${BOLD}⚠️  DEPRECATION WARNING${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}This script (install.sh) is deprecated and will be removed in a future release.${NC}"
    echo -e "${YELLOW}Please use ${BOLD}install-new.sh${NC}${YELLOW} instead for new installations and updates.${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Continuing in 3 seconds...${NC}"
    sleep 3
    echo ""

    # Parse arguments
    local install_all=false
    local no_setup=false
    local setup_only=false
    local install_packages=false
    local reference_mac=false
    local development_mode=false
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
            --packages)
                install_packages=true
                ;;
            --reference-mac)
                reference_mac=true
                REFERENCE_MAC=true
                ;;
            --development)
                development_mode=true
                ;;
            *)
                package_args+=("$arg")
                ;;
        esac
    done

    # Development mode implies --all and --packages
    if [ "$development_mode" = true ]; then
        install_all=true
        install_packages=true
        info "Development mode: Installing all packages and system dependencies with full setup"
    fi

    # Determine setup mode
    local setup_mode="interactive"
    if [ "$no_setup" = true ]; then
        setup_mode="skip"
    elif [ "$install_all" = true ] || [ "$development_mode" = true ]; then
        setup_mode="all"
    fi

    # Check if this is packages-only mode early to skip unnecessary steps
    local packages_only_mode=false
    if [ "$install_packages" = true ] && [ "$setup_only" = false ] && [ "$install_all" = false ] && [ "$development_mode" = false ] && [ ${#package_args[@]} -eq 0 ]; then
        packages_only_mode=true
    fi

    # Run installation steps
    if [ "$setup_only" = false ]; then
        check_prerequisites

        # Only backup if not in packages-only mode
        if [ "$packages_only_mode" = false ]; then
            backup_existing
        fi

        # If only installing packages, handle that and exit
        if [ "$packages_only_mode" = true ]; then
            install_platform_packages
            success "Package installation complete!"
            exit 0
        fi

        # Install platform-specific packages if requested (as part of full installation)
        if [ "$install_packages" = true ]; then
            install_platform_packages
        fi

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
