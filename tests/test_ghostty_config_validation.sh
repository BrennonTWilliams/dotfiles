#!/bin/bash

# ==============================================================================
# Ghostty Configuration Validation Tests
# ==============================================================================
# Tests the integrity and correctness of Ghostty terminal configuration
# Validates syntax, theme integration, and macOS-specific settings
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Configuration paths
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"
GHOSTTY_LOCAL_CONFIG="$GHOSTTY_CONFIG_DIR/config.local"
DOTFILES_GHOSTTY_CONFIG="$(dirname "$0")/../ghostty/.config/ghostty/config.local.template"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_TOTAL++))
    log_info "Running test: $test_name"

    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# ==============================================================================
# Test Functions
# ==============================================================================

test_ghostty_binary_exists() {
    command -v ghostty >/dev/null 2>&1
}

test_ghostty_config_exists() {
    [[ -f "$GHOSTTY_CONFIG_FILE" ]]
}

test_ghostty_config_is_symlink() {
    [[ -L "$GHOSTTY_CONFIG_FILE" ]]
}

test_ghostty_config_syntax_valid() {
    # Basic syntax validation - check for balanced quotes and brackets
    local config_content
    config_content=$(cat "$GHOSTTY_CONFIG_FILE")

    # Check for unmatched quotes
    local single_quotes=0
    local double_quotes=0

    while IFS= read -r line; do
        # Count quotes ignoring escaped ones
        single_quotes=$((single_quotes + $(grep -o "[^\\\\]'" <<< "$line" | wc -l)))
        double_quotes=$((double_quotes + $(grep -o '[^\\\\]"' <<< "$line" | wc -l)))
    done <<< "$config_content"

    # Both counts should be even (balanced quotes)
    ((single_quotes % 2 == 0 && double_quotes % 2 == 0))
}

test_shell_integration_correct() {
    grep -q "shell-integration = zsh" "$GHOSTTY_CONFIG_FILE"
}

test_macos_specific_settings() {
    local required_settings=(
        "macos-titlebar-style"
        "macos-option-as-alt"
        "macos-window-shadow"
        "macos-native-keyboard"
        "macos-quit-behavior"
        "macos-auto-update"
        "macos-color-scheme"
    )

    for setting in "${required_settings[@]}"; do
        if ! grep -q "^$setting" "$GHOSTTY_CONFIG_FILE"; then
            return 1
        fi
    done
    return 0
}

test_font_configuration() {
    local required_fonts=(
        "font-family"
        "font-size"
        "font-render-mode"
        "font-dpi-aware"
        "font-fallback"
    )

    for font_setting in "${required_fonts[@]}"; do
        if ! grep -q "^$font_setting" "$GHOSTTY_CONFIG_FILE"; then
            return 1
        fi
    done
    return 0
}

test_gruvbox_theme() {
    grep -q "theme = gruvbox-dark" "$GHOSTTY_CONFIG_FILE" && \
    grep -q "palette = " "$GHOSTTY_CONFIG_FILE"
}

test_keybinding_no_conflicts() {
    # Check that Ctrl+C and Ctrl+V are not bound (avoid shell conflicts)
    ! grep -q "keybind = ctrl\+c=" "$GHOSTTY_CONFIG_FILE" && \
    ! grep -q "keybind = ctrl\+v=" "$GHOSTTY_CONFIG_FILE" && \
    ! grep -q "keybind = ctrl\+k=" "$GHOSTTY_CONFIG_FILE"
}

test_performance_settings() {
    local required_settings=(
        "renderer = gpu"
        "gpu-acceleration = true"
        "gpu-acceleration-fallback = true"
        "vsync = true"
        "resize-delay = 0"
    )

    for setting in "${required_settings[@]}"; do
        if ! grep -q "^$setting" "$GHOSTTY_CONFIG_FILE"; then
            return 1
        fi
    done
    return 0
}

test_local_config_import_enabled() {
    grep -q "^import = ~/.config/ghostty/config.local" "$GHOSTTY_CONFIG_FILE"
}

test_clipboard_integration() {
    local required_settings=(
        "clipboard-read-allow = true"
        "clipboard-write-allow = true"
        "paste-bracketed = true"
    )

    for setting in "${required_settings[@]}"; do
        if ! grep -q "^$setting" "$GHOSTTY_CONFIG_FILE"; then
            return 1
        fi
    done
    return 0
}

test_tmux_integration() {
    # Check for tmux-related keybindings
    grep -q "tmux.*new.*-s" "$GHOSTTY_CONFIG_FILE" && \
    grep -q "tmux.*attach" "$GHOSTTY_CONFIG_FILE"
}

test_no_duplicate_settings() {
    # Check for common duplicate settings
    local duplicates
    duplicates=$(grep "^resize-delay" "$GHOSTTY_CONFIG_FILE" | wc -l)
    [[ $duplicates -eq 1 ]]
}

test_window_configuration() {
    local required_settings=(
        "window-decoration"
        "window-padding-x"
        "window-padding-y"
        "background-opacity"
        "background-blur"
    )

    for setting in "${required_settings[@]}"; do
        if ! grep -q "^$setting" "$GHOSTTY_CONFIG_FILE"; then
            return 1
        fi
    done
    return 0
}

test_completion_installed() {
    # Check standard zsh completion locations
    [[ -f "$HOME/.local/share/zsh/completions/_ghostty" ]] || \
    [[ -f "/opt/homebrew/share/zsh/site-functions/_ghostty" ]] || \
    [[ -f "/usr/local/share/zsh/site-functions/_ghostty" ]]
}

test_completion_valid() {
    # Check that completion file exists in any standard location
    local completion_file=""
    for path in "$HOME/.local/share/zsh/completions/_ghostty" \
                "/opt/homebrew/share/zsh/site-functions/_ghostty" \
                "/usr/local/share/zsh/site-functions/_ghostty"; do
        [[ -f "$path" ]] && completion_file="$path" && break
    done
    [[ -n "$completion_file" ]] && \
    [[ -s "$completion_file" ]] && \
    grep -q "#compdef" "$completion_file"
}

test_local_config_template_exists() {
    [[ -f "$DOTFILES_GHOSTTY_CONFIG.local.template" ]]
}

test_config_file_permissions() {
    # Config file should be readable by user
    [[ -r "$GHOSTTY_CONFIG_FILE" ]]
}

# ==============================================================================
# Main Test Execution
# ==============================================================================

main() {
    echo "=============================================================================="
    echo "Ghostty Configuration Validation Tests"
    echo "=============================================================================="
    echo ""

    # Run all tests
    run_test "Ghostty binary exists" "test_ghostty_binary_exists"
    run_test "Ghostty config exists" "test_ghostty_config_exists"
    run_test "Ghostty config is properly symlinked" "test_ghostty_config_is_symlink"
    run_test "Config syntax is valid" "test_ghostty_config_syntax_valid"
    run_test "Shell integration set to zsh" "test_shell_integration_correct"
    run_test "macOS-specific settings present" "test_macos_specific_settings"
    run_test "Font configuration complete" "test_font_configuration"
    run_test "Gruvbox theme configured" "test_gruvbox_theme"
    run_test "Keybinding conflicts resolved" "test_keybinding_no_conflicts"
    run_test "Performance settings configured" "test_performance_settings"
    run_test "Local config import enabled" "test_local_config_import_enabled"
    run_test "Clipboard integration configured" "test_clipboard_integration"
    run_test "Tmux integration configured" "test_tmux_integration"
    run_test "No duplicate settings" "test_no_duplicate_settings"
    run_test "Window configuration complete" "test_window_configuration"
    run_test "Shell completion installed" "test_completion_installed"
    run_test "Shell completion valid" "test_completion_valid"
    run_test "Local config template exists" "test_local_config_template_exists"
    run_test "Config file permissions correct" "test_config_file_permissions"

    # Print summary
    echo ""
    echo "=============================================================================="
    echo "Test Summary"
    echo "=============================================================================="
    echo -e "Total tests: ${BLUE}$TESTS_TOTAL${NC}"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        log_success "All tests passed! Ghostty configuration is properly set up."
        exit 0
    else
        echo ""
        log_error "Some tests failed. Please review the configuration."
        exit 1
    fi
}

# Check if help is requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Ghostty Configuration Validation Tests"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "This script validates the Ghostty terminal configuration for:"
    echo "  - Syntax correctness"
    echo "  - macOS integration"
    echo "  - Theme configuration"
    echo "  - Performance settings"
    echo "  - Shell integration"
    echo "  - Completion setup"
    echo ""
    exit 0
fi

# Run main function
main "$@"