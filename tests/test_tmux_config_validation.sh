#!/usr/bin/env bash

# ==============================================================================
# Tmux Configuration Validation Tests
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

TMUX_CONF="$HOME/.tmux.conf"
DOTFILES_CONF="$(dirname "$0")/../tmux/.tmux.conf"

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

test_tmux_binary_exists() {
    command -v tmux >/dev/null 2>&1
}

test_tmux_conf_exists() {
    [[ -f "$TMUX_CONF" ]]
}

test_tmux_conf_is_symlink() {
    [[ -L "$TMUX_CONF" ]]
}

# Starts a temporary isolated tmux server to catch hard parse errors.
# Warnings from the config (unknown options, etc.) are captured separately.
test_tmux_config_parses() {
    local socket="tmux_validate_$$"
    local errfile="/tmp/tmux_validate_err_$$"
    tmux -L "$socket" start-server 2>"$errfile"
    local ret=$?
    tmux -L "$socket" kill-server 2>/dev/null
    rm -f "$errfile"
    return $ret
}

# Same isolated server pass; checks that no warnings appear on stderr.
test_tmux_config_no_warnings() {
    local socket="tmux_nowarn_$$"
    local errfile="/tmp/tmux_nowarn_err_$$"
    tmux -L "$socket" start-server 2>"$errfile"
    local ret=$?
    tmux -L "$socket" kill-server 2>/dev/null
    local warnings
    warnings=$(cat "$errfile")
    rm -f "$errfile"
    [[ $ret -eq 0 ]] && [[ -z "$warnings" ]]
}

test_tpm_installed() {
    [[ -d "$HOME/.tmux/plugins/tpm" ]]
}

test_required_plugins_installed() {
    [[ -d "$HOME/.tmux/plugins/tmux-sensible" ]]        && \
    [[ -d "$HOME/.tmux/plugins/tmux-resurrect" ]]       && \
    [[ -d "$HOME/.tmux/plugins/tmux-continuum" ]]       && \
    [[ -d "$HOME/.tmux/plugins/tmux-cpu" ]]             && \
    [[ -d "$HOME/.tmux/plugins/tmux-prefix-highlight" ]] && \
    [[ -d "$HOME/.tmux/plugins/tmux-thumbs" ]]          && \
    [[ -d "$HOME/.tmux/plugins/tmux-open" ]]
}

test_prefix_key_configured() {
    grep -q "^set -g prefix C-a" "$TMUX_CONF"
}

test_mouse_enabled() {
    grep -q "^set -g mouse on" "$TMUX_CONF"
}

test_vi_mode_configured() {
    grep -q "^setw -g mode-keys vi" "$TMUX_CONF"
}

test_base_index_one() {
    grep -q "^set -g base-index 1" "$TMUX_CONF" && \
    grep -q "^setw -g pane-base-index 1" "$TMUX_CONF"
}

test_history_limit_set() {
    grep -q "^set -g history-limit" "$TMUX_CONF"
}

test_escape_time_zero() {
    grep -q "^set -s escape-time 0" "$TMUX_CONF"
}

test_detach_on_destroy_configured() {
    grep -q "^set -g detach-on-destroy off" "$TMUX_CONF"
}

test_ghostty_passthrough() {
    grep -q "^set -g allow-passthrough" "$TMUX_CONF"
}

test_clipboard_integration() {
    grep -q "^set -g set-clipboard on" "$TMUX_CONF"
}

test_gruvbox_theme_configured() {
    grep -q "bg=#282828" "$TMUX_CONF" && \
    grep -q "bg=#f9f5d7" "$TMUX_CONF"
}

test_prefix_highlight_configured() {
    grep -q "@prefix_highlight_fg" "$TMUX_CONF" && \
    grep -q "@prefix_highlight_show_copy_mode" "$TMUX_CONF"
}

test_cpu_in_status_right() {
    grep -q "cpu_percentage" "$TMUX_CONF"
}

test_dotfiles_dir_env_set() {
    grep -q "setenv -g DOTFILES_DIR" "$TMUX_CONF"
}

test_resurrect_nvim_strategy() {
    grep -q "@resurrect-strategy-nvim" "$TMUX_CONF"
}

test_window_size_latest() {
    grep -q "^set -g window-size latest" "$TMUX_CONF"
}

test_renumber_windows() {
    grep -q "^set -g renumber-windows on" "$TMUX_CONF"
}

test_config_file_permissions() {
    [[ -r "$TMUX_CONF" ]]
}

test_dotfiles_source_exists() {
    [[ -f "$DOTFILES_CONF" ]]
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    echo "=============================================================================="
    echo "Tmux Configuration Validation Tests"
    echo "=============================================================================="
    echo ""

    run_test "tmux binary exists"                   "test_tmux_binary_exists"
    run_test "tmux.conf exists"                     "test_tmux_conf_exists"
    run_test "tmux.conf is symlinked"               "test_tmux_conf_is_symlink"
    run_test "Config parses without hard errors"    "test_tmux_config_parses"
    run_test "Config loads without warnings"        "test_tmux_config_no_warnings"
    run_test "TPM installed"                        "test_tpm_installed"
    run_test "Required plugins installed"           "test_required_plugins_installed"
    run_test "Prefix key set to C-a"               "test_prefix_key_configured"
    run_test "Mouse support enabled"                "test_mouse_enabled"
    run_test "Vi mode configured"                   "test_vi_mode_configured"
    run_test "Base index starts at 1"              "test_base_index_one"
    run_test "History limit configured"             "test_history_limit_set"
    run_test "Escape time set to 0"                "test_escape_time_zero"
    run_test "Detach-on-destroy configured"         "test_detach_on_destroy_configured"
    run_test "Ghostty passthrough enabled"          "test_ghostty_passthrough"
    run_test "Clipboard integration configured"     "test_clipboard_integration"
    run_test "Gruvbox dark/light theme present"     "test_gruvbox_theme_configured"
    run_test "Prefix highlight configured"          "test_prefix_highlight_configured"
    run_test "CPU percentage in status right"       "test_cpu_in_status_right"
    run_test "DOTFILES_DIR env exported"            "test_dotfiles_dir_env_set"
    run_test "Resurrect nvim strategy set"          "test_resurrect_nvim_strategy"
    run_test "Window size set to latest"            "test_window_size_latest"
    run_test "Renumber windows enabled"             "test_renumber_windows"
    run_test "Config file permissions correct"      "test_config_file_permissions"
    run_test "Dotfiles source config exists"        "test_dotfiles_source_exists"

    echo ""
    echo "=============================================================================="
    echo "Test Summary"
    echo "=============================================================================="
    echo -e "Total: ${BLUE}$TESTS_TOTAL${NC}  Passed: ${GREEN}$TESTS_PASSED${NC}  Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        log_success "All tests passed! Tmux configuration is properly set up."
        exit 0
    else
        echo ""
        log_error "$TESTS_FAILED test(s) failed. Please review the configuration."
        exit 1
    fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [-h|--help]"
    echo "Validates the tmux configuration against the current dotfiles."
    exit 0
fi

main "$@"
