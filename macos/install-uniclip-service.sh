#!/usr/bin/env bash

# ==============================================================================
# Uniclip macOS Service Installation Script
# ==============================================================================
# This script installs Uniclip as a launchd service on macOS.
# It creates the necessary plist file and loads it into launchd.
#
# Usage: ./install-uniclip-service.sh
# ==============================================================================

set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib/utils.sh"
source "$SCRIPT_DIR/../scripts/lib/service-utils.sh"

# Validate platform and dependencies
require_platform "macos"
require_command "uniclip" "Please install it first with: brew install uniclip"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST_FILE="$DOTFILES_DIR/macos/com.uniclip.plist"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
SERVICE_NAME="com.uniclip"

info "Installing Uniclip launchd service..."

# Create LaunchAgents directory if it doesn't exist
ensure_directory "$LAUNCHD_DIR"

# Copy plist file to LaunchAgents directory
cp "$PLIST_FILE" "$LAUNCHD_DIR/"

# Set correct permissions
chmod 644 "$LAUNCHD_DIR/$SERVICE_NAME.plist"

# Unload existing service (if running)
if launchctl list | grep -q "$SERVICE_NAME"; then
    info "Unloading existing Uniclip service..."
    launchctl unload "$LAUNCHD_DIR/$SERVICE_NAME.plist" || true
fi

# Load the service
info "Loading Uniclip service..."
launchctl load "$LAUNCHD_DIR/$SERVICE_NAME.plist"

# Start the service
info "Starting Uniclip service..."
launchctl start "$SERVICE_NAME"

# Verify the service is running
sleep 2
if launchctl list | grep -q "$SERVICE_NAME"; then
    success "Uniclip service installed and started successfully!"
    info "Service status:"
    launchctl list | grep "$SERVICE_NAME"

    # Display log locations and management commands using shared functions
    display_log_info "launchd" "uniclip" ""
    display_service_commands "launchd" "$SERVICE_NAME" "$LAUNCHD_DIR"
else
    error "Failed to start Uniclip service. Check logs for details."
fi