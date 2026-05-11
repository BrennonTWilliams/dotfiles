#!/usr/bin/env bash

# ==============================================================================
# Ghostty Configuration Validation Tests
# ==============================================================================

# set -e intentionally omitted: arithmetic counters return non-zero when zero
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

GHOSTTY_CONFIG_FILE="$HOME/.config/ghostty/config"
DOTFILES_TEMPLATE="$(dirname "$0")/../ghostty/.config/ghostty/config.local.template"

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[FAIL]${NC} $1"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

run_test() {
    local test_name="$1"
    local test_command="$2"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
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
# Tests
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

# Uses Ghostty's built-in validator; returns 0 on a clean config
test_ghostty_validate_config() {
    ghostty +validate-config 2>/dev/null
}

test_shell_integration_correct() {
    grep -q "^shell-integration = zsh" "$GHOSTTY_CONFIG_FILE"
}

test_macos_specific_settings() {
    grep -q "^macos-titlebar-style" "$GHOSTTY_CONFIG_FILE" && \
    grep -q "^macos-option-as-alt"  "$GHOSTTY_CONFIG_FILE"
}

test_font_configuration() {
    grep -q "^font-family" "$GHOSTTY_CONFIG_FILE" && \
    grep -q "^font-size"   "$GHOSTTY_CONFIG_FILE"
}

# Config uses the adaptive light/dark form introduced in Ghostty 1.x
test_gruvbox_theme() {
    grep -q "^theme = light:gruvbox-light-custom,dark:gruvbox-dark-custom" "$GHOSTTY_CONFIG_FILE"
}

# Local overrides are included via config-file, not the old import directive
test_local_config_import_enabled() {
    grep -q "^config-file = " "$GHOSTTY_CONFIG_FILE"
}

test_clipboard_integration() {
    grep -q "^clipboard-read = allow"  "$GHOSTTY_CONFIG_FILE" && \
    grep -q "^clipboard-write = allow" "$GHOSTTY_CONFIG_FILE"
}

# New sessions start in tmux; -A attaches if the session already exists
test_tmux_integration() {
    grep -q "command = .*tmux" "$GHOSTTY_CONFIG_FILE"
}

test_keybinding_no_conflicts() {
    ! grep -q "^keybind = ctrl+c=" "$GHOSTTY_CONFIG_FILE" && \
    ! grep -q "^keybind = ctrl+v=" "$GHOSTTY_CONFIG_FILE" && \
    ! grep -q "^keybind = ctrl+k=" "$GHOSTTY_CONFIG_FILE"
}

test_no_duplicate_settings() {
    # keybind and env are intentionally multi-value; exclude them
    local duplicates
    duplicates=$(grep -E "^[a-z][a-z-]+ =" "$GHOSTTY_CONFIG_FILE" \
        | grep -v "^keybind \|^env " \
        | sed 's/ =.*//' \
        | sort | uniq -d)
    [[ -z "$duplicates" ]]
}

test_window_configuration() {
    grep -q "^window-padding-x"  "$GHOSTTY_CONFIG_FILE" && \
    grep -q "^window-padding-y"  "$GHOSTTY_CONFIG_FILE" && \
    grep -q "^window-decoration" "$GHOSTTY_CONFIG_FILE"
}

test_local_config_template_exists() {
    [[ -f "$DOTFILES_TEMPLATE" ]]
}

test_config_file_permissions() {
    [[ -r "$GHOSTTY_CONFIG_FILE" ]]
}

test_completion_installed() {
    [[ -f "$HOME/.local/share/zsh/site-functions/_ghostty" ]] || \
    [[ -f "/opt/homebrew/share/zsh/site-functions/_ghostty" ]] || \
    [[ -f "/usr/local/share/zsh/site-functions/_ghostty" ]]
}

test_completion_valid() {
    local completion_file=""
    for path in "$HOME/.local/share/zsh/site-functions/_ghostty" \
                "/opt/homebrew/share/zsh/site-functions/_ghostty" \
                "/usr/local/share/zsh/site-functions/_ghostty"; do
        [[ -f "$path" ]] && completion_file="$path" && break
    done
    [[ -n "$completion_file" ]] && \
    [[ -s "$completion_file" ]] && \
    grep -q "#compdef" "$completion_file"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    echo "=============================================================================="
    echo "Ghostty Configuration Validation Tests"
    echo "=============================================================================="
    echo ""

    run_test "Ghostty binary exists"              "test_ghostty_binary_exists"
    run_test "Ghostty config exists"              "test_ghostty_config_exists"
    run_test "Ghostty config is symlinked"        "test_ghostty_config_is_symlink"
    run_test "Ghostty config validates cleanly"   "test_ghostty_validate_config"
    run_test "Shell integration set to zsh"       "test_shell_integration_correct"
    run_test "macOS-specific settings present"    "test_macos_specific_settings"
    run_test "Font configuration present"         "test_font_configuration"
    run_test "Gruvbox adaptive theme configured"  "test_gruvbox_theme"
    run_test "Local config file import enabled"   "test_local_config_import_enabled"
    run_test "Clipboard integration configured"   "test_clipboard_integration"
    run_test "Tmux launch command present"        "test_tmux_integration"
    run_test "No conflicting keybindings"         "test_keybinding_no_conflicts"
    run_test "No duplicate settings"              "test_no_duplicate_settings"
    run_test "Window configuration present"       "test_window_configuration"
    run_test "Local config template exists"       "test_local_config_template_exists"
    run_test "Config file permissions correct"    "test_config_file_permissions"
    run_test "Shell completion installed"         "test_completion_installed"
    run_test "Shell completion valid"             "test_completion_valid"

    echo ""
    echo "=============================================================================="
    echo "Test Summary"
    echo "=============================================================================="
    echo -e "Total: ${BLUE}$TESTS_TOTAL${NC}  Passed: ${GREEN}$TESTS_PASSED${NC}  Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        log_success "All tests passed! Ghostty configuration is properly set up."
        exit 0
    else
        echo ""
        log_error "$TESTS_FAILED test(s) failed. Please review the configuration."
        exit 1
    fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [-h|--help]"
    echo "Validates the Ghostty terminal configuration against the current dotfiles."
    exit 0
fi

main "$@"
