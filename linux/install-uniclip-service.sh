#!/usr/bin/env bash

# ==============================================================================
# Uniclip Linux Service Installation Script
# ==============================================================================
# This script installs Uniclip as a systemd user service on Linux.
# It creates the necessary service file and enables it in systemd.
#
# Usage: ./install-uniclip-service.sh
# ==============================================================================

set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib/utils.sh"

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    error "This script is designed for Linux only"
fi

# Check if systemd is available
if ! command -v systemctl &> /dev/null; then
    error "systemd is not available. This script requires systemd."
fi

# Check if uniclip is installed
if ! command -v uniclip &> /dev/null; then
    error "Uniclip is not installed. Please install it first with your package manager."
    echo "  - Debian/Ubuntu: sudo apt install uniclip (if available) or build from source"
    echo "  - Fedora: sudo dnf install uniclip (if available) or build from source"
    echo "  - Arch: yay -S uniclip (AUR) or build from source"
    echo "  - Source: https://github.com/elves/uniclip"
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_FILE="$DOTFILES_DIR/linux/uniclip.service"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_NAME="uniclip.service"

info "Installing Uniclip systemd user service..."

# Create systemd user directory if it doesn't exist
mkdir -p "$SYSTEMD_USER_DIR"

# Determine uniclip binary path dynamically
UNICLIP_PATH=$(which uniclip)
info "Found uniclip at: $UNICLIP_PATH"

# Update the service file with the correct binary path
sed "s|ExecStart=/usr/bin/uniclip|ExecStart=$UNICLIP_PATH|g" "$SERVICE_FILE" > "$SYSTEMD_USER_DIR/$SERVICE_NAME"

# Set correct permissions
chmod 644 "$SYSTEMD_USER_DIR/$SERVICE_NAME"

# Create logs directory
mkdir -p "$HOME/.local/share/uniclip"

# Stop existing service (if running)
if systemctl --user is-enabled "$SERVICE_NAME" &>/dev/null; then
    info "Stopping existing Uniclip service..."
    systemctl --user stop "$SERVICE_NAME" || true
fi

# Disable existing service (if enabled)
if systemctl --user is-enabled "$SERVICE_NAME" &>/dev/null; then
    info "Disabling existing Uniclip service..."
    systemctl --user disable "$SERVICE_NAME" || true
fi

# Reload systemd daemon
info "Reloading systemd user daemon..."
systemctl --user daemon-reload

# Enable the service
info "Enabling Uniclip service..."
systemctl --user enable "$SERVICE_NAME"

# Start the service
info "Starting Uniclip service..."
systemctl --user start "$SERVICE_NAME"

# Verify the service is running
sleep 2
if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
    success "Uniclip service installed and started successfully!"
    info "Service status:"
    systemctl --user status "$SERVICE_NAME" --no-pager -l
    echo
    info "Uniclip logs are available at:"
    echo "  - System logs: journalctl --user -u $SERVICE_NAME"
    echo "  - Log files: $HOME/.local/share/uniclip/"
    echo
    info "To manage the service:"
    echo "  - Stop:   systemctl --user stop $SERVICE_NAME"
    echo "  - Start:  systemctl --user start $SERVICE_NAME"
    echo "  - Restart:systemctl --user restart $SERVICE_NAME"
    echo "  - Status: systemctl --user status $SERVICE_NAME"
    echo "  - Disable:systemctl --user disable $SERVICE_NAME"
    echo "  - Remove: rm $SYSTEMD_USER_DIR/$SERVICE_NAME && systemctl --user daemon-reload"
    echo
    warn "Note: Make sure your display server is running. Service includes:"
    echo "  - DISPLAY environment variable for X11"
    echo "  - WAYLAND_DISPLAY for Wayland"
else
    error "Failed to start Uniclip service. Check logs for details:"
    echo "  journalctl --user -u $SERVICE_NAME"
fi