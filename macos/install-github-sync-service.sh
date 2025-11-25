#!/usr/bin/env bash

# ==============================================================================
# GitHub Sync macOS Service Installation Script
# ==============================================================================
# This script installs the GitHub repos sync as a launchd service on macOS.
# It syncs your recent GitHub repos to Obsidian daily at 7am and on login.
#
# Usage: ./install-github-sync-service.sh
# ==============================================================================

set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib/utils.sh"
source "$SCRIPT_DIR/../scripts/lib/service-utils.sh"

# Validate platform and dependencies
require_platform "macos"
require_command "gh" "Please install it first with: brew install gh"

# Check gh authentication
if ! gh auth status &> /dev/null 2>&1; then
    error "gh CLI not authenticated. Please run: gh auth login"
fi

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST_FILE="$DOTFILES_DIR/macos/com.vault.github-sync.plist"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
SERVICE_NAME="com.vault.github-sync"
SYNC_SCRIPT="$HOME/AIProjects/MC-vault/_Vault/scripts/sync-github-repos.sh"

# Verify sync script exists
if [[ ! -x "$SYNC_SCRIPT" ]]; then
    error "Sync script not found or not executable: $SYNC_SCRIPT"
fi

info "Installing GitHub Sync launchd service..."

# Create LaunchAgents directory if it doesn't exist
ensure_directory "$LAUNCHD_DIR"

# Copy plist file to LaunchAgents directory
cp "$PLIST_FILE" "$LAUNCHD_DIR/"

# Set correct permissions
chmod 644 "$LAUNCHD_DIR/$SERVICE_NAME.plist"

# Unload existing service (if running)
if launchctl list | grep -q "$SERVICE_NAME"; then
    info "Unloading existing GitHub Sync service..."
    launchctl unload "$LAUNCHD_DIR/$SERVICE_NAME.plist" 2>/dev/null || true
fi

# Load the service
info "Loading GitHub Sync service..."
launchctl load "$LAUNCHD_DIR/$SERVICE_NAME.plist"

# Verify the service loaded
sleep 1
if launchctl list | grep -q "$SERVICE_NAME"; then
    success "GitHub Sync service installed successfully!"

    echo
    info "Service configuration:"
    echo "  - Runs daily at: 7:00 AM"
    echo "  - Runs on login: Yes"
    echo "  - Output file: ~/AIProjects/MC-vault/_Vault/_Data/github-repos.md"

    # Display log locations and management commands
    display_log_info "launchd" "github-sync" ""
    display_service_commands "launchd" "$SERVICE_NAME" "$LAUNCHD_DIR"

    echo
    info "To run sync immediately:"
    echo "  launchctl start $SERVICE_NAME"
    echo "  # or directly:"
    echo "  $SYNC_SCRIPT"
else
    error "Failed to load GitHub Sync service. Check logs for details."
    echo "  Logs: /tmp/github-sync.error.log"
fi
