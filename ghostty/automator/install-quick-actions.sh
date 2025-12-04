#!/usr/bin/env bash
# ==============================================================================
# Ghostty Quick Actions Installer
# ==============================================================================
# Installs Automator Quick Actions for Finder integration with Ghostty
#
# Usage: ./install-quick-actions.sh [options]
# Options:
#   --uninstall    Remove Quick Actions instead of installing
#   --verify       Verify installation only
#   --help         Show this help message
# ==============================================================================

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="${HOME}/Library/Services"

# Functions
print_header() {
    echo -e "${BLUE}===================================================================${NC}"
    echo -e "${BLUE}  Ghostty Quick Actions Installer${NC}"
    echo -e "${BLUE}===================================================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is only for macOS"
        exit 1
    fi
    print_success "Running on macOS"
}

check_ghostty() {
    if ! command -v ghostty &> /dev/null && [[ ! -d "/Applications/Ghostty.app" ]]; then
        print_warning "Ghostty not found. Install it first:"
        echo "  brew install --cask ghostty"
        return 1
    fi
    print_success "Ghostty is installed"
    return 0
}

ensure_services_dir() {
    if [[ ! -d "${SERVICES_DIR}" ]]; then
        print_info "Creating Services directory..."
        mkdir -p "${SERVICES_DIR}"
    fi
    print_success "Services directory exists"
}

install_quick_actions() {
    print_info "Installing Quick Actions..."
    echo

    local installed=0
    local skipped=0

    # Find all workflow bundles
    while IFS= read -r -d '' workflow; do
        local workflow_name
        workflow_name="$(basename "${workflow}")"
        local target="${SERVICES_DIR}/${workflow_name}"

        if [[ -d "${target}" ]]; then
            print_warning "Already exists: ${workflow_name}"
            echo "  Overwriting..."
            rm -rf "${target}"
        fi

        print_info "Installing: ${workflow_name}"
        cp -R "${workflow}" "${target}"
        print_success "Installed: ${workflow_name}"
        ((installed++))
        echo
    done < <(find "${SCRIPT_DIR}" -maxdepth 1 -name "*.workflow" -type d -print0)

    if [[ ${installed} -eq 0 ]]; then
        print_error "No Quick Actions found to install"
        return 1
    fi

    print_success "Installed ${installed} Quick Action(s)"
    return 0
}

uninstall_quick_actions() {
    print_info "Uninstalling Quick Actions..."
    echo

    local removed=0

    # Find all workflow bundles in source directory
    while IFS= read -r -d '' workflow; do
        local workflow_name
        workflow_name="$(basename "${workflow}")"
        local target="${SERVICES_DIR}/${workflow_name}"

        if [[ -d "${target}" ]]; then
            print_info "Removing: ${workflow_name}"
            rm -rf "${target}"
            print_success "Removed: ${workflow_name}"
            ((removed++))
        else
            print_warning "Not found: ${workflow_name}"
        fi
        echo
    done < <(find "${SCRIPT_DIR}" -maxdepth 1 -name "*.workflow" -type d -print0)

    if [[ ${removed} -eq 0 ]]; then
        print_warning "No Quick Actions were installed"
        return 1
    fi

    print_success "Removed ${removed} Quick Action(s)"
    return 0
}

refresh_services() {
    print_info "Refreshing Services database..."

    # Flush services cache (pbs may not exist in newer macOS versions)
    local pbs_path="/System/Library/CoreServices/pbs"
    if [[ -x "$pbs_path" ]]; then
        if "$pbs_path" -flush 2>/dev/null; then
            print_success "Services cache flushed"
        else
            print_warning "Could not flush services cache (may require sudo)"
        fi
    else
        print_info "Services cache tool not available (normal on newer macOS)"
    fi

    # Restart Finder
    print_info "Restarting Finder..."
    killall Finder 2>/dev/null || true
    sleep 1
    print_success "Finder restarted"
}

verify_installation() {
    print_info "Verifying installation..."
    echo

    local verified=0
    local missing=0

    while IFS= read -r -d '' workflow; do
        local workflow_name
        workflow_name="$(basename "${workflow}")"
        local target="${SERVICES_DIR}/${workflow_name}"

        if [[ -d "${target}" ]]; then
            print_success "Found: ${workflow_name}"
            ((verified++))
        else
            print_error "Missing: ${workflow_name}"
            ((missing++))
        fi
    done < <(find "${SCRIPT_DIR}" -maxdepth 1 -name "*.workflow" -type d -print0)

    echo
    if [[ ${missing} -eq 0 ]]; then
        print_success "All Quick Actions are installed"
        return 0
    else
        print_error "${missing} Quick Action(s) not installed"
        return 1
    fi
}

print_usage() {
    print_info "To use the Quick Actions:"
    echo
    echo "  1. In Finder, right-click on a folder or inside a folder window"
    echo "  2. Navigate to Quick Actions submenu"
    echo "  3. Select 'Open Ghostty Here'"
    echo
    print_info "To assign a keyboard shortcut:"
    echo
    echo "  1. System Settings → Keyboard → Keyboard Shortcuts"
    echo "  2. Select 'Services' category"
    echo "  3. Find 'Open Ghostty Here' under 'Files and Folders'"
    echo "  4. Click and assign your preferred shortcut (e.g., ⌘⌥T)"
    echo
    print_info "Permissions required:"
    echo
    echo "  • System Settings → Privacy & Security → Automation"
    echo "    → Enable Finder to control Ghostty"
    echo "  • System Settings → Privacy & Security → Accessibility"
    echo "    → Add and enable Ghostty"
    echo
}

check_permissions() {
    print_info "Checking permissions..."
    echo

    local warnings=0

    # Check if Ghostty has accessibility permissions (indirect check)
    if ! osascript -e 'tell application "System Events" to get properties' &> /dev/null; then
        print_warning "Accessibility permissions may not be granted"
        echo "  Grant in: System Settings → Privacy & Security → Accessibility"
        ((warnings++))
    else
        print_success "Accessibility permissions appear to be granted"
    fi

    # Check Automator permissions
    if [[ ! -d "${SERVICES_DIR}" ]]; then
        print_warning "Services directory doesn't exist yet"
        ((warnings++))
    else
        print_success "Services directory exists"
    fi

    echo
    if [[ ${warnings} -gt 0 ]]; then
        print_warning "Some permissions may need to be configured"
        return 1
    else
        print_success "Permissions look good"
        return 0
    fi
}

show_help() {
    print_header
    cat << EOF
Install Automator Quick Actions for Ghostty Finder integration.

Usage:
    $(basename "$0") [OPTIONS]

Options:
    --uninstall     Remove Quick Actions instead of installing
    --verify        Verify installation without making changes
    --help          Show this help message

Examples:
    # Install Quick Actions
    $(basename "$0")

    # Verify installation
    $(basename "$0") --verify

    # Uninstall Quick Actions
    $(basename "$0") --uninstall

Description:
    This script installs Automator Quick Actions that enable opening Ghostty
    terminal windows directly from Finder. After installation, you can:
    - Right-click folders in Finder → Quick Actions → Open Ghostty Here
    - Assign keyboard shortcuts in System Settings
    - Add Quick Actions button to Finder toolbar

Requirements:
    - macOS 12+ (Monterey or later)
    - Ghostty terminal emulator installed
    - Permissions: Automation, Accessibility

For more information:
    See: docs/GHOSTTY_FINDER_INTEGRATION.md

EOF
}

main() {
    local mode="install"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --uninstall)
                mode="uninstall"
                shift
                ;;
            --verify)
                mode="verify"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    print_header

    # Pre-flight checks
    check_macos
    check_ghostty || print_warning "Ghostty not found, but continuing..."
    echo

    # Execute based on mode
    case ${mode} in
        install)
            ensure_services_dir
            echo
            if install_quick_actions; then
                echo
                refresh_services
                echo
                verify_installation
                echo
                check_permissions
                echo
                print_usage
                echo
                print_success "Installation complete!"
            else
                print_error "Installation failed"
                exit 1
            fi
            ;;
        uninstall)
            if uninstall_quick_actions; then
                echo
                refresh_services
                echo
                print_success "Uninstallation complete!"
            else
                print_error "Uninstallation failed"
                exit 1
            fi
            ;;
        verify)
            verify_installation
            echo
            check_permissions
            ;;
    esac

    echo
    print_success "Done!"
}

# Run main function
main "$@"
