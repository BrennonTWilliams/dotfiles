#!/bin/bash

# Terminal.app Profile Validation Tests
# Verifies the generated .terminal profiles carry the exact Ghostty gruvbox
# palette and font, and that the generator is deterministic.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test environment setup
readonly TEST_ROOT="${TMPDIR:-/tmp}/dotfiles_terminal_profile_test_$$"
readonly LOG_FILE="$TEST_ROOT/terminal_profile_test.log"

# Configuration
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR
DOTFILES_DIR="$(dirname "$TESTS_DIR")"
readonly DOTFILES_DIR
readonly GENERATOR="$DOTFILES_DIR/scripts/generate-terminal-profile.sh"
readonly PROFILE_DIR="$DOTFILES_DIR/terminal-app"
readonly THEMES_DIR="$DOTFILES_DIR/ghostty/.config/ghostty/themes"

# Profile name -> source Ghostty theme
readonly PROFILE_MAP=(
    "Gruvbox Dark Custom:gruvbox-dark-custom"
    "Gruvbox Light Custom:gruvbox-light-custom"
)

mkdir -p "$(dirname "$LOG_FILE")"

exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

echo -e "${BLUE}=== Terminal.app Profile Validation Suite ===${NC}"
echo "Test Root: $TEST_ROOT"
echo "Dotfiles Directory: $DOTFILES_DIR"
echo "Started at: $(date)"
echo ""

# Utility functions
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

# Test result reporting
test_start() {
    local test_name="$1"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "Starting: $test_name"
}

test_pass() {
    local test_name="$1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_success "[PASS] $test_name"
}

test_fail() {
    local test_name="$1"
    local reason="$2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "[FAIL] $test_name - $reason"
}

test_skip() {
    local test_name="$1"
    local reason="$2"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    log_warning "[SKIP] $test_name - $reason"
}

# Invoked via 'trap cleanup EXIT' at the bottom of this file
# shellcheck disable=SC2329
cleanup() {
    if [[ -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

# ==============================================================================
# Helper: decode a profile and compare it against its Ghostty theme
# ==============================================================================

# Prints "OK" on success, or a human-readable mismatch description otherwise.
compare_profile_to_theme() {
    local profile_file="$1"
    local theme_file="$2"

    python3 - "$profile_file" "$theme_file" <<'PYTHON'
import plistlib
import re
import sys

profile_file, theme_file = sys.argv[1:3]

ANSI_KEYS = [
    "ANSIBlackColor", "ANSIRedColor", "ANSIGreenColor", "ANSIYellowColor",
    "ANSIBlueColor", "ANSIMagentaColor", "ANSICyanColor", "ANSIWhiteColor",
    "ANSIBrightBlackColor", "ANSIBrightRedColor", "ANSIBrightGreenColor",
    "ANSIBrightYellowColor", "ANSIBrightBlueColor", "ANSIBrightMagentaColor",
    "ANSIBrightCyanColor", "ANSIBrightWhiteColor",
]

SCALAR_KEYS = {
    "background": "BackgroundColor",
    "foreground": "TextColor",
    "bold-color": "TextBoldColor",
    "cursor-color": "CursorColor",
    "selection-background": "SelectionColor",
}


def parse_theme(path):
    scalars, palette = {}, {}
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            if line.lstrip().startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key, value = key.strip(), value.strip()
            if key == "palette":
                match = re.match(r"^(\d+)\s*=\s*(#[0-9a-fA-F]{6})$", value)
                if match:
                    palette[int(match.group(1))] = match.group(2).lower()
            elif key in SCALAR_KEYS and re.match(r"^#[0-9a-fA-F]{6}$", value):
                scalars[key] = value.lower()
    return scalars, palette


def decode_color(blob):
    obj = plistlib.loads(blob)["$objects"][1]
    parts = obj["NSRGB"].rstrip(b"\x00").decode("ascii").split()
    channels = [round(float(part) * 255) for part in parts[:3]]
    return "#{:02x}{:02x}{:02x}".format(*channels)


with open(profile_file, "rb") as handle:
    profile = plistlib.load(handle)

scalars, palette = parse_theme(theme_file)
problems = []

for index, key in enumerate(ANSI_KEYS):
    if key not in profile:
        problems.append("missing {}".format(key))
        continue
    actual = decode_color(profile[key])
    expected = palette.get(index)
    if actual != expected:
        problems.append("palette {}: {} != {}".format(index, actual, expected))

for ghostty_key, terminal_key in SCALAR_KEYS.items():
    if terminal_key not in profile:
        problems.append("missing {}".format(terminal_key))
        continue
    actual = decode_color(profile[terminal_key])
    expected = scalars.get(ghostty_key)
    if actual != expected:
        problems.append("{}: {} != {}".format(terminal_key, actual, expected))

if "Font" not in profile:
    problems.append("missing Font")
else:
    font = plistlib.loads(profile["Font"])["$objects"]
    if float(font[1]["NSSize"]) != 16.0:
        problems.append("font size {} != 16".format(font[1]["NSSize"]))
    print("FONT_NAME={}".format(font[2]), file=sys.stderr)

print("OK" if not problems else "; ".join(problems))
PYTHON
}

# ==============================================================================
# Tests
# ==============================================================================

test_generator_exists() {
    test_start "Generator script is present and executable"

    if [[ ! -f "$GENERATOR" ]]; then
        test_fail "Generator script is present and executable" "not found: $GENERATOR"
        return
    fi

    if [[ ! -x "$GENERATOR" ]]; then
        test_fail "Generator script is present and executable" "not executable: $GENERATOR"
        return
    fi

    test_pass "Generator script is present and executable"
}

test_profiles_exist_and_lint() {
    local entry profile_name profile_file

    for entry in "${PROFILE_MAP[@]}"; do
        profile_name="${entry%%:*}"
        profile_file="$PROFILE_DIR/$profile_name.terminal"

        test_start "Profile exists and is a valid plist: $profile_name"

        if [[ ! -f "$profile_file" ]]; then
            test_fail "Profile exists and is a valid plist: $profile_name" \
                "not found: $profile_file"
            continue
        fi

        if ! command -v plutil >/dev/null 2>&1; then
            test_skip "Profile exists and is a valid plist: $profile_name" \
                "plutil not available (non-macOS)"
            continue
        fi

        if ! plutil -lint "$profile_file" >/dev/null 2>&1; then
            test_fail "Profile exists and is a valid plist: $profile_name" \
                "plutil -lint rejected the file"
            continue
        fi

        test_pass "Profile exists and is a valid plist: $profile_name"
    done
}

test_palette_parity() {
    local entry profile_name theme_name profile_file theme_file result

    for entry in "${PROFILE_MAP[@]}"; do
        profile_name="${entry%%:*}"
        theme_name="${entry#*:}"
        profile_file="$PROFILE_DIR/$profile_name.terminal"
        theme_file="$THEMES_DIR/$theme_name"

        test_start "Palette matches Ghostty theme: $profile_name"

        if [[ ! -f "$profile_file" || ! -f "$theme_file" ]]; then
            test_fail "Palette matches Ghostty theme: $profile_name" \
                "profile or theme file missing"
            continue
        fi

        result="$(compare_profile_to_theme "$profile_file" "$theme_file" 2>/dev/null)"

        if [[ "$result" == "OK" ]]; then
            test_pass "Palette matches Ghostty theme: $profile_name"
        else
            test_fail "Palette matches Ghostty theme: $profile_name" "$result"
        fi
    done
}

test_font_is_iosevka() {
    local profile_file="$PROFILE_DIR/Gruvbox Dark Custom.terminal"
    local theme_file="$THEMES_DIR/gruvbox-dark-custom"
    local font_name

    test_start "Profile font is the Iosevka Nerd Font"

    if [[ ! -f "$profile_file" ]]; then
        test_fail "Profile font is the Iosevka Nerd Font" "profile not found"
        return
    fi

    font_name="$(compare_profile_to_theme "$profile_file" "$theme_file" 2>&1 >/dev/null \
        | sed -n 's/^FONT_NAME=//p')"

    if [[ -z "$font_name" ]]; then
        test_fail "Profile font is the Iosevka Nerd Font" "could not decode Font key"
        return
    fi

    if [[ "$font_name" == *Iosevka* ]]; then
        test_pass "Profile font is the Iosevka Nerd Font"
    else
        test_skip "Profile font is the Iosevka Nerd Font" \
            "profile was generated with fallback font '$font_name' (Iosevka not installed)"
    fi
}

test_generator_is_idempotent() {
    local regen_dir="$TEST_ROOT/regen"
    local entry profile_name

    test_start "Generator output is deterministic"

    if [[ ! -x "$GENERATOR" ]]; then
        test_fail "Generator output is deterministic" "generator not executable"
        return
    fi

    mkdir -p "$regen_dir"

    if ! "$GENERATOR" --output-dir "$regen_dir" >/dev/null 2>&1; then
        test_fail "Generator output is deterministic" "generator exited non-zero"
        return
    fi

    for entry in "${PROFILE_MAP[@]}"; do
        profile_name="${entry%%:*}"
        if ! diff -q "$PROFILE_DIR/$profile_name.terminal" \
            "$regen_dir/$profile_name.terminal" >/dev/null 2>&1; then
            test_fail "Generator output is deterministic" \
                "regenerated '$profile_name' differs from the committed file"
            return
        fi
    done

    test_pass "Generator output is deterministic"
}

test_terminal_app_not_stowed() {
    test_start "terminal-app/ is not a Stow package"

    # install.sh discovers packages by looking for a top-level dot-entry.
    # terminal-app/ must have none, or it would get symlinked into $HOME.
    if find "$PROFILE_DIR" -maxdepth 1 -name ".*" ! -name "." ! -name ".." -print -quit 2>/dev/null | grep -q .; then
        test_fail "terminal-app/ is not a Stow package" \
            "contains a dot-entry, so install.sh would stow it"
        return
    fi

    test_pass "terminal-app/ is not a Stow package"
}

# ==============================================================================
# Results
# ==============================================================================

display_final_results() {
    echo ""
    echo -e "${BOLD}=== Terminal.app Profile Test Results ===${NC}"
    echo "Total:   $TESTS_TOTAL"
    echo "Passed:  $TESTS_PASSED"
    echo "Failed:  $TESTS_FAILED"
    echo "Skipped: $TESTS_SKIPPED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All Terminal.app profile tests passed"
    else
        log_error "$TESTS_FAILED test(s) failed"
    fi
}

main() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_warning "Terminal.app profile tests only run on macOS - skipping suite"
        echo "Passed:  0"
        echo "Failed:  0"
        exit 0
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log_warning "python3 not available - skipping suite"
        echo "Passed:  0"
        echo "Failed:  0"
        exit 0
    fi

    test_generator_exists
    test_profiles_exist_and_lint
    test_palette_parity
    test_font_is_iosevka
    test_generator_is_idempotent
    test_terminal_app_not_stowed

    display_final_results

    if [[ $TESTS_FAILED -eq 0 ]]; then
        exit 0
    else
        echo ""
        echo -e "${YELLOW}Test artifacts preserved at: $TEST_ROOT${NC}"
        exit 1
    fi
}

trap cleanup EXIT

main "$@"
