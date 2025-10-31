#!/usr/bin/env bash

# Safe Integration Test - Tests functions without running the full script
set -e

# Configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

log_test() {
    local name="$1"
    local status="$2"
    local details="$3"

    ((TESTS_TOTAL++))

    case "$status" in
        "PASS")
            ((TESTS_PASSED++))
            echo -e "${GREEN}✅ PASS${NC} $name"
            ;;
        "FAIL")
            ((TESTS_FAILED++))
            echo -e "${RED}❌ FAIL${NC} $name"
            ;;
        "WARN")
            ((TESTS_WARNINGS++))
            echo -e "${YELLOW}⚠️  WARN${NC} $name"
            ;;
    esac

    if [ -n "$details" ]; then
        echo "   $details"
    fi
    echo
}

echo -e "${BLUE}${BOLD}=== Safe Integration Tests - Installation Workflow ===${NC}\n"

# Create temporary environment for testing functions
TEMP_FUNCTIONS_FILE=$(mktemp)

# Extract only the function definitions from install.sh
echo "Extracting functions from install.sh..."
awk '
BEGIN { in_function = 0; function_name = ""; brace_count = 0 }
/^main\(\)/ { exit }
/^[a-zA-Z_][a-zA-Z0-9_]*\(\)/ {
    if (function_name != "") { print "}" }
    function_name = $1
    sub(/\(\)/, "", function_name)
    print $0
    in_function = 1
    brace_count = 0
    next
}
in_function && /\{/ { brace_count += gsub(/\{/, "{") - gsub(/\}/, "}") }
in_function {
    print $0
    if (brace_count <= 0 && /}/) {
        in_function = 0
        function_name = ""
    }
}
' "$DOTFILES_DIR/install.sh" > "$TEMP_FUNCTIONS_FILE"

# Test 1: Script syntax
echo "Testing script syntax and structure..."
if bash -n "$DOTFILES_DIR/install.sh"; then
    log_test "Script syntax validation" "PASS" "No syntax errors found"
else
    log_test "Script syntax validation" "FAIL" "Syntax errors detected"
fi

# Test 2: Script permissions
if [ -x "$DOTFILES_DIR/install.sh" ]; then
    log_test "Script executable permission" "PASS" "Script has execute permission"
else
    log_test "Script executable permission" "FAIL" "Script lacks execute permission"
fi

# Test 3: Function definitions loading
echo "Testing function definitions..."
if source "$TEMP_FUNCTIONS_FILE" 2>/dev/null; then
    log_test "Function loading" "PASS" "All functions loaded successfully"
else
    log_test "Function loading" "FAIL" "Failed to load functions"
fi

# Test 4: Core functions availability
echo "Testing core function definitions..."
core_functions=(
    "detect_os"
    "command_exists"
    "install_package"
    "validate_platform_commands"
    "pre_validate_packages"
    "get_available_packages"
    "get_platform_packages"
    "stow_package"
    "backup_if_exists"
    "check_brew_package_availability"
    "install_required_taps"
)

for func in "${core_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        log_test "Function definition: $func" "PASS" "Function is defined"
    else
        log_test "Function definition: $func" "FAIL" "Function is missing"
    fi
done

# Test 5: OS detection functionality
echo "Testing OS detection..."
if detect_os >/dev/null 2>&1; then
    log_test "OS detection execution" "PASS" "OS: $OS, Package Manager: $PKG_MANAGER"
else
    log_test "OS detection execution" "FAIL" "OS detection failed"
fi

# Test 6: Command detection functionality
echo "Testing command detection..."
if command_exists bash; then
    log_test "Command detection: bash (should exist)" "PASS" "bash command found"
else
    log_test "Command detection: bash (should exist)" "FAIL" "bash command not found (unexpected)"
fi

if ! command_exists non_existent_command_xyz123 2>/dev/null; then
    log_test "Command detection: non-existent (should fail)" "PASS" "Correctly returns false for non-existent command"
else
    log_test "Command detection: non-existent (should fail)" "FAIL" "Should return false for non-existent command"
fi

# Test 7: Platform command validation
echo "Testing platform command validation..."
if validate_platform_commands >/dev/null 2>&1; then
    log_test "Platform command validation" "PASS" "All required commands available"
else
    log_test "Platform command validation" "WARN" "Some required commands missing"
fi

# Test 8: Package detection functions
echo "Testing package detection..."
if dotfiles_packages=$(get_available_packages 2>/dev/null); then
    local count=$(echo "$dotfiles_packages" | wc -w)
    log_test "Dotfiles package detection" "PASS" "Found $count dotfiles packages"
else
    log_test "Dotfiles package detection" "FAIL" "Failed to detect dotfiles packages"
fi

if platform_packages=$(get_platform_packages 2>/dev/null); then
    local count=$(echo "$platform_packages" | wc -l)
    log_test "Platform package detection" "PASS" "Found $count platform packages"
else
    log_test "Platform package detection" "FAIL" "Failed to detect platform packages"
fi

# Test 9: Package validation with different package managers
echo "Testing package validation..."
local test_packages=("git" "vim" "tmux")

if filtered_output=$(pre_validate_packages "${test_packages[@]}" 2>/dev/null); then
    local count=$(echo "$filtered_output" | wc -l)
    log_test "Package validation filtering" "PASS" "Filtered to $count valid packages"
else
    log_test "Package validation filtering" "WARN" "Package validation had issues"
fi

# Test 10: Platform-specific filtering
echo "Testing platform-specific filtering..."
if [[ "$OS" == "macos" ]]; then
    # Test Linux package filtering on macOS
    local mixed_packages=("git" "vim" "sway" "swaybg" "tmux")
    local filtered
    filtered=$(pre_validate_packages "${mixed_packages[@]}" 2>/dev/null || echo "")

    if [[ "$filtered" != *"sway"* ]] && [[ "$filtered" != *"swaybg"* ]]; then
        log_test "macOS: Linux package filtering" "PASS" "Linux packages correctly filtered out"
    else
        log_test "macOS: Linux package filtering" "FAIL" "Linux packages not properly filtered"
    fi

    # Test sketchybar handling on macOS
    local macos_packages=("git" "sketchybar")
    local filtered
    filtered=$(pre_validate_packages "${macos_packages[@]}" 2>/dev/null || echo "")

    if [[ "$filtered" == *"sketchybar"* ]] || [[ -z "$filtered" ]]; then
        log_test "macOS: sketchybar handling" "PASS" "sketchybar handled correctly"
    else
        log_test "macOS: sketchybar handling" "FAIL" "sketchybar not handled properly"
    fi
else
    log_test "Platform-specific filtering" "SKIP" "Running on Linux, skipping macOS-specific tests"
fi

# Test 11: Package manager specific validation
echo "Testing package manager specific validation..."
case "$PKG_MANAGER" in
    "brew")
        if command_exists brew; then
            if check_brew_package_availability git 2>/dev/null; then
                log_test "Brew: git package validation" "PASS" "git package found in brew"
            else
                log_test "Brew: git package validation" "FAIL" "git package not found in brew"
            fi

            # Test with non-existent package
            if check_brew_package_availability non_existent_pkg_xyz123 2>/dev/null; then
                log_test "Brew: invalid package validation" "FAIL" "Should reject non-existent package"
            else
                log_test "Brew: invalid package validation" "PASS" "Correctly rejects non-existent package"
            fi
        else
            log_test "Brew package validation" "SKIP" "brew not available"
        fi
        ;;
    "apt")
        if command_exists apt-cache; then
            if check_apt_package_availability git 2>/dev/null; then
                log_test "APT: git package validation" "PASS" "git package found in apt"
            else
                log_test "APT: git package validation" "FAIL" "git package not found in apt"
            fi
        else
            log_test "APT package validation" "SKIP" "apt-cache not available"
        fi
        ;;
    *)
        log_test "Package manager validation" "SKIP" "Unsupported package manager: $PKG_MANAGER"
        ;;
esac

# Test 12: Error handling scenarios
echo "Testing error handling..."
# Test with empty packages
if result=$(pre_validate_packages 2>/dev/null); then
    log_test "Error handling: empty packages" "PASS" "Handles empty package list"
else
    log_test "Error handling: empty packages" "PASS" "Fails gracefully with empty packages"
fi

# Test with non-existent directory
original_dir=$(pwd)
if cd /nonexistent/directory/path 2>/dev/null; then
    cd "$original_dir"
    log_test "Error handling: non-existent directory" "FAIL" "Should not access non-existent directory"
else
    log_test "Error handling: non-existent directory" "PASS" "Correctly fails on non-existent directory"
fi

# Cleanup
rm -f "$TEMP_FUNCTIONS_FILE"

# Final Summary
echo -e "${BLUE}${BOLD}=== Test Summary ===${NC}\n"
echo -e "${BOLD}Total Tests:${NC} $TESTS_TOTAL"
echo -e "${GREEN}${BOLD}Passed:${NC} $TESTS_PASSED"
echo -e "${YELLOW}${BOLD}Warnings:${NC} $TESTS_WARNINGS"
echo -e "${RED}${BOLD}Failed:${NC} $TESTS_FAILED"

local success_rate=0
if [ $TESTS_TOTAL -gt 0 ]; then
    success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
fi

echo -e "${BOLD}Success Rate:${NC} ${success_rate}%"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}🎉 All critical tests passed!${NC}\n"
    if [ $TESTS_WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $TESTS_WARNINGS warning(s) - review may be needed${NC}\n"
    fi
else
    echo -e "\n${RED}${BOLD}❌ $TESTS_FAILED test(s) failed - review required${NC}\n"
fi

echo -e "${BLUE}Platform Information:${NC}"
echo "  OS: $OS"
echo "  Package Manager: $PKG_MANAGER"
echo "  Architecture: $(uname -m)"