#!/usr/bin/env bash

# ============================================================================
# Preview Mode Library for Dotfiles Installation
# ============================================================================
# Provides dry-run functionality to preview installation changes without
# making actual modifications to the system.
#
# Functions:
#   - preview_packages()      Preview package installations
#   - preview_dotfiles()      Preview symlink creation
#   - preview_conflicts()     Preview file conflicts and backups
#   - preview_shell_setup()   Preview shell/terminal configuration
#   - preview_summary()       Display summary of changes
# ============================================================================

# Ensure utils.sh is sourced
if [ -z "$RED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/utils.sh"
fi

# ============================================================================
# Global Variables
# ============================================================================

# Counters for summary
PREVIEW_PKG_INSTALL=0
PREVIEW_PKG_UPGRADE=0
PREVIEW_PKG_SKIP=0
PREVIEW_SYMLINKS=0
PREVIEW_CONFLICTS=0
PREVIEW_BACKUPS=0
PREVIEW_SHELL_CHANGES=0

# ============================================================================
# Output Formatting Functions
# ============================================================================

preview_header() {
    echo ""
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║${NC}  ${BOLD}INSTALLATION PREVIEW MODE${NC}                                    ${BOLD}${BLUE}║${NC}"
    echo -e "${BOLD}${BLUE}╟───────────────────────────────────────────────────────────────────╢${NC}"
    echo -e "${BOLD}${BLUE}║${NC}  No changes will be made to your system                        ${BOLD}${BLUE}║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

preview_section() {
    local title="$1"
    echo ""
    echo -e "${BOLD}${CYAN}▶ ${title}${NC}"
    echo -e "${CYAN}$(printf '─%.0s' {1..70})${NC}"
}

preview_action() {
    local action="$1"
    echo -e "  ${YELLOW}[WOULD]${NC} $action"
}

preview_package_install() {
    local pkg="$1"
    local version="$2"
    echo -e "  ${GREEN}⬡${NC} ${BOLD}$pkg${NC} ${CYAN}($version)${NC} - would install"
    ((PREVIEW_PKG_INSTALL++))
}

preview_package_upgrade() {
    local pkg="$1"
    local current="$2"
    local new="$3"
    echo -e "  ${YELLOW}⬆${NC} ${BOLD}$pkg${NC} ${CYAN}($current → $new)${NC} - would upgrade"
    ((PREVIEW_PKG_UPGRADE++))
}

preview_package_skip() {
    local pkg="$1"
    local version="$2"
    if [ "$VERBOSE" = true ]; then
        echo -e "  ${GREEN}✓${NC} ${BOLD}$pkg${NC} ${CYAN}($version)${NC} - already installed"
    fi
    ((PREVIEW_PKG_SKIP++))
}

preview_symlink() {
    local source="$1"
    local target="$2"
    if [ "$VERBOSE" = true ]; then
        echo -e "    ${CYAN}→${NC} $target ${CYAN}⇒${NC} $source"
    fi
    ((PREVIEW_SYMLINKS++))
}

preview_conflict() {
    local file="$1"
    echo -e "  ${YELLOW}⚠${NC} Conflict: ${BOLD}$file${NC} (would be backed up)"
    ((PREVIEW_CONFLICTS++))
    ((PREVIEW_BACKUPS++))
}

preview_shell_change() {
    local change="$1"
    echo -e "  ${BLUE}◆${NC} $change"
    ((PREVIEW_SHELL_CHANGES++))
}

# ============================================================================
# Package Preview Functions
# ============================================================================

preview_packages() {
    preview_section "Packages"

    local manifest=""

    # Determine manifest file based on OS
    case "$OS" in
        macos)
            manifest="$DOTFILES_DIR/packages-macos.txt"
            ;;
        debian|ubuntu)
            manifest="$DOTFILES_DIR/packages-linux.txt"
            ;;
        *)
            manifest="$DOTFILES_DIR/packages-linux.txt"
            ;;
    esac

    if [ ! -f "$manifest" ]; then
        warn "Package manifest not found: $manifest"
        return 1
    fi

    info "Analyzing packages from: $(basename "$manifest")"
    echo ""

    # Parse package manifest
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # Handle comma-separated packages
        IFS=',' read -ra PKGS <<< "$line"
        for pkg in "${PKGS[@]}"; do
            # Trim whitespace
            pkg=$(echo "$pkg" | xargs)
            [ -z "$pkg" ] && continue

            preview_package "$pkg"
        done
    done < "$manifest"

    # Summary for this section
    if [ "$VERBOSE" = false ]; then
        echo ""
        info "Total: $PREVIEW_PKG_INSTALL to install, $PREVIEW_PKG_UPGRADE to upgrade, $PREVIEW_PKG_SKIP already installed"
    fi
}

preview_package() {
    local pkg="$1"

    # Check if package is already installed
    if command_exists "$pkg"; then
        local installed_version=$(get_installed_version "$pkg")
        local available_version=$(get_package_version "$pkg")

        if [ -n "$available_version" ] && [ "$available_version" != "$installed_version" ]; then
            # Version available and different
            preview_package_upgrade "$pkg" "$installed_version" "$available_version"
        else
            # Already up to date
            preview_package_skip "$pkg" "$installed_version"
        fi
    else
        # Not installed
        local available_version=$(get_package_version "$pkg")
        if [ -n "$available_version" ]; then
            preview_package_install "$pkg" "$available_version"
        else
            preview_package_install "$pkg" "latest"
        fi
    fi
}

# ============================================================================
# Dotfiles Preview Functions
# ============================================================================

preview_dotfiles() {
    preview_section "Dotfiles & Symlinks"

    # Get available packages
    local packages=($(get_available_packages))

    if [ ${#packages[@]} -eq 0 ]; then
        warn "No stowable packages found"
        return 1
    fi

    info "Found ${#packages[@]} package(s) to stow"
    echo ""

    for package in "${packages[@]}"; do
        preview_stow_package "$package"
    done

    # Summary for this section
    if [ "$VERBOSE" = false ]; then
        echo ""
        info "Total: $PREVIEW_SYMLINKS symlink(s) would be created"
        if [ $PREVIEW_CONFLICTS -gt 0 ]; then
            warn "$PREVIEW_CONFLICTS conflict(s) detected - files would be backed up"
        fi
    fi
}

preview_stow_package() {
    local package="$1"

    echo -e "${BOLD}Package:${NC} $package"

    # Use stow dry-run to preview
    local stow_output
    stow_output=$(stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "$package" 2>&1)
    local stow_status=$?

    if [ $stow_status -eq 0 ]; then
        # Parse stow output for LINK actions
        local link_count=0
        while IFS= read -r line; do
            if [[ "$line" =~ LINK:\ (.+)\ =\>\ (.+) ]]; then
                local target="${BASH_REMATCH[1]}"
                local source="${BASH_REMATCH[2]}"
                preview_symlink "$source" "$target"
                ((link_count++))
            fi
        done <<< "$stow_output"

        if [ "$VERBOSE" = false ]; then
            echo -e "  ${CYAN}→${NC} Would create $link_count symlink(s)"
            PREVIEW_SYMLINKS=$((PREVIEW_SYMLINKS + link_count))
        fi
    else
        # Check for conflicts
        if echo "$stow_output" | grep -q "existing target is"; then
            echo -e "  ${YELLOW}⚠${NC} Conflicts detected:"

            while IFS= read -r line; do
                if [[ "$line" =~ existing\ target\ is.*:\ (.+) ]]; then
                    local conflict_file="${BASH_REMATCH[1]}"
                    preview_conflict "$conflict_file"
                fi
            done <<< "$stow_output"
        else
            warn "Stow encountered an error with $package"
            if [ "$VERBOSE" = true ]; then
                echo "$stow_output" | sed 's/^/    /'
            fi
        fi
    fi

    echo ""
}

# ============================================================================
# Shell Setup Preview Functions
# ============================================================================

preview_shell_setup() {
    preview_section "Shell & Terminal Configuration"

    local changes=0

    # Check current shell
    if [ "$SHELL" != "$(which zsh 2>/dev/null)" ]; then
        preview_shell_change "Change default shell to zsh"
        preview_action "chsh -s $(which zsh 2>/dev/null || echo '/bin/zsh')"
        ((changes++))
    else
        if [ "$VERBOSE" = true ]; then
            info "Default shell is already zsh"
        fi
    fi

    # Check Starship
    if ! command_exists starship; then
        preview_shell_change "Install Starship prompt"
        if [ "$OS" = "macos" ]; then
            preview_action "brew install starship"
        else
            preview_action "curl -sS https://starship.rs/install.sh | sh"
        fi
        ((changes++))
    else
        if [ "$VERBOSE" = true ]; then
            info "Starship is already installed ($(get_installed_version starship))"
        fi
    fi

    # Check tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        preview_shell_change "Install tmux plugin manager (TPM)"
        preview_action "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
        ((changes++))
    else
        if [ "$VERBOSE" = true ]; then
            info "Tmux plugin manager is already installed"
        fi
    fi

    PREVIEW_SHELL_CHANGES=$changes

    if [ $changes -eq 0 ]; then
        echo ""
        success "No shell configuration changes needed"
    fi
}

# ============================================================================
# Summary Functions
# ============================================================================

preview_summary() {
    preview_section "Summary"

    echo -e "${BOLD}Changes Overview:${NC}"
    echo ""

    # Packages
    echo -e "  ${CYAN}Packages:${NC}"
    [ $PREVIEW_PKG_INSTALL -gt 0 ] && echo -e "    ${GREEN}⬡${NC} $PREVIEW_PKG_INSTALL to install"
    [ $PREVIEW_PKG_UPGRADE -gt 0 ] && echo -e "    ${YELLOW}⬆${NC} $PREVIEW_PKG_UPGRADE to upgrade"
    [ $PREVIEW_PKG_SKIP -gt 0 ] && echo -e "    ${GREEN}✓${NC} $PREVIEW_PKG_SKIP already installed"

    # Dotfiles
    echo -e "  ${CYAN}Dotfiles:${NC}"
    echo -e "    ${CYAN}→${NC} $PREVIEW_SYMLINKS symlink(s) to create"
    [ $PREVIEW_CONFLICTS -gt 0 ] && echo -e "    ${YELLOW}⚠${NC} $PREVIEW_CONFLICTS conflict(s) requiring backup"

    # Shell
    echo -e "  ${CYAN}Shell Configuration:${NC}"
    if [ $PREVIEW_SHELL_CHANGES -gt 0 ]; then
        echo -e "    ${BLUE}◆${NC} $PREVIEW_SHELL_CHANGES change(s)"
    else
        echo -e "    ${GREEN}✓${NC} No changes needed"
    fi

    echo ""
    echo -e "${BOLD}Resource Estimates:${NC}"
    echo -e "  ${CYAN}Disk Space:${NC} ~$((PREVIEW_PKG_INSTALL * 50))MB for new packages"
    [ $PREVIEW_CONFLICTS -gt 0 ] && echo -e "  ${CYAN}Backups:${NC} $PREVIEW_BACKUPS file(s) to backup"

    echo ""
    echo -e "${BOLD}${GREEN}To proceed with installation:${NC}"
    echo -e "  ${CYAN}./install-new.sh --all${NC}"
    echo ""
}

# ============================================================================
# Conflict Detection Functions
# ============================================================================

preview_conflicts() {
    local package="$1"

    # Use stow dry-run to detect conflicts
    local conflicts=$(stow -n "$package" 2>&1 | grep "WARNING:")

    if [ -n "$conflicts" ]; then
        echo "$conflicts" | while IFS= read -r line; do
            if [[ "$line" =~ WARNING:.*:\ (.+) ]]; then
                local file="${BASH_REMATCH[1]}"
                preview_conflict "$HOME/$file"
            fi
        done
    fi
}
