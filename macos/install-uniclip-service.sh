#!/usr/bin/env bash

# ==============================================================================
# Uniclip macOS Service Installation Script
# ==============================================================================
# This script installs Uniclip as a launchd service on macOS.
# It creates the necessary plist file and loads it into launchd.
#
# Usage: ./install-uniclip-service.sh
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS only"
fi

# Check if uniclip is installed
if ! command -v uniclip &> /dev/null; then
    error "Uniclip is not installed. Please install it first with: brew install uniclip"
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST_FILE="$DOTFILES_DIR/macos/com.uniclip.plist"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
SERVICE_NAME="com.uniclip"

info "Installing Uniclip launchd service..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCHD_DIR"

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
    echo
    info "Uniclip logs are available at:"
    echo "  - Standard output: /tmp/uniclip.log"
    echo "  - Error output: /tmp/uniclip.error.log"
    echo
    info "To manage the service:"
    echo "  - Stop:  launchctl stop $SERVICE_NAME"
    echo "  - Start: launchctl start $SERVICE_NAME"
    echo "  - Restart: launchctl unload $LAUNCHD_DIR/$SERVICE_NAME.plist && launchctl load $LAUNCHD_DIR/$SERVICE_NAME.plist"
    echo "  - Remove: launchctl unload $LAUNCHD_DIR/$SERVICE_NAME.plist && rm $LAUNCHD_DIR/$SERVICE_NAME.plist"
else
    error "Failed to start Uniclip service. Check logs for details."
fi