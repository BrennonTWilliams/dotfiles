#!/usr/bin/env bash

# ==============================================================================
# Service Management Utilities
# ==============================================================================
# Shared utility functions for platform-specific service installation scripts
# Used by both Linux (systemd) and macOS (launchd) service installers
# ==============================================================================

# Source base utilities if not already sourced
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "${GREEN:-}" ]]; then
    source "$SCRIPT_DIR/utils.sh"
fi

# ==============================================================================
# Validation Functions
# ==============================================================================

# Require a command to be available
# Usage: require_command "uniclip" "Please install it first with: brew install uniclip"
require_command() {
    local cmd="$1"
    local install_hint="${2:-Please install $cmd first.}"

    if ! command -v "$cmd" &> /dev/null; then
        error "$cmd is not installed. $install_hint"
    fi
}

# Require running on a specific platform
# Usage: require_platform "linux" or require_platform "macos"
require_platform() {
    local required_platform="$1"

    case "$required_platform" in
        "linux")
            if [[ "$OSTYPE" != "linux-gnu"* ]]; then
                error "This script is designed for Linux only"
            fi
            ;;
        "macos")
            if [[ "$OSTYPE" != "darwin"* ]]; then
                error "This script is designed for macOS only"
            fi
            ;;
        *)
            error "Unknown platform: $required_platform"
            ;;
    esac
}

# Require systemd to be available (Linux only)
require_systemd() {
    if ! command -v systemctl &> /dev/null; then
        error "systemd is not available. This script requires systemd."
    fi
}

# ==============================================================================
# Directory Management Functions
# ==============================================================================

# Create directory if it doesn't exist
# Usage: ensure_directory "$HOME/.config/systemd/user"
ensure_directory() {
    local dir_path="$1"

    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
        info "Created directory: $dir_path"
    fi
}

# ==============================================================================
# File Management Functions
# ==============================================================================

# Set file permissions
# Usage: set_permissions "644" "/path/to/file"
set_permissions() {
    local perms="$1"
    local file_path="$2"

    chmod "$perms" "$file_path"
}

# ==============================================================================
# Service Status Display Functions
# ==============================================================================

# Display management commands for a service
# Usage: display_service_commands "systemd" "uniclip.service" "$SYSTEMD_USER_DIR"
display_service_commands() {
    local service_type="$1"
    local service_name="$2"
    local service_dir="$3"

    echo
    info "To manage the service:"

    case "$service_type" in
        "systemd")
            echo "  - Stop:    systemctl --user stop $service_name"
            echo "  - Start:   systemctl --user start $service_name"
            echo "  - Restart: systemctl --user restart $service_name"
            echo "  - Status:  systemctl --user status $service_name"
            echo "  - Disable: systemctl --user disable $service_name"
            echo "  - Remove:  rm $service_dir/$service_name && systemctl --user daemon-reload"
            ;;
        "launchd")
            echo "  - Stop:    launchctl stop $service_name"
            echo "  - Start:   launchctl start $service_name"
            echo "  - Restart: launchctl unload $service_dir/$service_name.plist && launchctl load $service_dir/$service_name.plist"
            echo "  - Remove:  launchctl unload $service_dir/$service_name.plist && rm $service_dir/$service_name.plist"
            ;;
    esac
}

# Display log locations
# Usage: display_log_info "systemd" "uniclip.service" "/path/to/logs"
display_log_info() {
    local service_type="$1"
    local service_name="$2"
    local log_dir="$3"

    echo
    info "Log locations:"

    case "$service_type" in
        "systemd")
            echo "  - System logs: journalctl --user -u $service_name"
            if [[ -n "$log_dir" ]]; then
                echo "  - Log files: $log_dir"
            fi
            ;;
        "launchd")
            echo "  - Standard output: /tmp/${service_name}.log"
            echo "  - Error output: /tmp/${service_name}.error.log"
            ;;
    esac
}

# ==============================================================================
# Path Resolution Functions
# ==============================================================================

# Get the dotfiles directory from a script location
# Usage: DOTFILES_DIR=$(get_dotfiles_dir)
get_dotfiles_dir() {
    local script_path="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
    cd "$(dirname "$script_path")/.." && pwd
}

# Find binary path for a command
# Usage: BINARY_PATH=$(get_binary_path "uniclip")
get_binary_path() {
    local cmd="$1"
    which "$cmd"
}
