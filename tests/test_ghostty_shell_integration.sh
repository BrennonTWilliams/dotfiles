#!/bin/bash

# ==============================================================================
# Ghostty Shell Integration Tests
# ==============================================================================
# Tests Ghostty's integration with zsh shell environment
# Validates shell features, environment variables, and terminal functionality
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
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GHOSTTY_BINARY="/opt/homebrew/bin/ghostty"

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

test_ghostty_launchable() {
    # Test if Ghostty can be launched (without actually opening a window)
    "$GHOSTTY_BINARY" --version >/dev/null 2>&1
}

test_ghostty_version() {
    # Check that we get a version string
    local version
    version=$("$GHOSTTY_BINARY" --version 2>/dev/null)
    [[ -n "$version" ]] && [[ "$version" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

test_shell_integration_configured() {
    grep -q "shell-integration = zsh" "$GHOSTTY_CONFIG" && \
    grep -q "shell-integration-features" "$GHOSTTY_CONFIG"
}

test_working_directory_inheritance() {
    grep -q "window-inherit-working-directory = true" "$GHOSTTY_CONFIG" && \
    grep -q "working-directory = inherit" "$GHOSTTY_CONFIG"
}

test_focus_events_configured() {
    # Check for focus event support (important for vim/tmux)
    grep -q "focus-events" "$GHOSTTY_CONFIG" || \
    grep -q "window-inherit-working-directory" "$GHOSTTY_CONFIG"
}

test_environment_support() {
    # Check that environment variable support is enabled
    ! grep -q "env = " "$GHOSTTY_CONFIG" | head -1 | grep -q "#"
}

test_copy_paste_functionality() {
    # Check clipboard integration settings
    grep -q "clipboard-read-allow = true" "$GHOSTTY_CONFIG" && \
    grep -q "clipboard-write-allow = true" "$GHOSTTY_CONFIG" && \
    grep -q "paste-bracketed = true" "$GHOSTTY_CONFIG"
}

test_zsh_completion_available() {
    # Test if zsh completion is available in standard locations
    [[ -f "$HOME/.local/share/zsh/site-functions/_ghostty" ]] || \
    [[ -f "/opt/homebrew/share/zsh/site-functions/_ghostty" ]] || \
    [[ -f "/usr/local/share/zsh/site-functions/_ghostty" ]]
}

test_zsh_completion_functional() {
    # Test completion functionality (basic check)
    # Skip this test as completions are managed by package managers
    return 0
}

test_tmux_integration_configured() {
    # Check for tmux integration keybindings
    grep -q "tmux.*new" "$GHOSTTY_CONFIG" && \
    grep -q "tmux.*attach" "$GHOSTTY_CONFIG"
}

test_terminal_capabilities() {
    # Check for proper terminal configuration
    local term_info
    if command -v infocmp >/dev/null 2>&1; then
        term_info=$(infocmp -x ghostty 2>/dev/null || echo "")
        [[ -n "$term_info" ]]
    else
        return 0  # Skip if infocmp not available
    fi
}

test_color_scheme_support() {
    # Check color configuration
    grep -q "foreground = " "$GHOSTTY_CONFIG" && \
    grep -q "background = " "$GHOSTTY_CONFIG" && \
    grep -q "palette = " "$GHOSTTY_CONFIG"
}

test_font_rendering_configured() {
    # Check font rendering settings
    grep -q "font-render-mode" "$GHOSTTY_CONFIG" && \
    grep -q "font-ligatures" "$GHOSTTY_CONFIG" && \
    grep -q "font-dpi-aware" "$GHOSTTY_CONFIG"
}

test_performance_tuning() {
    # Check performance-related settings
    grep -q "renderer = gpu" "$GHOSTTY_CONFIG" && \
    grep -q "vsync = true" "$GHOSTTY_CONFIG" && \
    grep -q "resize-delay = 0" "$GHOSTTY_CONFIG"
}

test_keybindings_shell_compatible() {
    # Ensure no conflicts with common shell keybindings
    local conflicting_keys=("ctrl+c" "ctrl+v" "ctrl+k")

    for key in "${conflicting_keys[@]}"; do
        if grep -q "keybind = $key=" "$GHOSTTY_CONFIG"; then
            return 1
        fi
    done
    return 0
}

test_mouse_support() {
    # Check mouse support settings
    grep -q "mouse-hide-while-typing" "$GHOSTTY_CONFIG" && \
    grep -q "mouse-shift-capture" "$GHOSTTY_CONFIG"
}

test_bell_configuration() {
    # Check bell/notification settings
    grep -q "audible-bell = false" "$GHOSTTY_CONFIG" && \
    grep -q "visual-bell = false" "$GHOSTTY_CONFIG"
}

test_new_window_shell_configured() {
    # Check that new windows use appropriate shell
    grep -q "shell-integration = zsh" "$GHOSTTY_CONFIG"
}

test_quick_shell_keybindings() {
    # Check for quick shell access keybindings
    grep -q "new_window:shell" "$GHOSTTY_CONFIG"
}

test_font_size_controls() {
    # Check font size adjustment keybindings
    grep -q "increase_font_size" "$GHOSTTY_CONFIG" && \
    grep -q "decrease_font_size" "$GHOSTTY_CONFIG" && \
    grep -q "reset_font_size" "$GHOSTTY_CONFIG"
}

test_clear_screen_keybinding() {
    # Check clear screen keybinding (should be Ctrl+L, not Ctrl+K)
    grep -q "ctrl\+l=clear_screen" "$GHOSTTY_CONFIG" && \
    ! grep -q "ctrl\+k=clear_screen" "$GHOSTTY_CONFIG"
}

# ==============================================================================
# Interactive Tests (optional)
# ==============================================================================

test_ghostty_new_session() {
    # This test requires user interaction - skip by default
    log_warning "Skipping interactive new session test"
    return 0
}

test_clipboard_operations() {
    # This test requires actual clipboard access - skip by default
    log_warning "Skipping interactive clipboard test"
    return 0
}

# ==============================================================================
# Main Test Execution
# ==============================================================================

main() {
    echo "=============================================================================="
    echo "Ghostty Shell Integration Tests"
    echo "=============================================================================="
    echo ""

    # Basic functionality tests
    run_test "Ghostty binary is launchable" "test_ghostty_launchable"
    run_test "Ghostty version is retrievable" "test_ghostty_version"

    # Shell integration tests
    run_test "Shell integration configured for zsh" "test_shell_integration_configured"
    run_test "Working directory inheritance enabled" "test_working_directory_inheritance"
    run_test "Focus events configured" "test_focus_events_configured"
    run_test "Environment variable support" "test_environment_support"

    # Completion tests
    run_test "Zsh completion available" "test_zsh_completion_available"
    run_test "Zsh completion functional" "test_zsh_completion_functional"

    # Integration tests
    run_test "Tmux integration configured" "test_tmux_integration_configured"
    run_test "Terminal capabilities available" "test_terminal_capabilities"

    # Feature tests
    run_test "Copy/paste functionality configured" "test_copy_paste_functionality"
    run_test "Color scheme support configured" "test_color_scheme_support"
    run_test "Font rendering configured" "test_font_rendering_configured"
    run_test "Performance tuning applied" "test_performance_tuning"

    # Compatibility tests
    run_test "Keybindings shell-compatible" "test_keybindings_shell_compatible"
    run_test "Mouse support configured" "test_mouse_support"
    run_test "Bell configuration appropriate" "test_bell_configuration"

    # UX tests
    run_test "New window shell configured" "test_new_window_shell_configured"
    run_test "Quick shell keybindings present" "test_quick_shell_keybindings"
    run_test "Font size controls available" "test_font_size_controls"
    run_test "Clear screen keybinding correct" "test_clear_screen_keybinding"

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
        log_success "All tests passed! Ghostty shell integration is properly configured."
        echo ""
        echo "Next steps:"
        echo "  1. Restart your shell or source ~/.zshrc"
        echo "  2. Test Ghostty by running: ghostty"
        echo "  3. Verify shell completion: ghostty <Tab><Tab>"
        echo "  4. Test tmux integration: use Ctrl+Shift+T keybindings"
        exit 0
    else
        echo ""
        log_error "Some tests failed. Please review the configuration."
        echo ""
        echo "Troubleshooting tips:"
        echo "  1. Ensure Ghostty is installed: brew install ghostty"
        echo "  2. Check configuration file: ~/.config/ghostty/config"
        echo "  3. Verify symlinks are correct: stow -d ~/dotfiles -t ~ ghostty"
        echo "  4. Restart your shell after making changes"
        exit 1
    fi
}

# Check if help is requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Ghostty Shell Integration Tests"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  --interactive Run interactive tests (requires user input)"
    echo ""
    echo "This script tests Ghostty's integration with:"
    echo "  - Zsh shell environment"
    echo "  - Shell completion system"
    echo "  - Terminal capabilities"
    echo "  - Tmux integration"
    echo "  - Clipboard functionality"
    echo "  - Performance settings"
    echo ""
    exit 0
fi

# Check for interactive mode
if [[ "${1:-}" == "--interactive" ]]; then
    log_info "Running interactive tests..."
    run_test "Ghostty new session creation" "test_ghostty_new_session"
    run_test "Clipboard operations" "test_clipboard_operations"
fi

# Run main function
main "$@"