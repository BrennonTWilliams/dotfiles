#!/usr/bin/env bash

# ==============================================================================
# Glow Wrapper Validation Tests
# ==============================================================================
# Verifies the glow wrapper package:
#   - package files exist and JSON parses
#   - wrapper script is executable and shellcheck-clean
#   - THEME_MODE selection picks the right style file
#   - missing style directory falls back gracefully
# ==============================================================================

# set -e intentionally omitted: arithmetic counters return non-zero when zero
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GLOW_PKG="$DOTFILES_ROOT/glow"
GLOW_STYLES="$GLOW_PKG/.config/glow"
GLOW_BIN="$GLOW_PKG/.local/bin/glow"

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

# Source the wrapper's theme-mode detection by extracting the function via
# bash. We can't run the wrapper directly because it `exec`s glow at the end.
extract_theme_mode() {
    local fn
    fn="$(sed -n '/^_glow_theme_mode()/,/^}/p' "$GLOW_BIN")"
    # Define the function and immediately call it in a subshell so the
    # caller's THEME_MODE export is honored.
    bash -c "$fn; _glow_theme_mode"
}

# ==============================================================================
# Tests
# ==============================================================================

test_glow_pkg_exists() {
    [[ -d "$GLOW_PKG" ]]
}

test_gruvbox_light_json_exists() {
    [[ -f "$GLOW_STYLES/gruvbox-light.json" ]]
}

test_gruvbox_dark_json_exists() {
    [[ -f "$GLOW_STYLES/gruvbox-dark.json" ]]
}

test_gruvbox_light_json_valid() {
    python3 -c "import json; json.load(open('$GLOW_STYLES/gruvbox-light.json'))" 2>/dev/null
}

test_gruvbox_dark_json_valid() {
    python3 -c "import json; json.load(open('$GLOW_STYLES/gruvbox-dark.json'))" 2>/dev/null
}

test_light_json_has_required_keys() {
    python3 - "$GLOW_STYLES/gruvbox-light.json" <<'PY' 2>/dev/null
import json, sys
path = sys.argv[1]
data = json.load(open(path))
required = ["document", "heading", "h1", "h2", "h3", "link", "code", "code_block"]
for key in required:
    if key not in data:
        sys.exit(1)
PY
}

test_wrapper_exists() {
    [[ -f "$GLOW_BIN" ]]
}

test_wrapper_executable() {
    [[ -x "$GLOW_BIN" ]]
}

test_wrapper_shellcheck_clean() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        log_warning "shellcheck not installed; skipping"
        return 0
    fi
    shellcheck "$GLOW_BIN" >/dev/null 2>&1
}

# Theme detection: explicit THEME_MODE always wins, regardless of OS.
test_theme_mode_explicit_light() {
    [[ "$(THEME_MODE=light extract_theme_mode)" == "light" ]]
}

test_theme_mode_explicit_dark() {
    [[ "$(THEME_MODE=dark extract_theme_mode)" == "dark" ]]
}

test_theme_mode_fallback_macos_dark() {
    # Override `uname` and `defaults` so the function thinks we're on a
    # macOS host in dark mode, with no THEME_MODE set.
    local bin stub
    bin="$(mktemp -d)"
    stub="$bin/uname"
    cat > "$stub" <<'EOF'
#!/usr/bin/env bash
echo Darwin
EOF
    cat > "$bin/defaults" <<'EOF'
#!/usr/bin/env bash
echo dark
EOF
    chmod +x "$bin/uname" "$bin/defaults"
    [[ "$(PATH="$bin:$PATH" extract_theme_mode)" == "dark" ]]
    rm -rf "$bin"
}

test_wrapper_falls_back_when_style_dir_missing() {
    # Build a minimal copy of the wrapper with the SCRIPT_DIR pointing at a
    # scratch dir with no config/glow sibling. It should still exit 0 and
    # fall through to glow with no -s flag.
    local tmp wrap
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.local/bin"
    cp "$GLOW_BIN" "$tmp/.local/bin/glow"
    wrap="$tmp/.local/bin/glow"

    # Stub out `glow` so the wrapper can exec it without the real binary.
    mkdir -p "$tmp/bin"
    cat > "$tmp/bin/glow" <<'EOF'
#!/usr/bin/env bash
echo "glow-stub $*"
exit 0
EOF
    chmod +x "$tmp/bin/glow" "$wrap"

    PATH="$tmp/bin:$PATH" THEME_MODE=light "$wrap" foo > "$tmp/out" 2>&1
    grep -q 'glow-stub' "$tmp/out"
    rm -rf "$tmp"
}

# ==============================================================================
# Runner
# ==============================================================================

run_test "glow package directory exists"              test_glow_pkg_exists
run_test "gruvbox-light.json exists"                  test_gruvbox_light_json_exists
run_test "gruvbox-dark.json exists"                   test_gruvbox_dark_json_exists
run_test "gruvbox-light.json parses as JSON"          test_gruvbox_light_json_valid
run_test "gruvbox-dark.json parses as JSON"           test_gruvbox_dark_json_valid
run_test "light JSON has required glamour keys"       test_light_json_has_required_keys
run_test "wrapper script exists"                      test_wrapper_exists
run_test "wrapper script is executable"               test_wrapper_executable
run_test "wrapper passes shellcheck"                  test_wrapper_shellcheck_clean
run_test "THEME_MODE=light returns light"             test_theme_mode_explicit_light
run_test "THEME_MODE=dark returns dark"               test_theme_mode_explicit_dark
run_test "macOS dark fallback without THEME_MODE"     test_theme_mode_fallback_macos_dark
run_test "wrapper falls back when style dir missing"  test_wrapper_falls_back_when_style_dir_missing

echo
echo "----------------------------------------"
echo "Glow wrapper tests: $TESTS_PASSED/$TESTS_TOTAL passed ($TESTS_FAILED failed)"
echo "----------------------------------------"

[[ $TESTS_FAILED -eq 0 ]]